import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composePainComparisonSentence} from '../pages/pain_comparison_sentences.mjs';
import {midiFromPainComparison,decodePainComparisonMidi} from '../pages/pain_comparison_music.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),directory=fs.mkdtempSync(path.join(os.tmpdir(),'era-pain-comparison-')),cases=[];
for(const [phrase,interpretation] of [['Is "Treatment A" not more painful for Nora than "Treatment B"? [2]','expected_outcome'],['"Treatment B" is less painful for Nora than "Treatment A". [0]','disposition']]){
 const document=await composePainComparisonSentence(phrase,{allowDraft:true,interpretation,context:'this session'}),bytes=await midiFromPainComparison(document,authority,{allowDraft:true}),expected=decodePainComparisonMidi(bytes,authority.atoms,{allowDraft:true});
 const wav=path.join(directory,`comparison-${cases.length}.wav`);
 execFileSync('python3',['tools/acoustic_transport.py','synth',wav],{input:JSON.stringify(notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick})))});
 // Only the waveform path and draft opt-in enter this independent decoder process.
 const result=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',wav,'--allow-draft'],{encoding:'utf8',maxBuffer:3000000}));
 assert.deepEqual(result.meaning,expected);assert.equal(result.meaning.relation,document.relation);assert.equal(result.meaning.scale,'ordinal_no_numeric_score');
 cases.push({phrase,interpretation,wav,meaning:result.meaning,checksum:result.checksum});
}
fs.writeFileSync(new URL('../reports/pain_comparison_acoustic_probe.json',import.meta.url),JSON.stringify({status:'PASS',scope:'Two authored clean synthetic WAVs; no original text, selected context, semantic document or expected notes supplied to decoder. No physical recordings or channel perturbations.',physical_recordings:0,cases},null,2)+'\n');
console.log('PASS two blind comparison WAV recoveries preserve ordered stimuli, shared context, relation mode, ordinal direction, scope and runtime.');
