import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composeDesiredOwnership} from '../pages/desired_ownership.mjs';
import {midiFromDesiredOwnership,decodeDesiredOwnershipMidi} from '../pages/desired_ownership_music.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';

const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),phrase="Didn't Nora want Eli to not own this tea [0]? [2]";
const composed=await composeDesiredOwnership(phrase,{allowDraft:true,framework:'"Harbor charter"'}),bytes=await midiFromDesiredOwnership(composed,authority,{allowDraft:true}),expected=decodeDesiredOwnershipMidi(bytes,authority.atoms,{allowDraft:true});
const directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-desired-ownership-')),wav=path.join(directory,'question.wav');
execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{input:JSON.stringify(notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick})))});
// The decoder gets only recorded samples and shared vocabulary, not source bindings.
const recovered=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{encoding:'utf8',maxBuffer:3000000}));
assert.deepEqual(recovered.meaning,expected);assert.equal(recovered.meaning.speech_act,'question');assert.equal(recovered.meaning.runtime_state,2);assert.deepEqual(recovered.meaning.scopes,[{operator:'time',relation:'before_speech'},{operator:'negation'}]);assert.deepEqual(recovered.meaning.content.framework.phonemes,composed.content.framework.name.phonemes);assert.equal(recovered.meaning.content.physical_custody,'not_entailed');
assert.equal(recovered.meaning.content_status,'intensional');assert.equal(recovered.meaning.content.runtime_state,0);assert.deepEqual(recovered.meaning.content.scopes,[{operator:'negation'}]);assert.notDeepEqual(recovered.meaning.holder,recovered.meaning.content.owner);
fs.writeFileSync(new URL('../reports/desired_ownership_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'One authored clean synthetic WAV; no original text, bindings or expected notes supplied to decoder. No physical recording or channel perturbation.',physical_recordings:0,phrase,wav,meaning:recovered.meaning,checksum:recovered.checksum},null,2)+'\n');
console.log('PASS blind desired-ownership WAV recovers distinct holder/owner, nested framework, separate negations and runtime 2/0.');
