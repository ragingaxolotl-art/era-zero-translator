import assert from 'node:assert/strict';
import fs from 'node:fs';
import crypto from 'node:crypto';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {scoreSongText} from '../pages/song_lines.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {analyzeEnglish} from '../pages/english.mjs';
import {recognizedClausePredicate} from '../pages/dictionary_clauses.mjs';
import {addLocalCompound,emptyLocalCompounds} from '../pages/local_compounds.mjs';
import {storyAdjectiveLibrary} from '../pages/story_saved_adjectives.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const change='CMP:9a954f78879ed70ce262bdc5',cause='CMP:3019a12938289fa9f3a23237',closed='CMP:82a697e83c845e4a7b38b53e';
let cases=0;
async function hear(text,{caused=true,runtime=1,scopes=[],act='assertion',answers={},adjectives}={}){
 const plan=storyReading(text+' ['+runtime+']',authority,{answers,adjectives});assert(plan?.events,text+' '+JSON.stringify(plan));
 const {midi}=await scoreStory(plan,authority),heard=decodeStoryMidi(midi,authority.atoms,adjectives);
 assert.deepEqual(decodeStoryMidi(expandChordMidi(compactChordMidi(midi,authority.atoms),authority.atoms),authority.atoms,adjectives),heard);
 assert.equal(heard.events[0].predicate,caused?cause:change);
 assert.deepEqual(heard.events[0].arguments.map(a=>a.role),caused?['cause','bearer']:['bearer']);
 assert.deepEqual(heard.events[0].arguments.map(a=>a.entity),caused?[0,1]:[0]);
 assert.deepEqual(heard.events[0].scopes,scopes);assert.equal(heard.runtime_state,runtime);assert.equal(heard.speech_act,act);cases++;
 return {plan,heard,midi};
}
for(const [base,third,past,progressive] of [['close','closes','closed','closing'],['shut','shuts','shut','shutting']])for(const runtime of [0,1,2]){
 for(const [text,scopes,act] of [
  [`Nora ${third} the gate.`,[]],[`Nora ${past} the gate.`,['time_before_speech']],
  [`Nora is ${progressive} the gate.`,['aspect_ongoing']],
  [`Nora was not ${progressive} the gate.`,['time_before_speech','negation','aspect_ongoing']],
  [`Nora will not ${base} the gate.`,['time_after_speech','negation']],
  [`Nora might not ${base} the gate.`,['modality_possible','negation']],
  [`Nora cannot ${base} the gate.`,['negation','ability']],
  [`We need to ${base} the gate.`,['modality_necessary']],
  [`Can Nora ${base} the gate?`,['ability'],'question'],
  [`Did Nora ${base} the gate?`,['time_before_speech'],'question'],
  [`Please ${base} the gate.`,[],'command'],[`Do not ${base} the gate.`,['negation'],'command']
 ])await hear(text,{runtime,scopes,act:act||'assertion'});
 for(const [text,scopes,act] of [
  [`The gate ${third}.`,[]],[`The gate ${past}.`,['time_before_speech']],
  [`The gate is ${progressive}.`,['aspect_ongoing']],
  [`The gate was not ${progressive}.`,['time_before_speech','negation','aspect_ongoing']],
  [`The gate will not ${base}.`,['time_after_speech','negation']],
  [`The gate might not ${base}.`,['modality_possible','negation']],
  [`Can the gate ${base}?`,['ability'],'question'],[`Did the gate ${base}?`,['time_before_speech'],'question']
 ])await hear(text,{caused:false,runtime,scopes,act:act||'assertion'});
}
for(const [text,caused] of [['We shut the gate.',true],['The gates shut.',false]]){
 assert.equal(storyReading(text,authority).question.key,'tense0');
 await hear(text,{caused,answers:{tense0:'present'}});
 await hear(text,{caused,scopes:['time_before_speech'],answers:{tense0:'past'}});
}
for(const text of ['Nora closed the file.','Nora shut the window.','The meeting closed.']){
 assert.equal(storyReading(text,authority).question.key,'closing0');
 assert.equal(storyReading(text,authority,{answers:{closing0:'other'}}),null);
}
await hear('Nora shut the window.',{scopes:['time_before_speech'],answers:{closing0:'physical'}});
const described=await hear('The awake robot closed the wide gate.',{scopes:['time_before_speech'],answers:{property0Objectwide:'physical'}});
assert.deepEqual(described.heard.events[0].arguments.map(a=>a.properties),[['LIF:001'],[{contextual_norm:'wide'}]]);
const alternatives=await hear('Nora closed the gate or the hatch.',{scopes:['time_before_speech']});
assert.equal(alternatives.heard.events[0].arguments[1].alternatives.length,1);
for(const text of ['The closed gate closed.','Nora closed the open gate.','Nora shut the blocked gate.']){
 const plan=storyReading(text,authority);assert.equal(plan?.unsupported,true,text);assert.match(plan.reason,/before and after/);
 assert.equal(await scoreSongText(text,authority,()=>{throw Error('No unrelated interpretation');}),null);
}
for(const text of ['Nora closed only the gate.','Nora closed the gate with a lever.','The gate has been closed by Nora.','Nora has closed the gate.','Nora shut down the gate.'])assert.equal(storyReading(text,authority),null,text);
for(const text of ['Nora shuted the gate.','Nora is shuting the gate.'])assert.equal(recognizedClausePredicate(text,authority),null,text);
for(const form of ['close','closes','closed','closing','shut','shuts','shutting'])assert(analyzeEnglish(`Nora ${form} the gate.`,authority).term_coverage.some(t=>t.term===form&&t.matches.some(m=>m.target_id===cause)),form);

