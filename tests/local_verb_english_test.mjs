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
const inflected=await addLocalCompound(emptyLocalCompounds(),{...d,english_forms:{third_person:'glowmends',past:'glowmended'}},a);
for(const [sentence,equivalent] of [['Nora glowmends this tea.','Nora does glowmend this tea.'],['Nora glowmended this tea.','Nora did glowmend this tea.'],['I glowmend this tea.','I do glowmend this tea.']]){
 const direct=await composeLocalVerb(sentence,inflected,a,options),auxiliary=await composeLocalVerb(equivalent,inflected,a,options);assert.deepEqual(direct.meaning,auxiliary.meaning);assert.deepEqual(direct.midi,auxiliary.midi);
}
assert.equal(await localVerbPlan('Nora glowmend this tea.',inflected,a),null);
const irregular=await addLocalCompound(emptyLocalCompounds(),{...d,label:'take',english_forms:{third_person:'takes',past:'took'}},a);assert.deepEqual((await composeLocalVerb('Nora took this tea.',irregular,a,options)).meaning.scopes,[{operator:'time',relation:'before_speech'}]);
const ambiguous=await addLocalCompound(emptyLocalCompounds(),{...d,label:'put',english_forms:{third_person:'puts',past:'put'}},a);assert.equal(await localVerbPlan('I put this tea.',ambiguous,a),null);
await assert.rejects(addLocalCompound(emptyLocalCompounds(),{...d,english_forms:{third_person:'glowmends',past:''}},a));
console.log('PASS explicit regular/irregular verb forms match auxiliary meanings/music; agreement, incomplete forms and ambiguous tense reject.');
const {localVerbCandidates}=await import('../pages/local_compound_english.mjs');
const alternatives=await localVerbCandidates('I put this tea.',ambiguous,a);assert.equal(alternatives.length,2);assert.deepEqual(alternatives.map(p=>p.scopes),[[],[{operator:'time',relation:'before_speech'}]]);
const now=await composeLocalVerb('I put this tea.',ambiguous,a,{...options,interpretation:alternatives[0]}),then=await composeLocalVerb('I put this tea.',ambiguous,a,{...options,interpretation:alternatives[1]});assert.notDeepEqual(now.midi,then.midi);assert.deepEqual(now.meaning.bindings,then.meaning.bindings);
await assert.rejects(composeLocalVerb('Nora put this tea.',ambiguous,a,{...options,interpretation:alternatives[0]}),/no longer matches/);
await assert.rejects(composeLocalVerb('I put this tea.',ambiguous,a,{...options,interpretation:{...alternatives[0],runtime_state:2}}),/no longer matches/);
console.log('PASS explicit ambiguous-tense selection preserves participants and changes time/music; stale or forged interpretations reject.');
