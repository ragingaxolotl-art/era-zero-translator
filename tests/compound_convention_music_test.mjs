import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {midiFromFormal,svgFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {decodeConventionFrame} from '../pages/compound_conventions.mjs';
const ruby=String.raw`
require 'minitest/mock'
require 'era_zero_renderer'
require 'era_zero_presentation'
require 'base64'
atoms, = EraZeroRenderer.load_authority
results=[]
[0,1,2].product([0,1,2],[false,true]).each do |code,state,bound|
 meaning={'profile'=>'EZLEX-1','sense_key'=>"fixture_sense_#{code}",'sound_code'=>code,'added_definition'=>'A test-only lexical distinction, not an approved sensory meaning.','excludes'=>['Unmarked composition']}
 inner={'compound_id'=>'inner','definition_version'=>'1.0.0','status'=>'approved','semantic_head'=>'h',
 'nodes'=>[{'node_id'=>'q','kind'=>'root','root_id'=>'DAT:111'},{'node_id'=>'h','kind'=>'root','root_id'=>'MIN:011'}],
 'edges'=>[{'type'=>'qualifies','from'=>'q','to'=>'h'}],'lexical_constraints'=>[],'conventional_meaning'=>meaning}
 outer={'compound_id'=>'outer','definition_version'=>'1.0.0','status'=>'approved','semantic_head'=>'h',
 'nodes'=>[{'node_id'=>'q','kind'=>'compound_ref','compound_id'=>'inner','definition_version'=>'1.0.0'},{'node_id'=>'h','kind'=>'root','root_id'=>'MIN:211'}],
 'edges'=>[{'type'=>'qualifies','from'=>'q','to'=>'h'}],'lexical_constraints'=>[],
 'conventional_meaning'=>meaning.merge('sound_code'=>6560,'sense_key'=>'fixture_outer')}
 ir={'ir_version'=>'1.0','root_clause'=>'c','speech_act'=>'assertion','discourse_constraints'=>{},
 'nodes'=>[{'node_id'=>'c','kind'=>'clause','clause_type'=>'predication'},
 {'node_id'=>'p','kind'=>'lexical_occurrence','target_type'=>'compound','target_id'=>'outer','runtime_state'=>{'code'=>state}}],
 'edges'=>[{'edge_id'=>'e','type'=>'centers','from'=>'p','to'=>'c'}]}
 if bound
  inner['nodes'] << {'node_id'=>'s','kind'=>'slot','slot_name'=>'experiencer','slot_type'=>'entity'}
  inner['edges'] << {'type'=>'fills_role','from'=>'s','to'=>'h','role'=>'experiencer'}
  ir['nodes'][1]['compound_bindings']=[{'slot_path'=>['q','s'],'argument_id'=>'a'}]
  ir['nodes'] << {'node_id'=>'a','kind'=>'lexical_occurrence','target_type'=>'atom','target_id'=>'LIF:010','runtime_state'=>{'code'=>2},'value_type'=>'entity'}
 end
 digest=EraZeroRenderer.semantic_digest(ir);ir.merge!('utterance_id'=>"UTT:#{digest[0,24]}",'serialization'=>{'content_digest'=>digest})
 EraZeroRenderer.stub(:load_authority,[atoms,{'outer'=>outer,'inner'=>inner}]) do
  f=EraZeroRenderer.render(ir)
  results << {code:code,state:state,bound:bound,formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f)),svg:EraZeroPresentation.svg(f)}
 end
end
puts JSON.generate(results)
`;
const cases=JSON.parse(execFileSync('ruby',['-Itools/lib','-e',ruby],{cwd:new URL('..',import.meta.url),encoding:'utf8',maxBuffer:20_000_000}));
for(const {code,state,bound,formal,midi,svg} of cases){
 const scheduled=scheduledLexicalEvents(formal);
 assert.deepEqual(scheduled.map(e=>e.marker||e.target_id),['convention_6560_open',`convention_${code}_open`,...(bound?['role_experiencer_open','LIF:010','role_experiencer_close']:[]),'DAT:111','MIN:011',`convention_${code}_close`,'MIN:211','convention_6560_close']);
 assert.deepEqual(scheduled.filter(e=>!e.marker).map(e=>e.runtime_tail?.code),[...(bound?[2]:[]),undefined,undefined,state]);
 assert(scheduled.filter(e=>e.marker).every(e=>!e.runtime_tail));
 assert.deepEqual(Buffer.from(midiFromFormal(formal)),Buffer.from(midi,'base64'));
 assert.equal(svgFromFormal(formal),svg);
 // Read MIDI notes without the source IR or formal event labels.
 const {notes,division}=notesFromMidi(Buffer.from(midi,'base64')),segments=[];
 for(const note of notes){if(!segments.length||note.start_tick>segments.at(-1).at(-1).end_tick)segments.push([]);segments.at(-1).push(note);}
 const frames=segments.map(segment=>{
  const decoded=decodeConventionFrame(segment.map(n=>n.midi-notes[0].midi));
  if(decoded)assert(segment.every(n=>n.end_tick-n.start_tick===division/4));
  return decoded;
 }).filter(Boolean);
 assert.deepEqual(frames.map(f=>[f.side,f.sound_code]),[['open',6560],['open',code],['close',code],['close',6560]]);
}
assert.equal(new Set(cases.map(c=>c.midi)).size,18);
assert.equal(decodeConventionFrame([0,7,12]),null);
assert.throws(()=>decodeConventionFrame([0,-19,0]),/Malformed/);
assert.throws(()=>decodeConventionFrame([0,-19,0,0,0,0,0,0,0,2,0]),/trit/);
console.log('Explicit compound conventions: 18 nested identity/runtime/binding contrasts preserve roots and head-only endings; Ruby/browser MIDI and SVG agree; independent MIDI frame reading recovers scoped convention codes. Fixtures do not approve vocabulary.');
