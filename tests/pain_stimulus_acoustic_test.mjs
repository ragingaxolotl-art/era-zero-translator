import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composePainStimulusSentence} from '../pages/pain_stimulus_sentences.mjs';
import {midiFromPainStimulus,decodePainStimulusMidi} from '../pages/pain_stimulus_music.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-pain-stimulus-audio-')),cases=[];
for(const [phrase,options] of [['The treatment caused bodily pain for Nora. [0]',{}],['Is the treatment not expected to cause bodily pain for Nora? [2]',{}],['It tends to cause bodily pain for them. [1]',{bindings:{ref0:'the treatment',ref1:{referent:'Nora',number:'singular'}}}]]){
 const document=await composePainStimulusSentence(phrase,{allowDraft:true,...options}),bytes=await midiFromPainStimulus(document,authority,{allowDraft:true});
 const expected=decodePainStimulusMidi(bytes,authority.atoms,{allowDraft:true}),wav=path.join(directory,`pain-${cases.length}.wav`);
 execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{input:JSON.stringify(notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick})))});
 // No source text, binding, meaning document or expected score enters this process.
 const result=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{encoding:'utf8',maxBuffer:2000000}));
 assert.deepEqual(result.meaning,expected);assert.equal(result.meaning.relation,document.relation);assert.equal(result.meaning.outcome.injury_commitment,'not_entailed');assert.equal(result.meaning.runtime_state,document.runtime_state);
 assert.deepEqual(result.meaning.outcome.experiencer.phonemes,document.outcome.experiencer.name.phonemes);
 cases.push({phrase,meaning:result.meaning,wav,checksum:result.checksum});
}
const sample=cases[1],channels=JSON.parse(execFileSync('python3',['tools/acoustic_channel_probe.py',sample.wav],{encoding:'utf8',maxBuffer:10000000}));
const channelResults=[];
for(const channel of channels){
 const file=sample.wav.replace(/\.wav$/,`-${channel.channel}.wav`);
 if(channel.channel==='dropout'){
  assert.equal(channel.accepted,false);assert.throws(()=>execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',file,'--allow-draft'],{stdio:'pipe'}));channelResults.push({channel:channel.channel,status:'rejected'});
 }else{
  assert.equal(channel.accepted,true);const decoded=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',file,'--allow-draft'],{encoding:'utf8',maxBuffer:2000000}));assert.deepEqual(decoded.meaning,sample.meaning);channelResults.push({channel:channel.channel,status:'meaning_recovered'});
 }
}
fs.writeFileSync(new URL('../reports/pain_stimulus_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'Three authored clean synthetic WAVs decoded with only waveform path and draft opt-in. One negated-expectation question also tested under simulated gain/noise, speed change, weak echo and dropout; no physical recordings.',physical_recordings:0,cases,channelResults},null,2)+'\n');
console.log('PASS three blind pain-stimulus WAV recoveries distinguish causation, negated expectation question and disposition with separate stimulus/experiencer references.');
