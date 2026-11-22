import assert from 'node:assert/strict';
import fs from 'node:fs';
import {createHash} from 'node:crypto';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {dictionaryClausePlan} from '../pages/dictionary_clauses.mjs';
import {scoreDictionaryClause,decodeDictionaryClauseMidi} from '../pages/dictionary_clause_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi,midiFromNoteTimeline} from '../pages/performance_codec.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {encodeName} from '../pages/names.mjs';
import {ERASURE} from '../pages/information_operations.mjs';

const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
let checks=0;
async function hear(text,{scopes=[],state=1,act='assertion',answers={},event=0}={}){
  const plan=storyReading(text+' ['+state+']',authority,{answers});
  assert(plan?.events,text+' '+JSON.stringify(plan?.question));
  const {midi}=await scoreStory(plan,authority);
  const heard=await decodeSupportedMeaningWithDrafts(midi,authority.atoms,[],{allowDraft:true});
  const chords=expandChordMidi(compactChordMidi(midi,authority.atoms),authority.atoms);
  assert.deepEqual(await decodeSupportedMeaningWithDrafts(chords,authority.atoms,[],{allowDraft:true}),heard);
  assert.equal(heard.events[event].predicate,ERASURE,text);
  assert.deepEqual(heard.events[event].scopes,scopes,text);
  assert.deepEqual(heard.events[event].arguments.map(a=>a.role),['actor','target'],text);
  assert.equal(heard.runtime_state,state,text);assert.equal(heard.speech_act,act,text);
  checks++;return {heard,midi,plan};
}
for(const state of [0,1,2]){
  for(const [subject,target,third] of [['Nora','file',true],['Mira','log',true],['We','record',false],['The routine','document',true]]){
    const s=subject,o='the '+target;
    for(const [text,scopes,act] of [
      [`${s} ${third?'deletes':'delete'} ${o}.`,[]],
      [`${s} deleted ${o}.`,['time_before_speech']],
      [`${s} ${third?'does':'do'} not delete ${o}.`,['negation']],
      [`${s} did not delete ${o}.`,['time_before_speech','negation']],
      [`${s} ${third?'is':'are'} deleting ${o}.`,['aspect_ongoing']],
      [`${s} ${third?'was':'were'} not deleting ${o}.`,['time_before_speech','negation','aspect_ongoing']],
      [`${s} will delete ${o}.`,['time_after_speech']],
      [`${s} will not delete ${o}.`,['time_after_speech','negation']],
      [`${s} might not delete ${o}.`,['modality_possible','negation']],
      [`${s} cannot delete ${o}.`,['negation','ability']],
      [`${s} ${third?'needs':'need'} to delete ${o}.`,['modality_necessary']],
      [`Did ${s} delete ${o}?`,['time_before_speech'],'question'],
      [`Can ${s} delete ${o}?`,['ability'],'question']]){
      const {heard}=await hear(text,{state,scopes,act:act||'assertion'});
      assert.equal(heard.entities.length,2);
      if(subject==='We')assert.deepEqual(heard.entities[0].identity,{kind:'deictic',role:'speaker_group'});
      else assert.deepEqual(heard.entities[0].identity.phonemes,(await encodeName(subject.replace(/^The /,''))).phonemes);
      assert.deepEqual(heard.entities[1].identity.phonemes,(await encodeName(target)).phonemes);
    }
  }
}
for(const [text,scopes] of [['Delete the file.',[]],['Please delete this record.',[]],
  ['Do not delete the backup.',['negation']], ["Please don't delete the log.",['negation']]]){
  const {heard}=await hear(text,{scopes,act:'command'});
  assert.deepEqual(heard.entities[0].identity,{kind:'deictic',role:'addressee'});
}
for(const text of ['Nora found the file. Mira deleted it.','Nora found a file and deleted it.']){
  const {heard}=await hear(text,{event:1,scopes:['time_before_speech']});
  assert.equal(heard.events[1].arguments[1].entity,1);
  assert.equal(heard.events[1].arguments[0].entity,text.includes('Mira')?2:0);
}
const condition=await hear('If Nora finds the file, Mira will not delete it.',{event:1,scopes:['time_after_speech','negation']});
assert.deepEqual(condition.heard.relations,[{kind:'condition',events:[0,1]}]);
assert.equal(condition.heard.events[1].arguments[1].entity,1);
const plural=await hear('The routine deleted the files.',{scopes:['time_before_speech']});
assert.equal(plural.heard.entities[1].plural,true);
const alternate=await hear('Nora will delete the file or the backup.',{scopes:['time_after_speech']});
assert.equal(alternate.heard.events[0].arguments[1].coordination,'any_of');
assert.equal(alternate.heard.events[0].arguments[1].alternatives.length,1);
for(const text of ['Nora deleted Mira.','Nora deleted the child.','Nora deleted the file or the child.']){
  const p=storyReading(text,authority);assert(p?.question,text);
  assert.equal(storyReading(text,authority,{answers:{[p.question.key]:'other'}}),null,text);
}
const named=await hear('Nora deleted Mira.',{scopes:['time_before_speech'],answers:{information0:'stored'}});
const reversed=await hear('Mira deleted Nora.',{scopes:['time_before_speech'],answers:{information0:'stored'}});
assert.notDeepEqual(named.heard.entities,reversed.heard.entities);
for(const text of ['Nora deleted the file from the folder.','Nora deleted only the file.','Nora has deleted the file.','The file was deleted.',
  'Nora deleted the file because Mira asked.','Nora might delete the file yesterday.']){
  // The final example must retain its calendar scope if accepted; it must not
  // silently discard yesterday, regardless of which parser supports the wording.
  const p=storyReading(text,authority);
  if(text.endsWith('yesterday.')){
    if(p?.events)assert(p.events[0].scopes.includes('time_previous_day'));
  }else assert(!p?.events,text);
}
// Direct dictionary clauses select the existing appropriate definition, instead
// of labeling a completed fact as a requested operation.
for(const [text,id,scopes] of [['Nora deleted the file.','GSE:045',['time_before_speech']],
  ['Nora is deleting the file.','GSE:044',['aspect_ongoing']],
  ['Nora needs to delete the file.','GSE:043',['modality_necessary']]]){
  const p=dictionaryClausePlan(text,authority);assert(p?.readings.length,text);
  assert.equal(p.readings[0].sense.sense_id,id);
  const {midi}=await scoreDictionaryClause(p,0,authority),d=decodeDictionaryClauseMidi(midi,authority.atoms);
  assert.equal(d.predicate,ERASURE);assert.deepEqual(d.scopes,scopes);
}
// Scores that were already supported retain their exact audible data.
const legacy=JSON.parse(fs.readFileSync(new URL('./information_erasure_legacy_cases.json',import.meta.url)));
for(const row of legacy.cases){
  const p=dictionaryClausePlan(row.text,authority),s=await scoreDictionaryClause(p,0,authority);
  assert.equal(createHash('sha256').update(s.midi).digest('hex'),row.sha256);
  assert.deepEqual(decodeDictionaryClauseMidi(s.midi,authority.atoms),row.meaning);
}
// Corrupt the result atom: a valid operation marker must not authenticate it.
const result=await hear('Nora deleted the file.',{scopes:['time_before_speech']});
const observed=decodeStrictMusicMidi(result.midi,authority.atoms,{allowDraftInformationPassage:true});
const retained=observed.tokens.find(t=>t.kind==='root'&&t.root_id==='DAT:000');assert(retained);
const timeline=notesFromMidi(result.midi),attack=timeline.notes.findIndex(n=>n.start_tick===retained.start_tick);
timeline.notes[attack+2].midi+=1;
assert.throws(()=>decodeStoryMidi(midiFromNoteTimeline(timeline.notes,timeline.division,timeline.tempos[0].value),authority.atoms));
console.log('PASS '+checks+' reusable erasure sentences in melody/chords, existing score compatibility, phase definitions, reference/scopes and corrupt-result rejection.');
