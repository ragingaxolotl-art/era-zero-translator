import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {decodeCustodyAcquisitionMidi} from '../pages/custody_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-acquisition-viewpoint-')),cases=[];
for(const [phrase,viewpoint] of [
 ['It is possible that Nora acquires physical custody of this tea. [2]','ongoing'],
 ['It is not the case that it is possible that Nora acquires physical custody of this tea. [0]','bounded']
]){
 const document=await composeNamedSentence(phrase,{authority},{viewpoint}),bytes=midiFromFormal(document.formal),expected=decodeCustodyAcquisitionMidi(bytes,authority.atoms),wav=path.join(directory,`case-${cases.length}.wav`);
 execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{input:JSON.stringify(notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick})))});
 // Only samples and shared vocabulary enter the decoder; no expected meaning.
 const r=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav],{encoding:'utf8',maxBuffer:3000000}));
 assert.deepEqual(r.meaning,expected);assert(!r.meaning.scopes.some(s=>s.operator==='time'));assert.equal(r.meaning.scopes.at(-1).aspect,viewpoint);assert.equal(r.meaning.participants.object.reference_mode,'proximal_nominal');assert.equal(r.meaning.meaning.ownership_asserted,false);cases.push({phrase,viewpoint,wav,meaning:r.meaning,checksum:r.checksum});
}
fs.writeFileSync(new URL('../reports/acquisition_viewpoint_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'Two authored clean synthetic WAVs. No original text, viewpoint or semantic metadata supplied to decoder. Not availability translation or physical recording validation.',physical_recordings:0,cases},null,2)+'\n');
console.log('PASS two blind modal-acquisition WAVs preserve viewpoint, possibility/negation, references and runtime without invented past time.');
