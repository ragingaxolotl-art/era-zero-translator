import assert from 'node:assert/strict';
import fs from 'node:fs';
import {emptyLocalCompounds,addLocalCompound} from '../pages/local_compounds.mjs';
import {expandLocalCompound} from '../pages/local_compound_expansion.mjs';
import {contextualContentReference} from '../pages/contextual_content.mjs';
import {localCompoundMusic} from '../pages/local_compound_music.mjs';
const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));let count=0;
for(const canonical of a.compounds){
 const registry=await addLocalCompound(emptyLocalCompounds(),{label:'test '+count,definition:'Test-only canonical reuse.',part_of_speech:'verb',roles:[],components:[{target_id:canonical.compound_id,relation:'head'},{target_id:a.atoms[0].canonical_id,relation:'qualifies'}]},a),id=registry.entries[0].compound_id,expanded=await expandLocalCompound(id,registry,a),plan=a.compound_plans[canonical.compound_id];
 const parent=new Map(expanded.role_requirements.map(r=>[JSON.stringify(r.slot_path),JSON.stringify(r.slot_path)]));
 const find=x=>parent.get(x)===x?x:find(parent.get(x));
 for(const c of plan.expanded.binding_constraints||[])if(c.relation==='same_argument'){const keys=c.slot_paths.map(p=>JSON.stringify(p));for(const k of keys.slice(1))parent.set(find(k),find(keys[0]));}
 const groups=[...new Set([...parent.keys()].map(find))],bindings=[];
 for(const r of expanded.role_requirements)bindings.push({path:r.path,slot_path:r.slot_path,role:r.role,reference:await contextualContentReference(`"Participant ${String.fromCharCode(97+groups.indexOf(find(JSON.stringify(r.slot_path))))}"`)});
 try{const result=await localCompoundMusic(id,registry,a,bindings);assert(result.midi.length>0);}catch(e){throw new Error(`${canonical.display_title}: ${e.message}`);}
 count++;
}
console.log(`PASS all ${count} approved compounds reused as local heads with canonical same/distinct participant constraints.`);
