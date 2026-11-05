import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composePronounSentence} from '../pages/pronouns.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {decodeCustodyDeliveryMidi} from '../pages/delivery_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),phrase='Were they not delivering this tea to them? [2]';
const composed=await composePronounSentence(phrase,()=>({authority}),{ref0:{referent:'Nora',number:'singular'},ref1:{referent:'Eli',number:'singular'}},{destination:'custody_delivery'}),bytes=midiFromFormal(composed.formal),expected=decodeCustodyDeliveryMidi(bytes,authority.atoms);
const directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-delivery-question-')),wav=path.join(directory,'question.wav');
execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{input:JSON.stringify(notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick})))});
// The decoder gets only recorded samples and shared vocabulary, not source bindings.
const recovered=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav],{encoding:'utf8',maxBuffer:3000000}));
assert.deepEqual(recovered.meaning,expected);assert.equal(recovered.meaning.speech_act,'question');assert.equal(recovered.meaning.runtime_state,2);assert.deepEqual(recovered.meaning.scopes,[{operator:'time',relation:'before_speech'},{operator:'negation'},{operator:'aspect',aspect:'ongoing'}]);assert.notDeepEqual(recovered.meaning.participants.carrier,recovered.meaning.participants.recipient);
fs.writeFileSync(new URL('../reports/delivery_question_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'One authored clean synthetic WAV; no original text, bindings or expected notes supplied to decoder. No physical recording or channel perturbation.',physical_recordings:0,phrase,wav,meaning:recovered.meaning,checksum:recovered.checksum},null,2)+'\n');
console.log('PASS blind delivery-question WAV preserves explicitly bound neutral participants, past negated ongoing scope, question and runtime 2.');
