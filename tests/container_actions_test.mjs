import assert from 'node:assert/strict';
import fs from 'node:fs';
import crypto from 'node:crypto';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {scoreSongText} from '../pages/song_lines.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {storyWords} from '../pages/story_words.mjs';
import {analyzeEnglish} from '../pages/english.mjs';
import {addLocalCompound,emptyLocalCompounds} from '../pages/local_compounds.mjs';
import {storyAdjectiveLibrary} from '../pages/story_saved_adjectives.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const id=word=>storyWords.find(w=>w.word===word).id;
const actions={fill:'CMP:8732bb43e880fb058158e27d',empty:'CMP:f6a1885a79cc91ee94fb86aa'};
let cases=0;
async function hear(text,verb,{state=1,scopes=[],act='assertion',answers={},adjectives}={}){
 const plan=storyReading(text+' ['+state+']',authority,{answers,adjectives});assert(plan?.events,text+' '+JSON.stringify(plan));
 const {midi}=await scoreStory(plan,authority),heard=decodeStoryMidi(midi,authority.atoms,adjectives);
 assert.deepEqual(decodeStoryMidi(expandChordMidi(compactChordMidi(midi,authority.atoms),authority.atoms),authority.atoms,adjectives),heard);
 assert.equal(heard.events[0].predicate,actions[verb]);assert.deepEqual(heard.events[0].scopes,scopes);
 assert.deepEqual(heard.events[0].arguments.map(a=>a.role),['actor','target']);assert.deepEqual(heard.events[0].arguments.map(a=>a.entity),[0,1]);
 assert.equal(heard.runtime_state,state);assert.equal(heard.speech_act,act);cases++;
 return {plan,heard,midi};
}
for(const [verb,third,past,progressive] of [['fill','fills','filled','filling'],['empty','empties','emptied','emptying']]){
 for(const state of [0,1,2])for(const [text,scopes,act] of [
  [`Nora ${third} the bottle.`,[]],[`Mira ${past} the box.`,['time_before_speech']],
  [`We are ${progressive} the tank.`,['aspect_ongoing']],
  [`Nora was not ${progressive} the crate.`,['time_before_speech','negation','aspect_ongoing']],
  [`Nora will not ${verb} the bottle.`,['time_after_speech','negation']],
  [`Nora cannot ${verb} the bottle.`,['negation','ability']],
  [`Nora might not ${verb} the bottle.`,['modality_possible','negation']],
  [`Nora needs to ${verb} the bottle.`,['modality_necessary']],
  [`Can Nora ${verb} the bottle?`,['ability'],'question'],
  [`Did Nora ${verb} the bottle?`,['time_before_speech'],'question'],
  [`Please ${verb} the bottle.`,[],'command'],[`Do not ${verb} the bottle.`,['negation'],'command']
 ])await hear(text,verb,{state,scopes,act:act||'assertion'});
 const described=await hear(`The awake robot ${past} the cracked box.`,verb,{scopes:['time_before_speech']});
 assert.deepEqual(described.heard.events[0].arguments.map(a=>a.properties),[['LIF:001'],[id('cracked')]]);
 const alternatives=await hear(`Nora ${past} the box or the crate.`,verb,{scopes:['time_before_speech']});
 assert.equal(alternatives.heard.events[0].arguments[1].alternatives.length,1);
 for(const object of ['the file','the form','the meeting','Mira']){
  const text=`Nora ${past} ${object}.`,key='containerAction0';assert.equal(storyReading(text,authority)?.question?.key,key);
  assert.equal(storyReading(text,authority,{answers:{[key]:'other'}}),null);
 }
 await hear(`Nora ${past} the archive.`,verb,{scopes:['time_before_speech'],answers:{containerAction0:'physical'}});
 for(const text of [`Nora ${past} the empty box.`,`Nora ${past} the full box.`]){
  const unsupported=storyReading(text,authority);assert.equal(unsupported?.unsupported,true);
  assert.match(unsupported.reason,/before and after/);
  assert.equal(await scoreSongText(text,authority,()=>{throw Error('Must not reinterpret the failed sentence');}),null);
 }
 for(const text of [`Nora ${past} only the box.`,`The box was ${past}.`,`Nora has ${past} the box.`,
  `Nora ${past} the box with water.`,`Nora ${past} the box into the bin.`])assert.equal(storyReading(text,authority),null,text);
 for(const form of [verb,third,past,progressive])assert(analyzeEnglish(`Nora ${form} the box.`,authority).term_coverage.some(t=>t.term===form&&t.matches.some(m=>m.target_id===actions[verb])),form);
 for(const change of [p=>p.events[0].arguments[1].entity=0,p=>p.events[0].arguments[1].role='content',
  p=>p.events[0].arguments[1].properties.push(id('empty'))]){
  const plan=structuredClone(described.plan);change(plan);const {midi}=await scoreStory(plan,authority);
  assert.throws(()=>decodeStoryMidi(midi,authority.atoms));
 }
 const damaged=structuredClone(authority);
 damaged.compound_plans[actions[verb]].expanded.nodes.find(n=>n.root_id==='ORI:110').root_id='ORI:111';
 await assert.rejects(()=>scoreStory(storyReading(`Nora ${past} the bottle.`,damaged),damaged));
}
for(const [text,first] of [
 ['Nora filled the box and Mira emptied the bottle.','fill'],
 ['Nora emptied the box before Mira filled the bottle.','empty'],
 ['If Nora emptied the box, Mira will not fill the bottle.','empty'],
 ['Nora filled the box. Mira emptied it.','fill']
]){
 const {heard}=await hear(text,first,{scopes:['time_before_speech']});assert.equal(heard.events.length,2);
 if(text.startsWith('If')){assert.deepEqual(heard.relations,[{kind:'condition',events:[0,1]}]);assert.deepEqual(heard.events[1].scopes,['time_after_speech','negation']);}
 if(text.endsWith('it.'))assert.equal(heard.events[1].arguments[1].entity,1);
}
for(const [text,verb] of [['Fill filled the bottle.','fill'],['"Empty" emptied the box.','empty']]){
 const {heard}=await hear(text,verb,{scopes:['time_before_speech']});
 assert.equal(heard.entities[0].identity.kind,'phonemic');
 assert.equal(heard.entities[0].identity.reference_mode,'name');
}

