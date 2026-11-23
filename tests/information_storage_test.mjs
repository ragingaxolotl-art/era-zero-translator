import assert from 'node:assert/strict';
import fs from 'node:fs';
import crypto from 'node:crypto';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {scoreSongText} from '../pages/song_lines.mjs';
import {readSongLine} from '../pages/song_readback.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi,midiFromNoteTimeline} from '../pages/performance_codec.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {analyzeEnglish} from '../pages/english.mjs';
import {addLocalCompound,emptyLocalCompounds} from '../pages/local_compounds.mjs';
import {storyAdjectiveLibrary} from '../pages/story_saved_adjectives.mjs';
import {erasurePropertyNeedsPhase} from '../pages/information_operations.mjs';
import {encodeName} from '../pages/names.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const save='CMP:58cfa479709294b9809be1b7',keep='CMP:cac584a394535e4912c75b5a',stay='CMP:ec3a1fad0ed828279e948372';
let checks=0;
async function hear(text,{predicate=save,roles=['actor','target'],entities=roles.map((_,i)=>i),scopes=[],state=1,act='assertion',answers={},adjectives}={}){
  const plan=storyReading(text+' ['+state+']',authority,{answers,adjectives});
  assert(plan?.events,text+' '+JSON.stringify(plan));
  const result=await scoreStory(plan,authority),heard=decodeStoryMidi(result.midi,authority.atoms,adjectives);
  assert.deepEqual(decodeStoryMidi(expandChordMidi(compactChordMidi(result.midi,authority.atoms),authority.atoms),authority.atoms,adjectives),heard);
  assert.equal(heard.events[0].predicate,predicate,text);
  assert.deepEqual(heard.events[0].arguments.map(a=>a.role),roles,text);
  assert.deepEqual(heard.events[0].arguments.map(a=>a.entity),entities,text);
  assert.deepEqual(heard.events[0].scopes,scopes,text);
  assert.equal(heard.runtime_state,state);assert.equal(heard.speech_act,act);checks++;
  return {...result,plan,heard};
}
for(const [base,third,past,ongoing] of [['save','saves','saved','saving'],['store','stores','stored','storing']])for(const state of [0,1,2])for(const subject of ['Nora','We']){
  const singular=subject==='Nora';
  for(const [text,scopes,act='assertion'] of [
    [`${subject} ${singular?third:base} the file.`,[]],
    [`${subject} ${past} the file.`,['time_before_speech']],
    [`${subject} ${singular?'does':'do'} not ${base} the file.`,['negation']],
    [`${subject} did not ${base} the file.`,['time_before_speech','negation']],
    [`${subject} ${singular?'is':'are'} ${ongoing} the file.`,['aspect_ongoing']],
    [`${subject} ${singular?'was':'were'} not ${ongoing} the file.`,['time_before_speech','negation','aspect_ongoing']],
    [`${subject} will not ${base} the file.`,['time_after_speech','negation']],
    [`${subject} might not ${base} the file.`,['modality_possible','negation']],
    [`${subject} cannot ${base} the file.`,['negation','ability']],
    [`${subject} ${singular?'needs':'need'} to ${base} the file.`,['modality_necessary']],
    [`Did ${subject} ${base} the file?`,['time_before_speech'],'question'],
    [`Can ${subject} ${base} the file?`,['ability'],'question']
  ]){
    const {heard}=await hear(text,{state,scopes,act});
    assert.deepEqual(heard.entities[1].identity.phonemes,(await encodeName('file')).phonemes);
    if(singular)assert.deepEqual(heard.entities[0].identity.phonemes,(await encodeName('Nora')).phonemes);
    else assert.deepEqual(heard.entities[0].identity,{kind:'deictic',role:'speaker_group'});
  }
}
for(const state of [0,1,2])for(const [text,scopes] of [['Save the file.',[]],['Please do not store the record.',['negation']]]){
  const {heard}=await hear(text,{state,scopes,act:'command'});
  assert.deepEqual(heard.entities[0].identity,{kind:'deictic',role:'addressee'});
}
for(const state of [0,1,2]){
  for(const [text,predicate,roles,scopes] of [
    ['The file was stored.','DAT:000',['bearer'],['time_before_speech']],
    ['The file will not be stored.','DAT:000',['bearer'],['time_after_speech','negation']],
    ['Nora keeps the file stored.',keep,['cause','bearer'],[]],
    ['The file stayed stored.',stay,['bearer'],['time_before_speech']],
    ['The file remains stored.',stay,['bearer'],[]]
  ]){
    const {heard}=await hear(text,{state,predicate,roles,scopes});
    if(predicate!=='DAT:000')assert.equal(heard.events[0].condition,'DAT:000');
  }
}
const described=await hear('The awake robot saved the stored file.',{scopes:['time_before_speech']});
assert.deepEqual(described.heard.events[0].arguments.map(a=>a.properties),[['LIF:001'],['DAT:000']]);
const plural=await hear('The routine saved the records.',{scopes:['time_before_speech']});assert.equal(plural.heard.entities[1].plural,true);
const alternatives=await hear('Nora saved the file or the log.',{scopes:['time_before_speech']});
assert.equal(alternatives.heard.events[0].arguments[1].coordination,'any_of');assert.equal(alternatives.heard.events[0].arguments[1].alternatives.length,1);
const chain=await hear('Nora saved the file. Mira copied it.',{scopes:['time_before_speech']});
assert.equal(chain.heard.events[1].predicate,'CMP:9ea919967152aa85bc1c7169');assert.deepEqual(chain.heard.events[1].arguments.map(a=>a.entity),[2,1]);
const conditional=await hear('If Nora saves the file, Mira might not delete it.');
assert.deepEqual(conditional.heard.relations,[{kind:'condition',events:[0,1]}]);assert.equal(conditional.heard.events[1].arguments[1].entity,1);
assert.deepEqual(conditional.heard.events[1].scopes,['modality_possible','negation']);
const before=await hear('The file was stored before Nora deleted it.',{predicate:'DAT:000',roles:['bearer'],scopes:['time_before_speech']});
assert.deepEqual(before.heard.relations,[{kind:'before',events:[0,1]}]);assert.equal(before.heard.events[1].arguments[1].entity,0);
for(const text of ['Nora saved the game.','Nora stored the box.','Nora saved the file or Mira.','The box is stored.','Nora keeps the box stored.']){
  const plan=storyReading(text,authority);assert(plan?.question,text);const {key}=plan.question;
  assert.equal(storyReading(text,authority,{answers:{[key]:'other'}}),null,text);
  const chosen=storyReading(text,authority,{answers:{[key]:'stored'}});assert(chosen?.events,text);
  assert.equal(await scoreSongText(text,authority,()=>{throw Error('No unrelated fallback');}),null,text);
}
for(const text of ['Nora saved the file to the folder.','Nora saved only the file.','Nora has saved the file.',
  'The file was saved by Nora.','The saved file is awake.','Nora saved the file as version two.',
  'Nora saved Nora.','Nora saved the file or Nora.','The program saves the program.']){
  assert(!storyReading(text,authority)?.events,text);
  assert.equal(await scoreSongText(text,authority,()=>{throw Error('No invented template');}),null,text);
}
for(const form of ['save','saves','saved','saving','store','stores','stored','storing'])assert(analyzeEnglish(`Nora ${form} the file.`,authority).term_coverage.some(t=>t.term===form&&t.matches.some(m=>m.target_id===save)),form);
assert.match(JSON.stringify(await readSongLine(described.midi,authority.atoms,[],false)),/save|retention|commit/i);

