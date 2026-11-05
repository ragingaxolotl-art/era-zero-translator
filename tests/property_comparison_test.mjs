import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const root=new URL('..',import.meta.url),index=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const template=JSON.parse(fs.readFileSync(new URL('pages/'+index.resolution_files['MAT:010'],root))).variants['assertion:1'];
const forms=[['the same mass as','equal'],['more mass than','greater_than'],['less mass than','less_than'],['at least as much mass as','at_least'],['at most as much mass as','at_most'],['a different mass from','not_equal']];
const outputs=[];
for(const [surface,relation] of forms){
 for(const [left,right] of [['The box','the radio'],['The radio','the box']]){
  const result=await composeNamedSentence(`${left} has ${surface} ${right}.`,template);outputs.push(result);
  const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','f=EraZeroRenderer.render(JSON.parse(STDIN.read));puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})'],{cwd:root,input:JSON.stringify(result.semantic_ir),encoding:'utf8'}));
  assert.deepEqual(result.formal,ruby.formal);
  assert.deepEqual(Buffer.from(midiFromFormal(result.formal)),Buffer.from(ruby.midi,'base64'));
  const comparison=result.semantic_ir.nodes.find(n=>n.operator==='comparison');assert.equal(comparison.dimension,'mass');assert.equal(comparison.relation,relation);
  const roleLabel=role=>{const edge=result.semantic_ir.edges.find(e=>e.role===role);return result.semantic_ir.nodes.find(n=>n.node_id===edge.from).name.normalized_label};
  assert.equal(roleLabel('bearer'),left.split(' ')[1]);assert.equal(roleLabel('comparison_standard'),right.split(' ')[1]);
  const schedule=scheduledLexicalEvents(result.formal);assert.equal(schedule[0].marker,`property_mass_${relation}_open`);assert.equal(schedule.at(-1).marker,`property_mass_${relation}_close`);
 }
}
const sound=r=>Buffer.from(midiFromFormal(r.formal)).toString('base64');
assert.equal(new Set(outputs.filter((_,i)=>i%2===0).map(sound)).size,6);
assert.notEqual(sound(outputs[2]),sound(outputs[3]));
assert.deepEqual((await composeNamedSentence('The box has greater mass than the radio.',template)).formal,outputs[2].formal);
for(const mutation of [ir=>{ir.nodes.find(n=>n.operator==='comparison').dimension='temperature'},ir=>{ir.edges.find(e=>e.role==='comparison_standard').role='target'},ir=>{ir.nodes.find(n=>n.operator==='comparison').relation='approximately'}]){
 const formal=structuredClone(outputs[0].formal);mutation(formal.semantic_ir);
 assert.throws(()=>scheduledLexicalEvents(formal),/property comparison/);
 const errors=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_semantic_validation','-e','puts JSON.generate(EraZeroSemanticValidation.validate(JSON.parse(STDIN.read)))'],{cwd:root,input:JSON.stringify(formal.semantic_ir),encoding:'utf8'}));assert(errors.includes('invalid_property_comparison'));
}
const modal=await composeNamedSentence('It is possible that the box has more mass than the radio [2].',template);
assert.equal(modal.semantic_ir.nodes.find(n=>n.node_id==='p').runtime_state.code,2);
assert.equal(scheduledLexicalEvents(modal.formal)[0].marker,'modality_possible_open');
for(const input of ['The box is heavier than the radio.','Exactly three boxes have more mass than the radio.','The box has more mass than it.'])assert.equal(parseNamedSentence(input),null,input);
console.log('Entity mass comparison: 12 reference-renderer/MIDI cases preserve six relations and operand direction; explicit paraphrases normalize, invalid dimensions/roles fail, and modal/runtime scope remains separate.');
