import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {execFileSync} from 'node:child_process';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const records=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_preview_candidates.json',import.meta.url))).records;
const directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-preference-noun-')),cases=[];
for(const [adjective,state,negative] of [['heavy',0,false],['light',2,true]]){
 const other=adjective==='heavy'?'light':'heavy';
 const phrase=`Does Nora ${negative?'not ':''}prefer the ${adjective} box to the ${other} box? [${state}]`;
 const composed=await composeFoundationSentence(phrase,authority,records,()=>{throw new Error('Unexpected embedded clause');},{allowDraft:true,contextualMassModifiers:true});
 const bytes=midiFromFormal(composed.formal),expected=await decodeFoundationSentenceMidi(bytes,authority.atoms,records,{allowDraft:true});
 const wav=path.join(directory,`${adjective}.wav`);
 const notes=notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick}));
 execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{input:JSON.stringify(notes)});
 // Separate process receives only waveform path. Expected meaning stays here.
 const recovered=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{encoding:'utf8',maxBuffer:2000000}));
 assert.deepEqual(recovered.meaning,expected);
 assert.equal(recovered.meaning.meaning.arguments.target.reference.property.norm,adjective);
 assert.equal(recovered.meaning.meaning.runtime_state,state);
 assert.equal(recovered.meaning.meaning.scopes.some(s=>s.operator==='negation'),negative);
 assert.equal(recovered.meaning.speech_act,'question');
 const args=recovered.meaning.meaning.arguments;
 assert.notEqual(args.target.reference.instance_code,args.comparison_standard.reference.instance_code);
 assert.equal(args.comparison_standard.reference.property.norm,other);
 cases.push({phrase,wav,meaning:recovered.meaning,checksum:recovered.checksum});
}
fs.writeFileSync(new URL('../reports/preference_nominal_mass_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'Two authored clean synthetic WAVs, decoded by shared dispatch with no text, source IR or expected notes. No physical recording or channel perturbation.',physical_recordings:0,cases},null,2)+'\n');
console.log('PASS two blind synthetic WAV recoveries preserve modified preference direction, separate noun instances, question, negation and runtime.');
