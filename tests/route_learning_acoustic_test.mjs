import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composeRouteLearning,ROUTE_LEARNING_READINGS} from '../pages/route_learning.mjs';
import {midiFromRouteLearning,decodeRouteLearningMidi} from '../pages/route_learning_music.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-route-learning-')),cases=[];
for(const [i,reading] of Object.keys(ROUTE_LEARNING_READINGS).entries()){
 const phrase=['Nora learned the route.','Nora did not learn this route.','Did Nora learn that route?'][i];
 const document=await composeRouteLearning(phrase+` [${i}]`,{allowDraft:true,interpretation:reading,resultRuntime:2-i});
 const bytes=await midiFromRouteLearning(document,authority,{allowDraft:true});
 const expected=await decodeRouteLearningMidi(bytes,authority.atoms,{allowDraft:true});
 const file=path.join(directory,reading+'.wav');
 const notes=notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick}));
 execFileSync('python3',['tools/acoustic_transport.py','synth',file],{input:JSON.stringify(notes)});
 // Only the WAV and draft opt-in reach this independent process, not the
 // phrase, selected reading, source meaning, expected notes or predicate hint.
 const recovered=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',file,'--allow-draft'],{encoding:'utf8'}));
 assert.deepEqual(recovered.meaning,expected);
 cases.push({phrase,reading,wav:file,meaning:recovered.meaning});
}
fs.writeFileSync(new URL('../reports/route_learning_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'Three authored clean synthetic WAVs; no physical recordings or simulated channel tests',cases},null,2)+'\n');
console.log('PASS three route-learning readings through blind WAV recovery, including negation, questions, reference modes and independent runtime trits.');
