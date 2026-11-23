import assert from 'node:assert/strict';
import fs from 'node:fs';
import crypto from 'node:crypto';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {readSongLine} from '../pages/song_readback.mjs';
import {addLocalCompound,emptyLocalCompounds} from '../pages/local_compounds.mjs';
import {storyAdjectiveLibrary} from '../pages/story_saved_adjectives.mjs';
import {informationMusic} from '../pages/information_music.mjs';
import {scoreRoleReference} from '../pages/dictionary_clause_music.mjs';
import {midiFromScheduledEvents} from '../pages/engine.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const keep='CMP:cac584a394535e4912c75b5a',stay='CMP:ec3a1fad0ed828279e948372';
const norms=['hot','cold','heavy','light','bright','dim','rough','smooth','wide','narrow'];
let cases=0;
function interpret(text,{answers={},adjectives}={}){
 answers={...answers};
 for(let i=0;i<12;i++){
  const plan=storyReading(text,authority,{answers,adjectives});
  if(!plan?.question)return plan;
  assert(plan.question.options.some(o=>o.value==='physical'),text+' '+JSON.stringify(plan.question));
  answers[plan.question.key]='physical';
 }
 throw Error('Unexpected repeated question');
}
async function hear(text,options){
 const plan=interpret(text,options);assert(plan?.events,text+' '+JSON.stringify(plan));
 const result=await scoreStory(plan,authority),heard=decodeStoryMidi(result.midi,authority.atoms,options?.adjectives);
 assert.deepEqual(decodeStoryMidi(expandChordMidi(compactChordMidi(result.midi,authority.atoms),authority.atoms),authority.atoms,options?.adjectives),heard);
 assert.deepEqual(heard.events,plan.events);assert.deepEqual(heard.relations,plan.relations);
 assert.equal(heard.runtime_state,plan.runtime);assert.equal(heard.speech_act,plan.act);cases++;
 return {plan,heard,...result};
}
// Pin intended predicate, attachment and scope independently of the generated plan.
for(const norm of norms)for(const state of [0,1,2])for(const [text,predicate,roles] of [
 [`Nora kept the box ${norm}.`,keep,['cause','bearer']],
 [`The box stayed ${norm}.`,stay,['bearer']],
 [`The box remained ${norm}.`,stay,['bearer']]
]){
 const {heard}=await hear(text+' ['+state+']'),event=heard.events[0];
 assert.equal(event.predicate,predicate);assert.deepEqual(event.condition,{contextual_norm:norm});
 assert.deepEqual(event.arguments.map(a=>a.role),roles);assert.deepEqual(event.arguments.map(a=>a.entity),roles.map((_,i)=>i));
 assert.deepEqual(event.arguments.map(a=>a.properties),roles.map(()=>[]));
 assert.deepEqual(event.scopes,['time_before_speech']);assert.equal(heard.runtime_state,state);
}
for(const [text,predicate,scopes,act='assertion'] of [
 ['Nora keeps the box cold.',keep,[]],['Nora is keeping the box cold.',keep,['aspect_ongoing']],
 ['The box stays cold.',stay,[]],['The box is staying cold.',stay,['aspect_ongoing']],
 ['The box remains cold.',stay,[]],['The box is remaining cold.',stay,['aspect_ongoing']],
 ['Nora will not keep the box cold.',keep,['time_after_speech','negation']],
 ['Nora cannot keep the box cold.',keep,['negation','ability']],
 ['Nora might not keep the box cold.',keep,['modality_possible','negation']],
 ['We need to keep the box cold.',keep,['modality_necessary']],
 ['The box might stay cold.',stay,['modality_possible']],
 ['Can the box stay cold?',stay,['ability'],'question'],
 ['Did Nora not keep the box cold?',keep,['time_before_speech','negation'],'question'],
 ['Please keep the box cold.',keep,[],'command'],
 ['Do not keep the box cold.',keep,['negation'],'command']
]){
 const {heard,description,midi}=await hear(text);assert.equal(heard.events[0].predicate,predicate);
 assert.deepEqual(heard.events[0].condition,{contextual_norm:'cold'});
 assert.deepEqual(heard.events[0].scopes,scopes,text);assert.equal(heard.speech_act,act,text);
 assert.match(description,/cold \(temperature, relative to the local standard\)/);assert.match(JSON.stringify(await readSongLine(midi,authority.atoms,[],false)),/local standard/);
}
const mixed=await hear('The heavy robot kept the light box cold.');
assert.deepEqual(mixed.heard.events[0].arguments.map(a=>a.properties),[[{contextual_norm:'heavy'}],[{contextual_norm:'light'}]]);
assert.deepEqual(mixed.heard.events[0].condition,{contextual_norm:'cold'});
const sequence=await hear('Nora kept the box cold. The box stayed cold.');
assert.equal(sequence.heard.entities.length,2);assert.equal(sequence.heard.events[1].arguments[0].entity,1);
const pronounText='Nora kept the box cold. It stayed heavy.';
assert.equal(storyReading(pronounText,authority,{answers:{condition0:'physical'}}).question.key,'subject1');
const pronoun=await hear(pronounText,{answers:{subject1:'1'}});
assert.equal(pronoun.heard.events[1].arguments[0].entity,1);assert.deepEqual(pronoun.heard.events[1].arguments[0].properties,[]);
const conditional=await hear('If Nora keeps the box cold, Mira might not empty it. [2]');
assert.deepEqual(conditional.heard.relations,[{kind:'condition',events:[0,1]}]);
assert.equal(conditional.heard.events[1].arguments[1].entity,1);assert.deepEqual(conditional.heard.events[1].scopes,['modality_possible','negation']);
const before=await hear('The box stayed cold before Nora filled it.');
assert.deepEqual(before.heard.relations,[{kind:'before',events:[0,1]}]);assert.equal(before.heard.events[1].arguments[1].entity,0);
await hear('Nora keeps "Cold" hot.');
for(const text of ['Nora keeps the box light.','The idea stays cold.']){
 const question=storyReading(text,authority).question;assert(question);
 assert.equal(storyReading(text,authority,{answers:{[question.key]:'other'}}),null);
}
for(const text of ['Nora keeps the box very cold.','The box stays colder.','The box stays cold for two hours.',
 'The box has stayed cold.','The box was kept cold.','Nora keeps the box cold and heavy.','Keep listening.'])assert.equal(storyReading(text,authority),null,text);

