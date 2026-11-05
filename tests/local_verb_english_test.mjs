import assert from 'node:assert/strict';
import fs from 'node:fs';
import {emptyLocalCompounds,addLocalCompound} from '../pages/local_compounds.mjs';
import {localVerbPlan,composeLocalVerb} from '../pages/local_compound_english.mjs';
const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),d={label:'glowmend',definition:'Test-only user-defined action.',part_of_speech:'verb',roles:[{role:'actor',definition:'Doer.'},{role:'target',definition:'Affected entity.'}],components:a.atoms.slice(0,2).map((v,i)=>({target_id:v.canonical_id,relation:i?'qualifies':'head'}))};
const registry=await addLocalCompound(emptyLocalCompounds(),d,a),options={subjectRole:'actor',objectRole:'target'};let count=0;
for(const state of [0,1,2])for(const negative of [false,true])for(const past of [false,true])for(const question of [false,true]){
 const aux=past?'did':'does',input=(question?`${aux[0].toUpperCase()+aux.slice(1)} Nora `:`Nora ${aux} `)+(negative?'not ':'')+`glowmend this tea${question?'?':'.'} [${state}]`;
 const r=await composeLocalVerb(input,registry,a,options);assert.equal(r.meaning.runtime_state,state);assert.equal(r.meaning.speech_act,question?'question':'assertion');assert.deepEqual(r.meaning.scopes,[...(past?[{operator:'time',relation:'before_speech'}]:[]),...(negative?[{operator:'negation'}]:[])]);assert.equal(r.meaning.bindings[0].reference.name.normalized_label,'nora');assert.equal(r.meaning.bindings[1].reference.name.normalized_label,'tea');count++;
}
await assert.rejects(composeLocalVerb('Nora did glowmend this tea.',registry,a),/Choose/);
await assert.rejects(composeLocalVerb('Nora did glowmend this tea.',registry,a,{subjectRole:'actor',objectRole:'actor'}),/distinct/);
assert.equal(await localVerbPlan('Nora do glowmend this tea.',registry,a),null);
assert.equal(await localVerbPlan('Nora did glowmend this tea yesterday.',registry,a),null);
const contracted=await composeLocalVerb("Didn't Nora glowmend this tea?",registry,a,options);assert.equal(contracted.meaning.scopes.length,2);
console.log(`PASS ${count} saved verb auxiliary sentences, explicit role mapping, contraction and unsupported-tail rejection.`);
