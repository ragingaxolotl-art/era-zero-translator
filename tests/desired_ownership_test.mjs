import assert from 'node:assert/strict';
import {composeDesiredOwnership,validateDesiredOwnership} from '../pages/desired_ownership.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
const options={allowDraft:true,framework:'"Harbor charter"'};let count=0;
for(const outer of [0,1,2])for(const inner of [0,1,2])for(const negative of [false,true]){
 const d=await composeDesiredOwnership(`Does Nora not want Eli to ${negative?'not ':''}own this tea [${inner}]? [${outer}]`,options);
 assert.equal(d.runtime_state,outer);assert.equal(d.content.runtime_state,inner);assert.equal(d.speech_act,'question');assert.deepEqual(d.scopes,[{operator:'negation'}]);assert.deepEqual(d.content.scopes,negative?[{operator:'negation'}]:[]);assert.equal(d.holder.name.normalized_label,'nora');assert.equal(d.content.owner.name.normalized_label,'eli');assert.equal(d.subject_binding,'explicit_content_subject');assert.equal(d.content_status,'intensional');assert.equal(d.outcome_commitment,'desired_not_asserted');assert.equal(d.content.framework.name.normalized_label,'harbor charter');assert.equal(d.content.physical_custody,'not_entailed');count++;
}
const controlled=await composeDesiredOwnership('Nora wants to own this tea.',options);assert.equal(controlled.subject_binding,'same_as_desire_holder');assert.deepEqual(controlled.holder,controlled.content.owner);
const neutral=await composeDesiredOwnership('They want to own it.',{...options,bindings:{ref0:{referent:'Nora',number:'singular'},ref1:'this tea'}});assert.deepEqual(neutral,controlled);
const past=await composeDesiredOwnership('Nora wanted Eli to own this tea.',options);assert.deepEqual(past.scopes,[{operator:'time',relation:'before_speech'}]);assert.deepEqual(past.content.scopes,[]);
await assert.rejects(composeDesiredOwnership('Nora wants to own this tea.',{allowDraft:true}),/framework explicitly/);
for(const change of [d=>d.content_status='asserted',d=>d.outcome_commitment='happens',d=>d.foundation_id='FND:wrong',d=>d.subject_binding='same_as_desire_holder']){
 const d=structuredClone(await composeDesiredOwnership('Nora wants Eli to own this tea.',options));change(d);delete d.content_id;delete d.content_digest;const hash=await canonicalDigest(d);d.content_digest=hash;d.content_id=`EZDESOWN:${hash.slice(0,24)}`;await assert.rejects(validateDesiredOwnership(d,{allowDraft:true}));
}
console.log(`PASS ${count} desired ownership scope/runtime cases, controlled and neutral subject identity, past scope and forged commitment rejection. Music not yet implemented.`);
