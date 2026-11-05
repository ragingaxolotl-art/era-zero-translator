import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composePainStimulusSentence} from '../pages/pain_stimulus_sentences.mjs';
import {createPainStimulus} from '../pages/pain_stimulus.mjs';
import {composePainMeaning} from '../pages/pain_meaning.mjs';
import {midiFromPainStimulus,decodePainStimulusMidi} from '../pages/pain_stimulus_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),sounds=new Set();
for(const phrase of ['The treatment caused bodily pain for Nora.','The treatment is not expected to cause bodily pain for Nora.','Does the treatment tend to cause bodily pain for Nora?'])for(const state of [0,1,2])for(const outcomeState of [0,1,2]){
 const base=await composePainStimulusSentence(`${phrase} [${state}]`,{allowDraft:true});
 const d=await createPainStimulus(base.stimulus,await composePainMeaning(`Nora is in bodily pain. [${outcomeState}]`,{allowDraft:true}),{allowDraft:true,relation:base.relation,runtimeState:state,speechAct:base.speech_act,scopes:base.scopes});
 const bytes=await midiFromPainStimulus(d,authority,{allowDraft:true}),r=decodePainStimulusMidi(bytes,authority.atoms,{allowDraft:true});
 assert.equal(r.relation,d.relation);assert.equal(r.runtime_state,state);assert.equal(r.outcome.runtime_state,outcomeState);assert.deepEqual(r.stimulus.phonemes,d.stimulus.name.phonemes);assert.deepEqual(r.outcome.experiencer.phonemes,d.outcome.experiencer.name.phonemes);assert.deepEqual(r.scopes,d.scopes);assert.equal(r.speech_act,d.speech_act);assert.equal(r.outcome_scope,d.outcome_scope);
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,[],{allowDraft:true}),r);assert.throws(()=>decodePainStimulusMidi(bytes,authority.atoms));
 assert.deepEqual(decodePainStimulusMidi(await midiFromPainStimulus(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);
 sounds.add(Buffer.from(bytes).toString('base64'));
}
assert.equal(sounds.size,27);console.log('PASS 27 stimulus/outcome runtime contrasts preserve relations, separate participants and scopes through unique shared MIDI decoding and transposition.');
