import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {acquisitionMusicFrames} from '../pages/acquisition_music_frames.mjs';
import {strictGrammarFrameInventory} from '../pages/strict_music_decoder.mjs';
import {contentSelectionFrames} from '../pages/content_selection.mjs';
import {contextualContentMusicFrames} from '../pages/contextual_content_frames.mjs';
import {questionContentMusicFrames} from '../pages/question_music_frames.mjs';
import {quantifiedMusicFrames} from '../pages/quantified_music.mjs';
import {composeCameToUnderstand,validateUnderstandingAcquisition,createUnderstandingAcquisition,parseCameToUnderstand} from '../pages/understanding_acquisition.mjs';
import {composeUnderstandingContent} from '../pages/understanding_content.mjs';
import {midiFromUnderstandingAcquisition,decodeUnderstandingAcquisitionMidi} from '../pages/understanding_acquisition_music.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const paths=acquisitionMusicFrames({includeUnderstanding:true}).map(f=>f.path.join(','));assert.equal(new Set(paths).size,6);assert.equal(acquisitionMusicFrames().length,4);
for(const frame of [...strictGrammarFrameInventory(),...contentSelectionFrames(),...contextualContentMusicFrames(),...questionContentMusicFrames(),...quantifiedMusicFrames()])assert(!paths.includes(frame.path.join(',')));
let count=0;const parity=[];const sounds=new Set();
for(const event of [0,1,2])for(const result of [0,1,2])for(const text of ['Eli came to understand what Nora said.','Eli did not come to understand what Nora said.','Did Eli come to understand what Nora said?']){
 const d=await composeCameToUnderstand(text+` [${event}]`,{allowDraft:true,resultRuntime:result}),bytes=await midiFromUnderstandingAcquisition(d,authority,{allowDraft:true}),r=await decodeUnderstandingAcquisitionMidi(bytes,authority.atoms,{allowDraft:true});
 parity.push({document:d,midi:Buffer.from(bytes).toString('base64')});
 assert.equal(r.transition_runtime,event);assert.equal(r.result.runtime_state,result);assert.equal(r.result_assertion,'at_culmination_only');assert.equal(r.phase_contract.after,'unspecified');assert.deepEqual(r.result.scopes,[]);assert.equal(r.result.content.selection.time,'before_speech');assert.deepEqual(r.scopes.map(s=>s.relation||s.operator),d.event_scopes);assert.equal(r.speech_act,d.speech_act);sounds.add(Buffer.from(bytes).toString('base64'));count++;
 await assert.rejects(()=>decodeUnderstandingAcquisitionMidi(bytes,authority.atoms));
}
assert.equal(sounds.size,27);
const neg=await composeUnderstandingContent('Eli did not understand Nora.',{allowDraft:true,interpretation:'reasons'});await assert.rejects(()=>createUnderstandingAcquisition(neg,{allowDraft:true}));
await assert.rejects(()=>composeCameToUnderstand('Eli came to understand Nora.',{interpretation:'perspective'}));
const d=await composeCameToUnderstand('Eli came to understand Nora.',{allowDraft:true,interpretation:'perspective'});d.phase_contract.after='permanent';await assert.rejects(()=>validateUnderstandingAcquisition(d,{allowDraft:true}));
console.log(`PASS ${count} comprehension-acquisition musical inverses: independent transition/result runtime, positive result at culmination only, negation/time/question scope and past speech selection.`);

const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_understanding_acquisition','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|Base64.strict_encode64(EraZeroUnderstandingAcquisition.midi(d,allow_draft:true))})"],{input:JSON.stringify(parity.map(p=>p.document)),encoding:'utf8',maxBuffer:20_000_000}));assert.deepEqual(ruby,parity.map(p=>p.midi));
console.log('PASS all 27 comprehension acquisition performances match independent Ruby document validation and regeneration.');

assert.equal(parseCameToUnderstand('Nora came to understand why Eli left.'),null);
