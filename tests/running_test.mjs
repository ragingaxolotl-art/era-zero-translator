import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeRunningMidi} from '../pages/running_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),results=[];
for(const state of [0,1,2])for(const text of ['Eli is running.','Nora is running.','I am running.','Eli is not running.','Is Eli running?','Eli was running yesterday.','It is possible that Eli is running.']){
 const input=text+` [${state}]`,r=await composeNamedSentence(input,{authority}),decoded=decodeRunningMidi(midiFromFormal(r.formal),authority.atoms);results.push(r);
 assert.equal(decoded.runtime_state,state);assert.deepEqual(decoded.convention_codes,[23,20]);
 assert.equal(decoded.meaning.gait,'running');assert.equal(decoded.meaning.airborne_interval_required,false);assert.equal(decoded.meaning.speed_threshold_asserted,false);assert.equal(decoded.meaning.arrival_asserted,false);
 assert.deepEqual(decoded.actor,text.startsWith('I ')?{kind:'deictic',role:'speaker'}:{kind:'phonemic',reference_mode:'name',phonemes:text.startsWith('Nora')?['N','AO','R','AE']:['EH','L','IH'],instance_code:null});
 assert.equal(decoded.speech_act,text.startsWith('Is ')?'question':'assertion');
 assert.deepEqual(decoded.scopes,text.includes('not ')?[{operator:'negation'}]:text.includes('yesterday')?[{operator:'time',relation:'previous_day'}]:text.includes('possible')?[{operator:'modality',mode:'possible'}]:[]);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:20_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,21);
for(const text of ['Nora runs the program.','Eli is running quickly.'])assert.equal(parseNamedSentence(text),null);
execFileSync('ruby',['-Itools/lib','-rera_zero_validation','-e',"v=EraZeroValidation;d=v.load_yaml('lexicon/compound_dictionary.yaml')['entries'];m=v.load_yaml('migrations/running_2026_11_04.yaml');old=d.select{|e|m['previous_compound_ids'].include?(e['compound_id'])};raise 'Prior meanings changed' unless old.length==55&&v.fingerprint(old)==m['before_dictionary_fingerprint']"],{cwd:root});
console.log('PASS 21 running participant/state/scope contrasts with Ruby formal/MIDI parity and independent inverse; prior 55 compounds unchanged; unsupported paths remain unresolved.');

const corrupt=structuredClone(results[0].formal),body=corrupt.performance.lexical_events.find(e=>e.target_id==='MAT:000'),wrong=authority.atoms.find(a=>a.canonical_id==='MAT:001');
body.address_absolute_midi=wrong.note_path_semitones.map(n=>n+body.base_midi);
assert.throws(()=>decodeRunningMidi(midiFromFormal(corrupt),authority.atoms));

const swimming=await composeNamedSentence('Eli is swimming.',{authority});
assert.throws(()=>decodeRunningMidi(midiFromFormal(swimming.formal),authority.atoms));
const motionTemplate=JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files['MOV:111'],root)));
const motion=await composeNamedSentence('Eli is moving toward Nora.',motionTemplate.variants['assertion:1']);
assert.throws(()=>decodeRunningMidi(midiFromFormal(motion.formal),authority.atoms));
assert.notDeepEqual(midiFromFormal(swimming.formal),midiFromFormal(results[0].formal));
console.log('PASS running remains distinct from swimming and generic displacement.');
