import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {midiFromFormal,svgFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {visemePlanFromFormal} from '../pages/visemes.mjs';
const samples=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_controlled_english','-rera_zero_presentation','-rbase64','-e',`
c=EraZeroControlledEnglish::Compiler.new
inputs=['ASSERT "active care" [1].','ASSERT NOT "active care" [1].','ASSERT "active care" [0].']
puts JSON.generate(inputs.map{|input|f=EraZeroRenderer.render(c.compile(input).fetch("semantic_ir"));{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f)),svg:EraZeroPresentation.svg(f)}})
`],{cwd:new URL('..',import.meta.url),encoding:'utf8',stdio:['pipe','pipe','pipe']}));
for(const sample of samples){
  assert.deepEqual(Buffer.from(midiFromFormal(sample.formal)),Buffer.from(sample.midi,'base64'));
  assert.equal(svgFromFormal(sample.formal),sample.svg);
}
assert.equal(new Set(samples.map(sample=>sample.midi)).size,3);
const negative=samples[1].formal,events=scheduledLexicalEvents(negative);
assert.deepEqual(events.map(event=>event.kind||'lexical'),['grammar_marker','lexical','grammar_marker']);
assert.equal(events[1].runtime_tail.code,1);
const notes=notesFromMidi(midiFromFormal(negative)).notes;
assert.deepEqual(notes.slice(0,4).map(note=>note.midi),[60,59,59,60]);
assert(notes.slice(0,4).every(note=>note.end_tick-note.start_tick===120));
const cues=visemePlanFromFormal(negative).cues.filter(cue=>cue.section==='grammar_marker');
assert.equal(cues.length,8);
assert(cues.every(cue=>cue.duration===.06&&cue.nucleus_viseme==='REST'));
const nested=structuredClone(negative);
const ir=nested.semantic_ir,inner=ir.nodes.find(node=>node.operator==='negation');
const center=ir.edges.find(edge=>edge.type==='centers');
center.from='outer_negation';
ir.nodes.push({node_id:'outer_negation',kind:'scope_operator',operator:'negation'});
ir.edges.push({edge_id:'outer_scope',type:'scopes',from:inner.node_id,to:'outer_negation'});
assert.deepEqual(scheduledLexicalEvents(nested).map(event=>event.marker||'lexical'),['negation_open','negation_open','lexical','negation_close','negation_close']);
console.log('Negation: positive/negative/inactive distinction, grammar framing, marker durations and Ruby/browser parity pass.');
