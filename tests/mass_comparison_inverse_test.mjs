import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeMassComparisonMidi} from '../pages/mass_comparison_decoder.mjs';
const root=new URL('..',import.meta.url),index=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const load=id=>JSON.parse(fs.readFileSync(new URL('pages/'+index.resolution_files[id],root))).variants['assertion:1'];
const relations=[['the same mass as','equal'],['more mass than','greater_than'],['less mass than','less_than'],['at least as much mass as','at_least'],['at most as much mass as','at_most'],['a different mass from','not_equal']];
const labels={box:['B','AA','K','S'],radio:['R','AE','D','IH','AA']};
let count=0;
for(const [words,relation] of relations)for(const state of [0,1,2])for(const [left,right] of [['box','radio'],['radio','box']]){
 const {formal}=await composeNamedSentence(`The ${left} has ${words} the ${right} [${state}].`,load('MAT:010'));
 const bytes=midiFromFormal(formal),decoded=decodeMassComparisonMidi(bytes);
 assert.equal(decoded.dimension,'mass');assert.equal(decoded.relation,relation);assert.equal(decoded.runtime_state,state);assert.equal(decoded.material_root,'MAT:010');assert.equal(decoded.speech_act,'assertion');
 assert.deepEqual(decoded.participants.bearer,{kind:'phonemic',reference_mode:'definite_nominal',phonemes:labels[left]});
 assert.deepEqual(decoded.participants.comparison_standard,{kind:'phonemic',reference_mode:'definite_nominal',phonemes:labels[right]});
 const transposed=structuredClone(formal);transposed.performance.anchor_midi+=12;
 for(const event of transposed.performance.lexical_events){event.base_midi+=12;for(const key of ['family_opening_absolute_midi','address_absolute_midi'])event[key]=event[key].map(n=>n+12);if(event.runtime_tail)event.runtime_tail.absolute_note+=12;}
 assert.deepEqual(decodeMassComparisonMidi(midiFromFormal(transposed)),decoded);
 const corrupt=bytes.slice(),first=corrupt.indexOf(0x90);corrupt[first+1]++;
 assert.throws(()=>decodeMassComparisonMidi(corrupt));assert.throws(()=>decodeMassComparisonMidi(bytes.slice(0,-1)));
 count++;
}
const {formal}=await composeNamedSentence('I have less mass than you [2].',load('MAT:000'));
const decoded=decodeMassComparisonMidi(midiFromFormal(formal));
assert.deepEqual(decoded.participants.bearer,{kind:'deictic',role:'speaker'});
assert.deepEqual(decoded.participants.comparison_standard,{kind:'deictic',role:'addressee'});
assert.equal(decoded.material_root,'MAT:000');assert.equal(decoded.runtime_state,2);
const wrapped=await composeNamedSentence('It is possible that the box has more mass than the radio.',load('MAT:010'));
assert.throws(()=>decodeMassComparisonMidi(midiFromFormal(wrapped.formal)),/Unsupported/);
const kay=await composeNamedSentence('Kay has more mass than the radio.',load('MAT:010'));
const cay=await composeNamedSentence('Cay has more mass than the radio.',load('MAT:010'));
assert.notEqual(kay.semantic_ir.nodes.find(n=>n.node_id==='a').referent_id,cay.semantic_ir.nodes.find(n=>n.node_id==='a').referent_id);
assert.deepEqual(midiFromFormal(kay.formal),midiFromFormal(cay.formal));
assert.deepEqual(decodeMassComparisonMidi(midiFromFormal(kay.formal)),decodeMassComparisonMidi(midiFromFormal(cay.formal)));
assert.match(decoded.reference_resolution,/not original spelling or external referent identity/);
console.log(`Independent MIDI inverse: ${count} relation/runtime/direction cases plus deictic operands; octave transposition preserves decoding, corruption/truncation fail, unsupported modal scope is explicit. No source IR or formal plan is supplied to the decoder.`);
