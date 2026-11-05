import assert from 'node:assert/strict';
import fs from 'node:fs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {composePainMeaning} from '../pages/pain_meaning.mjs';
import {midiFromPain,decodePainMidi} from '../pages/pain_music.mjs';
import {decodeFeltConditionMidi} from '../pages/felt_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),sounds=new Set();
for(const state of [0,1,2])for(const past of [false,true])for(const neg of [false,true])for(const q of [false,true]){
 const text=(q?`${past?'Was':'Is'} Nora ${neg?'not ':''}in bodily pain?`:`Nora ${past?'was':'is'} ${neg?'not ':''}in bodily pain.`)+` [${state}]`;
 const d=await composePainMeaning(text,{allowDraft:true}),bytes=await midiFromPain(d,authority,{allowDraft:true}),r=decodePainMidi(bytes,authority.atoms,{allowDraft:true});
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,[],{allowDraft:true}),r);
 assert.equal(r.predicate,d.predicate);assert.deepEqual(r.experiencer.phonemes,d.experiencer.name.phonemes);assert.deepEqual(r.scopes,d.scopes);assert.equal(r.runtime_state,state);assert.equal(r.speech_act,d.speech_act);assert.equal(r.injury_commitment,'not_entailed');
 assert.throws(()=>decodePainMidi(bytes,authority.atoms));assert.throws(()=>decodeFeltConditionMidi(bytes,authority.atoms));
 sounds.add(Buffer.from(bytes).toString('base64'));
 const shifted=await midiFromPain(d,authority,{allowDraft:true,anchor:72});assert.deepEqual(decodePainMidi(shifted,authority.atoms,{allowDraft:true}),r);
}
assert.equal(sounds.size,24);console.log('PASS 24 pain music contrasts with full MIDI meaning recovery, transposition, default opt-out and generic-feeling cross-rejection.');