const follow=await hear('Nora closed the gate. Mira opened it.',{scopes:['time_before_speech']});
assert.equal(follow.heard.events[1].arguments[1].entity,1);
const conditional=await hear('If Nora closed the gate, Mira might not open it.',{scopes:['time_before_speech']});
assert.deepEqual(conditional.heard.relations,[{kind:'condition',events:[0,1]}]);assert.deepEqual(conditional.heard.events[1].scopes,['modality_possible','negation']);
const before=storyReading('The gate was open before Nora closed it.',authority);assert(before?.events);
const beforeHeard=decodeStoryMidi((await scoreStory(before,authority)).midi,authority.atoms);
assert.equal(beforeHeard.events[1].predicate,cause);assert.equal(beforeHeard.events[0].arguments[0].entity,beforeHeard.events[1].arguments[1].entity);
assert.deepEqual(beforeHeard.relations,[{kind:'before',events:[0,1]}]);
for(const [text,caused] of [['Close closed the gate.',true],['"Shut" closed.',false]])await hear(text,{caused,scopes:['time_before_speech'],answers:{closing0:'physical'}});

const registry=await addLocalCompound(emptyLocalCompounds(),{label:'quietshut',definition:'A material closure in the shut configuration.',part_of_speech:'adjective',
 components:[{target_id:'MAT:000',relation:'qualifies'},{target_id:closed,relation:'head'}],roles:[{role:'bearer',definition:'The closure'}]},authority);
const adjectives=await storyAdjectiveLibrary(registry,authority);assert.equal(storyReading('Nora closed the quietshut gate.',authority,{adjectives}).unsupported,true);
for(const edit of [p=>p.events[0].arguments[1].entity=0,p=>p.events[0].arguments[1].role='target',p=>p.events[0].arguments[1].properties.push(closed),p=>p.events[0].arguments.pop()]){
 const plan=structuredClone(described.plan);edit(plan);
 const {midi}=await scoreStory(plan,authority);assert.throws(()=>decodeStoryMidi(midi,authority.atoms));
}
const damaged=structuredClone(authority);
damaged.compound_plans[cause].expanded.nodes.find(n=>n.root_id==='ORI:211').root_id='ORI:210';
await assert.rejects(()=>scoreStory(storyReading('Nora closed the gate.',damaged),damaged));
const legacy=JSON.parse(fs.readFileSync(new URL('./closing_state_legacy_2026_11_22.json',import.meta.url)));
for(const old of legacy.performances){
 const {midi}=await scoreStory(storyReading(old.text,authority),authority);
 assert.equal(crypto.createHash('sha256').update(midi).digest('hex'),old.sha256);
 assert(![change,cause].includes(decodeStoryMidi(midi,authority.atoms).events[0].predicate));
}
console.log('PASS '+cases+' independent closing message pairs, 12 unchanged closed-state sounds, state/transition/cause distinctions, tense choices, roles, scopes and rejection boundaries.');
