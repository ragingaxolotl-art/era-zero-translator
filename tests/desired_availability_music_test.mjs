import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeDesiredAvailability} from '../pages/desired_availability.mjs';
import {midiFromDesiredAvailability,decodeDesiredAvailabilityMidi} from '../pages/desired_availability_music.mjs';
import {midiFromCustodyOpportunity,decodeCustodyOpportunityMidi} from '../pages/custody_opportunity_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_candidates.json',import.meta.url))).records,sounds=new Set();
for(const outer of [0,1,2])for(const inner of [0,1,2])for(const negative of [false,true]){
 const d=await composeDesiredAvailability(`Didn't Nora want this tea to ${negative?'not ':''}be available to Eli [${inner}]? [${outer}]`,{allowDraft:true,interpretation:'practical_custody_opportunity',accessContext:'"Pantry access"'});
 const bytes=await midiFromDesiredAvailability(d,authority,{allowDraft:true}),r=decodeDesiredAvailabilityMidi(bytes,authority.atoms,{allowDraft:true});
 assert.equal(r.runtime_state,outer);assert.equal(r.content.runtime_state,inner);assert.equal(r.speech_act,'question');assert.deepEqual(r.scopes,[{operator:'time',relation:'before_speech'},{operator:'negation'}]);
 assert.deepEqual(r.content,decodeCustodyOpportunityMidi(await midiFromCustodyOpportunity(d.content,authority,{allowDraft:true}),authority.atoms,{allowDraft:true}));
 assert.deepEqual(r.holder.phonemes,d.holder.name.phonemes);assert.deepEqual(r.content.resource.phonemes,d.content.resource.name.phonemes);assert.deepEqual(r.content.prospective_holder.phonemes,d.content.prospective_holder.name.phonemes);
 assert.equal(r.content_status,'intensional');assert.equal(r.outcome_commitment,'desired_not_asserted');assert.equal(r.foundation_id,d.foundation_id);assert.equal(r.subject_binding,'explicit_content_subject');
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,records,{allowDraft:true}),r);assert.deepEqual(decodeDesiredAvailabilityMidi(await midiFromDesiredAvailability(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);assert.throws(()=>decodeDesiredAvailabilityMidi(bytes,authority.atoms));sounds.add(Buffer.from(bytes).toString('base64'));
}
assert.equal(sounds.size,18);
console.log('PASS 18 desired availability musical contrasts, complete nested inverse, participant identity, independent scopes, shared dispatch and transposition.');
