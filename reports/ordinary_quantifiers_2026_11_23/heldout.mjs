import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
const [root,output]=process.argv.slice(2),load=name=>import(pathToFileURL(path.join(root,'pages',name)));
const {storyReading}=await load('story_readings.mjs'),{scoreStory,decodeStoryMidi}=await load('story_music.mjs');
const {compactChordMidi,expandChordMidi}=await load('compact_chords.mjs'),{encodeName}=await load('names.mjs');
const a=JSON.parse(fs.readFileSync(path.join(root,'pages/data/index.json'))),save='CMP:58cfa479709294b9809be1b7',copy='CMP:9ea919967152aa85bc1c7169';
const cases=[
 {text:'Each child heard the bell.',noun:'child',predicate:'CMP:6cb819bd20ef8429225daca3',roles:['experiencer','source'],scopes:['time_before_speech']},
 {text:'No children found the file.',noun:'children',predicate:'CMP:ec01f9b5c6eb3c5483bc3b72',roles:['experiencer','target'],scopes:['time_before_speech'],q:'none'},
 {text:'Not every robot will put the box at the gate. [2]',noun:'robot',predicate:'CMP:64574c1a25d72a89aafc46ef',roles:['actor','target','destination'],scopes:['time_after_speech'],negative:true,runtime:2},
 {text:'No files are stored. [0]',noun:'files',predicate:'DAT:000',roles:['bearer'],scopes:[],q:'none',runtime:0},
 {text:'Can each robot copy the record?',noun:'robot',predicate:copy,roles:['actor','target'],scopes:['ability'],act:'question'},
 {text:'Each child lifted the heavy board. [2]',noun:'child',predicate:'CMP:e1d0059daad4093d8a5ce05c',roles:['actor','target'],scopes:['time_before_speech'],runtime:2,answers:{property0Objectheavy:'physical'},properties:[[],[{contextual_norm:'heavy'}]]},
 {text:'Every robot made the box.',noun:'robot',predicate:'CRE:110',roles:['source','result'],scopes:['time_before_speech']},
 {text:'Every program does not need to store the record.',noun:'program',predicate:save,roles:['actor','target'],scopes:['modality_necessary'],negative:true,answers:{quantityScope0:'not_all'}}
];
const results=[];
for(const c of cases){
 const plan=storyReading(c.text,a,{answers:c.answers});assert(plan?.events,c.text+' '+JSON.stringify(plan));
 const {midi}=await scoreStory(plan,a),m=decodeStoryMidi(midi,a.atoms),e=m.events[0];
 assert.equal(e.predicate,c.predicate);assert.deepEqual(e.scopes,c.scopes);assert.equal(e.quantifier,c.q||'all');assert.equal(e.negated_quantifier,!!c.negative);
 assert.deepEqual(e.arguments.map(v=>v.role),c.roles);assert.deepEqual(e.arguments.map(v=>v.entity),c.roles.map((_,i)=>i));
 assert.deepEqual(e.arguments.map(v=>v.properties),c.properties||c.roles.map(()=>[]));
 assert.equal(m.entities[0].identity.reference_mode,'nominal_class');assert.deepEqual(m.entities[0].identity.phonemes,(await encodeName(c.noun)).phonemes);
 assert.equal(m.runtime_state,c.runtime??1);assert.equal(m.speech_act,c.act||'assertion');assert.deepEqual(m.relations,[]);assert.equal(m.events.length,1);
 const chords=compactChordMidi(midi,a.atoms);assert.deepEqual(decodeStoryMidi(expandChordMidi(chords,a.atoms),a.atoms),m);
 results.push({input:c.text,answers:c.answers||{},status:'pass',melody_sha256:createHash('sha256').update(midi).digest('hex'),chord_sha256:createHash('sha256').update(chords).digest('hex'),meaning:m});
}
fs.writeFileSync(output,JSON.stringify({status:'pass',note:'Post-implementation engineering combinations, not an independently sampled language benchmark.',results},null,2)+'\n');
console.log('PASS eight additional class/role/scope combinations.');
