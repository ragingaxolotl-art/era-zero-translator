import {composePainPreference} from '../pages/pain_preference.mjs';
import {midiFromPainPreference,decodePainPreferenceMidi} from '../pages/pain_preference_music.mjs';
import {composeCuriosity} from '../pages/curiosity.mjs';
import {midiFromCuriosity,decodeCuriosityMidi} from '../pages/curiosity_music.mjs';
// Reconcile the original requirements against execution, without approving vocabulary.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {encodeName} from '../pages/names.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const root=new URL('..',import.meta.url),read=p=>JSON.parse(fs.readFileSync(new URL(p,root)));
const authority=read('pages/data/index.json'),records=read('reviews/foundation_extension_candidates.json').records,requirements=read('tests/desire_preference_requirements.json');
const load=id=>({...read('pages/'+authority.resolution_files[id]).variants['assertion:1'],authority});
const supported=new Set(['relative_not_absolute','reversed','negation','question','past','participant_change','runtime_independence','kind_not_cup']);
const results=[];const sounds=new Map();
for(const requirement of requirements.cases){
 const row={id:requirement.id,input:requirement.input,required:requirement.required,must_not_infer:requirement.must_not_infer};
 let result;
 if(requirement.id==='both_unpleasant'){
  const choices={experiencer:'Eli',interpretation:'expected_outcome',context:'this session',comparisonTarget:'other_alternative'};
  await assert.rejects(composePainPreference(requirement.input,{allowDraft:true}));
  const document=await composePainPreference(requirement.input,{allowDraft:true,...choices}),bytes=await midiFromPainPreference(document,authority,{allowDraft:true}),recovered=decodePainPreferenceMidi(bytes,authority.atoms,{allowDraft:true});
  const foundation=records.find(r=>r.sound_code===1);
  assert.equal(recovered.foundation_id,foundation.foundation_id);assert.match(foundation.definition,/does not entail.*pleasantness.*objective superiority/);
  assert.deepEqual(recovered.holder.phonemes,(await encodeName('Nora')).phonemes);
  assert.equal(recovered.more_painful_role,'comparison_standard');assert.equal(recovered.restriction_scope,'reference_descriptions_not_preference_polarity');
  assert.deepEqual(recovered.pain_comparison.left.stimulus,recovered.comparison_standard);assert.deepEqual(recovered.pain_comparison.right.stimulus,recovered.target);
  assert.notEqual(recovered.target.instance_code,recovered.comparison_standard.instance_code);
  assert.deepEqual(recovered.pain_comparison.left.outcome.experiencer.phonemes,(await encodeName('Eli')).phonemes);
  assert.equal(recovered.pain_comparison.left.relation,'expected_outcome');assert.equal(recovered.pain_comparison.relation,'greater_than');
  assert.equal(recovered.speech_act,'assertion');assert.equal(recovered.runtime_state,1);assert.deepEqual(recovered.scopes,[]);
  results.push({...row,status:'candidate_semantic_checks_pass_with_explicit_context',choices,recovered,limits:'Original sentence requires clarification of pain experiencer, reading, context and comparison target. Draft meaning and strict MIDI checked here; separate synthetic WAV evidence exists. No canonical admission, held-out coverage or physical recording proof.'});continue;
 }
 if(requirement.id==='curiosity_not_attention'){
  const document=await composeCuriosity(requirement.input,{allowDraft:true}),bytes=await midiFromCuriosity(document,authority,records,{allowDraft:true}),recovered=await decodeCuriosityMidi(bytes,authority.atoms,records,{allowDraft:true});
  assert.equal(recovered.predicate,'epistemic_curiosity');
  assert.equal(recovered.desire_foundation_id,records.find(r=>r.sound_code===0).foundation_id);
  assert.deepEqual(recovered.experiencer.phonemes,(await encodeName('Orin')).phonemes);
  assert.deepEqual(recovered.inquiry.topic.anchor.phonemes,(await encodeName('map')).phonemes);
  assert.equal(recovered.inquiry.topic.anchor.reference_mode,'definite_nominal');
  assert.equal(recovered.inquiry.question_selection,'contextually_relevant_unresolved');
  assert.equal(recovered.inquiry.specific_question_supplied,false);assert.equal(recovered.inquiry.answer_commitment,'none');
  assert.equal(recovered.outcome_commitment,'desired_not_asserted');
  assert.equal(recovered.desired_outcome,'same_experiencer_gains_contextually_relevant_information_resolving_some_inquiry_uncertainty');
  assert.match(recovered.criterion,/itself motivationally attractive/);assert.match(recovered.criterion,/does not require pleasure, current attention/);
  assert.equal(recovered.speech_act,'assertion');assert.equal(recovered.runtime_state,1);assert.deepEqual(recovered.scopes,[]);
  results.push({...row,status:'candidate_semantic_checks_pass',recovered,limits:'Selected epistemic reading, shared convention and strict MIDI only. Does not establish all curiosity readings, canonical admission or physical audio evidence.'});continue;
 }
 try{result=await composeFoundationSentence(requirement.input,authority,records,load,{allowDraft:true});}
 catch(error){
  assert(!supported.has(requirement.id),`${requirement.id}: ${error.message}`);
  results.push({...row,status:'not_composed',diagnostic:error.message});continue;
 }
 if(!supported.has(requirement.id)){
  results.push({...row,status:'composition_needs_semantic_review',diagnostic:'Composition alone does not prove the original acceptance obligations.'});continue;
 }
 const bytes=midiFromFormal(result.formal),decoded=await decodeFoundationSentenceMidi(bytes,authority.atoms,records,{allowDraft:true}),m=decoded.meaning;
 assert.equal(m.predicate.foundation_id,records.find(r=>r.sound_code===1).foundation_id);
 assert.deepEqual(Object.keys(m.arguments).sort(),['comparison_standard','experiencer','target']);
 const holder=requirement.id==='participant_change'?'Eli':'Nora',reverse=requirement.id==='reversed';
 for(const [role,label] of [['experiencer',holder],['target',reverse?'coffee':'tea'],['comparison_standard',reverse?'tea':'coffee']]){
  assert.deepEqual(m.arguments[role].reference.phonemes,(await encodeName(label)).phonemes);
  assert.equal(m.arguments[role].type,role==='experiencer'?'entity':'kind');
 }
 assert.equal(m.runtime_state,requirement.id==='runtime_independence'?2:1);
 assert.equal(decoded.speech_act,requirement.id==='question'?'question':'assertion');
 const expectedScopes=requirement.id==='negation'?[{operator:'negation'}]:requirement.id==='past'?[{operator:'time',relation:'previous_day'}]:[];
 assert.deepEqual(m.scopes,expectedScopes);
 // Entire recovered structure is bounded to the preference and these arguments;
 // no drinking, ownership, pleasure, choice or desire predicate is introduced.
 assert.deepEqual(Object.keys(m).sort(),['arguments','predicate','runtime_state','scopes']);
 sounds.set(requirement.id,Buffer.from(bytes).toString('base64'));
 results.push({...row,status:'candidate_semantic_checks_pass',recovered:decoded,limits:'Candidate registry semantics and strict MIDI only; no listening or canonical admission evidence.'});
}
const baseline=sounds.get('relative_not_absolute');
for(const id of ['reversed','negation','question','past','participant_change','runtime_independence'])assert.notEqual(sounds.get(id),baseline,id);
assert.equal(sounds.get('kind_not_cup'),baseline);
const counts=Object.fromEntries([...new Set(results.map(r=>r.status))].map(s=>[s,results.filter(r=>r.status===s).length]));
const report={scope:'Original authored acceptance requirements, executed against candidate preview. Not held-out validation or vocabulary approval.',completion_proven:false,counts,results};
fs.writeFileSync(new URL('reports/foundation_requirements_audit.json',root),JSON.stringify(report,null,2)+'\n');
const lines=['# Original desire/preference requirements audit','',report.scope,'','Full translator completion: **not established**.','','| Requirement | Input | Current evidence |','|---|---|---|',...results.map(r=>`| ${r.id} | ${r.input.replaceAll('|','\\|')} | ${r.status} |`),'','Passing cases recover holder, ordered alternatives, kind/entity typing, speech act, scope and runtime from MIDI. Changed direction, holder, negation, time, question and runtime have distinct performances. Curiosity now recovers epistemic interest and unresolved topic inquiry without asserting information acquisition or current attention. The painful-treatment preference passes only with explicit contextual choices; this is not automatic interpretation of the underspecified sentence. Missing cases include object desire, temporariness, other modified noun phrases and preference combined with choice.',''];
fs.writeFileSync(new URL('reports/foundation_requirements_audit.md',root),lines.join('\n'));
console.log(JSON.stringify(counts));
