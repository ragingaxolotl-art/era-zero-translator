import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composeUnderstandingContent} from '../pages/understanding_content.mjs';
import {midiFromUnderstanding,decodeUnderstandingMidi,understandingFoundation,understandingMusicEvents} from '../pages/understanding_music.mjs';
import {contentSelectionFrames} from '../pages/content_selection.mjs';
import {strictGrammarFrameInventory} from '../pages/strict_music_decoder.mjs';
import {contextualContentMusicFrames} from '../pages/contextual_content_frames.mjs';
import {acquisitionMusicFrames} from '../pages/acquisition_music_frames.mjs';
import {questionContentMusicFrames} from '../pages/question_music_frames.mjs';
import {quantifiedMusicFrames} from '../pages/quantified_music.mjs';
import {midiFromScheduledEvents,canonicalDigest} from '../pages/engine.mjs';
import {validateContextualContent} from '../pages/contextual_content.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),cases=[];
const newPaths=contentSelectionFrames().map(f=>f.path.join(','));assert.equal(new Set(newPaths).size,2);
for(const frame of [...strictGrammarFrameInventory(),...contextualContentMusicFrames(),...acquisitionMusicFrames(),...questionContentMusicFrames(),...quantifiedMusicFrames()])assert(!newPaths.includes(frame.path.join(',')));
for(const state of [0,1,2])for(const phrase of ['Eli understands what Nora said.','Eli did not understand what Nora said.','Does Eli understand what Nora said?']){
 const doc=await composeUnderstandingContent(phrase+` [${state}]`,{allowDraft:true}),bytes=await midiFromUnderstanding(doc,authority,{allowDraft:true}),decoded=await decodeUnderstandingMidi(bytes,authority.atoms,{allowDraft:true});
 assert.deepEqual(decoded.content.selection,{channel:'speech',time:'before_speech'});assert.deepEqual(decoded.scopes,doc.scopes);assert.equal(decoded.content.assertion_commitment,'none');assert.equal(decoded.runtime_state,state);assert.equal(decoded.speech_act,doc.speech_act);
 const generic=await composeUnderstandingContent(phrase.replace('what Nora said','Nora’s communicated content')+` [${state}]`,{allowDraft:true}),genericBytes=await midiFromUnderstanding(generic,authority,{allowDraft:true});assert.notDeepEqual(bytes,genericBytes);assert.equal(decoded.foundation_id,(await understandingFoundation()).foundation_id);
 cases.push({document:doc,midi:Buffer.from(bytes).toString('base64'),decoded});
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_understanding','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|Base64.strict_encode64(EraZeroUnderstanding.midi(d,allow_draft:true))})"],{input:JSON.stringify(cases.map(c=>c.document)),encoding:'utf8'}));assert.deepEqual(ruby,cases.map(c=>c.midi));
const first=cases[0],file=path.join(fs.mkdtempSync(path.join(os.tmpdir(),'era-spoken-content-')),'spoken.wav'),notes=notesFromMidi(Buffer.from(first.midi,'base64')).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick}));
execFileSync('python3',['tools/acoustic_transport.py','synth',file],{input:JSON.stringify(notes)});
const recovered=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',file,'--allow-draft'],{encoding:'utf8'}));assert.deepEqual(recovered.meaning,first.decoded);
fs.writeFileSync(new URL('../reports/understanding_spoken_content_probe.json',import.meta.url),JSON.stringify({status:'PASS',midi_ruby_cases:cases.length,clean_wav_cases:1,physical_recordings:0,meaning:recovered.meaning,wav:file},null,2)+'\n');
console.log('PASS 9 past-spoken-content scoped sentences, Ruby MIDI parity and one blind clean-WAV meaning recovery; source time stays inside content, no claim truth asserted.');

const bad=structuredClone(first.document.content);bad.selection.channel='writing';const {content_id,content_digest,...body}=bad,digest=await canonicalDigest(body);bad.content_digest=digest;bad.content_id=`EZCTX:${digest.slice(0,24)}`;await assert.rejects(()=>validateContextualContent(bad,{allowDraft:true}));
const events=await understandingMusicEvents(first.document,authority,{allowDraft:true});
const missingChannel=events.filter(e=>!/^spoken_source_/.test(e.marker||''));await assert.rejects(()=>decodeUnderstandingMidi(midiFromScheduledEvents(missingChannel,60,[0,0]),authority.atoms,{allowDraft:true}));
console.log('PASS unsupported source-channel substitution and missing source frame rejected.');
