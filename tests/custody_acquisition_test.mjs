import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {decodeCustodyAcquisitionMidi,decodePhysicalCustodyMidi} from '../pages/custody_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),template={authority};
const id='CMP:c332d2e89b9f6177486fc93b',results=[];
const inputs=['Ada acquired physical custody of the box.','Ben acquired physical custody of the box.','Ada acquired physical custody of Ben.','Ben acquired physical custody of Ada.','I acquired physical custody of the box.','Ada did not acquire physical custody of the box.','Did Ada acquire physical custody of the box?','Did Ada not acquire physical custody of the box?','Acquire physical custody of the box.','Do not acquire physical custody of the box.','Ada acquired physical custody of the heavy box.','Ada acquired physical custody of the light box.'];
for(const state of [0,1,2])for(const text of inputs){
 const input=text.replace(/([.?])$/,` [${state}]$1`),parsed=parseNamedSentence(input);assert(parsed,input);
 const r=await composeNamedSentence(input,template,parsed.requiredInterpretation?{interpretation:'mass_standard',standard:{dimension:'mass',threshold:'12.5',scale:'kilogram'}}:{});assert.equal(r.target_id,id,input);results.push(r);
 const bytes=midiFromFormal(r.formal),d=decodeCustodyAcquisitionMidi(bytes,authority.atoms);
 assert.equal(d.runtime_state,state);assert.equal(d.predicate,'completed_physical_custody_acquisition');assert.deepEqual(d.convention_codes,[8,7]);
 const command=/^(Acquire|Do not acquire)/.test(text),negative=/did not|not acquire/.test(text);
 assert.equal(d.speech_act,command?'command':text.startsWith('Did ')?'question':'assertion');
 assert.deepEqual(d.scopes,[...(!command?[{operator:'time',relation:'before_speech'}]:[]),...(negative?[{operator:'negation'}]:[])]);
 assert.deepEqual(d.meaning,{actualized_referent:'holder_object_custody_relation',custody_immediately_before:false,custody_at_culmination:true,holder_distinct_from_object:true,object_creation_asserted:false,object_movement_asserted:false,prior_custodian_asserted:false,sourced_transfer_asserted:false,ownership_asserted:false,persistence_after_culmination_asserted:false});
 const tokens=decodeStrictMusicMidi(bytes,authority.atoms).tokens;
 assert.deepEqual(tokens.filter(t=>t.kind==='root').map(t=>[t.root_id,t.runtime_state]),[['MAT:010',null],['MAT:210',null],['ORI:110',state]]);
 const expectedHolder=command?{kind:'deictic',role:'addressee'}:text.startsWith('I ')?{kind:'deictic',role:'speaker'}:{kind:'phonemic',reference_mode:'name',phonemes:text.startsWith('Ben ')?['B','EH','N']:['AE','D','AE'],instance_code:null};assert.deepEqual(d.participants.holder,expectedHolder);
 const targetName=text.includes('of Ada')?['AE','D','AE']:text.includes('of Ben')?['B','EH','N']:['B','AA','K','S'];
 assert.deepEqual(d.participants.object,{kind:'phonemic',reference_mode:targetName[0]==='B'&&targetName[1]==='AA'?'definite_nominal':'name',phonemes:targetName,instance_code:null,...(parsed.requiredInterpretation?{property:{dimension:'mass',comparison:parsed.adjective==='heavy'?'greater_than':'less_than',magnitude:'12.5',unit:'kilogram'}}:{})});
 assert.throws(()=>decodePhysicalCustodyMidi(bytes,authority.atoms));
 const bad=structuredClone(r.semantic_ir),p=bad.nodes.find(n=>n.target_id===id);p.compound_bindings[1].argument_id=p.compound_bindings[0].argument_id;await assert.rejects(()=>renderLexicalOccurrences(bad,authority),/distinct arguments/);
}
const refs=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:20_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,refs[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(refs[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
for(const input of ['Ada acquired the box.','Ada acquired ownership of the box.','Ada acquired physical custody of Ada.','Ada is acquiring physical custody of the box.','Ada acquired physical custody of the box from Ben.'])assert.equal(parseNamedSentence(input),null,input);
// Alter only performed pitches, leaving source IR untouched. Each corruption
// remains decodable strict structure but must fail this semantic profile.
for(const rootId of ['ORI:110','MAT:210']){
 const f=structuredClone(results.find(r=>r.source_input.includes('[1]')).formal);
 const e=f.performance.lexical_events.find(e=>e.target_id===rootId);e.address_absolute_midi[e.address_absolute_midi.length-1]+=2;
 const bytes=midiFromFormal(f);decodeStrictMusicMidi(bytes,authority.atoms);assert.throws(()=>decodeCustodyAcquisitionMidi(bytes,authority.atoms),/custody-acquisition/);
}
const changedConvention=structuredClone(results[0].formal);
for(const e of changedConvention.performance.lexical_events.filter(e=>['convention_8_open','convention_8_close'].includes(e.marker)))e.address_absolute_midi[9]=e.base_midi+1;
const corrupted=midiFromFormal(changedConvention);decodeStrictMusicMidi(corrupted,authority.atoms);assert.throws(()=>decodeCustodyAcquisitionMidi(corrupted,authority.atoms),/custody-acquisition/);
const existing=await composeNamedSentence('Ada has physical custody of the box.',template);assert.throws(()=>decodeCustodyAcquisitionMidi(midiFromFormal(existing.formal),authority.atoms));
const controlled=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_controlled_english','-rera_zero_presentation','-rbase64','-e',String.raw`
 d=EraZeroValidation.load_yaml('lexicon/compound_dictionary.yaml')['entries']
 m=EraZeroValidation.load_yaml('migrations/custody_acquisition_2026_11_04.yaml')
 old=d.reject{|e|e['compound_id']==m['added_compound_id']}
 raise 'Prior forty compounds changed' unless old.length==40 && EraZeroValidation.fingerprint(old)==m['before_dictionary_fingerprint']
 c=EraZeroControlledEnglish::Compiler.new
 puts JSON.generate([0,1,2].map{|s|ir=c.compile!(%Q{ASSERT "completed acquisition of physical custody" [#{s}] ROLE source "identified other" [0] ROLE target "distinct material object" [2].});f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})
`],{cwd:root,encoding:'utf8',maxBuffer:3_000_000}));
for(const [state,r] of controlled.entries()){assert.deepEqual(await renderLexicalOccurrences(r.formal.semantic_ir,authority),r.formal.performance.lexical_events);const d=decodeCustodyAcquisitionMidi(Buffer.from(r.midi,'base64'),authority.atoms);assert.equal(d.runtime_state,state);assert.deepEqual(d.participants,{holder:{kind:'lexical',root_id:'LIF:010',runtime_state:0},object:{kind:'lexical',root_id:'MAT:010',runtime_state:2}});}
console.log(`Custody acquisition: ${results.length} state/participant/negation/question/command/property cases preserve complete Ruby/browser formal and MIDI output; independent inverse recovers the bounded transition and scoped culmination. Three controlled nested performances retain participant states; all forty preceding compounds remain exact.`);