// A saved definition named cold must not silently become the published temperature sense.
const registry=await addLocalCompound(emptyLocalCompounds(),{label:'cold',definition:'The material bearer is awake.',part_of_speech:'adjective',
 components:[{target_id:'MAT:000',relation:'qualifies'},{target_id:'LIF:001',relation:'head'}],roles:[{role:'bearer',definition:'The described participant'}]},authority);
const adjectives=await storyAdjectiveLibrary(registry,authority),text='Nora kept the box cold.';
const question=storyReading(text,authority,{adjectives}).question;assert.equal(question.key,'condition0Sense');
const saved=await hear(text,{adjectives,answers:{[question.key]:'saved'}});
assert.equal(saved.heard.events[0].condition.local_id,registry.entries[0].compound_id);assert.deepEqual(saved.heard.events[0].condition.bindings,[1]);
const published=await hear(text,{adjectives,answers:{[question.key]:'dictionary'}});
assert.deepEqual(published.heard.events[0].condition,{contextual_norm:'cold'});

// Construct malformed condition sounds without relying on the sentence parser or encoder.
const music=informationMusic(authority,1),{wrap,marker}=music,draft=(name,body)=>wrap(name,body,true),digit=n=>[marker('digit_'+n)];
const entities=[];for(const ref of ['Nora','the box'])entities.push(...draft('story_entity',(await scoreRoleReference(ref,'content',music)).notes));
async function manual({bearer=1,root='MAT:010',runtime=1,scoped=false,extra=false}={}){
 let condition=wrap('contextual_cold',[...wrap('role_bearer',digit(bearer)),...await informationMusic(authority,runtime).lexical(root)]);
 if(scoped)condition=wrap('negation',condition);
 const event=[...await music.lexical(keep),...draft('story_property',[...condition,...(extra?digit(0):[])]),...wrap('role_cause',digit(0)),...wrap('role_bearer',digit(1))];
 return midiFromScheduledEvents(draft('story',[...entities,...draft('story_event',event)]),music.anchor,[0,0]);
}
assert.deepEqual(decodeStoryMidi(await manual(),authority.atoms).events[0].condition,{contextual_norm:'cold'});
for(const change of [{bearer:0},{bearer:2},{root:'MAT:000'},{runtime:0},{runtime:2},{scoped:true},{extra:true}]){
 const bytes=await manual(change);assert.throws(()=>decodeStoryMidi(bytes,authority.atoms),JSON.stringify(change));
}
const legacy=JSON.parse(fs.readFileSync(new URL('./contextual_state_legacy_2026_11_22.json',import.meta.url))),hash=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
for(const record of legacy.cases){
 const {midi,heard}=await hear(record.input);assert.deepEqual(heard,record.meaning);
 assert.equal(hash(midi),record.melody_sha256);assert.equal(hash(compactChordMidi(midi,authority.atoms)),record.chords_sha256);
}
console.log('PASS '+cases+' state-complement message pairs; ten existing norms, runtime 0/1/2, scope, roles, private homonyms, seven malformed-score rejections and '+legacy.cases.length+' unchanged earlier performances.');
