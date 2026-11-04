import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composeUnderstandingContent} from '../pages/understanding_content.mjs';
import {midiFromUnderstanding,decodeUnderstandingMidi} from '../pages/understanding_music.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),dir=fs.mkdtempSync(path.join(os.tmpdir(),'era-understanding-audio-')),cases=[];
for(const [kind,phrase] of [['communicated_content','Eli understands Nora [0].'],['reasons','Eli did not understand Nora [1].'],['perspective','Does Eli understand Nora [2]?']]){
 const document=await composeUnderstandingContent(phrase,{allowDraft:true,interpretation:kind}),bytes=await midiFromUnderstanding(document,authority,{allowDraft:true}),expected=await decodeUnderstandingMidi(bytes,authority.atoms,{allowDraft:true});
 const notes=notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick})),file=path.join(dir,kind+'.wav');
 execFileSync('python3',['tools/acoustic_transport.py','synth',file],{input:JSON.stringify(notes)});
 const decoded=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',file,'--allow-draft'],{encoding:'utf8'}));
 assert.deepEqual(decoded.meaning,expected);
 cases.push({phrase,reading:kind,status:'exact_wav_only_meaning_recovery',meaning:decoded.meaning,wav:file});
}
fs.writeFileSync(new URL('../reports/understanding_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'Three authored clean synthetic WAV cases; no channel simulation or physical microphone recording in this probe',original_text_or_ir_supplied_to_decoder:false,cases},null,2)+'\n');
console.log('PASS three understanding readings recovered from WAV alone with runtime, negation/past and question distinctions.');
