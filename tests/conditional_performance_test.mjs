import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {midiFromFormal,svgFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const samples=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',`
base=YAML.load_file('tests/semantic_ir_cases.yaml')['valid_cases'].find{|c|c['case_id']=='conditional'}['ir']
puts JSON.generate(%w[open satisfied unsatisfied counterfactual].product([false,true]).map do |status,reverse|
 ir=Marshal.load(Marshal.dump(base));edge=ir['edges'].find{|e|e['type']=='condition_of'};edge['condition_status']=status
 if reverse
  nodes=ir['nodes'].select{|n|n['kind']=='lexical_occurrence'};nodes[0]['target_id'],nodes[1]['target_id']=nodes[1]['target_id'],nodes[0]['target_id']
 end
 digest=EraZeroRenderer.semantic_digest(ir);ir['utterance_id']='UTT:'+digest[0,24];ir['serialization']['content_digest']=digest
 f=EraZeroRenderer.render(ir);{status:status,reverse:reverse,formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f)),svg:EraZeroPresentation.svg(f)}
end)
`],{cwd:new URL('..',import.meta.url),encoding:'utf8'}));
for(const sample of samples){
 assert.deepEqual(Buffer.from(midiFromFormal(sample.formal)),Buffer.from(sample.midi,'base64'));
 assert.equal(svgFromFormal(sample.formal),sample.svg);
 const events=scheduledLexicalEvents(sample.formal);
 assert.equal(events[0].marker,`conditional_${sample.status}_open`);
 assert.equal(events[2].marker,'conditional_then');
 assert.equal(events.at(-1).marker,`conditional_${sample.status}_close`);
 assert.deepEqual(events.filter(e=>e.kind!=='grammar_marker').map(e=>e.target_id),sample.reverse?['CRE:111','LOG:101']:['LOG:101','CRE:111']);
 assert(events.filter(e=>e.runtime_tail).every(e=>e.runtime_tail.code===1));
}
assert.equal(new Set(samples.map(s=>s.midi)).size,8);
for(const patch of [{condition_status:'unknown'},{strength:'0.5'},{from:'n003'}]){
 const formal=structuredClone(samples[0].formal);Object.assign(formal.semantic_ir.edges.find(e=>e.type==='condition_of'),patch);
 assert.throws(()=>scheduledLexicalEvents(formal),/Unsupported musical condition/);
}
console.log('Conditional music preserves antecedent/consequent direction and all four declared statuses; eight contrasts match Ruby/browser output.');
