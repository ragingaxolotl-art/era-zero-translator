import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composeDesiredDrinking} from '../pages/desired_drinking.mjs';
import {midiFromDesiredDrinking,decodeDesiredDrinkingMidi} from '../pages/desired_drinking_music.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-desired-drinking-')),cases=[];
const probes=[
 {phrase:'Nora wants to drink tea. [0]',materialReading:'kind',viewpoint:'bounded',binding:'same_as_desire_holder',outer:0,inner:1,outerNeg:false,innerNeg:false},
 {phrase:'Does Nora not want Eli to not drink this tea [0]? [2]',materialReading:'contextual_portion',viewpoint:'ongoing',binding:'explicit_content_subject',outer:2,inner:0,outerNeg:true,innerNeg:true}
];
for(const probe of probes){
 const d=await composeDesiredDrinking(probe.phrase,{allowDraft:true,interpretation:'literal_drinking',materialReading:probe.materialReading,viewpoint:probe.viewpoint}),bytes=await midiFromDesiredDrinking(d,authority,{allowDraft:true}),expected=decodeDesiredDrinkingMidi(bytes,authority.atoms,{allowDraft:true}),wav=path.join(directory,`desire-${cases.length}.wav`);
 execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{input:JSON.stringify(notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick})))});
 // The independent decoder receives only WAV path and draft permission.
 const result=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{encoding:'utf8',maxBuffer:3000000})),r=result.meaning;
 assert.deepEqual(r,expected);assert.equal(r.content_status,'intensional');assert.equal(r.outcome_commitment,'desired_not_asserted');assert.equal(r.subject_binding,probe.binding);assert.equal(r.runtime_state,probe.outer);assert.equal(r.content.runtime_state,probe.inner);assert.deepEqual(r.scopes,probe.outerNeg?[{operator:'negation'}]:[]);assert.deepEqual(r.content.scopes,probe.innerNeg?[{operator:'negation'}]:[]);assert.deepEqual(r.holder.phonemes,d.holder.name.phonemes);assert.deepEqual(r.content.drinker.phonemes,d.content.drinker.name.phonemes);
 cases.push({...probe,wav,meaning:r,checksum:result.checksum});
}
fs.writeFileSync(new URL('../reports/desired_drinking_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'Two authored clean synthetic WAVs. No original English, semantic document, interpretation choices or expected notes enter the decoder. No physical recordings or channel perturbations.',physical_recordings:0,cases},null,2)+'\n');
console.log('PASS two blind desired-drinking WAV recoveries retain controlled/explicit drinker, intensional status and separate negation/runtime.');
