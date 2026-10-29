import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {midiFromFormal,svgFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const samples=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',`
base=YAML.load_file('tests/semantic_ir_cases.yaml')['valid_cases'].find{|c|c['case_id']=='sequence'}['ir']
puts JSON.generate(%w[sequence all_of any_of exactly_one].map do |operator|
 ir=Marshal.load(Marshal.dump(base));node=ir['nodes'].find{|n|n['kind']=='coordination'};node['operator']=operator
 ir['edges'].select{|e|e['type']=='member_of'&&e['to']==node['node_id']}.each{|e|e.delete('order')} unless operator=='sequence'
 digest=EraZeroRenderer.semantic_digest(ir);ir['utterance_id']='UTT:'+digest[0,24];ir['serialization']['content_digest']=digest
 f=EraZeroRenderer.render(ir)
 {operator:operator,formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f)),svg:EraZeroPresentation.svg(f)}
end)
`],{cwd:new URL('..',import.meta.url),encoding:'utf8'}));
for(const sample of samples){
 assert.deepEqual(Buffer.from(midiFromFormal(sample.formal)),Buffer.from(sample.midi,'base64'));
 assert.equal(svgFromFormal(sample.formal),sample.svg);
 const markers=scheduledLexicalEvents(sample.formal).filter(event=>event.kind==='grammar_marker').map(event=>event.marker);
 assert.deepEqual(markers,sample.operator==='sequence'?[]:[`coord_${sample.operator}_open`,'coord_member',`coord_${sample.operator}_close`]);
}
assert.equal(new Set(samples.map(sample=>sample.midi)).size,4);
const invalid=structuredClone(samples[1].formal);
invalid.semantic_ir.edges.find(edge=>edge.type==='member_of').order=1;
assert.throws(()=>scheduledLexicalEvents(invalid),/cannot declare sequence order/);
console.log('Coordination: sequence, all-of, any-of and exactly-one sound distinct; Ruby/browser MIDI/SVG agree and unordered members retain boundaries.');
