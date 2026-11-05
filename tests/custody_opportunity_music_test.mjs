import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeAvailabilitySentence} from '../pages/availability_sentences.mjs';
import {midiFromCustodyOpportunity,decodeCustodyOpportunityMidi} from '../pages/custody_opportunity_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_candidates.json',import.meta.url))).records,sounds=new Set();let count=0;
for(const accessContext of ['"Pantry access"','"Market access"'])for(const state of [0,1,2])for(const phrase of ['This tea is available to Nora.','Is this tea available to Nora?','This tea was not available to Nora.']){
 const d=await composeAvailabilitySentence(phrase+` [${state}]`,{allowDraft:true,interpretation:'practical_custody_opportunity',accessContext}),bytes=await midiFromCustodyOpportunity(d,authority,{allowDraft:true}),r=decodeCustodyOpportunityMidi(bytes,authority.atoms,{allowDraft:true});
 assert.deepEqual(r.prospective_holder.phonemes,d.prospective_holder.name.phonemes);assert.deepEqual(r.resource.phonemes,d.resource.name.phonemes);assert.deepEqual(r.access_context.phonemes,d.access_context.name.phonemes);assert.equal(r.resource.reference_mode,'proximal_nominal');assert.equal(r.runtime_state,state);assert.equal(r.speech_act,d.speech_act);assert.deepEqual(r.scopes,d.scopes);assert.equal(r.activity_status,'possible_not_asserted');assert.equal(r.normative_permission,'not_entailed');assert.equal(r.actual_acquisition,'not_entailed');assert.equal(r.activity_time,'prospective_relative_to_opportunity');
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,records,{allowDraft:true}),r);assert.deepEqual(decodeCustodyOpportunityMidi(await midiFromCustodyOpportunity(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);assert.throws(()=>decodeStrictMusicMidi(bytes,authority.atoms));sounds.add(Buffer.from(bytes).toString('base64'));count++;
}
assert.equal(sounds.size,count);console.log(`PASS ${count} custody-opportunity musical inverses preserve context, resource, prospective holder, scope and runtime without asserting permission or acquisition; transposition and unique dispatch verified.`);
