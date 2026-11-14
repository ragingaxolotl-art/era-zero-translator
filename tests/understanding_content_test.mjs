import assert from 'node:assert/strict';
import {understandingInterpretationPlan as plan,composeUnderstandingContent as compose,validateUnderstandingContent as validate,UNDERSTANDING_READINGS} from '../pages/understanding_content.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
assert.equal(plan('Eli understands Nora.').choices.length,3);
await assert.rejects(()=>compose('Eli understands Nora.',{allowDraft:true}),e=>e.code==='understanding_interpretation_required');
let count=0;const identities=new Set();
for(const state of [0,1,2])for(const kind of Object.keys(UNDERSTANDING_READINGS))for(const phrase of ['Eli understands Nora.','Eli did not understand Nora.','Does Eli understand Nora?']){
 const d=await compose(`${phrase} [${state}]`,{allowDraft:true,interpretation:kind});
 assert.equal(d.runtime_state,state);assert.equal(d.content.content_kind,kind);assert.equal(d.content.assertion_commitment,'none');
 assert.deepEqual(d.experiencer.name.phonemes,['EH','L','IH']);assert.deepEqual(d.content.anchor.name.phonemes,['N','AO','R','AE']);
 assert.deepEqual(d.scopes,phrase.includes('did not')?[{operator:'time',relation:'before_speech'},{operator:'negation'}]:[]);
 assert.equal(d.speech_act,phrase.endsWith('?')?'question':'assertion');identities.add(d.content_id);count++;
}
assert.equal(identities.size,27);
for(const [phrase,kind] of [["Eli understands Nora’s communicated content.",'communicated_content'],["Eli understands Nora's reasons.",'reasons'],["Eli understands Nora’s perspective.",'perspective']]){
 const d=await compose(phrase,{allowDraft:true});assert.equal(d.content.content_kind,kind);
 await assert.rejects(()=>compose(phrase,{allowDraft:true,interpretation:kind==='reasons'?'perspective':'reasons'}));
}
const a=await compose("Eli didn't understand Nora.",{allowDraft:true,interpretation:'perspective'}),b=await compose('Eli did not understand Nora.',{allowDraft:true,interpretation:'perspective'});assert.deepEqual(a,b);
for(const input of ['Eli understands why Nora left.','Eli understands Nora completely.','Eli understands that Nora is conscious.'])assert.equal(plan(input),null);
await assert.rejects(()=>compose('Eli understands Nora.',{interpretation:'reasons'}));
for(const mutate of [d=>d.criterion='Attention is sufficient',d=>d.content.assertion_commitment='true',d=>d.experiencer.runtime_state=1,d=>d.runtime_state=3,d=>d.scopes.push({operator:'certainty'})]){
 const d=structuredClone(a);mutate(d);const {content_id,content_digest,...body}=d,digest=await canonicalDigest(body);d.content_digest=digest;d.content_id=`EZUND:${digest.slice(0,24)}`;await assert.rejects(()=>validate(d,{allowDraft:true}));
}
console.log(`PASS ${count} understanding interpretation contracts; three content readings, temporal/negation scope, runtime, questions, exact references and corrupted semantic rejection. Musical predicate is tested separately.`);
