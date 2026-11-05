import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeOwnershipSentence} from '../pages/ownership_sentences.mjs';
import {midiFromOwnership,decodeOwnershipMidi} from '../pages/ownership_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_candidates.json',import.meta.url))).records;
let count=0;const sounds=new Set();
for(const framework of ['"Harbor charter"','"Island charter"'])for(const state of [0,1,2])for(const phrase of ['Nora owns this tea.','Does Nora own this tea?','Nora did not own this tea.']){
 const d=await composeOwnershipSentence(phrase+` [${state}]`,{allowDraft:true,framework}),midi=await midiFromOwnership(d,authority,{allowDraft:true}),r=decodeOwnershipMidi(midi,authority.atoms,{allowDraft:true});
 assert.equal(r.runtime_state,state);assert.equal(r.speech_act,d.speech_act);assert.deepEqual(r.scopes,d.scopes);assert.deepEqual(r.owner.phonemes,d.owner.name.phonemes);assert.deepEqual(r.object.phonemes,d.object.name.phonemes);assert.equal(r.object.reference_mode,'proximal_nominal');assert.deepEqual(r.framework.phonemes,d.framework.name.phonemes);assert.equal(r.physical_custody,'not_entailed');assert.equal(r.other_framework_status,'not_asserted');
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(midi,authority.atoms,records,{allowDraft:true}),r);assert.deepEqual(decodeOwnershipMidi(await midiFromOwnership(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);
 assert.throws(()=>decodeStrictMusicMidi(midi,authority.atoms));assert.throws(()=>decodeOwnershipMidi(midi,authority.atoms),/draft/);sounds.add(Buffer.from(midi).toString('base64'));count++;
}
assert.equal(sounds.size,count);console.log(`PASS ${count} ownership music/inverse cases preserve three references, scopes and runtime; transposition and unique draft dispatch verified.`);
