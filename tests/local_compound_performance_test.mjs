import assert from 'node:assert/strict';
import fs from 'node:fs';
import {emptyLocalCompounds,addLocalCompound} from '../pages/local_compounds.mjs';
import {prepareLocalCompoundPerformance} from '../pages/local_compound_performance.mjs';
import {contextualContentReference} from '../pages/contextual_content.mjs';
const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const d={label:'test local action',definition:'Test-only structure.',part_of_speech:'verb',roles:[{role:'actor',definition:'Person acting.'}],components:a.atoms.slice(0,2).map((v,i)=>({target_id:v.canonical_id,relation:i?'qualifies':'head'}))};
let registry=await addLocalCompound(emptyLocalCompounds(),d,a);const first=registry.entries[0].compound_id;
registry=await addLocalCompound(registry,{...d,label:'nested test action',roles:[],components:[{target_id:first,relation:'qualifies'},{target_id:first,relation:'head'}]},a);
const id=registry.entries[1].compound_id,bindings=await Promise.all(['Nora','Eli'].map(async(name,i)=>({path:[i],role:'actor',reference:await contextualContentReference(name)})));
for(const state of [0,1,2]){
 const p=await prepareLocalCompoundPerformance(id,registry,a,bindings,{runtimeState:state});
 assert.equal(p.tree.components[0].participants[0].events[0].register,'low');
 assert.equal(p.tree.components[1].participants[0].events[0].label,'eli');
 const leaves=p.tree.components.flatMap(c=>c.components.flatMap(v=>v.events));
 assert.equal(leaves.filter(e=>e.runtime_tail).length,1);assert.equal(leaves.find(e=>e.runtime_tail).runtime_tail.code,state);
 assert.deepEqual(leaves.map(e=>e.target_id),[a.atoms[0].canonical_id,a.atoms[1].canonical_id,a.atoms[0].canonical_id,a.atoms[1].canonical_id]);
}
console.log('PASS nested performance tree reuses root sounds, preserves actor name/register and applies runtime 0/1/2 only to the external semantic head. Audible local framing pending.');
