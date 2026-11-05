import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeDesiredDrinking} from '../pages/desired_drinking.mjs';
import {midiFromDesiredDrinking,decodeDesiredDrinkingMidi} from '../pages/desired_drinking_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),sounds=new Set();
for(const subject of ['', 'Eli '])for(const outerNeg of ['', 'not '])for(const innerNeg of ['', 'not '])for(const state of [0,1,2]){
 const d=await composeDesiredDrinking(`Does Nora ${outerNeg}want ${subject}to ${innerNeg}drink tea? [${state}]`,{allowDraft:true,interpretation:'literal_drinking',viewpoint:'bounded',materialReading:'kind'}),bytes=await midiFromDesiredDrinking(d,authority,{allowDraft:true}),r=decodeDesiredDrinkingMidi(bytes,authority.atoms,{allowDraft:true});
 assert.equal(r.runtime_state,state);assert.equal(r.content.runtime_state,1);assert.equal(r.content_status,'intensional');assert.equal(r.subject_binding,d.subject_binding);assert.deepEqual(r.holder.phonemes,d.holder.name.phonemes);assert.deepEqual(r.content.drinker.phonemes,d.content.drinker.name.phonemes);assert.deepEqual(r.scopes,outerNeg?[{operator:'negation'}]:[]);assert.deepEqual(r.content.scopes,innerNeg?[{operator:'negation'}]:[]);assert.equal(r.speech_act,'question');assert.equal(r.content.material.reading,'kind');
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,[],{allowDraft:true}),r);assert.throws(()=>decodeDesiredDrinkingMidi(bytes,authority.atoms));assert.deepEqual(decodeDesiredDrinkingMidi(await midiFromDesiredDrinking(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);sounds.add(Buffer.from(bytes).toString('base64'));
}
assert.equal(sounds.size,24);console.log('PASS 24 desired-drinking musical contrasts preserve subject control, separate negations, question and runtime through shared inverse/transposition.');
