import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const root=new URL('..',import.meta.url),index=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const template=JSON.parse(fs.readFileSync(new URL('pages/'+index.resolution_files['MAT:010'],root))).variants['assertion:1'];
const cases=[['exactly',undefined],['greater than','greater_than'],['less than','less_than'],['at least','at_least'],['at most','at_most'],['not exactly','not_equal']];
const results=[];
for(const [words,comparison] of cases){
 const input=`The box has a mass of ${words} 5 kilograms.`;
 assert.equal(parseNamedSentence(input).measurement.comparison,comparison);
 const result=await composeNamedSentence(input,template);results.push(result);
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','f=EraZeroRenderer.render(JSON.parse(STDIN.read));puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})'],{cwd:root,input:JSON.stringify(result.semantic_ir),encoding:'utf8'}));
 assert.deepEqual(result.formal,ruby.formal);
 assert.deepEqual(Buffer.from(midiFromFormal(result.formal)),Buffer.from(ruby.midi,'base64'));
 const frames=scheduledLexicalEvents(result.formal).filter(e=>e.marker?.startsWith('measure_compare_')).map(e=>e.marker);
 assert.deepEqual(frames,comparison?[`measure_compare_${comparison}_open`,`measure_compare_${comparison}_close`]:[]);
 assert.equal(result.semantic_ir.nodes.find(n=>n.node_id==='p').runtime_state.code,1);
}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,6);
assert.deepEqual((await composeNamedSentence('The box has a mass greater than 5000 grams.',template)).formal,results[1].formal);
assert.deepEqual((await composeNamedSentence('The box has a mass of 5 kilograms.',template)).formal,results[0].formal);
for(const comparison of ['approximately','equal',null,2]){
 const formal=structuredClone(results[0].formal);formal.semantic_ir.nodes.find(n=>n.kind==='measurement').comparison=comparison;
 assert.throws(()=>scheduledLexicalEvents(formal),/measurement comparison/);
 const errors=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_semantic_validation','-e','puts JSON.generate(EraZeroSemanticValidation.validate(JSON.parse(STDIN.read)))'],{cwd:root,input:JSON.stringify(formal.semantic_ir),encoding:'utf8'}));
 assert(errors.includes('invalid_measurement_comparison'));
}
assert.equal(parseNamedSentence('The box has a mass approximately 5 kilograms.'),null);
console.log('Six scalar comparison meanings produce distinct music with Ruby/browser formal and MIDI parity; exact and compatible-unit paraphrases normalize, and unknown comparisons fail validation.');
