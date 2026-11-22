// Optional synthetic transport check, not a microphone or browser-voice claim.
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
const root=fileURLToPath(new URL('..',import.meta.url));
const authority=JSON.parse(fs.readFileSync(path.join(root,'pages/data/index.json')));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'era-physical-wav-'));
try{
  for(const [i,[text,verb,scopes,state]] of [
    ['Nora might not drop the full box.','drop',['modality_possible','negation'],2],
    ['The empty bottle fell.','fall',['time_before_speech'],0]
  ].entries()){
    const plan=storyReading(text+' ['+state+']',authority);assert(plan?.events,text);
    const {midi}=await scoreStory(plan,authority),wav=path.join(dir,i+'.wav');
    const notes=notesFromMidi(midi).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick}));
    execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{cwd:root,input:JSON.stringify(notes)});
    // Isolated decoder process gets the WAV and public dictionary only.
    const heard=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{cwd:root,encoding:'utf8'}));
    assert.equal(heard.meaning.events[0].predicate,storyWords.find(w=>w.word===verb).id);
    assert.equal(heard.meaning.runtime_state,state);assert.deepEqual(heard.meaning.events[0].scopes,scopes);
    const target=heard.meaning.events[0].arguments.at(-1);
    assert.deepEqual(target.properties,[storyWords.find(w=>w.word===(i?'empty':'full')).id]);
  }
  console.log('PASS two synthetic WAVs independently recovered nested physical meanings, adjective attachment, scope and runtime. No microphone recordings tested.');
}finally{for(const name of fs.readdirSync(dir))fs.unlinkSync(path.join(dir,name));fs.rmdirSync(dir);}
