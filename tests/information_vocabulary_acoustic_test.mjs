// Synthetic mono transport only; not browser chord audio or microphone evidence.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {execFileSync} from 'node:child_process';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory} from '../pages/story_music.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {storyWords} from '../pages/story_words.mjs';
import {encodeName} from '../pages/names.mjs';
const root=fileURLToPath(new URL('..',import.meta.url));
const authority=JSON.parse(fs.readFileSync(path.join(root,'pages/data/index.json')));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'era-information-vocabulary-wav-'));
try{
  for(const [i,[text,verb,target,scopes,state,answers]] of [
    ['Nora might not copy the file.','copy','file',['modality_possible','negation'],0,{}],
    ['Nora recalled Mira.','recall','Mira',['time_before_speech'],2,{retrieval0:'retrieval'}]
  ].entries()){
    const plan=storyReading(text+' ['+state+']',authority,{answers});assert(plan?.events,text);
    const {midi}=await scoreStory(plan,authority),wav=path.join(dir,i+'.wav');
    const notes=notesFromMidi(midi).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick}));
    execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{cwd:root,input:JSON.stringify(notes)});
    // Only the WAV and public language definitions are available to the decoder.
    const heard=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{cwd:root,encoding:'utf8'})).meaning;
    assert.equal(heard.events[0].predicate,storyWords.find(w=>w.word===verb).id);
    assert.equal(heard.runtime_state,state);assert.deepEqual(heard.events[0].scopes,scopes);
    assert.deepEqual(heard.events[0].arguments.map(a=>[a.role,a.entity]),[[verb==='copy'?'actor':'experiencer',0],['target',1]]);
    assert.deepEqual(heard.entities[0].identity.phonemes,(await encodeName('Nora')).phonemes);
    assert.deepEqual(heard.entities[1].identity.phonemes,(await encodeName(target)).phonemes);
  }
  console.log('PASS two synthetic WAVs independently recovered copying and mental retrieval, participants, scopes and runtime. No microphone recordings tested.');
}finally{for(const name of fs.readdirSync(dir))fs.unlinkSync(path.join(dir,name));fs.rmdirSync(dir);}
