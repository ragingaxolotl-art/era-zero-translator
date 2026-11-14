import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {midiFromFormal, svgFromFormal, soundPlanFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';

const samples = JSON.parse(execFileSync('ruby', ['-Itools/lib', '-rera_zero_controlled_english', '-rera_zero_presentation', '-rbase64', '-e', `
c=EraZeroControlledEnglish::Compiler.new
puts JSON.generate([1,2,3].map do |count|
  r=c.compile(%Q{ASSERT REPEAT #{count} TIMES "ongoing physical repair" [1].})
  f=EraZeroRenderer.render(r.fetch("semantic_ir"))
  {formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f)),svg:EraZeroPresentation.svg(f),count:count}
end)
`], {cwd: new URL('..', import.meta.url), encoding:'utf8'}));
for (const {formal,midi,svg,count} of samples) {
  const events=scheduledLexicalEvents(formal);
  assert.equal(events.length,2*count);
  assert.deepEqual(Buffer.from(midiFromFormal(formal)),Buffer.from(midi,'base64'));
  assert.equal(svgFromFormal(formal),svg);
  assert.equal(soundPlanFromFormal(formal).lexical_events.length,2*count);
  const phrase=formal.performance.lexical_events.flatMap(event=>[...event.family_opening_absolute_midi,...event.address_absolute_midi,...(event.runtime_tail?[event.runtime_tail.absolute_note]:[])]);
  assert.deepEqual(notesFromMidi(midiFromFormal(formal)).notes.map(note=>note.midi),Array.from({length:count},()=>phrase).flat().concat(formal.performance.contour_relative_semitones.map(n=>n+60)));
}
const oversized=structuredClone(samples[0].formal);
oversized.semantic_ir.nodes.find(node=>node.operator==='repetition').count=1e9;
assert.throws(()=>scheduledLexicalEvents(oversized),/event limit/);
console.log('Browser repetition: Ruby/JS MIDI and SVG parity, sound-plan counts, and export bounds pass.');
