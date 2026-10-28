import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {midiFromFormal,svgFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const cwd=new URL('..',import.meta.url);
const base=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_controlled_english','-e',`puts JSON.generate(EraZeroRenderer.render(EraZeroControlledEnglish::Compiler.new.compile('ASSERT NOT "active care" [1].').fetch('semantic_ir')))`],{cwd,encoding:'utf8'}));
const cases=[...['modality','quantifier','aspect'].map(operator=>['scope_operator',operator]),...['all_of','any_of','exactly_one','parallel'].map(operator=>['coordination',operator])];
for(const [kind,operator] of cases){
  const formal=structuredClone(base);
  const node=formal.semantic_ir.nodes.find(node=>node.operator==='negation');
  Object.assign(node,{kind,operator});
  // No supported operator remains to activate the old scheduling path.
  for(const render of [scheduledLexicalEvents,midiFromFormal,svgFromFormal])
    assert.throws(()=>render(formal),/Unsupported musical/,operator);
  const ruby=execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-e',`
ir=JSON.parse(STDIN.read).fetch('semantic_ir')
digest=EraZeroRenderer.semantic_digest(ir)
ir['utterance_id']='UTT:'+digest[0,24]
ir['serialization']['content_digest']=digest
f=EraZeroRenderer.render(ir)
[:midi,:svg].each do |method|
  begin
    EraZeroPresentation.send(method,f)
    abort 'silently rendered unsupported operator'
  rescue EraZeroPresentation::PresentationError => e
    abort e.message unless e.message.include?('unsupported musical')
  end
end
puts 'rejected'
`],{cwd,input:JSON.stringify(formal),encoding:'utf8'});
  assert.equal(ruby.trim(),'rejected');
}
assert(scheduledLexicalEvents(base).some(event=>event.marker==='negation_open'));
console.log(`Unsupported music scopes: ${cases.length} operators rejected by browser schedule/MIDI/SVG and Ruby MIDI/SVG; supported negation preserved.`);
