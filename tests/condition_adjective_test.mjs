import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence,composeSentenceConditional} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const root=new URL('..',import.meta.url),index=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const load=async target=>JSON.parse(fs.readFileSync(new URL('pages/'+index.resolution_files[target],root))).variants['assertion:1'];
const results=[];
for(const [input,target] of [
 ['The radio is damaged.','WRN:001'],['The radio is impaired.','WRN:001'],
 ['The radio is restored.','REP:001'],['The radio is not damaged.','WRN:001'],
 ['The radio was restored.','REP:001'],['Is the radio damaged?','WRN:001'],
 ['I am impaired.','WRN:001'],['Exactly three radios are damaged.','WRN:001'],
 ...[0,1,2].map(state=>[`The radio is damaged [${state}].`,'WRN:001']),
 ['Ada is damaging the radio.','WRN:111'],['Ada damaged the radio.','WRN:110'],
 ['Ada is restoring the radio.','REP:111'],['Ada restored the radio.','REP:110']
]){
 const parsed=parseNamedSentence(input);assert.equal(parsed?.predicate,target,input);
 const result=await composeNamedSentence(input,await load(target));
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','f=EraZeroRenderer.render(JSON.parse(STDIN.read));puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})'],{cwd:root,input:JSON.stringify(result.semantic_ir),encoding:'utf8'}));
 assert.deepEqual(result.formal,ruby.formal,input);
 assert.deepEqual(Buffer.from(midiFromFormal(result.formal)),Buffer.from(ruby.midi,'base64'),input);
 if(['WRN:001','REP:001'].includes(target))assert(result.semantic_ir.edges.some(edge=>edge.type==='fills_role'&&edge.role==='bearer'));
 results.push(result);
}
const sound=r=>Buffer.from(midiFromFormal(r.formal)).toString('base64');
assert.equal(sound(results[0]),sound(results[1])); // reviewed same condition sense
assert.equal(new Set([0,2,11,12,13,14].map(i=>sound(results[i]))).size,6);
for(const state of [0,1,2]){
 const result=results[8+state],event=result.formal.performance.lexical_events.find(e=>e.occurrence_id==='p');
 assert.equal(event.target_id,'WRN:001');assert.equal(event.runtime_tail.code,state);
 assert.deepEqual(event.address_relative_semitones,results[0].formal.performance.lexical_events.find(e=>e.occurrence_id==='p').address_relative_semitones);
}
assert.equal(new Set(results.slice(8,11).map(sound)).size,3);
assert.notEqual(sound(results[3]),sound(results[8]));
assert(scheduledLexicalEvents(results[3].formal).some(e=>e.marker==='negation_open'));
const conditional=await composeSentenceConditional('If the radio is damaged, then Ada is repairing the radio.',load);
assert.equal(conditional.semantic_ir.nodes.find(n=>n.node_id==='s000_p').target_id,'WRN:001');
assert.equal(conditional.semantic_ir.nodes.find(n=>n.node_id==='s001_p').target_id,'REP:111');
assert.equal(scheduledLexicalEvents(conditional.formal)[0].marker,'conditional_open_open');
for(const text of ['The radio is damaged by Ada.','The radio is hot.','The radio is tired.'])assert.equal(parseNamedSentence(text),null,text);
console.log('Condition adjectives: 15 reference-renderer parity cases; impairment/restoration state versus event, bearer roles, negation, questions, quantities, conditional scope, and all runtime endings pass.');
