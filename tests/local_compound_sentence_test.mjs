import assert from 'node:assert/strict';
import fs from 'node:fs';
import {emptyLocalCompounds,addLocalCompound} from '../pages/local_compounds.mjs';
import {contextualContentReference} from '../pages/contextual_content.mjs';
import {composeLocalCompoundSentence} from '../pages/local_compound_sentence.mjs';
const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),d={label:'test action',definition:'Test-only predicate.',part_of_speech:'verb',roles:[{role:'actor',definition:'Person acting.'},{role:'target',definition:'Affected object.'}],components:a.atoms.slice(0,2).map((v,i)=>({target_id:v.canonical_id,relation:i?'qualifies':'head'}))};
const registry=await addLocalCompound(emptyLocalCompounds(),d,a),id=registry.entries[0].compound_id,bindings=[{path:[],role:'actor',reference:await contextualContentReference('Nora')},{path:[],role:'target',reference:await contextualContentReference('this tea')}];
const neg={operator:'negation'},possible={operator:'modality',mode:'possible'},past={operator:'time',relation:'before_speech'},sounds=new Set();
for(const runtimeState of [0,1,2])for(const scopes of [[],[past,neg],[possible,neg],[neg,possible]])for(const speechAct of ['assertion','question']){
 const result=await composeLocalCompoundSentence(id,registry,a,bindings,{runtimeState,scopes,speechAct});
 assert.deepEqual(result.meaning.scopes,scopes);assert.equal(result.meaning.runtime_state,runtimeState);assert.equal(result.meaning.speech_act,speechAct);assert.equal(result.meaning.bindings[0].reference.name.normalized_label,'nora');assert.equal(result.meaning.bindings[1].reference.name.normalized_label,'tea');
 if(scopes[0]===possible)assert.equal(result.events[0].marker,'modality_possible_open');if(scopes[0]===neg)assert.equal(result.events[0].marker,'negation_open');
 sounds.add(Buffer.from(result.midi).toString('base64'));
}
assert.equal(sounds.size,24);await assert.rejects(composeLocalCompoundSentence(id,registry,a,bindings,{scopes:[{operator:'modality',mode:'unknown'}]}));
await assert.rejects(composeLocalCompoundSentence(id,registry,a,bindings.slice(0,1)));
console.log('PASS 24 local sentence performances preserve participants, ordered negation/modality/time, question contour and runtime. Natural English parsing remains pending.');
