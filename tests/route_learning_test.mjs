import assert from 'node:assert/strict';
import {composeRouteLearning as compose,routeLearningInterpretationPlan as plan,validateRouteLearning,evaluateRouteLearning,ROUTE_LEARNING_READINGS} from '../pages/route_learning.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
assert.equal(plan('Nora learned the route.').choices.length,3);
await assert.rejects(()=>compose('Nora learned the route.',{allowDraft:true}),e=>e.code==='route_learning_interpretation_required');
let count=0;const ids=new Set();
for(const reading of Object.keys(ROUTE_LEARNING_READINGS))for(const event of [0,1,2])for(const result of [0,1,2])for(const text of ['Nora learned the route.','Nora did not learn the route.','Did Nora learn the route?']){
 const d=await compose(text+` [${event}]`,{allowDraft:true,interpretation:reading,resultRuntime:result});assert.equal(d.transition_runtime,event);assert.equal(d.result_state.runtime_state,result);assert.equal(d.result_state.reading,reading);assert.equal(d.phase_contract.after,'unspecified');assert.equal(d.result_assertion,'at_culmination_only');assert.equal(d.speech_act,text.endsWith('?')?'question':'assertion');assert.deepEqual(d.event_scopes,['before_speech',...(text.includes('did not')?['negation']:[])]);ids.add(d.acquisition_id);count++;
}
assert.equal(ids.size,81);
const neutral=await compose('They learned this route.',{allowDraft:true,interpretation:'navigation',bindings:{ref0:{referent:'Nora',number:'singular'}}}),named=await compose('Nora learned this route.',{allowDraft:true,interpretation:'navigation'});assert.deepEqual(neutral,named);
const contracted=await compose("Didn't Nora learn the route?",{allowDraft:true,interpretation:'memorization'});assert.equal(contracted.result_state.content_commitment,'representation_without_truth_assertion');assert.deepEqual(contracted.event_scopes,['before_speech','negation']);
assert.equal(evaluateRouteLearning({before:false,culmination:true,transitionCompleted:true}),true);assert.equal(evaluateRouteLearning({before:true,culmination:true,transitionCompleted:true}),false);assert.equal(evaluateRouteLearning({before:null,culmination:true,transitionCompleted:true}),null);assert.throws(()=>evaluateRouteLearning({before:0,culmination:1,transitionCompleted:2}));
for(const mutate of [d=>d.result_state.criterion='Any revision is enough',d=>d.result_state.content_commitment='true',d=>d.phase_contract.after='permanent',d=>d.result_state.route.name.semantic_claim=true]){
 const d=structuredClone(contracted);mutate(d);const {content_digest,acquisition_id,...body}=d,digest=await canonicalDigest(body);d.content_digest=digest;d.acquisition_id=`EZROUTEACQ:${digest.slice(0,24)}`;await assert.rejects(()=>validateRouteLearning(d,{allowDraft:true}));
}
for(const text of ['Nora learned that the route is safe.','Nora learned the route quickly.','Nora learned three routes.'])assert.equal(plan(text),null);
console.log(`PASS ${count} route-learning meaning contracts, distinct readings, independent runtimes, event scope, explicit neutral reference and corruption rejection.`);
