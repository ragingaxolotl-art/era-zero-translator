import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composePainMeaning} from '../pages/pain_meaning.mjs';
import {midiFromPain,decodePainMidi} from '../pages/pain_music.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-pain-audio-')),cases=[];
for(const [phrase,options] of [['Was Nora not in bodily pain? [2]',{}],['They are in bodily pain. [0]',{bindings:{ref0:{referent:'Nora',number:'singular'}}}]]){
 const document=await composePainMeaning(phrase,{allowDraft:true,...options}),bytes=await midiFromPain(document,authority,{allowDraft:true});
 const expected=decodePainMidi(bytes,authority.atoms,{allowDraft:true}),wav=path.join(directory,`pain-${cases.length}.wav`);
 execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{input:JSON.stringify(notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick})))});
 // No source text, binding, meaning document or expected score enters this process.
 const result=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{encoding:'utf8',maxBuffer:2000000}));
 assert.deepEqual(result.meaning,expected);assert.equal(result.meaning.predicate,'felt_bodily_pain');assert.equal(result.meaning.injury_commitment,'not_entailed');
 assert.deepEqual(result.meaning.experiencer.phonemes,document.experiencer.name.phonemes);
 cases.push({phrase,meaning:result.meaning,wav,checksum:result.checksum});
}
fs.writeFileSync(new URL('../reports/pain_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'Two authored clean synthetic WAVs decoded with only waveform path and draft opt-in. No physical recordings or channel perturbations.',physical_recordings:0,cases},null,2)+'\n');
console.log('PASS two blind pain WAV recoveries preserve reference, past negation/question and independent runtime 0/2.');
