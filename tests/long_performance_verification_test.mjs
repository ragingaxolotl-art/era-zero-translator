import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeSentenceSequence} from '../pages/sentences.mjs';
import {visemePlanFromFormal} from '../pages/visemes.mjs';
import {verifyPerformanceNotes,verifyPerformanceMidi,midiFromPerformance} from '../pages/performance_codec.mjs';
const data=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const load=async target=>JSON.parse(fs.readFileSync(new URL(`../pages/${data.resolution_files[target]}`,import.meta.url))).variants['assertion:1'];
const sentence=Array.from({length:32},(_,i)=>i%2?'Ada cares for Pip':'Pip cares for Ada').join(', then ')+'.';
const {formal}=await composeSentenceSequence(sentence,load);
assert.equal(formal.performance.lexical_events.length,96);
const registry=data.recognition_audio;
for(const [mode,status] of [['strict','valid_strict_absence'],['recognition','valid_checksum']]){
  const result=verifyPerformanceMidi(formal,registry,midiFromPerformance(formal,registry,mode));
  assert.equal(result.status,status);
  assert.equal(result.targets.length,96);
  assert.equal(result.first_mismatch,null);
}
const strict=visemePlanFromFormal(formal,{mode:'strict',recognitionRegistry:registry});
const recognized=visemePlanFromFormal(formal,{mode:'recognition',recognitionRegistry:registry});
const mixed=[];
for(let i=0;i<96;i++)mixed.push(...(i%2?recognized:strict).cues.filter(cue=>cue.event_index===i).map(cue=>cue.note));
mixed.push(...strict.cues.filter(cue=>cue.section==='sentence_contour').map(cue=>cue.note));
assert.equal(verifyPerformanceNotes(formal,registry,mixed).status,'valid_checksum');
const corrupted=mixed.slice();corrupted[10]=(corrupted[10]+1)%128;
assert.equal(verifyPerformanceNotes(formal,registry,corrupted).status,'checksum_or_path_mismatch');
assert.equal(verifyPerformanceNotes(formal,registry,mixed.slice(0,-1)).status,'checksum_or_path_mismatch');
assert.equal(verifyPerformanceNotes(formal,registry,[...mixed,127]).status,'checksum_or_path_mismatch');
assert.equal(verifyPerformanceNotes(formal,registry,[]).status,'checksum_or_path_mismatch');
console.log('Long performance verification: 96 events accept strict, recognition and mixed paths; changed, missing, extra and empty notes are rejected.');
