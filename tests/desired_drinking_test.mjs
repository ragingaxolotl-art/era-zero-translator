import assert from 'node:assert/strict';
import {composeDesiredDrinking,validateDesiredDrinking} from '../pages/desired_drinking.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
const opts={allowDraft:true,interpretation:'literal_drinking',viewpoint:'bounded',materialReading:'kind'};
for(const subject of ['', 'Eli '])for(const neg of ['', 'not '])for(const state of [0,1,2]){
 const d=await composeDesiredDrinking(`Does Nora not want ${subject}to ${neg}drink tea? [${state}]`,opts);
 assert.equal(d.runtime_state,state);assert.equal(d.speech_act,'question');assert.deepEqual(d.scopes,[{operator:'negation'}]);assert.deepEqual(d.content.scopes,neg?[{operator:'negation'}]:[]);assert.equal(d.content.runtime_state,1);assert.equal(d.content.drinker.name.normalized_label,subject?'eli':'nora');assert.equal(d.subject_binding,subject?'explicit_content_subject':'same_as_desire_holder');assert.equal(d.outcome_commitment,'desired_not_asserted');
}
const d=await composeDesiredDrinking('Nora wants Eli to drink tea.',opts),{content_id,content_digest,...body}=d;body.subject_binding='same_as_desire_holder';const hash=await canonicalDigest(body);await assert.rejects(validateDesiredDrinking({...body,content_digest:hash,content_id:`EZDESDRINK:${hash.slice(0,24)}`},{allowDraft:true}),/binding/);
await assert.rejects(composeDesiredDrinking('Nora wants to drink tea.',{...opts,viewpoint:undefined}),/Choose/);
console.log('PASS 12 desired-drinking meanings preserve controlled/explicit subject, independent negation and runtime; forged control rejects. No music claim.');