// A separate before-clause explicitly supplies the phase that a bare modifier lacks.
const before=storyReading('The box was empty before Nora filled it.',authority);assert(before?.events);
const beforeHeard=decodeStoryMidi((await scoreStory(before,authority)).midi,authority.atoms);
assert.equal(beforeHeard.events[0].predicate,id('empty'));assert.equal(beforeHeard.events[1].predicate,actions.fill);
assert.equal(beforeHeard.events[1].arguments[1].entity,beforeHeard.events[0].arguments[0].entity);
assert.deepEqual(beforeHeard.relations,[{kind:'before',events:[0,1]}]);

// Nested private adjectives retain their definitions, including the need for a
// phase if any nested component already describes full/empty content state.
const definition={label:'vacantload',definition:'A material container with no relevant contents.',part_of_speech:'adjective',
 components:[{target_id:'MAT:000',relation:'qualifies'},{target_id:id('empty'),relation:'head'}],
 roles:[{role:'bearer',definition:'The described container'}]};
let registry=await addLocalCompound(emptyLocalCompounds(),definition,authority),base=registry.entries[0].compound_id;
registry=await addLocalCompound(registry,{...definition,label:'still vacantload',
 components:[{target_id:base,relation:'head'},{target_id:'MAT:000',relation:'qualifies'}],
 role_links:[{outer_role:'bearer',component_path:[0],role:'bearer'}]},authority);
const adjectives=await storyAdjectiveLibrary(registry,authority);
for(const value of adjectives.byId.values()){assert(!value.unavailable,value.unavailable);assert(value.canonicalTargets.includes(id('empty')));}
assert.equal(storyReading('Nora filled the still vacantload box.',authority,{adjectives}).unsupported,true);
const held=storyReading('Nora held the still vacantload box.',authority,{adjectives});assert(held?.events);
assert.equal(decodeStoryMidi((await scoreStory(held,authority)).midi,authority.atoms,adjectives).events[0].predicate,id('physical holding foundation'));

const legacy=JSON.parse(fs.readFileSync(new URL('./container_adjective_legacy_2026_11_22.json',import.meta.url)));
for(const old of legacy.performances){
 const plan=storyReading(old.text,authority),{midi}=await scoreStory(plan,authority);
 assert.equal(crypto.createHash('sha256').update(midi).digest('hex'),old.sha256);
 assert(!Object.values(actions).includes(decodeStoryMidi(midi,authority.atoms).events[0].predicate));
}
assert.notEqual(id('empty'),actions.empty);
console.log('PASS '+cases+' independent container-action message pairs, 12 unchanged adjective sounds, nested adjective phase boundaries, separate before-clause meaning, scope/role/runtime contrasts and malformed-score rejection.');
