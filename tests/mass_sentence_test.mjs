import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const root=new URL('..',import.meta.url),index=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const outputs=[];
for(const [input,value] of [
 ['The box has a mass of 5 kilograms.','5'],['The box has a mass of 5000 grams.','5'],
 ['The box has a mass of 0.5 grams.','0.0005'],['The box has a mass of 0005.000 kilograms.','5'],
 ['I have a mass of 50 kilograms.','50'],['The radio has a mass of 2 kilograms [2].','2'],
 ['It is possible that the box has a mass of 4 kilograms.','4'],
 ['The box has a mass of 9007199254740993 grams.','9007199254740.993']
]){
 const parsed=parseNamedSentence(input);assert.equal(parsed?.measurement?.magnitude,value,input);
 const template=JSON.parse(fs.readFileSync(new URL('pages/'+index.resolution_files[parsed.predicate],root))).variants['assertion:1'];
 const result=await composeNamedSentence(input,template);outputs.push(result);
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','f=EraZeroRenderer.render(JSON.parse(STDIN.read));puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})'],{cwd:root,input:JSON.stringify(result.semantic_ir),encoding:'utf8'}));
 assert.deepEqual(result.formal,ruby.formal);
 assert.deepEqual(Buffer.from(midiFromFormal(result.formal)),Buffer.from(ruby.midi,'base64'));
 assert.equal(result.semantic_ir.nodes.find(n=>n.kind==='measurement').magnitude,value);
 assert.equal(result.semantic_ir.nodes.find(n=>n.kind==='measurement').unit,'kilogram');
 assert(result.semantic_ir.edges.some(e=>e.role==='bearer'));
 assert(result.semantic_ir.edges.some(e=>e.role==='quantity'&&e.from==='measure'&&e.to==='p'));
 assert(scheduledLexicalEvents(result.formal).some(e=>e.marker==='measurement_open'));
}
assert.deepEqual(outputs[0].formal,outputs[1].formal);
assert.deepEqual(outputs[0].formal,outputs[3].formal);
assert.notDeepEqual(midiFromFormal(outputs[0].formal),midiFromFormal(outputs[2].formal));
assert.equal(outputs[4].semantic_ir.nodes.find(n=>n.node_id==='p').target_id,'MAT:000');
assert.equal(outputs[5].semantic_ir.nodes.find(n=>n.node_id==='p').runtime_state.code,2);
for(const input of ['The box has a mass of -5 kilograms.','The box has a mass of 5 meters.','The box weighs 5 kilograms.','The box is heavy.','Exactly three boxes have a mass of 5 kilograms.','The box has a mass of 5e3 grams.'])assert.equal(parseNamedSentence(input),null,input);
console.log('Mass statements: eight reference-renderer/MIDI parity cases, exact gram/kilogram normalization beyond floating-point precision, bearer/quantity binding, modal and runtime preservation, and unsupported-dimension rejection.');
