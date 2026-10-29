import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {midiFromFormal,svgFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const modes=['possible','necessary','permitted','obligated','intended','predicted','counterfactual'];
const samples=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_controlled_english','-rera_zero_presentation','-rbase64','-e',`
base=EraZeroControlledEnglish::Compiler.new.compile('ASSERT NOT "active care" [1].').fetch('semantic_ir')
puts JSON.generate(%w[possible necessary permitted obligated intended predicted counterfactual].map do |mode|
  ir=Marshal.load(Marshal.dump(base))
  node=ir['nodes'].find{|n|n['operator']=='negation'}
  node['operator']='modality';node['mode']=mode
  digest=EraZeroRenderer.semantic_digest(ir)
  ir['utterance_id']='UTT:'+digest[0,24];ir['serialization']['content_digest']=digest
  f=EraZeroRenderer.render(ir)
  {formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f)),svg:EraZeroPresentation.svg(f)}
end)
`],{cwd:new URL('..',import.meta.url),encoding:'utf8'}));
for(const [index,sample] of samples.entries()){
  assert.deepEqual(Buffer.from(midiFromFormal(sample.formal)),Buffer.from(sample.midi,'base64'));
  assert.equal(svgFromFormal(sample.formal),sample.svg);
  const events=scheduledLexicalEvents(sample.formal);
  assert.equal(events[0].marker,`modality_${modes[index]}_open`);
  assert.equal(events.at(-1).marker,`modality_${modes[index]}_close`);
  assert.equal(events[1].runtime_tail.code,1);
  assert.deepEqual(events[0].address_relative_semitones,[0,-(index+2),-(index+2),0]);
  const withStrength=structuredClone(sample.formal);
  withStrength.semantic_ir.nodes.find(n=>n.operator==='modality').strength='0.70';
  assert.throws(()=>scheduledLexicalEvents(withStrength),/confidence strength/);
}
assert.equal(new Set(samples.map(s=>s.midi)).size,modes.length);
console.log('Modality: seven distinct scoped modes preserve runtime and match Ruby/browser MIDI/SVG; unsounded confidence is rejected.');
