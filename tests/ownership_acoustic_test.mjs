import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composeOwnershipSentence} from '../pages/ownership_sentences.mjs';
import {midiFromOwnership,decodeOwnershipMidi} from '../pages/ownership_music.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';

const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),phrase="Didn't Nora own this tea? [2]";
const composed=await composeOwnershipSentence(phrase,{allowDraft:true,framework:'"Harbor charter"'}),bytes=await midiFromOwnership(composed,authority,{allowDraft:true}),expected=decodeOwnershipMidi(bytes,authority.atoms,{allowDraft:true});
const directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-ownership-')),wav=path.join(directory,'question.wav');
execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{input:JSON.stringify(notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick})))});
// The decoder gets only recorded samples and shared vocabulary, not source bindings.
const recovered=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{encoding:'utf8',maxBuffer:3000000}));
assert.deepEqual(recovered.meaning,expected);assert.equal(recovered.meaning.speech_act,'question');assert.equal(recovered.meaning.runtime_state,2);assert.deepEqual(recovered.meaning.scopes,[{operator:'time',relation:'before_speech'},{operator:'negation'}]);assert.deepEqual(recovered.meaning.framework.phonemes,composed.framework.name.phonemes);assert.equal(recovered.meaning.physical_custody,'not_entailed');
fs.writeFileSync(new URL('../reports/ownership_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'One authored clean synthetic WAV; no original text, bindings or expected notes supplied to decoder. No physical recording or channel perturbation.',physical_recordings:0,phrase,wav,meaning:recovered.meaning,checksum:recovered.checksum},null,2)+'\n');
console.log('PASS blind ownership WAV recovers owner, object and framework with past negation, question and runtime 2.');
