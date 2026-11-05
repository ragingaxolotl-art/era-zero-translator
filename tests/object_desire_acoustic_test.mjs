import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composeObjectDesire} from '../pages/object_desire.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../reviews/foundation_extension_candidates.json',import.meta.url))).records,directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-object-desire-')),cases=[];
const load=id=>!authority.resolution_files[id]?{authority}:({...JSON.parse(fs.readFileSync(new URL('../pages/'+authority.resolution_files[id],import.meta.url))).variants['assertion:1'],authority});
for(const [phrase,desiredProposition] of [['Nora wants tea. [0]','Eli has physical custody of the tea.'],['Does Nora not want the tea? [2]','Eli does not have physical custody of the tea.']]){
 const document=await composeObjectDesire(phrase,authority,records,load,{allowDraft:true,desiredProposition}),bytes=midiFromFormal(document.formal),expected=await decodeFoundationSentenceMidi(bytes,authority.atoms,records,{allowDraft:true});
 const wav=path.join(directory,`desire-${cases.length}.wav`);
 execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{input:JSON.stringify(notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick})))});
 // Only the waveform path and draft opt-in enter the independent decoder process.
 const result=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{encoding:'utf8',maxBuffer:3000000}));
 assert.deepEqual(result.meaning,expected);
 const content=result.meaning.meaning.arguments.content;assert.equal(content.content_status,'intensional');assert.equal(content.proposition.predicate.name,'practical_physical_custody');assert.equal(content.proposition.meaning.ownership_asserted,false);
 assert.deepEqual(content.proposition.scopes,cases.length?[{operator:'negation'}]:[]);assert.deepEqual(result.meaning.meaning.scopes,cases.length?[{operator:'negation'}]:[]);
 cases.push({phrase,desiredProposition,wav,meaning:result.meaning,checksum:result.checksum});
}
fs.writeFileSync(new URL('../reports/object_desire_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'Two authored clean synthetic WAVs. Decoder receives neither original text nor clarification, semantic document or expected notes. No physical recordings or channel perturbations.',physical_recordings:0,cases},null,2)+'\n');
console.log('PASS two blind object-desire WAV recoveries preserve intensional custody, independent inner/outer negation, participants, question and runtime.');
