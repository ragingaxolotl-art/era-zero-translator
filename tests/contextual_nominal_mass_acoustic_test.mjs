import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeDestinationCarryingMidi} from '../pages/carrying_decoder.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {execFileSync} from 'node:child_process';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-contextual-noun-')),cases=[];
for(const [adjective,state,negative] of [['heavy',0,false],['light',2,true]]){
 const phrase=`Pip is ${negative?'not ':''}carrying the ${adjective} box to Ada [${state}].`;
 const composed=await composeNamedSentence(phrase,{authority},{destination:'spatial',interpretation:'mass_standard',standard:{kind:'contextual',dimension:'mass'}});
 const bytes=midiFromFormal(composed.formal),expected=decodeDestinationCarryingMidi(bytes,authority.atoms);
 const wav=path.join(directory,`${adjective}.wav`);
 const notes=notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick}));
 execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{input:JSON.stringify(notes)});
 // Separate process receives only waveform path. Expected meaning stays here.
 const recovered=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav],{encoding:'utf8',maxBuffer:2000000}));
 assert.deepEqual(recovered.meaning,expected);
 assert.equal(recovered.meaning.participants.load.property.norm,adjective);
 assert.equal(recovered.meaning.runtime_state,state);
 assert.equal(recovered.meaning.scopes.some(s=>s.operator==='negation'),negative);
 cases.push({phrase,wav,meaning:recovered.meaning,checksum:recovered.checksum});
}
fs.writeFileSync(new URL('../reports/contextual_nominal_mass_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'Two authored clean synthetic WAVs, decoded by shared dispatch with no text, source IR or expected notes. No physical recording or channel perturbation.',physical_recordings:0,cases},null,2)+'\n');
console.log('PASS two blind synthetic WAV recoveries preserve contextual noun mass, participant roles, negation and runtime.');
