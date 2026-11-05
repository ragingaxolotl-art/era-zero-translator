import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {midiFromFormal,svgFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const samples=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',`
base=YAML.load_file('tests/semantic_ir_cases.yaml')['valid_cases'].find{|c|c['case_id']=='possible_clause'}['ir']
puts JSON.generate(%w[0 0.7 0.8 1 0.123456789].map do |strength|
 ir=Marshal.load(Marshal.dump(base));ir['nodes'].find{|n|n['operator']=='modality'}['strength']=strength
 digest=EraZeroRenderer.semantic_digest(ir);ir['utterance_id']='UTT:'+digest[0,24];ir['serialization']['content_digest']=digest
 f=EraZeroRenderer.render(ir)
 {formal:f,strength:strength,midi:Base64.strict_encode64(EraZeroPresentation.midi(f)),svg:EraZeroPresentation.svg(f)}
end)
`],{cwd:new URL('..',import.meta.url),encoding:'utf8'}));
for(const sample of samples){
 assert.deepEqual(Buffer.from(midiFromFormal(sample.formal)),Buffer.from(sample.midi,'base64'));
 assert.equal(svgFromFormal(sample.formal),sample.svg);
 const events=scheduledLexicalEvents(sample.formal),open=events.findIndex(event=>event.marker==='confidence_open'),close=events.findIndex(event=>event.marker==='confidence_close');
 assert.equal(open,1);
 const recovered=events.slice(open+1,close).map(event=>{
   const notes=event.address_relative_semitones;
   if(notes.join(',')==='0,10,-1,0')return '.';
   assert.equal(notes[1],10);assert.equal(notes.length,5);
   return String(notes[2]*4+notes[3]);
 }).join('');
 assert.equal(recovered,sample.strength);
 assert.equal(events[close+1].runtime_tail.code,2);
}
assert.equal(new Set(samples.map(s=>s.midi)).size,samples.length);
for(const strength of ['0.70','1.1','-0.1','7e-1',0.7]){
 const invalid=structuredClone(samples[0].formal);invalid.semantic_ir.nodes.find(n=>n.operator==='modality').strength=strength;
 assert.throws(()=>scheduledLexicalEvents(invalid),/confidence strength/);
}
console.log('Confidence: five exact decimal values recover from note frames; Ruby/browser output agrees; noncanonical or out-of-range strengths fail.');
