import assert from 'node:assert/strict';
import fs from 'node:fs';
import {dictionaryClausePlan,clauseSyntax} from '../pages/dictionary_clauses.mjs';
import {scoreDictionaryClause} from '../pages/dictionary_clause_music.mjs';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory} from '../pages/story_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {updateWordChoice} from '../pages/dictionary_word_choices.mjs';
import {faultCorrectionPlan,composeFaultCorrection} from '../pages/fault_correction.mjs';

const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const modalScopes=[['will',['time_after_speech']],['will not',['time_after_speech','negation']],
  ['can',['ability']],['cannot',['negation','ability']],['can not',['negation','ability']],
  ['might',['modality_possible']],['might not',['modality_possible','negation']]];
let checked=0;
async function heard(line){
  const decode=bytes=>decodeSupportedMeaningWithDrafts(bytes,authority.atoms,[],{allowDraft:true});
  const melody=await decode(line.midi);
  assert.deepEqual(await decode(expandChordMidi(compactChordMidi(line.midi,authority.atoms),authority.atoms)),melody);
  checked++;return melody;
}
// Expectations are specified independently of the encoder's returned meaning.
// Both dedicated story predicates and dictionary fallbacks must retain the scopes.
for(const state of [0,1,2])for(const [modal,expected] of modalScopes){
  for(const verb of ['leave','wait','lift the box','create the tool']){
    const text=`If Nora opens the hatch, Mira ${modal} ${verb}. [${state}]`;
    const plan=storyReading(text,authority);assert(plan?.events,text+' '+JSON.stringify(plan?.question));
    const decoded=await heard(await scoreStory(plan,authority));
    assert.equal(decoded.runtime_state,state);
    assert.deepEqual(decoded.events[0].scopes,[],text);
    assert.deepEqual(decoded.events[1].scopes,expected,text);
    assert.deepEqual(decoded.relations,[{kind:'condition',events:[0,1]}],text);
  }
  for(const text of [`Mira ${modal} leave. [${state}]`,`Mira ${modal} repair the gate. [${state}]`]){
    const plan=dictionaryClausePlan(text,authority);assert(plan,text);
    const decoded=await heard(await scoreDictionaryClause(plan,0,authority));
    assert.equal(decoded.runtime_state,state);assert.deepEqual(decoded.scopes,expected,text);
  }
}
for(const [text,expected,act] of [
  ['Will Nora not leave?',['time_after_speech','negation'],'question'],
  ['Can Nora leave?',['ability'],'question'],
  ['Can Nora not leave?',['negation','ability'],'question'],
  ['Mira will not need to leave tomorrow.',['time_next_day','time_after_speech','negation','modality_necessary'],'assertion'],
  ['Mira will need to not leave.',['time_after_speech','modality_necessary','negation'],'assertion'],
  ['Mira can be repairing the gate.',['ability','aspect_ongoing'],'assertion'],
  ['Mira cannot be repairing the gate tomorrow.',['time_next_day','negation','ability','aspect_ongoing'],'assertion']]){
  const plan=dictionaryClausePlan(text,authority);assert(plan,text);
  const decoded=await heard(await scoreDictionaryClause(plan,0,authority));
  assert.deepEqual(decoded.scopes,expected,text);assert.equal(decoded.speech_act,act);
}
for(const [text,expected] of [
  ['Nora will leave and Mira cannot wait.',[['time_after_speech'],['negation','ability']]],
  ['Mira can leave before Nora will wait.',[['ability'],['time_after_speech']]],
  ['Mira will not leave. Nora might wait.',[['time_after_speech','negation'],['modality_possible']]]]){
  const plan=storyReading(text,authority);assert(plan?.events,text);
  const decoded=await heard(await scoreStory(plan,authority));
  assert.deepEqual(decoded.events.map(event=>event.scopes),expected,text);
}

// Remembering a new spelling for an existing meaning must not change its scopes.
const store=new Map(),storage={getItem:key=>store.get(key)??null,setItem:(key,value)=>store.set(key,value)};
const definition=dictionaryClausePlan('Mira might glimmerseal the gate.',authority,{offerDefinition:true});
const preference=updateWordChoice(storage,definition.readings.find(r=>r.root==='REP:110'),definition.preferenceForms);
for(const [modal,expected] of modalScopes){
  const text=`If Nora opens the hatch, Mira ${modal} glimmerseal the gate.`;
  const plan=storyReading(text,authority,{preferences:preference});assert(plan?.events,text);
  const decoded=await heard(await scoreStory(plan,authority));
  assert.equal(decoded.events[1].predicate,'REP:110');assert.deepEqual(decoded.events[1].scopes,expected);
}
for(const [text,expected] of [
  ['Mira will need to resolve the sensor error.',['time_after_speech','necessary']],
  ['Can Mira need to resolve the sensor error?',['ability','necessary']]]){
  const plan=faultCorrectionPlan(text);assert(plan,text);
  const decoded=await heard(await composeFaultCorrection(plan,authority));assert.deepEqual(decoded.scopes,expected);
}
for(const text of ['Mira cannot not leave.','Mira will leaves.','Mira can left.']){
  assert.equal(dictionaryClausePlan(text,authority),null,text);
}
assert.deepEqual(clauseSyntax('Mira will not need to leave tomorrow.').scopes,
  ['time_next_day','time_after_speech','negation','modality_necessary']);
console.log(`PASS ${checked} independently decoded melody/chord sentence pairs: future, ability, possibility, negation, nesting and saved word choices.`);
