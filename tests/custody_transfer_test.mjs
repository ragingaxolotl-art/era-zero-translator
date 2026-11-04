import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,needsSentenceComposition} from '../pages/sentences.mjs';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {decodeCustodyTransferMidi,decodeCustodyAcquisitionMidi} from '../pages/custody_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),template={authority};
const id='CMP:e3075c904daf1c647969fef6',results=[];
const inputs=['Ben transferred physical custody of the box to Ada.','Ada transferred physical custody of the box to Ben.','Ben transferred physical custody of Ada to Pip.','I transferred physical custody of the box to you.','Ben did not transfer physical custody of the box to Ada.','Did Ben transfer physical custody of the box to Ada?','Did Ben not transfer physical custody of the box to Ada?','Transfer physical custody of the box to Ada.','Do not transfer physical custody of the box to Ada.','Ben transferred physical custody of the heavy box to Ada.','Ben transferred physical custody of the light box to Ada.','Ben transferred physical custody of the box to Ada yesterday.'];
const phonemic=(phonemes,reference_mode='name')=>({kind:'phonemic',reference_mode,phonemes,instance_code:null});
for(const state of [0,1,2])for(const text of inputs){
 const input=text.replace(/([.?])$/,` [${state}]$1`),parsed=parseNamedSentence(input);assert(parsed,input);
 const r=await composeNamedSentence(input,template,parsed.requiredInterpretation?{interpretation:'mass_standard',standard:{dimension:'mass',threshold:'12.5',scale:'kilogram'}}:{});assert.equal(r.target_id,id);results.push(r);
 const bytes=midiFromFormal(r.formal),d=decodeCustodyTransferMidi(bytes,authority.atoms);
 assert.equal(d.runtime_state,state);assert.equal(d.predicate,'completed_physical_custody_transfer');assert.deepEqual(d.convention_codes,[9,7,8,7]);
 const command=/^(Transfer|Do not transfer)/.test(text),negative=/not transfer/.test(text);
 assert.equal(d.speech_act,command?'command':text.startsWith('Did ')?'question':'assertion');
 assert.deepEqual(d.scopes,[...(!command?[{operator:'time',relation:text.includes('yesterday')?'previous_day':'before_speech'}]:[]),...(negative?[{operator:'negation'}]:[])]);
 assert.deepEqual(d.meaning,{same_object:true,same_reallocation_event:true,source_custody_before:true,source_custody_at_culmination:false,recipient_custody_before:false,recipient_custody_at_culmination:true,distinct_source_recipient:true,object_distinct_from_holders:true,ownership_asserted:false,willingness_asserted:false,movement_asserted:false,carrying_asserted:false,exclusivity_against_third_parties_asserted:false,persistence_after_culmination_asserted:false});
 const source=command?{kind:'deictic',role:'addressee'}:text.startsWith('I ')?{kind:'deictic',role:'speaker'}:phonemic(text.startsWith('Ada ')?['AE','D','AE']:['B','EH','N']);
 const recipient=text.includes('to you')?{kind:'deictic',role:'addressee'}:phonemic(text.includes('to Ben')?['B','EH','N']:text.includes('to Pip')?['P','IH','P']:['AE','D','AE']);
 const object=text.includes('of Ada')?phonemic(['AE','D','AE']):{...phonemic(['B','AA','K','S'],'definite_nominal'),...(parsed.requiredInterpretation?{property:{dimension:'mass',comparison:parsed.adjective==='heavy'?'greater_than':'less_than',magnitude:'12.5',unit:'kilogram'}}:{})};
 assert.deepEqual(d.participants,{source,object,recipient});
 assert.deepEqual(decodeStrictMusicMidi(bytes,authority.atoms).tokens.filter(t=>t.kind==='root').map(t=>[t.root_id,t.runtime_state]),[['MAT:010',null],['MAT:210',null],['MAT:010',null],['MAT:210',null],['ORI:110',state]]);
 assert.throws(()=>decodeCustodyAcquisitionMidi(bytes,authority.atoms));
 // Same object and distinct source/recipient must be structural bindings.
 const p=r.semantic_ir.nodes.find(n=>n.target_id===id);
 for(const mutation of ['object','holder']){
  const bad=structuredClone(r.semantic_ir),b=bad.nodes.find(n=>n.target_id===id).compound_bindings;
  if(mutation==='object')b.find(b=>b.slot_path.join('/')==='h/q-custody/s-target').argument_id=p.compound_bindings[0].argument_id;
  else b.find(b=>b.slot_path.join('/')==='h/q-custody/s-source').argument_id=p.compound_bindings[0].argument_id;
  await assert.rejects(()=>renderLexicalOccurrences(bad,authority),/same argument|distinct arguments/);
 }
}
const ruby=String.raw`puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})`;
const refs=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e',ruby],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:30_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,refs[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(refs[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
for(const text of ['Ben delivered the box to Ada.','Ben transferred the box to Ada.','Ben transferred ownership of the box to Ada.','Ben transferred physical custody of the box to Ben.','Ben transferred physical custody of Ben to Ada.','Ben transferred physical custody of Ada to Ada.','Ben is transferring physical custody of the box to Ada.']){assert.equal(parseNamedSentence(text),null,text);assert(needsSentenceComposition(text));}
for(const rootId of ['ORI:110','MAT:210']){
 const f=structuredClone(results[12].formal),e=f.performance.lexical_events.find(e=>e.target_id===rootId);e.address_absolute_midi[e.address_absolute_midi.length-1]+=2;
 const bytes=midiFromFormal(f);decodeStrictMusicMidi(bytes,authority.atoms);assert.throws(()=>decodeCustodyTransferMidi(bytes,authority.atoms),/custody-transfer/);
}
// Corrupt just the second object sound, preserving balanced valid grammar.
const mismatch=structuredClone(results[0].formal),names=mismatch.performance.lexical_events.filter(e=>e.kind==='phonemic_label');
assert.equal(names.length,4);names[3].address_absolute_midi=names[0].address_relative_semitones.map(n=>n+names[3].base_midi);
const mismatchBytes=midiFromFormal(mismatch);decodeStrictMusicMidi(mismatchBytes,authority.atoms);assert.throws(()=>decodeCustodyTransferMidi(mismatchBytes,authority.atoms),/custody-transfer/);
// Independent lexical participant states coexist with each whole-event state.
const lexical=[];
for(const state of [0,1,2]){
 const r=results.find(r=>r.formal.semantic_ir.nodes.find(n=>n.target_id===id).runtime_state.code===state),ir=structuredClone(r.semantic_ir);
 const p=ir.nodes.find(n=>n.target_id===id),ids=[p.compound_bindings[0].argument_id,p.compound_bindings[1].argument_id,p.compound_bindings.at(-1).argument_id];
 ids.forEach((nodeId,i)=>{const index=ir.nodes.findIndex(n=>n.node_id===nodeId);ir.nodes[index]={node_id:nodeId,kind:'lexical_occurrence',target_type:'atom',target_id:['LIF:010','MAT:010','LIF:000'][i],runtime_state:{code:[0,2,1][i]},value_type:'entity'};});
 delete ir.serialization;delete ir.utterance_id;lexical.push(ir);
}
const lr=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e',ruby.replace('f=EraZeroRenderer.render(ir);',"digest=EraZeroRenderer.semantic_digest(ir);ir['utterance_id']='UTT:'+digest[0,24];ir['serialization']={'content_digest'=>digest};f=EraZeroRenderer.render(ir);")],{cwd:root,input:JSON.stringify(lexical),encoding:'utf8',maxBuffer:5_000_000}));
for(const [state,r] of lr.entries()){assert.deepEqual(await renderLexicalOccurrences(r.formal.semantic_ir,authority),r.formal.performance.lexical_events);const d=decodeCustodyTransferMidi(Buffer.from(r.midi,'base64'),authority.atoms);assert.equal(d.runtime_state,state);assert.deepEqual(d.participants,{source:{kind:'lexical',root_id:'LIF:010',runtime_state:0},object:{kind:'lexical',root_id:'MAT:010',runtime_state:2},recipient:{kind:'lexical',root_id:'LIF:000',runtime_state:1}});}
execFileSync('ruby',['-Itools/lib','-rera_zero_controlled_english','-e',String.raw`
 d=EraZeroValidation.load_yaml('lexicon/compound_dictionary.yaml')['entries'];m=EraZeroValidation.load_yaml('migrations/custody_transfer_2026_11_04.yaml')
 old=d.select{|e|m['previous_compound_ids'].include?(e['compound_id'])}
 raise 'Prior 41 compounds changed' unless old.length==41 && EraZeroValidation.fingerprint(old)==m['before_dictionary_fingerprint']
 begin
 EraZeroControlledEnglish::Compiler.new.compile!('ASSERT "completed transfer of physical custody" [1] ROLE source "identified other" [0] ROLE target "distinct material object" [2].')
 raise 'Ambiguous nested holders silently bound'
 rescue EraZeroControlledEnglish::CompileError => e
 raise unless e.message.include?('Repeated scoped roles')
 end
`],{cwd:root,encoding:'utf8'});
console.log(`Custody transfer: ${results.length} sentence/state cases preserve source, recipient and shared object, scoped before/after linkage and Ruby/browser MIDI parity. Three explicit lexical-participant fixtures preserve independent states. Corrupted object/root music and invalid identity bindings are rejected; 41 prior definitions remain exact.`);
