import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeSwimmingMidi} from '../pages/swimming_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),results=[];
for(const state of [0,1,2])for(const text of ['Eli is swimming.','Nora is swimming.','I am swimming.','Eli is not swimming.','Is Eli swimming?','Eli was swimming yesterday.','It is possible that Eli is swimming.']){
 const input=text+` [${state}]`,r=await composeNamedSentence(input,{authority}),decoded=decodeSwimmingMidi(midiFromFormal(r.formal),authority.atoms);results.push(r);
 assert.equal(decoded.runtime_state,state);assert.deepEqual(decoded.convention_codes,[21,20]);
 assert.equal(decoded.meaning.medium,'water');assert.equal(decoded.meaning.swimming_propulsion,true);assert.equal(decoded.meaning.arrival_asserted,false);
 assert.deepEqual(decoded.actor,text.startsWith('I ')?{kind:'deictic',role:'speaker'}:{kind:'phonemic',reference_mode:'name',phonemes:text.startsWith('Nora')?['N','AO','R','AE']:['EH','L','IH'],instance_code:null});
 assert.equal(decoded.speech_act,text.startsWith('Is ')?'question':'assertion');
 assert.deepEqual(decoded.scopes,text.includes('not ')?[{operator:'negation'}]:text.includes('yesterday')?[{operator:'time',relation:'previous_day'}]:text.includes('possible')?[{operator:'modality',mode:'possible'}]:[]);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:20_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,21);
for(const text of ['Eli is swimming across the river.','Eli swims across the river.','Eli is swimming quickly.'])assert.equal(parseNamedSentence(text),null);
execFileSync('ruby',['-Itools/lib','-rera_zero_validation','-e',"v=EraZeroValidation;d=v.load_yaml('lexicon/compound_dictionary.yaml')['entries'];m=v.load_yaml('migrations/swimming_2026_11_04.yaml');old=d.select{|e|m['previous_compound_ids'].include?(e['compound_id'])};raise 'Prior meanings changed' unless old.length==52&&v.fingerprint(old)==m['before_dictionary_fingerprint']"],{cwd:root});
console.log('PASS 21 swimming participant/state/scope contrasts with Ruby formal/MIDI parity and independent inverse; prior 52 compounds unchanged; unsupported paths remain unresolved.');

const corrupt=structuredClone(results[0].formal),body=corrupt.performance.lexical_events.find(e=>e.target_id==='MAT:000'),wrong=authority.atoms.find(a=>a.canonical_id==='MAT:001');
body.address_absolute_midi=wrong.note_path_semitones.map(n=>n+body.base_midi);
assert.throws(()=>decodeSwimmingMidi(midiFromFormal(corrupt),authority.atoms));
