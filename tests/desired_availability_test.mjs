import assert from 'node:assert/strict';
import {composeDesiredAvailability,validateDesiredAvailability,desiredAvailabilityPlan} from '../pages/desired_availability.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
const options={allowDraft:true,interpretation:'practical_custody_opportunity',accessContext:'"Pantry access"'};
let count=0;
for(const outer of [0,1,2])for(const inner of [0,1,2])for(const negated of [false,true]){
 const d=await composeDesiredAvailability(`Does Nora not want this tea to ${negated?'not ':''}be available to Eli [${inner}]? [${outer}]`,options);
 assert.equal(d.holder.name.normalized_label,'nora');assert.equal(d.content.resource.name.normalized_label,'tea');assert.equal(d.content.prospective_holder.name.normalized_label,'eli');
 assert.equal(d.runtime_state,outer);assert.equal(d.content.runtime_state,inner);assert.equal(d.speech_act,'question');assert.deepEqual(d.scopes,[{operator:'negation'}]);assert.deepEqual(d.content.scopes,negated?[{operator:'negation'}]:[]);
 assert.equal(d.content_status,'intensional');assert.equal(d.outcome_commitment,'desired_not_asserted');assert.equal(d.content.actual_acquisition,'not_entailed');count++;
}
const base=await composeDesiredAvailability('Nora wants this tea to be available to Eli.',options);
const neutral=await composeDesiredAvailability('They want it to be available to Eli.',{...options,bindings:{ref0:{referent:'Nora',number:'singular'},ref1:'this tea'}});
assert.deepEqual(neutral,base);
const past=await composeDesiredAvailability('Nora wanted this tea to be available.',{...options,prospectiveHolder:'Eli'});
assert.deepEqual(past.scopes,[{operator:'time',relation:'before_speech'}]);assert.deepEqual(past.content.scopes,[]);
assert.equal(desiredAvailabilityPlan('Nora wants to be available.'),null);
await assert.rejects(composeDesiredAvailability('Nora wants this tea to be available.',options),/who has the opportunity/);
await assert.rejects(composeDesiredAvailability('Nora wants this tea to be available to Eli.',{...options,interpretation:undefined}),/Select the practical/);
await assert.rejects(composeDesiredAvailability('Nora wants this tea to be available to Eli.',{...options,accessContext:undefined}),/access context/);
for(const change of [d=>d.content_status='asserted',d=>d.outcome_commitment='happens',d=>d.foundation_id='FND:wrong',d=>d.subject_binding='same_as_desire_holder']){
 const d=structuredClone(base);change(d);delete d.content_digest;delete d.content_id;const hash=await canonicalDigest(d);d.content_digest=hash;d.content_id=`EZDESAVAIL:${hash.slice(0,24)}`;await assert.rejects(validateDesiredAvailability(d,{allowDraft:true}));
}
console.log(`PASS ${count} desired availability scope/runtime combinations; distinct participants, neutral references, explicit choices and forged contracts. Music integration pending.`);
