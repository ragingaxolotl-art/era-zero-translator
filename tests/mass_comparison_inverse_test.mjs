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
assert.deepEqual(decodeMassComparisonMidi(midiFromFormal(wrapped.formal)).scopes,[{operator:'modality',mode:'possible'}]);
for(const state of [0,1,2]){
 const outer=await composeNamedSentence(`It is not possible that the box has more mass than the radio [${state}].`,load('MAT:010'));
 const result=decodeMassComparisonMidi(midiFromFormal(outer.formal));
 assert.equal(result.runtime_state,state);
 assert.deepEqual(result.scopes,[{operator:'negation'},{operator:'modality',mode:'possible'}]);
 const inner=structuredClone(outer.formal);
 const modal=inner.semantic_ir.nodes.find(n=>n.operator==='modality'),negative=inner.semantic_ir.nodes.find(n=>n.operator==='negation');
 Object.assign(modal,{operator:'negation'});delete modal.mode;
 Object.assign(negative,{operator:'modality',mode:'possible'});
 const innerBytes=midiFromFormal(inner);
 assert.notDeepEqual(innerBytes,midiFromFormal(outer.formal));
 assert.deepEqual(decodeMassComparisonMidi(innerBytes).scopes,[{operator:'modality',mode:'possible'},{operator:'negation'}]);
 assert.equal(decodeMassComparisonMidi(innerBytes).runtime_state,state);
}

const confidence=structuredClone(wrapped.formal);
confidence.semantic_ir.nodes.find(n=>n.operator==='modality').strength='0.5';
assert.throws(()=>decodeMassComparisonMidi(midiFromFormal(confidence)),/Unsupported/);
const kay=await composeNamedSentence('Kay has more mass than the radio.',load('MAT:010'));
const cay=await composeNamedSentence('Cay has more mass than the radio.',load('MAT:010'));
assert.notEqual(kay.semantic_ir.nodes.find(n=>n.node_id==='a').referent_id,cay.semantic_ir.nodes.find(n=>n.node_id==='a').referent_id);
assert.deepEqual(midiFromFormal(kay.formal),midiFromFormal(cay.formal));
assert.deepEqual(decodeMassComparisonMidi(midiFromFormal(kay.formal)),decodeMassComparisonMidi(midiFromFormal(cay.formal)));
assert.match(decoded.reference_resolution,/not original spelling or external referent identity/);
console.log(`Independent MIDI inverse: ${count} relation/runtime/direction cases plus deictic operands; octave transposition preserves decoding, corruption/truncation fail, negated possibility preserves scope independently of all three runtime states. No source IR or formal plan is supplied to the decoder.`);
