import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {decodeFeltConditionMidi} from '../pages/felt_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),results=[];
const profiles={sad:['sad_felt_mood',[19,18,11],'sorrow_or_low_spirits'],happy:['happy_felt_mood',[13,12,11],'glad_or_content_mood'],hungry:['felt_hunger',[15,14,11],'food_directed_bodily_demand'],thirsty:['felt_thirst',[16,14,11],'water_directed_bodily_demand'],tired:['felt_fatigue',[17,11],'physical_or_mental_weariness']};
for(const [adjective,[predicate,codes,quality]] of Object.entries(profiles))for(const state of [0,1,2]){
 for(const text of [`Eli is ${adjective}.`,`Nora is ${adjective}.`,`I am ${adjective}.`,`Eli is not ${adjective}.`,`Is Eli ${adjective}?`,`Eli was ${adjective} yesterday.`,`Eli will be ${adjective} tomorrow.`,`It is possible that Eli is not ${adjective}.`]){
  const input=text+` [${state}]`,p=parseNamedSentence(input);assert(p,input);
  const r=await composeNamedSentence(input,{authority},p.requiredInterpretation?{interpretation:'future_assertion'}:{});results.push(r);
  const bytes=midiFromFormal(r.formal),d=decodeFeltConditionMidi(bytes,authority.atoms);
  assert.equal(d.predicate,predicate);assert.equal(d.runtime_state,state);assert.deepEqual(d.convention_codes,codes);
  assert.deepEqual(d.participants.experiencer,text.startsWith('I ')?{kind:'deictic',role:'speaker'}:{kind:'phonemic',reference_mode:'name',phonemes:text.startsWith('Nora')?['N','AO','R','AE']:['EH','L','IH'],instance_code:null});
  assert.equal(d.speech_act,text.startsWith('Is ')?'question':'assertion');
  assert.deepEqual(d.scopes,[...(text.startsWith('It is possible')?[{operator:'modality',mode:'possible'}]:[]),...(text.includes('yesterday')?[{operator:'time',relation:'previous_day'}]:text.includes('tomorrow')?[{operator:'time',relation:'next_day'}]:[]),...(text.includes('not ')?[{operator:'negation'}]:[])]);
  assert.deepEqual(d.meaning,{consciously_felt_self_condition:true,focal_self_is_bound_experiencer:true,quality,measured_physiological_deficit_asserted:false,care_behavior_asserted:false,intended_action_asserted:false,sleep_or_dormancy_asserted:false,damage_asserted:false});
  const roots=decodeStrictMusicMidi(bytes,authority.atoms).tokens.filter(t=>t.kind==='root');assert.equal(roots.at(-1).root_id,'MIN:001');assert.equal(roots.at(-1).runtime_state,state);assert(roots.slice(0,-1).every(t=>t.runtime_state===null));
 }
}
const refs=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:80_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,refs[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(refs[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
for(const word of Object.keys(profiles))for(const text of [`Eli is ${word} for power.`,`Eli is ${word} of the task.`])assert.equal(parseNamedSentence(text),null,text);
const fixtures=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_controlled_english','-rera_zero_presentation','-rbase64','-e',String.raw`
 d=EraZeroValidation.load_yaml('lexicon/compound_dictionary.yaml')['entries'];m=EraZeroValidation.load_yaml('migrations/felt_conditions_2026_11_04.yaml')
 old=d.select{|e|m['previous_compound_ids'].include?(e['compound_id'])};raise 'Existing 43 meanings changed' unless old.length==43&&EraZeroValidation.fingerprint(old)==m['before_dictionary_fingerprint']
 newer=EraZeroValidation.load_yaml('migrations/sadness_2026_11_04.yaml');prior=d.select{|e|newer['previous_compound_ids'].include?(e['compound_id'])};raise 'Previous 50 definitions changed' unless prior.length==50&&EraZeroValidation.fingerprint(prior)==newer['before_dictionary_fingerprint']
 m['added_compounds'].merge!(newer['added_compounds'])
 c=EraZeroControlledEnglish::Compiler.new;out=[]
 m['added_compounds'].each do |key,id|
  label=d.find{|e|e['compound_id']==id}['display_title']
  [0,1,2].each{|state|f=EraZeroRenderer.render(c.compile!(%Q{ASSERT "#{label}" [#{state}] ROLE experiencer "identified other" [2].}));out<<{key:key,state:state,formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}}
 end
 puts JSON.generate(out)
`],{cwd:root,encoding:'utf8',maxBuffer:18_000_000}));
for(const r of fixtures){assert.deepEqual(await renderLexicalOccurrences(r.formal.semantic_ir,authority),r.formal.performance.lexical_events);const d=decodeFeltConditionMidi(Buffer.from(r.midi,'base64'),authority.atoms);assert.equal(d.predicate,r.key);assert.equal(d.runtime_state,r.state);assert.deepEqual(d.participants.experiencer,{kind:'lexical',root_id:'LIF:010',runtime_state:2});}
for(const id of ['LIF:001','MIN:001']){
 const f=structuredClone(results[8].formal),event=f.performance.lexical_events.find(e=>e.target_id===id),replacement=authority.atoms.find(a=>a.canonical_id===id.replace('001','000'));
 event.address_absolute_midi=replacement.note_path_semitones.map(n=>n+event.base_midi);const bytes=midiFromFormal(f);decodeStrictMusicMidi(bytes,authority.atoms);assert.throws(()=>decodeFeltConditionMidi(bytes,authority.atoms));
}
console.log(`Felt conditions: ${results.length} ordinary adjective/state/scope cases and ${fixtures.length} controlled dependency/state cases preserve experiencer, distinct feeling and Ruby/browser formal/MIDI parity. All prior 43 definitions remain exact; wrong-root music and figurative substitutions are rejected.`);

const sad=await composeNamedSentence('Nora is sad.',{authority});
const notHappy=await composeNamedSentence('Nora is not happy.',{authority});
assert.notDeepEqual(midiFromFormal(sad.formal),midiFromFormal(notHappy.formal));
assert.equal(decodeFeltConditionMidi(midiFromFormal(sad.formal),authority.atoms).meaning.quality,'sorrow_or_low_spirits');
assert.deepEqual(decodeFeltConditionMidi(midiFromFormal(notHappy.formal),authority.atoms).scopes,[{operator:'negation'}]);
