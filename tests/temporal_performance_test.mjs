import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {midiFromFormal,svgFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const samples=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',`
base=YAML.load_file('tests/semantic_ir_cases.yaml')['valid_cases'].find{|c|c['case_id']=='temporal_before'}['ir']
puts JSON.generate(%w[before at after].map do |relation|
 ir=Marshal.load(Marshal.dump(base));ir['edges'].find{|e|e['type']=='time_relation'}['relation']=relation
 digest=EraZeroRenderer.semantic_digest(ir);ir['utterance_id']='UTT:'+digest[0,24];ir['serialization']['content_digest']=digest
 f=EraZeroRenderer.render(ir)
 {relation:relation,formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f)),svg:EraZeroPresentation.svg(f)}
end)
`],{cwd:new URL('..',import.meta.url),encoding:'utf8'}));
for(const sample of samples){
 assert.deepEqual(Buffer.from(midiFromFormal(sample.formal)),Buffer.from(sample.midi,'base64'));
 assert.equal(svgFromFormal(sample.formal),sample.svg);
 const events=scheduledLexicalEvents(sample.formal);
 assert.equal(events[0].marker,`time_${sample.relation}_speech_open`);
 assert.equal(events.at(-1).marker,`time_${sample.relation}_speech_close`);
 assert.deepEqual(events.filter(e=>e.kind!=='grammar_marker'),sample.formal.performance.lexical_events);
}
assert.equal(new Set(samples.map(s=>s.midi)).size,3);
const unsupported=structuredClone(samples[0].formal);
unsupported.semantic_ir.nodes.find(n=>n.kind==='time_anchor').anchor_type='absolute_time';
assert.throws(()=>scheduledLexicalEvents(unsupported),/Unsupported musical time/);
const extra=structuredClone(samples[0].formal);
extra.semantic_ir.nodes.find(n=>n.kind==='time_anchor').day_offset=-1;
assert.throws(()=>scheduledLexicalEvents(extra),/Unsupported musical time/);
console.log('Temporal music: before/at/after speech time remain distinct, lexical state is unchanged, Ruby/browser output agrees, and unsounded anchor details fail.');
