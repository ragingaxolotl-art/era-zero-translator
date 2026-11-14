import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeRunningMidi} from '../pages/running_decoder.mjs';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {encodeName} from '../pages/names.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),results=[];
const past=[{operator:'time',relation:'before_speech'}],negative=[...past,{operator:'negation'}];
for(const state of [0,1,2])for(const [text,actor,destination,scope] of [
 ['Nora ran to the gate.','Nora','gate',past],
 ['Eli ran to Nora.','Eli','Nora',past],
 ['Nora ran to Eli.','Nora','Eli',past],
 ['I ran to the gate.','speaker','gate',past],
 ['Nora did not run to the gate.','Nora','gate',negative],
 ["Nora didn't run to the gate.",'Nora','gate',negative],
 ['Did Nora run to the gate?','Nora','gate',past],
 ['Did Nora not run to the gate?','Nora','gate',negative],
 ['Nora ran to the gate yesterday.','Nora','gate',[{operator:'time',relation:'previous_day'}]],
 ['Nora did not run to the gate yesterday.','Nora','gate',[{operator:'time',relation:'previous_day'},{operator:'negation'}]]
]){
 const r=await composeNamedSentence(text+` [${state}]`,{authority}),decoded=decodeRunningMidi(midiFromFormal(r.formal),authority.atoms);results.push(r);
 assert.equal(decoded.runtime_state,state);assert.deepEqual(decoded.convention_codes,[25,24,23,20]);
 assert.equal(decoded.predicate,'completed_destination_running');assert.equal(decoded.meaning.same_actor,true);assert.equal(decoded.meaning.same_event,true);assert.equal(decoded.meaning.arrival_asserted,true);assert.equal(decoded.meaning.receipt_asserted,false);assert.equal(decoded.meaning.culmination_part_of_event_type,true);assert.equal(decoded.meaning.approach_internal_phase,true);assert.equal(decoded.meaning.continued_presence_asserted,false);assert.equal(decoded.meaning.destination_relative_displacement_asserted,true);assert.equal(decoded.meaning.net_ground_progress_asserted,false);
 if(actor==='speaker')assert.deepEqual(decoded.actor,{kind:'deictic',role:'speaker'});else assert.deepEqual(decoded.actor.phonemes,(await encodeName(actor)).phonemes);
 assert.deepEqual(decoded.destination.phonemes,(await encodeName(destination)).phonemes);assert.equal(decoded.destination.reference_mode,destination==='gate'?'definite_nominal':'name');
 assert.deepEqual(decoded.scopes,scope);assert.equal(decoded.speech_act,text.endsWith('?')?'question':'assertion');
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:20_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,27);
execFileSync('ruby',['-Itools/lib','-rera_zero_validation','-e',"v=EraZeroValidation;d=v.load_yaml('lexicon/compound_dictionary.yaml')['entries'];m=v.load_yaml('migrations/completed_running_2026_11_04.yaml');old=d.select{|e|m['previous_compound_ids'].include?(e['compound_id'])};raise 'Prior meanings changed' unless old.length==57&&v.fingerprint(old)==m['before_dictionary_fingerprint']"],{cwd:root});
for(const text of ['Nora ran the program.','Nora ran to the conclusion.'])assert.equal(parseNamedSentence(text),null);
const corrupt=structuredClone(results[0].formal),approach=corrupt.performance.lexical_events.find(e=>e.target_id==='MOV:110'),arrival=authority.atoms.find(a=>a.canonical_id==='MOV:111');
approach.address_absolute_midi=arrival.note_path_semitones.map(n=>n+approach.base_midi);
assert.throws(()=>decodeRunningMidi(midiFromFormal(corrupt),authority.atoms));
console.log('PASS 30 completed-running actor/destination/runtime/scope cases, Ruby parity, independent MIDI recovery, wrong-root rejection and prior 57 meanings unchanged.');

const invalid=[];
for(const kind of ['missing_destination','different_actor','different_destination']){
 const ir=structuredClone(results[0].semantic_ir),predicate=ir.nodes.find(n=>n.kind==='lexical_occurrence');
 if(kind==='missing_destination')predicate.compound_bindings=predicate.compound_bindings.filter(b=>b.slot_path[0]!=='s-destination');
 else if(kind==='different_actor')predicate.compound_bindings.find(b=>b.slot_path.join('/')==='q-path/s-actor').argument_id='b';
 else predicate.compound_bindings.find(b=>b.slot_path.join('/')==='q-path/s-destination').argument_id='a';
 await assert.rejects(renderLexicalOccurrences(ir,authority));invalid.push(ir);
}
const rejected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|begin;EraZeroRenderer.render(ir);false;rescue StandardError;true;end})"],{cwd:root,input:JSON.stringify(invalid),encoding:'utf8'}));assert.deepEqual(rejected,[true,true,true]);
const inconsistent=structuredClone(results[0].formal),labels=inconsistent.performance.lexical_events.filter(e=>e.kind==='phonemic_label'&&e.argument_node_id==='a');
assert.equal(labels.length,3);
const eli=(await composeNamedSentence('Eli ran to the gate.',{authority})).formal.performance.lexical_events.find(e=>e.kind==='phonemic_label'&&e.argument_node_id==='a');
for(const field of ['family_opening_absolute_midi','address_absolute_midi'])labels[1][field]=eli[field];
assert.throws(()=>decodeRunningMidi(midiFromFormal(inconsistent),authority.atoms));
console.log('PASS missing destination and unequal actor bindings reject in browser/Ruby; inconsistent actor sounds reject independently.');

const inconsistentDestination=structuredClone(results[0].formal),destinations=inconsistentDestination.performance.lexical_events.filter(e=>e.kind==='phonemic_label'&&e.argument_node_id==='b');assert.equal(destinations.length,2);
const otherDestination=(await composeNamedSentence('Nora ran to the lake.',{authority})).formal.performance.lexical_events.find(e=>e.kind==='phonemic_label'&&e.argument_node_id==='b');
for(const field of ['family_opening_absolute_midi','address_absolute_midi'])destinations[1][field]=otherDestination[field];
assert.throws(()=>decodeRunningMidi(midiFromFormal(inconsistentDestination),authority.atoms));
const approachResult=await composeNamedSentence('Nora is running toward the gate.',{authority});
assert.equal(decodeRunningMidi(midiFromFormal(approachResult.formal),authority.atoms).meaning.arrival_asserted,false);
assert.notDeepEqual(midiFromFormal(approachResult.formal),midiFromFormal(results[0].formal));
console.log('PASS mismatched destination identity rejects in IR/music and ongoing approach stays distinct from completed running.');
