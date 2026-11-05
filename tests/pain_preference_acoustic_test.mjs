import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composePainPreference} from '../pages/pain_preference.mjs';
import {midiFromPainPreference,decodePainPreferenceMidi} from '../pages/pain_preference_music.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-pain-preference-')),cases=[];
for(const [phrase,interpretation] of [['Nora prefers the painful treatment to the more painful treatment. [0]','expected_outcome'],['Does Nora not prefer the more painful treatment to the painful treatment? [2]','disposition']]){
 const document=await composePainPreference(phrase,{allowDraft:true,experiencer:'Eli',interpretation,context:'this session',comparisonTarget:'other_alternative'}),bytes=await midiFromPainPreference(document,authority,{allowDraft:true}),expected=decodePainPreferenceMidi(bytes,authority.atoms,{allowDraft:true});
 const wav=path.join(directory,`preference-${cases.length}.wav`);
 execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{input:JSON.stringify(notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick})))});
 // Decoder gets only the WAV path and draft permission, not context or sentence.
 const result=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{encoding:'utf8',maxBuffer:3000000}));
 assert.deepEqual(result.meaning,expected);assert.equal(result.meaning.more_painful_role,document.more_painful_role);assert.equal(result.meaning.restriction_scope,document.restriction_scope);assert.deepEqual(result.meaning.holder.phonemes,document.holder.name.phonemes);assert.deepEqual(result.meaning.pain_comparison.left.outcome.experiencer.phonemes,document.pain_comparison.left.outcome.experiencer.name.phonemes);
 cases.push({phrase,interpretation,wav,meaning:result.meaning,checksum:result.checksum});
}
fs.writeFileSync(new URL('../reports/pain_preference_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'Two authored clean synthetic WAVs. Decoder receives no original text, semantic document, selected context, experiencer or expected notes. No physical recordings or channel perturbations.',physical_recordings:0,cases},null,2)+'\n');
console.log('PASS two blind preference WAV recoveries retain distinct participants, alternative identity, description binding, matrix scope, question and runtime.');
