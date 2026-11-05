import assert from 'node:assert/strict';
import fs from 'node:fs';
import {emptyLocalCompounds,addLocalCompound} from '../pages/local_compounds.mjs';
import {localAdjectivePlan,composeLocalAdjective} from '../pages/local_compound_english.mjs';
const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const d={label:'glowsteady',definition:'Test-only author-defined quality.',part_of_speech:'adjective',roles:[{role:'bearer',definition:'The entity with this quality.'}],components:a.atoms.slice(0,2).map((v,i)=>({target_id:v.canonical_id,relation:i?'qualifies':'head'}))};
const registry=await addLocalCompound(emptyLocalCompounds(),d,a);let count=0;
for(const state of [0,1,2])for(const negative of [false,true])for(const past of [false,true])for(const question of [false,true]){
 const verb=past?'was':'is',input=(question?`${verb[0].toUpperCase()+verb.slice(1)} Nora `:`Nora ${verb} `)+(negative?'not ':'')+`glowsteady${question?'?':'.'} [${state}]`;
 const r=await composeLocalAdjective(input,registry,a);assert.equal(r.meaning.runtime_state,state);assert.equal(r.meaning.speech_act,question?'question':'assertion');assert.deepEqual(r.meaning.scopes,[...(past?[{operator:'time',relation:'before_speech'}]:[]),...(negative?[{operator:'negation'}]:[])]);assert.equal(r.meaning.bindings[0].reference.name.normalized_label,'nora');assert.equal(r.source_input,input);count++;
}
const contraction=await composeLocalAdjective("Wasn't Nora glowsteady?",registry,a);assert.equal(contraction.meaning.scopes.length,2);
for(const input of ['Nora are glowsteady.','I is glowsteady.','Nora is unknown.','Nora is glowsteady and happy.'])assert.equal(await localAdjectivePlan(input,registry,a),null);
await assert.rejects(composeLocalAdjective('Nora is glowsteady.',registry,a,{bindings:[{path:[],role:'bearer'}]}),/already supplies/);
console.log(`PASS ${count} saved adjective English sentences preserve subject, past, negation, questions and runtime; agreement/unsupported remainder rejects.`);
