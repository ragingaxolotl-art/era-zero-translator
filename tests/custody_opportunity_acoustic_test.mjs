import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composeAvailabilitySentence} from '../pages/availability_sentences.mjs';
import {midiFromCustodyOpportunity,decodeCustodyOpportunityMidi} from '../pages/custody_opportunity_music.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';

const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),phrase="Wasn't this tea available to Nora? [2]";
const composed=await composeAvailabilitySentence(phrase,{allowDraft:true,interpretation:'practical_custody_opportunity',accessContext:'"Pantry access"'}),bytes=await midiFromCustodyOpportunity(composed,authority,{allowDraft:true}),expected=decodeCustodyOpportunityMidi(bytes,authority.atoms,{allowDraft:true});
const directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-custody-opportunity-')),wav=path.join(directory,'question.wav');
execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{input:JSON.stringify(notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick})))});
// The decoder gets only recorded samples and shared vocabulary, not source bindings.
const recovered=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{encoding:'utf8',maxBuffer:3000000}));
assert.deepEqual(recovered.meaning,expected);assert.equal(recovered.meaning.speech_act,'question');assert.equal(recovered.meaning.runtime_state,2);assert.deepEqual(recovered.meaning.scopes,[{operator:'time',relation:'before_speech'},{operator:'negation'}]);assert.deepEqual(recovered.meaning.access_context.phonemes,composed.access_context.name.phonemes);assert.equal(recovered.meaning.current_custody,'not_entailed');
fs.writeFileSync(new URL('../reports/custody_opportunity_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'One authored clean synthetic WAV; no original text, bindings or expected notes supplied to decoder. No physical recording or channel perturbation.',physical_recordings:0,phrase,wav,meaning:recovered.meaning,checksum:recovered.checksum},null,2)+'\n');
console.log('PASS blind custody-opportunity WAV recovers holder, resource and access context with past negation, question and runtime 2.');
