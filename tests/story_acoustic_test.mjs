// Optional clean-WAV transport check. The decoder subprocess receives only its WAV path and the shared dictionary.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {execFileSync} from 'node:child_process';
import {scoreSongText} from '../pages/song_lines.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const root=fileURLToPath(new URL('..',import.meta.url));
const authority=JSON.parse(fs.readFileSync(path.join(root,'pages/data/index.json')));
const directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-story-wav-'));
try{
 for(const [index,text] of ['Pip found a cracked bell. They repaired it before Ada arrived.','Not all the bells rang.','None of the bells rang.'].entries()){
  const scored=await scoreSongText(text,authority);
  const samples=notesFromMidi(scored.midi).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick}));
  const wav=path.join(directory,index+'.wav');
  execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{cwd:root,input:JSON.stringify(samples)});
  const output=execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{cwd:root,encoding:'utf8'});
  assert.deepEqual(JSON.parse(output).meaning,scored.meaning,text);
 }
 console.log('PASS three clean synthesized WAVs recovered the linked events, noun properties and quantifier scopes.');
}finally{for(const name of fs.readdirSync(directory))fs.unlinkSync(path.join(directory,name));fs.rmdirSync(directory);}
