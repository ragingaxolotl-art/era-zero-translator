import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeDrinkingSentence} from '../pages/drinking_sentences.mjs';
import {midiFromDrinking,decodeDrinkingMidi} from '../pages/drinking_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),sounds=new Set();
for(const viewpoint of ['ongoing','bounded','habitual'])for(const state of [0,1,2])for(const [material,reading] of [['tea','kind'],['this tea','contextual_portion']]){
 const d=await composeDrinkingSentence(`Does Nora not drink ${material}? [${state}]`,{allowDraft:true,interpretation:'literal_drinking',viewpoint,materialReading:reading}),bytes=await midiFromDrinking(d,authority,{allowDraft:true}),r=decodeDrinkingMidi(bytes,authority.atoms,{allowDraft:true});
 assert.equal(r.viewpoint,viewpoint);assert.equal(r.runtime_state,state);assert.equal(r.material.reading,reading);assert.deepEqual(r.material.reference.phonemes,d.material.reference.name.phonemes);assert.deepEqual(r.drinker.phonemes,d.drinker.name.phonemes);assert.deepEqual(r.scopes,[{operator:'negation'}]);assert.equal(r.speech_act,'question');assert.equal(r.whole_amount_consumption,'not_asserted');
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,[],{allowDraft:true}),r);assert.throws(()=>decodeDrinkingMidi(bytes,authority.atoms));assert.deepEqual(decodeDrinkingMidi(await midiFromDrinking(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);sounds.add(Buffer.from(bytes).toString('base64'));
}
assert.equal(sounds.size,18);console.log('PASS 18 drinking MIDI contrasts recover viewpoint, material kind/portion, participants, negated question and runtime via shared dispatch and transposition.');