// Personal definitions stay distinct from the new public adjective, including nested words.
let registry=await addLocalCompound(emptyLocalCompounds(),{label:'stored',definition:'A material bearer is awake.',part_of_speech:'adjective',
  components:[{target_id:'MAT:000',relation:'qualifies'},{target_id:'LIF:001',relation:'head'}],roles:[{role:'bearer',definition:'The described participant'}]},authority);
registry=await addLocalCompound(registry,{label:'recordedhere',definition:'An awake retained information item.',part_of_speech:'adjective',
  components:[{target_id:'LIF:001',relation:'qualifies'},{target_id:'DAT:000',relation:'head'}],roles:[{role:'bearer',definition:'The retained item'}]},authority);
const inner=registry.entries.find(e=>e.definition.label==='recordedhere').compound_id;
registry=await addLocalCompound(registry,{label:'nestedrecord',definition:'The retained information item described by recordedhere.',part_of_speech:'adjective',
  components:[{target_id:'MAT:000',relation:'qualifies'},{target_id:inner,relation:'head'}],roles:[{role:'bearer',definition:'The retained item'}]},authority);
const adjectives=await storyAdjectiveLibrary(registry,authority),text='Nora keeps the file stored.';
const question=storyReading(text,authority,{adjectives}).question;assert.equal(question.key,'condition0Sense');
const personal=await hear(text,{predicate:keep,roles:['cause','bearer'],adjectives,answers:{[question.key]:'saved'}});
assert.equal(personal.heard.events[0].condition.local_id,registry.entries.find(e=>e.definition.label==='stored').compound_id);
const published=await hear(text,{predicate:keep,roles:['cause','bearer'],adjectives,answers:{[question.key]:'dictionary'}});
assert.equal(published.heard.events[0].condition,'DAT:000');
for(const quality of ['stored','recordedhere','nestedrecord']){
  const options=quality==='stored'?{}:{adjectives,answers:quality==='nestedrecord'?{property0ObjectnestedrecordSlot1:'1'}:{}};
  const invalidText=`Nora deleted the ${quality} file.`;
  const plan=storyReading(invalidText,authority,options);assert.equal(plan?.unsupported,true,invalidText);assert.match(plan.reason,/before and after/);
  assert.equal(await scoreSongText(invalidText,authority,()=>{throw Error('No unrelated fallback');},[],options.adjectives),null);
}
assert.equal(erasurePropertyNeedsPhase(null,adjectives),false);
// A forged event cannot bypass distinct actors or the before/after requirement.
for(const edit of [p=>p.events[0].arguments[1].entity=0,p=>p.events[0].arguments[1].role='bearer',p=>p.events[0].arguments.pop(),
  p=>p.events[0].arguments[1].alternatives=[{entity:0,properties:[]}],
  p=>{p.events[0].predicate='erase_stored_object';p.events[0].arguments[1].properties=['DAT:000'];}]){
  const plan=structuredClone(described.plan);edit(plan);if(plan.events[0].arguments[1]?.alternatives)plan.events[0].arguments[1].coordination='any_of';
  const {midi}=await scoreStory(plan,authority);assert.throws(()=>decodeStoryMidi(midi,authority.atoms));
}
const forged=structuredClone(described.plan);forged.events[0].predicate='erase_stored_object';
const nested=adjectives.byLabel.get('nestedrecord');forged.events[0].arguments[1].properties=[{local_id:nested.id,bindings:nested.slots.map(()=>1)}];
forged.adjectives=adjectives;
const forgedMidi=(await scoreStory(forged,authority)).midi;assert.throws(()=>decodeStoryMidi(forgedMidi,authority.atoms,adjectives));
const {midi}=await hear('Nora saved the file.',{scopes:['time_before_speech']});
const observed=decodeStrictMusicMidi(midi,authority.atoms,{allowDraftInformationPassage:true});
for(const root of ['DAT:000','ORI:110','ORI:211']){
  const component=observed.tokens.find(t=>t.kind==='root'&&t.root_id===root);assert(component);
  const timeline=notesFromMidi(midi),attack=timeline.notes.findIndex(n=>n.start_tick===component.start_tick);timeline.notes[attack+2].midi+=1;
  assert.throws(()=>decodeStoryMidi(midiFromNoteTimeline(timeline.notes,timeline.division,timeline.tempos[0].value),authority.atoms),root);
}
const legacy=JSON.parse(fs.readFileSync(new URL('./information_storage_legacy_2026_11_23.json',import.meta.url))),hash=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
for(const old of legacy.cases){
  const {midi}=await scoreStory(storyReading(old.input,authority,{answers:old.answers}),authority);
  assert.deepEqual(decodeStoryMidi(midi,authority.atoms),old.meaning);assert.equal(hash(midi),old.melody_sha256);assert.equal(hash(compactChordMidi(midi,authority.atoms)),old.chords_sha256);
}
console.log('PASS '+checks+' independently decoded save/store/stored pairs; 18 unchanged performances, scopes, roles, private compounds, sense choices and malformed-score rejection.');
