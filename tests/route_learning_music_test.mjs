import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeRouteLearning} from '../pages/route_learning.mjs';
import {midiFromRouteLearning,decodeRouteLearningMidi,routeLearningFoundations} from '../pages/route_learning_music.mjs';
import {validateFoundations} from '../pages/foundations.mjs';
import {understandingFoundation} from '../pages/understanding_music.mjs';
import {acquisitionMusicFrames} from '../pages/acquisition_music_frames.mjs';
import {strictGrammarFrameInventory} from '../pages/strict_music_decoder.mjs';
import {contentSelectionFrames} from '../pages/content_selection.mjs';
import {contextualContentMusicFrames} from '../pages/contextual_content_frames.mjs';
import {questionContentMusicFrames} from '../pages/question_music_frames.mjs';
import {quantifiedMusicFrames} from '../pages/quantified_music.mjs';
const paths=acquisitionMusicFrames({includeUnderstanding:true,includeRoute:true}).map(f=>f.path.join(','));
assert.equal(new Set(paths).size,8);assert.equal(acquisitionMusicFrames().length,4);
for(const f of [...strictGrammarFrameInventory(),...contentSelectionFrames(),...contextualContentMusicFrames(),...questionContentMusicFrames(),...quantifiedMusicFrames()])assert(!paths.includes(f.path.join(',')));
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),existing=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_preview_candidates.json',import.meta.url))).records;
await validateFoundations([...existing,await understandingFoundation(),...await routeLearningFoundations()],{allowDraft:true});
let count=0;const sounds=new Set();
for(const reading of ['memorization','navigation','familiarity'])for(const event of [0,1,2])for(const result of [0,1,2])for(const phrase of ['Nora learned the route.','Nora did not learn the route.','Did Nora learn the route?']){
 const d=await composeRouteLearning(phrase+` [${event}]`,{allowDraft:true,interpretation:reading,resultRuntime:result}),bytes=await midiFromRouteLearning(d,authority,{allowDraft:true}),r=await decodeRouteLearningMidi(bytes,authority.atoms,{allowDraft:true});
 assert.equal(r.result_state.reading,reading);assert.equal(r.result_state.criterion,d.result_state.criterion);assert.equal(r.result_state.runtime_state,result);assert.equal(r.transition_runtime,event);assert.equal(r.speech_act,d.speech_act);assert.deepEqual(r.scopes.map(s=>s.relation||s.operator),d.event_scopes);assert.equal(r.result_state.content_commitment,d.result_state.content_commitment);assert.deepEqual(r.result_state.experiencer.phonemes,d.result_state.experiencer.name.phonemes);assert.deepEqual(r.result_state.route.phonemes,d.result_state.route.name.phonemes);assert.equal(r.phase_contract.after,'unspecified');sounds.add(Buffer.from(bytes).toString('base64'));count++;
 await assert.rejects(()=>decodeRouteLearningMidi(bytes,authority.atoms));
}
assert.equal(sounds.size,81);
console.log(`PASS ${count} distinct route-learning musical meanings with separate result criteria, participants, scope, speech act and independent runtimes. Ruby/UI pending; WAV evidence is in the separate acoustic suite.`);
