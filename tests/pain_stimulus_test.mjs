import assert from 'node:assert/strict';
import {composePainMeaning} from '../pages/pain_meaning.mjs';
import {contextualContentReference} from '../pages/contextual_content.mjs';
import {createPainStimulus,validatePainStimulus} from '../pages/pain_stimulus.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
const stimulus=await contextualContentReference('the treatment'),outcome=await composePainMeaning('Nora is in bodily pain. [2]',{allowDraft:true}),ids=new Set();
for(const relation of ['actual_causation','expected_outcome','disposition'])for(const state of [0,1,2])for(const speechAct of ['assertion','question'])for(const negative of [false,true]){
 const d=await createPainStimulus(stimulus,outcome,{allowDraft:true,relation,runtimeState:state,speechAct,scopes:negative?[{operator:'negation'}]:[]});ids.add(d.content_id);
 assert.equal(d.stimulus.name.normalized_label,'treatment');assert.equal(d.outcome.experiencer.name.normalized_label,'nora');assert.equal(d.outcome.runtime_state,2);assert.equal(d.runtime_state,state);assert.equal(d.outcome_scope,'governed_by_relation_and_matrix_scope');
 const {content_digest,content_id,...body}=d;body.outcome_scope='independently_asserted';const hash=await canonicalDigest(body);await assert.rejects(validatePainStimulus({...body,content_digest:hash,content_id:`EZPAINSTIM:${hash.slice(0,24)}`},{allowDraft:true}));
}
assert.equal(ids.size,36);await assert.rejects(createPainStimulus(stimulus,outcome,{allowDraft:true}));await assert.rejects(createPainStimulus(stimulus,outcome,{relation:'actual_causation'}));
const negated=await composePainMeaning('Nora is not in bodily pain.',{allowDraft:true});await assert.rejects(createPainStimulus(stimulus,negated,{allowDraft:true,relation:'expected_outcome'}));
console.log('PASS 36 draft stimulus relation/speech-act/negation/runtime distinctions; treatment and experiencer remain separate; outcome not independently asserted. No English or music route claimed.');
