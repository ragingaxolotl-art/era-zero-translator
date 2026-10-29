import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
import {midiFromFormal,svgFromFormal} from '../pages/engine.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {conventionFramesFromNotes} from '../pages/compound_conventions.mjs';
const ruby=String.raw`
require 'minitest/mock'
require 'era_zero_renderer'
require 'era_zero_presentation'
require 'base64'
atoms, = EraZeroRenderer.load_authority
meaning=lambda{|code|{'profile'=>'EZLEX-1','sense_key'=>"fixture_#{code}",'sound_code'=>code,'added_definition'=>'Test-only conventional meaning; no vocabulary is approved.','excludes'=>['Unmarked interpretation']}}
results=[]
[0,1,2].product(%w[experiencer target],[0,1,2]).each do |level,role,state|
 nested=level.positive?; bound=level==2
 inner={'compound_id'=>'inner','definition_version'=>'1.0.0','status'=>'approved','semantic_head'=>'h','nodes'=>[{'node_id'=>'q','kind'=>'root','root_id'=>'MIN:011'},{'node_id'=>'h','kind'=>'root','root_id'=>'LIF:011'}],'edges'=>[{'type'=>'qualifies','from'=>'q','to'=>'h'}],'lexical_constraints'=>[],'conventional_meaning'=>meaning.call(101)}
 if bound
  inner['nodes']<<{'node_id'=>'s','kind'=>'slot','slot_name'=>'content','slot_type'=>'entity'}
  inner['edges']<<{'type'=>'fills_role','from'=>'s','to'=>'h','role'=>'content'}
 end
 q=nested ? {'node_id'=>'q','kind'=>'compound_ref','compound_id'=>'inner','definition_version'=>'1.0.0'} : {'node_id'=>'q','kind'=>'root','root_id'=>'LIF:011'}
 entry={'compound_id'=>'outer','definition_version'=>'1.0.0','status'=>'approved','semantic_head'=>'h','nodes'=>[q,{'node_id'=>'a','kind'=>'slot','slot_name'=>'experiencer','slot_type'=>'entity'},{'node_id'=>'b','kind'=>'slot','slot_name'=>'target','slot_type'=>'entity'},{'node_id'=>'h','kind'=>'root','root_id'=>'REP:111'}],
 'edges'=>[{'type'=>'qualifies','from'=>'q','to'=>role=='experiencer' ? 'a' : 'b'},{'type'=>'fills_role','from'=>'a','to'=>'h','role'=>'experiencer'},{'type'=>'fills_role','from'=>'b','to'=>'h','role'=>'target'}],'lexical_constraints'=>[],'conventional_meaning'=>meaning.call(100)}
 ir={'ir_version'=>'1.0','root_clause'=>'c','speech_act'=>'assertion','discourse_constraints'=>{},'nodes'=>[{'node_id'=>'c','kind'=>'clause','clause_type'=>'predication'},
 {'node_id'=>'p','kind'=>'lexical_occurrence','target_type'=>'compound','target_id'=>'outer','runtime_state'=>{'code'=>state},'compound_bindings'=>[{'slot_path'=>['a'],'argument_id'=>'a'},{'slot_path'=>['b'],'argument_id'=>'b'}]},
 {'node_id'=>'a','kind'=>'lexical_occurrence','target_type'=>'atom','target_id'=>'LIF:010','runtime_state'=>{'code'=>2},'value_type'=>'entity'},
 {'node_id'=>'b','kind'=>'lexical_occurrence','target_type'=>'atom','target_id'=>'MAT:010','runtime_state'=>{'code'=>0},'value_type'=>'entity'}], 'edges'=>[{'edge_id'=>'e','type'=>'centers','from'=>'p','to'=>'c'}]}
 if bound
  ir['nodes'][1]['compound_bindings']<<{'slot_path'=>['q','s'],'argument_id'=>'d'}
  ir['nodes']<<{'node_id'=>'d','kind'=>'lexical_occurrence','target_type'=>'atom','target_id'=>'DAT:010','runtime_state'=>{'code'=>1},'value_type'=>'entity'}
 end
 digest=EraZeroRenderer.semantic_digest(ir);ir.merge!('utterance_id'=>"UTT:#{digest[0,24]}",'serialization'=>{'content_digest'=>digest})
 EraZeroRenderer.stub(:load_authority,[atoms,{'outer'=>entry,'inner'=>inner}]) do
  f=EraZeroRenderer.render(ir);results<<{nested:nested,bound:bound,role:role,state:state,formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f)),svg:EraZeroPresentation.svg(f)}
 end
end
puts JSON.generate(results)
`;
const cases=JSON.parse(execFileSync('ruby',['-Itools/lib','-e',ruby],{cwd:new URL('..',import.meta.url),encoding:'utf8',maxBuffer:20_000_000}));
for(const {nested,bound,role,state,formal,midi,svg} of cases){
 const events=scheduledLexicalEvents(formal),keys=events.map(e=>e.marker||e.target_id);
 const modifier=nested?['convention_101_open',...(bound?['role_content_open','DAT:010','role_content_close']:[]),'MIN:011','LIF:011','convention_101_close']:['LIF:011'];
 assert.deepEqual(keys,['convention_100_open','role_experiencer_open',...(role==='experiencer'?modifier:[]),'LIF:010','role_experiencer_close','role_target_open',...(role==='target'?modifier:[]),'MAT:010','role_target_close','REP:111','convention_100_close']);
 const lastModifier=keys.indexOf(modifier.at(-1));assert.equal(events[lastModifier].boundary_after_beats,0);
 assert.deepEqual(events.filter(e=>e.runtime_tail).map(e=>e.runtime_tail.code),[...(bound&&role==='experiencer'?[1]:[]),2,...(bound&&role==='target'?[1]:[]),0,state]);
 assert.deepEqual(Buffer.from(midiFromFormal(formal)),Buffer.from(midi,'base64'));assert.equal(svgFromFormal(formal),svg);
 const {notes,division}=notesFromMidi(Buffer.from(midi,'base64'));
 const count=e=>e.family_opening_absolute_midi.length+e.address_absolute_midi.length+(e.runtime_tail?1:0);
 const preceding=events.slice(0,lastModifier+1).reduce((n,e)=>n+count(e),0);
 assert.equal(notes[preceding-1].end_tick,notes[preceding].start_tick);
 const frames=conventionFramesFromNotes(notes,division,60);
 const badTiming=structuredClone(notes);badTiming[0].end_tick++;
 assert.throws(()=>conventionFramesFromNotes(badTiming,division,60),/timing/);
 const badScope=structuredClone(notes);badScope[badScope.length-4].midi=badScope[badScope.length-4].midi===61?60:61;
 assert.throws(()=>conventionFramesFromNotes(badScope,division,60),/scope|trit/);
 assert.throws(()=>conventionFramesFromNotes(notes.slice(0,-13),division,60),/Unclosed/);
 assert.deepEqual(frames.map(f=>[f.side,f.sound_code]),[['open',100],...(nested?[['open',101],['close',101]]:[]),['close',100]]);
}
assert.equal(new Set(cases.map(c=>c.midi)).size,18);
console.log('Qualified slots: 18 attachment/runtime contrasts keep modifiers inside the correct participant role frame, including nested conventions; exact no-gap MIDI attachment, argument endings and Ruby/browser parity hold. Fixtures are structural, not approved experience vocabulary.');
