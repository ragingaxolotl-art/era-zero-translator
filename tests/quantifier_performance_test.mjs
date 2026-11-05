import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {midiFromFormal,svgFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const samples=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',`
base=YAML.load_file('tests/semantic_ir_cases.yaml')['valid_cases'].find{|c|c['case_id']=='exact_quantity'}['ir']
cases=%w[exact at_least at_most all some none].map{|q|[q,%w[exact at_least at_most].include?(q) ? '3' : nil]}+[['exact','4'],['exact','0']]
puts JSON.generate(cases.map do |quantifier,value|
 ir=Marshal.load(Marshal.dump(base));node=ir['nodes'].find{|n|n['operator']=='quantifier'};node['quantifier']=quantifier;node.delete('value');node['value']=value if value
 digest=EraZeroRenderer.semantic_digest(ir);ir['utterance_id']='UTT:'+digest[0,24];ir['serialization']['content_digest']=digest
 f=EraZeroRenderer.render(ir);{quantifier:quantifier,value:value,formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f)),svg:EraZeroPresentation.svg(f)}
end)
`],{cwd:new URL('..',import.meta.url),encoding:'utf8'}));
for(const sample of samples){
 assert.deepEqual(Buffer.from(midiFromFormal(sample.formal)),Buffer.from(sample.midi,'base64'));
 assert.equal(svgFromFormal(sample.formal),sample.svg);
 const events=scheduledLexicalEvents(sample.formal);
 assert.equal(events[0].marker,`quantifier_${sample.quantifier}_open`);
 assert.equal(events.at(-1).marker,`quantifier_${sample.quantifier}_close`);
 assert.deepEqual(events.filter(e=>e.kind!=='grammar_marker'),sample.formal.performance.lexical_events);
 assert.equal(events.filter(e=>e.marker?.startsWith('digit_')).map(e=>e.marker.slice(6)).join(''),sample.value||'');
}
assert.equal(new Set(samples.map(s=>s.midi)).size,8);
for(const patch of [{quantifier:'range'},{value:'-1'},{value:'01'},{value:'1.5'},{value:3},{quantifier:'all',value:'3'},{domain:'unsounded'}]){
 const formal=structuredClone(samples[0].formal);Object.assign(formal.semantic_ir.nodes.find(n=>n.operator==='quantifier'),patch);
 assert.throws(()=>scheduledLexicalEvents(formal),/Unsupported musical quantifier/);
}
console.log('Quantifier music: six scoped operators and exact cardinalities remain distinct, preserve runtime, and match Ruby/browser output.');
