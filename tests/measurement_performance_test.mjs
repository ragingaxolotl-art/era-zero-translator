import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {midiFromFormal,svgFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const samples=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',`
base=YAML.load_file('tests/semantic_ir_cases.yaml')['valid_cases'].find{|c|c['case_id']=='measurement'}['ir']
puts JSON.generate(%w[5 -5 0 0.5].product(%w[meter kilometer]).map do |value,unit|
 ir=Marshal.load(Marshal.dump(base));ir['nodes'].find{|n|n['kind']=='measurement'}.merge!('magnitude'=>value,'unit'=>unit)
 digest=EraZeroRenderer.semantic_digest(ir);ir['utterance_id']='UTT:'+digest[0,24];ir['serialization']['content_digest']=digest
 f=EraZeroRenderer.render(ir);{value:value,unit:unit,formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f)),svg:EraZeroPresentation.svg(f)}
end)
`],{cwd:new URL('..',import.meta.url),encoding:'utf8'}));
for(const sample of samples){
 assert.deepEqual(Buffer.from(midiFromFormal(sample.formal)),Buffer.from(sample.midi,'base64'));
 assert.equal(svgFromFormal(sample.formal),sample.svg);
 const events=scheduledLexicalEvents(sample.formal),markers=events.filter(e=>e.kind==='grammar_marker').map(e=>e.marker);
 assert.equal(markers[0],'measurement_open');assert.equal(markers.at(-1),'measurement_close');
 assert.equal(markers.includes('measurement_negative'),sample.value.startsWith('-'));
 assert(markers.includes(sample.unit==='meter'?'measurement_unit_6':'measurement_unit_7'));
 assert.deepEqual(events.filter(e=>e.kind!=='grammar_marker'),sample.formal.performance.lexical_events);
}
assert.equal(new Set(samples.map(s=>s.midi)).size,8);
for(const patch of [{magnitude:'05'},{magnitude:'-0'},{magnitude:'1.0'},{magnitude:5},{unit:'celsius'},{precision:2}]){
 const formal=structuredClone(samples[0].formal);Object.assign(formal.semantic_ir.nodes.find(n=>n.kind==='measurement'),patch);
 assert.throws(()=>scheduledLexicalEvents(formal),/Unsupported musical measurement/);
}
console.log('Measurement music preserves sign, exact decimal value and unit; eight contrasts match Ruby/browser output without changing lexical state.');
