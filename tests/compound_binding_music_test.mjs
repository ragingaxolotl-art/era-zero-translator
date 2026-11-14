import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {midiFromFormal,svgFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const ruby=String.raw`
require 'minitest/mock'
require 'era_zero_renderer'
require 'era_zero_presentation'
require 'base64'
atoms, = EraZeroRenderer.load_authority
results=[]
%w[actor source target result].product([0,1,2]).each do |role,state|
 entry={ 'compound_id'=>'slotted','definition_version'=>'1.0.0','status'=>'approved','semantic_head'=>'h',
 'nodes'=>[{'node_id'=>'s','kind'=>'slot','slot_name'=>'participant','slot_type'=>'entity'},{'node_id'=>'h','kind'=>'root','root_id'=>'REP:111'}],
 'edges'=>[{'type'=>'fills_role','from'=>'s','to'=>'h','role'=>role}], 'lexical_constraints'=>[] }
 inner=Marshal.load(Marshal.dump(entry));inner['compound_id']='inner';inner['edges'][0]['role']='experiencer'
 ir={'ir_version'=>'1.0','root_clause'=>'c','speech_act'=>'assertion','discourse_constraints'=>{},
 'nodes'=>[{'node_id'=>'c','kind'=>'clause','clause_type'=>'predication'},
 {'node_id'=>'p','kind'=>'lexical_occurrence','target_type'=>'compound','target_id'=>'slotted','runtime_state'=>{'code'=>state},'compound_bindings'=>[{'slot_path'=>['s'],'argument_id'=>'a'}]},
 {'node_id'=>'a','kind'=>'lexical_occurrence','target_type'=>'compound','target_id'=>'inner','runtime_state'=>{'code'=>1},'value_type'=>'entity','compound_bindings'=>[{'slot_path'=>['s'],'argument_id'=>'b'}]},
 {'node_id'=>'b','kind'=>'lexical_occurrence','target_type'=>'atom','target_id'=>'LIF:010','runtime_state'=>{'code'=>2},'value_type'=>'entity'}],
 'edges'=>[{'edge_id'=>'e','type'=>'centers','from'=>'p','to'=>'c'}]}
 digest=EraZeroRenderer.semantic_digest(ir);ir.merge!('utterance_id'=>"UTT:#{digest[0,24]}",'serialization'=>{'content_digest'=>digest})
 EraZeroRenderer.stub(:load_authority,[atoms,{'slotted'=>entry,'inner'=>inner}]) do
  f=EraZeroRenderer.render(ir)
  results << {role:role,state:state,formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f)),svg:EraZeroPresentation.svg(f)}
 end
end
puts JSON.generate(results)
`;
const cases=JSON.parse(execFileSync('ruby',['-Itools/lib','-e',ruby],{cwd:new URL('..',import.meta.url),encoding:'utf8',maxBuffer:20_000_000}));
for(const {role,state,formal,midi,svg} of cases){
 const scheduled=scheduledLexicalEvents(formal);
 assert.deepEqual(scheduled.map(e=>e.marker||e.target_id),[`role_${role}_open`,'role_experiencer_open','LIF:010','role_experiencer_close','REP:111',`role_${role}_close`,'REP:111']);
 assert.deepEqual(scheduled.filter(e=>!e.marker).map(e=>e.runtime_tail?.code),[2,1,state]);
 assert.deepEqual(Buffer.from(midiFromFormal(formal)),Buffer.from(midi,'base64'));
 assert.equal(svgFromFormal(formal),svg);
 assert.equal(formal.performance.lexical_events[0].binding_chain.length,2);
 assert.throws(()=>scheduledLexicalEvents(formal,6),/event limit/);
}
assert.equal(new Set(cases.map(c=>c.midi)).size,12);
const invalid=structuredClone(cases[0].formal);delete invalid.performance.lexical_events[0].binding_chain[1].role;
assert.throws(()=>scheduledLexicalEvents(invalid),/binding chain/);
console.log('Nested bound compounds: 12 role/runtime contrasts retain both binding scopes, no duplicate payload, Ruby/browser MIDI and SVG parity, and event limits. Structural probes do not assert lexical valence.');
