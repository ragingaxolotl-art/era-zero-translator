import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeCustodyTransferMidi} from '../pages/custody_decoder.mjs';
import {decodeCustodyDeliveryMidi} from '../pages/delivery_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const output=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_controlled_english','-rera_zero_presentation','-rbase64','-e',String.raw`
c=EraZeroControlledEnglish::Compiler.new
transfer=' SLOT ["q-prior","s-source"] "identified other" [0] SLOT ["q-prior","s-target"] "distinct material object" [2] SLOT ["h","q-custody","s-source"] "continuous self" [1] SLOT ["h","q-custody","s-target"] REF ["q-prior","s-target"]'
delivery=' SLOT ["q-arrival","q-path","q-carry","q-support","s-source"] "identified other" [0] SLOT ["q-arrival","s-load"] "distinct material object" [2] SLOT ["q-arrival","s-destination"] "continuous self" [1]'
{
 ['q-arrival','q-path','q-carry','q-support','s-target']=>['q-arrival','s-load'],
 ['q-arrival','q-path','q-carry','s-load']=>['q-arrival','s-load'],
 ['q-arrival','q-path','s-load']=>['q-arrival','s-load'],
 ['q-arrival','q-path','s-destination']=>['q-arrival','s-destination'],
 ['h','q-prior','s-source']=>['q-arrival','q-path','q-carry','q-support','s-source'],
 ['h','q-prior','s-target']=>['q-arrival','s-load'],
 ['h','h','q-custody','s-source']=>['q-arrival','s-destination'],
 ['h','h','q-custody','s-target']=>['q-arrival','s-load']
}.each{|path,ref|delivery += " SLOT #{JSON.generate(path)} REF #{JSON.generate(ref)}"}
results=[]
[['completed transfer of physical custody',transfer],['completed carrying-mediated custody delivery',delivery]].each do |label,bindings|
 %w[ASSERT QUESTION COMMAND].each do |act|
  [0,1,2].each do |state|
   ir=c.compile!(%Q{#{act} NOT "#{label}" [#{state}]#{bindings}.});f=EraZeroRenderer.render(ir)
   raise 'Determinism lost' unless c.compile!(%Q{#{act} NOT "#{label}" [#{state}]#{bindings} .})==ir
   results<<{label:label,act:act,state:state,formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}
  end
 end
end
base=%Q{ASSERT "completed transfer of physical custody" [1]#{transfer}.}
invalid={
 'empty path'=>[base.sub('["q-prior","s-source"]','[]'),'invalid_slot_path'],
 'non-string component'=>[base.sub('["q-prior","s-source"]','[3]'),'invalid_slot_path'],
 'unknown path'=>[base.sub('["q-prior","s-source"]','["q-prior/s-source"]'),'invalid_slot_binding'],
 'duplicate path'=>[base.sub('["h","q-custody","s-source"]','["q-prior","s-source"]'),'duplicate_slot_binding'],
 'missing slot'=>[base.sub(' SLOT ["h","q-custody","s-target"] REF ["q-prior","s-target"]',''),'invalid_slot_binding'],
 'different object'=>[base.sub('REF ["q-prior","s-target"]','"distinct material object" [2]'),'invalid_slot_binding'],
 'same holders'=>[base.sub('"continuous self" [1]','REF ["q-prior","s-source"]'),'invalid_slot_binding'],
 'forward reference'=>[base.sub('"identified other" [0]','REF ["h","q-custody","s-source"]'),'unknown_slot_reference'],
 'mixed role after'=>[base.sub('.', ' ROLE source "identified other" [0].'),'mixed_compound_bindings'],
 'mixed role before'=>[base.sub(' SLOT ', ' ROLE source "identified other" [0] SLOT '),'mixed_compound_bindings'],
 'atomic predicate'=>[base.sub('completed transfer of physical custody','active care'),'invalid_slot_binding'],
 'ambiguous role only'=>['ASSERT "completed transfer of physical custody" [1] ROLE source "identified other" [0] ROLE target "distinct material object" [2].','ambiguous_compound_binding']
}
invalid.each{|key,(input,code)|r=c.compile(input);raise "#{key}: #{r}" unless r['status']=='error' && r.dig('error','code')==code && !r.key?('semantic_ir')}
puts JSON.generate({results:results,rejected:invalid.length})
`],{cwd:root,encoding:'utf8',maxBuffer:45_000_000}));
for(const r of output.results){
 assert.deepEqual(await renderLexicalOccurrences(r.formal.semantic_ir,authority),r.formal.performance.lexical_events);
 assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(r.midi,'base64'));
 const delivery=r.label.includes('delivery'),d=(delivery?decodeCustodyDeliveryMidi:decodeCustodyTransferMidi)(Buffer.from(r.midi,'base64'),authority.atoms);
 assert.equal(d.runtime_state,r.state);assert.equal(d.speech_act,{ASSERT:'assertion',QUESTION:'question',COMMAND:'command'}[r.act]);assert.deepEqual(d.scopes,[{operator:'negation'}]);
 assert.deepEqual(d.participants,{[delivery?'carrier':'source']:{kind:'lexical',root_id:'LIF:010',runtime_state:0},object:{kind:'lexical',root_id:'MAT:010',runtime_state:2},recipient:{kind:'lexical',root_id:'LIF:000',runtime_state:1}});
}
assert.equal(output.results.length,18);assert.equal(output.rejected,12);
console.log('Scoped controlled SLOT paths: 18 speech-act/event/state cases preserve independent participant states and Ruby/browser MIDI agreement; 12 malformed, ambiguous or identity-breaking cases return structured errors without partial IR.');
