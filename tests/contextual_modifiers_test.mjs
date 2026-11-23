import assert from 'node:assert/strict';
import fs from 'node:fs';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {CONTEXTUAL_NORMS} from '../pages/contextual_standards.mjs';
import {contextualPropertyNorm} from '../pages/story_contextual_properties.mjs';
import {readSongLine} from '../pages/song_readback.mjs';
import {informationMusic} from '../pages/information_music.mjs';
import {scoreRoleReference} from '../pages/dictionary_clause_music.mjs';
import {midiFromScheduledEvents} from '../pages/engine.mjs';
import {addLocalCompound,emptyLocalCompounds} from '../pages/local_compounds.mjs';
import {storyAdjectiveLibrary} from '../pages/story_saved_adjectives.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
let cases=0;
function interpreted(text,{answers={},adjectives}={}){
 answers={...answers};
 for(let i=0;i<20;i++){
  const plan=storyReading(text,authority,{answers,adjectives});
  if(!plan?.question)return plan;
  const q=plan.question;
  assert(q.options.some(o=>o.value==='physical'),text+' Unexpected question '+JSON.stringify(q));
  answers[q.key]='physical';
 }
 throw Error('Too many interpretation questions');
}
async function hear(text,options){
 const plan=interpreted(text,options);assert(plan?.events,text+' '+JSON.stringify(plan));
 const result=await scoreStory(plan,authority),heard=decodeStoryMidi(result.midi,authority.atoms,options?.adjectives);
 assert.deepEqual(decodeStoryMidi(expandChordMidi(compactChordMidi(result.midi,authority.atoms),authority.atoms),authority.atoms,options?.adjectives),heard);
 assert.deepEqual(heard.events,plan.events);assert.deepEqual(heard.relations,plan.relations);
 assert.equal(heard.runtime_state,plan.runtime);assert.equal(heard.speech_act,plan.act);cases++;
 return {plan,heard,...result};
}
for(const norm of Object.keys(CONTEXTUAL_NORMS))for(const state of [0,1,2]){
 for(const [text,index] of [
  [`The ${norm} board fell.`,0],
  [`Nora might not lift the ${norm} board.`,1],
  [`Please place the box at the ${norm} gate.`,2]
 ]){
  const {heard}=await hear(text+' ['+state+']');
  assert.deepEqual(heard.events[0].arguments[index].properties,[{contextual_norm:norm}]);
 }
}
for(const [text,properties] of [
 ['The heavy robot lifted the light board.',[['heavy'],['light']]],
 ['Nora lifted the wide and rough board.',[[],['wide','rough']]],
 ['Nora placed the narrow box at the wide gate.',[[],['narrow'],['wide']]],
 ['The hot box is empty.',[['hot']]],
 ['Nora filled the cold bottle.',[[],['cold']]]
]){
 const {heard,midi,description}=await hear(text);
 assert.deepEqual(heard.events[0].arguments.map(a=>a.properties.map(p=>p.contextual_norm)),properties);
 assert.match(description,/local standard/);
 const readback=await readSongLine(midi,authority.atoms,[],false);
 assert.match(JSON.stringify(readback),/local standard/);
}
const repeat=await hear('Nora lifted the wide board. Mira lowered the wide board.');
assert.equal(repeat.heard.entities.length,3);assert.equal(repeat.heard.events[1].arguments[1].entity,1);
const pronoun=await hear('Nora lifted the wide board. Mira lowered it.');
assert.equal(pronoun.heard.events[1].arguments[1].entity,1);
assert.deepEqual(pronoun.heard.events[1].arguments[1].properties,[],'A pronoun does not reassert a prior property');
const condition=await hear('If Nora lifted the heavy box, Mira might not lower it. [2]');
assert.deepEqual(condition.heard.relations,[{kind:'condition',events:[0,1]}]);
assert.deepEqual(condition.heard.events[1].scopes,['modality_possible','negation']);
const alternatives=await hear('Nora lifted the wide box or the narrow crate.');
assert.deepEqual(alternatives.heard.events[0].arguments[1].alternatives[0].properties,[{contextual_norm:'narrow'}]);
await hear('Can Nora lift the wide board?');
for(const text of ['Nora lifted the light board.','The wide idea fell.']){
 const question=storyReading(text,authority).question;assert(question);
 assert.equal(storyReading(text,authority,{answers:{[question.key]:'other'}}),null);
}
for(const text of ['Nora lifted the very wide board.','Nora lifted the wider board.','Nora lifted the two-metre-wide board.',
 'The board stayed wide.','Nora kept the board wide.','The wide board was lifted.'])assert.equal(storyReading(text,authority),null,text);

