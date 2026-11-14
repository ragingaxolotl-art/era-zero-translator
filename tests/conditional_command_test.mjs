import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseSentenceConditional,composeSentenceConditional} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const root=new URL('..',import.meta.url),index=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const load=async target=>JSON.parse(fs.readFileSync(new URL('pages/'+index.resolution_files[target],root))).variants['assertion:1'];
const inputs=['If the radio is damaged, repair it.','If the radio is damaged, then repair the radio.','If the radio is damaged, do not damage it.','If the radio is not restored, repair it.','If the radio is damaged, repair the pump.',...[0,1,2].map(n=>`If the radio is damaged [2], repair it [${n}].`)];
assert(parseSentenceConditional('If with 70% confidence, it is possible that Ada is conscious, then Pip is dormant.'));
const outputs=[];
for(const input of inputs){
 const result=await composeSentenceConditional(input,load);outputs.push(result);
 assert.equal(result.semantic_ir.speech_act,'command');
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','f=EraZeroRenderer.render(JSON.parse(STDIN.read));puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})'],{cwd:root,input:JSON.stringify(result.semantic_ir),encoding:'utf8'}));
 assert.deepEqual(result.formal,ruby.formal);
 assert.deepEqual(Buffer.from(midiFromFormal(result.formal)),Buffer.from(ruby.midi,'base64'));
 const ir=result.semantic_ir,condition=ir.nodes.find(n=>n.node_id==='s000_a'),actor=ir.nodes.find(n=>n.node_id==='s001_a'),target=ir.nodes.find(n=>n.node_id==='s001_b');
 assert.equal(actor.referent_id,'discourse:addressee');
 if(!input.includes('pump'))assert.equal(target.referent_id,condition.referent_id);
 else assert.notEqual(target.referent_id,condition.referent_id);
 assert.equal(ir.edges.find(e=>e.type==='condition_of').from,'s000_c');
 assert.equal(ir.edges.find(e=>e.type==='condition_of').to,'s001_c');
 assert.equal(scheduledLexicalEvents(result.formal)[0].marker,'conditional_open_open');
}
assert.deepEqual(outputs[0].formal,outputs[1].formal);
for(const n of [0,1,2]){
 const ir=outputs[5+n].semantic_ir;
 assert.equal(ir.nodes.find(node=>node.node_id==='s000_p').runtime_state.code,2);
 assert.equal(ir.nodes.find(node=>node.node_id==='s001_p').runtime_state.code,n);
}
assert.equal(new Set(outputs.slice(5).map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,3);
assert(outputs[2].semantic_ir.nodes.some(n=>n.node_id.startsWith('s001_')&&n.operator==='negation'));
assert(outputs[3].semantic_ir.nodes.some(n=>n.node_id.startsWith('s000_')&&n.operator==='negation'));
const assertion=await composeSentenceConditional('If the radio is damaged, then you are repairing the radio.',load);
assert.notDeepEqual(midiFromFormal(assertion.formal),midiFromFormal(outputs[0].formal));
for(const input of ['If Ada is damaging the radio, repair it.','If exactly three radios are damaged, repair it.','If the radio is damaged, repair them.','If it is damaged, repair it.','If the radio is damaged, is it restored?'])assert.equal(parseSentenceConditional(input),null,input);
console.log('Conditional commands: eight full renderer/MIDI parity cases, local definite-reference identity, explicit-reference paraphrase equivalence, command/assertion contrast, negation scope and independent runtime endings.');
