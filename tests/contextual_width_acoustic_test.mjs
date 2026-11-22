// Synthetic monophonic transport; no browser-chord or microphone claim.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {encodeName} from '../pages/names.mjs';
const root=fileURLToPath(new URL('..',import.meta.url)),authority=JSON.parse(fs.readFileSync(path.join(root,'pages/data/index.json')));
const template=JSON.parse(fs.readFileSync(path.join(root,'pages',authority.resolution_files['MAT:010']))).variants['assertion:1'];
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'era-width-wav-'));
try{
  for(const [i,[text,norm,bearer,state,scopes]] of [
    ['It is possible that the gate is wide. [0]','wide','gate',0,[{operator:'modality',mode:'possible'}]],
    ['The board was not narrow. [2]','narrow','board',2,[{operator:'time',relation:'before_speech'},{operator:'negation'}]]
  ].entries()){
    const r=await composeNamedSentence(text,template,{interpretation:'width_standard',standard:{kind:'contextual',dimension:'physical_width'}});
    const wav=path.join(dir,i+'.wav'),notes=notesFromMidi(midiFromFormal(r.formal)).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick}));
    execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{cwd:root,input:JSON.stringify(notes)});
    // Independent process receives the WAV path and public language, no source text or IR.
    const d=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{cwd:root,encoding:'utf8'})).meaning;
    assert.equal(d.dimension,'physical_width');assert.equal(d.standard.norm,norm);assert.equal(d.runtime_state,state);
    assert.deepEqual(d.scopes,scopes);assert.deepEqual(d.bearer.phonemes,(await encodeName(bearer)).phonemes);
  }
  console.log('PASS two clean synthetic WAVs independently recovered width, contextual norm, bearer, scopes and runtime. No physical recordings tested.');
}finally{for(const name of fs.readdirSync(dir))fs.unlinkSync(path.join(dir,name));fs.rmdirSync(dir);}