// A private adjective with the same label still asks which definition to use.
const registry=await addLocalCompound(emptyLocalCompounds(),{label:'wide',definition:'A material bearer is awake.',part_of_speech:'adjective',
 components:[{target_id:'MAT:000',relation:'qualifies'},{target_id:'LIF:001',relation:'head'}],roles:[{role:'bearer',definition:'The described participant'}]},authority);
const adjectives=await storyAdjectiveLibrary(registry,authority),text='The wide board fell.';
const conflict=storyReading(text,authority,{adjectives}).question;
assert.equal(conflict.key,'property0SubjectwideSense');
const saved=await hear(text,{adjectives,answers:{[conflict.key]:'saved'}});
assert.equal(saved.heard.events[0].arguments[0].properties[0].local_id,registry.entries[0].compound_id);
const published=await hear(text,{adjectives,answers:{[conflict.key]:'dictionary'}});
assert.deepEqual(published.heard.events[0].arguments[0].properties,[{contextual_norm:'wide'}]);
const combined=await hear('The wide and heavy board fell.',{adjectives,answers:{[conflict.key]:'saved'}});
assert.equal(combined.heard.events[0].arguments[0].properties[0].local_id,registry.entries[0].compound_id);
assert.deepEqual(combined.heard.events[0].arguments[0].properties[1],{contextual_norm:'heavy'});
const mixed=await hear('The hungry and heavy child lifted the wide box.');
assert.equal(typeof mixed.heard.events[0].arguments[0].properties[0],'string');
assert.deepEqual(mixed.heard.events[0].arguments[0].properties[1],{contextual_norm:'heavy'});
const different=await hear('The wide board pushed the narrow board.');
assert.notEqual(different.heard.events[0].arguments[0].entity,different.heard.events[0].arguments[1].entity);
const invalidPlan=structuredClone(published.plan);invalidPlan.events[0].arguments[0].properties[0].threshold=2;
await assert.rejects(()=>scoreStory(invalidPlan,authority),/exactly one supported norm/);

// Build sound-only corruptions independently of the sentence parser/encoder.
const music=informationMusic(authority,1),{wrap,marker}=music,draft=(name,body)=>wrap(name,body,true),digit=n=>[marker('digit_'+n)];
const entities=[];for(const ref of ['Nora','the board'])entities.push(...draft('story_entity',(await scoreRoleReference(ref,'content',music)).notes));
const lift=interpreted('Nora lifted the wide board.').events[0].predicate;
async function manual({bearer=1,root='MAT:010',runtime=1,scoped=false,extra=false}={}){
 let property=wrap('contextual_wide',[...wrap('role_bearer',digit(bearer)),...await informationMusic(authority,runtime).lexical(root)]);
 if(scoped)property=wrap('negation',property);
 const target=[...digit(1),...draft('story_property',[...property,...(extra?digit(0):[])])];
 const event=[...await music.lexical(lift),...wrap('role_actor',digit(0)),...wrap('role_target',target)];
 return midiFromScheduledEvents(draft('story',[...entities,...draft('story_event',event)]),music.anchor,[0,0]);
}
assert.deepEqual(decodeStoryMidi(await manual(),authority.atoms).events[0].arguments[1].properties,[{contextual_norm:'wide'}]);
for(const change of [{bearer:0},{bearer:2},{root:'MAT:000'},{runtime:0},{runtime:2},{scoped:true},{extra:true}]){
 const midi=await manual(change);assert.throws(()=>decodeStoryMidi(midi,authority.atoms),JSON.stringify(change));
}
for(const value of [{contextual_norm:'wide',threshold:3},{contextual_norm:'unknown'},{contextual_norm:'toString'},['wide']])assert.equal(contextualPropertyNorm(value),null);
console.log('PASS '+cases+' independent contextual-modifier message pairs; ten existing norms, three roles/runtime states, identity, private homonyms, boundaries and seven malformed-score rejections.');
