import assert from 'node:assert/strict';
import fs from 'node:fs';
import {emptyLocalCompounds,addLocalCompound,validateLocalCompounds,saveLocalCompounds,loadLocalCompounds,importLocalCompounds} from '../pages/local_compounds.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),before=JSON.stringify(authority);
const definition={label:'test local meaning',definition:'Author-defined test meaning; not an approved lexical claim.',part_of_speech:'verb',components:[{target_id:authority.atoms[0].canonical_id,relation:'head'},{target_id:authority.atoms[1].canonical_id,relation:'qualifies'}],roles:[{role:'actor',definition:'The participant performing this action.'}]};
const first=await addLocalCompound(emptyLocalCompounds(),definition,authority);
const nested=await addLocalCompound(first,{...definition,label:'nested test meaning',components:[{target_id:first.entries[0].compound_id,relation:'head'},definition.components[1]]},authority);
assert.equal(nested.entries[1].definition.components[0].target_id,first.entries[0].compound_id);assert.deepEqual(nested.entries[0],first.entries[0]);
const swapped=await addLocalCompound(emptyLocalCompounds(),{...definition,components:[...definition.components].reverse()},authority);assert.notEqual(swapped.entries[0].compound_id,first.entries[0].compound_id);
let stored=null;const storage={getItem:()=>stored,setItem:(_,v)=>stored=v};await saveLocalCompounds(storage,nested,authority);assert.deepEqual(await loadLocalCompounds(storage,authority),nested);assert.deepEqual(await importLocalCompounds(JSON.stringify(nested),authority),nested);
for(const mutate of [r=>r.entries.reverse(),r=>r.entries[0].definition.components[0].target_id=r.entries[0].compound_id,r=>r.entries[0].definition.definition='changed',r=>r.entries[0].definition.components[1].relation='head',r=>r.entries[0].definition.roles.push(r.entries[0].definition.roles[0])]){
 const broken=structuredClone(nested);mutate(broken);await assert.rejects(validateLocalCompounds(broken,authority));await assert.rejects(saveLocalCompounds(storage,broken,authority));assert.deepEqual(JSON.parse(stored),nested);
}
await assert.rejects(addLocalCompound(first,definition,authority));assert.equal(JSON.stringify(authority),before);
console.log('PASS ordered local compounds, nested reuse, persistence/import, immutable canonical data, invalid identity/dependency/cycle rejection and preservation of saved data. Compilation and UI pending.');
