import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {encodeName,notesForName} from '../pages/names.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {visemePlanFromFormal} from '../pages/visemes.mjs';

const names=await Promise.all([encodeName('Pip','pip-one'),encodeName('Ada','ada-one')]);
const run=values=>JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e',`
names=JSON.parse(STDIN.read)
nodes=[{"node_id"=>"c","kind"=>"clause","clause_type"=>"predication"},
 {"node_id"=>"p","kind"=>"lexical_occurrence","target_type"=>"atom","target_id"=>"LIF:211","runtime_state"=>{"code"=>1}}]
names.each_with_index{|name,i|nodes << {"node_id"=>"name#{i}","kind"=>"phonemic_reference","referent_id"=>"person#{i}","value_type"=>"entity","name"=>name}}
ir={"ir_version"=>"1.0","root_clause"=>"c","speech_act"=>"assertion","nodes"=>nodes,"edges"=>[
 {"edge_id"=>"e0","type"=>"centers","from"=>"p","to"=>"c"},
 {"edge_id"=>"e1","type"=>"fills_role","from"=>"name0","to"=>"p","role"=>"actor"},
 {"edge_id"=>"e2","type"=>"fills_role","from"=>"name1","to"=>"p","role"=>"target"}],"discourse_constraints"=>{}}
digest=EraZeroRenderer.semantic_digest(ir)
ir.merge!("utterance_id"=>"UTT:#{digest[0,24]}","serialization"=>{"content_digest"=>digest})
f=EraZeroRenderer.render(ir)
raise "roundtrip" unless EraZeroRenderer.decode(f)==ir
puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})
`],{cwd:new URL('..',import.meta.url),input:JSON.stringify(values),encoding:'utf8',stdio:['pipe','pipe','pipe']}));
const forward=run(names),reverse=run([...names].reverse());
assert.notEqual(forward.formal.semantic_digest,reverse.formal.semantic_digest);
assert.notEqual(forward.midi,reverse.midi);
const events=forward.formal.performance.lexical_events.filter(event=>event.kind==='phonemic_label');
assert.equal(events.length,2);
for(let i=0;i<2;i++){
  assert.deepEqual(events[i].address_absolute_midi,notesForName(names[i]).map(note=>note+(i===0?-12:12)));
  assert.equal(events[i].semantic_claim,false);
  assert.equal(events[i].runtime_tail,undefined);
}
assert.deepEqual(Buffer.from(midiFromFormal(forward.formal)),Buffer.from(forward.midi,'base64'));
const nameCues=visemePlanFromFormal(forward.formal).cues.filter(cue=>cue.section==='phonemic_label');
assert.equal(nameCues.length,events.reduce((n,event)=>n+event.address_absolute_midi.length,0));
assert(nameCues.every(cue=>cue.nucleus_viseme==='REST'));
const corrupt=structuredClone(names);corrupt[0].phonemes=['UNKNOWN'];
assert.throws(()=>run(corrupt),/invalid phonemic label/);
console.log('Name participants: existing EZNAME notes, role reversal, nonsemantic labels, roundtrip and MIDI parity pass.');
