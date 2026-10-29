import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {decodePropertyComparisonMidi} from '../pages/property_comparison_decoder.mjs';
import {decodeMassComparisonMidi} from '../pages/mass_comparison_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const load=id=>JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'];
const forms=[['the same temperature as','equal'],['a higher temperature than','greater_than'],['a lower temperature than','less_than'],['at least as high a temperature as','at_least'],['at most as high a temperature as','at_most'],['a different temperature from','not_equal']],results=[];
for(const state of [0,1,2])for(const [surface,relation] of forms)for(const [left,right] of [['The radio','the box'],['The box','the radio']]){
 const r=await composeNamedSentence(`${left} has ${surface} ${right} [${state}].`,load('MAT:010'));results.push(r);
 const bytes=midiFromFormal(r.formal),decoded=decodePropertyComparisonMidi(bytes);
 assert.equal(decoded.dimension,'thermodynamic_temperature');assert.equal(decoded.relation,relation);assert.equal(decoded.runtime_state,state);
 assert.equal(decoded.material_root,'MAT:010');assert.equal(decoded.speech_act,'assertion');
 for(const [role,id] of [['bearer','a'],['comparison_standard','b']])assert.deepEqual(decoded.participants[role].phonemes,r.semantic_ir.nodes.find(n=>n.node_id===id).name.phonemes);
 assert(decodeStrictMusicMidi(bytes,authority.atoms).tokens.some(t=>t.marker===`property_thermodynamic_temperature_${relation}_open`));
 assert.throws(()=>decodeMassComparisonMidi(bytes));
 const transposed=structuredClone(r.formal);transposed.performance.anchor_midi+=12;
 for(const event of transposed.performance.lexical_events){event.base_midi+=12;for(const key of ['family_opening_absolute_midi','address_absolute_midi'])event[key]=event[key].map(n=>n+12);if(event.runtime_tail)event.runtime_tail.absolute_note+=12;}
 assert.deepEqual(decodePropertyComparisonMidi(midiFromFormal(transposed)),decoded);
 const corrupt=bytes.slice();corrupt[corrupt.indexOf(0x90)+1]++;assert.throws(()=>decodePropertyComparisonMidi(corrupt));
}
const deictic=await composeNamedSentence('I have a higher temperature than you.',load('MAT:000'));results.push(deictic);
const d=decodePropertyComparisonMidi(midiFromFormal(deictic.formal));assert.equal(d.participants.bearer.role,'speaker');assert.equal(d.participants.comparison_standard.role,'addressee');
const modal=await composeNamedSentence('It is not necessary that the radio has a higher temperature than the box [2].',load('MAT:010'));results.push(modal);
assert.deepEqual(decodePropertyComparisonMidi(midiFromFormal(modal.formal)).scopes,[{operator:'negation'},{operator:'modality',mode:'necessary'}]);
const expected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:12_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,expected[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(expected[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
const mass=await composeNamedSentence('The radio has the same mass as the box [0].',load('MAT:010'));
assert.equal(decodePropertyComparisonMidi(midiFromFormal(mass.formal)).dimension,'mass');assert.notDeepEqual(midiFromFormal(mass.formal),midiFromFormal(results[0].formal));
for(const input of ['A radio has a higher temperature than the box.','Exactly two radios have a higher temperature than the box.','The radio is hot.','The radio has a higher temperature than it.'])assert.equal(parseNamedSentence(input),null,input);
// Corruption, truncation and transposition are checked by the inherited mass inverse suite.
const bytes=midiFromFormal(results[0].formal);assert.throws(()=>decodePropertyComparisonMidi(bytes.slice(0,-1)));
console.log(`Temperature comparison: ${results.length} six-relation/runtime/direction/deictic/scope cases match Ruby formal and MIDI; independent inverse recovers dimension, relation, ordered participants and state. Mass API remains mass-only.`);
