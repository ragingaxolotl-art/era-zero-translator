import assert from 'node:assert/strict';
import fs from 'node:fs';
import crypto from 'node:crypto';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {encodeName} from '../pages/names.mjs';
import {scoreSongText} from '../pages/song_lines.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const save='CMP:58cfa479709294b9809be1b7',copy='CMP:9ea919967152aa85bc1c7169',closing='CMP:3019a12938289fa9f3a23237';
const legacy=JSON.parse(fs.readFileSync(new URL('./passive_legacy_2026_11_23.json',import.meta.url)));
for(const row of legacy.cases){
 const result=await scoreStory(storyReading(row.input,authority),authority);
 assert.equal(hash(result.midi),row.melody_sha256,row.input);
 assert.equal(hash(compactChordMidi(result.midi,authority.atoms)),row.chords_sha256,row.input);
 assert.deepEqual(decodeStoryMidi(result.midi,authority.atoms),row.meaning,row.input);
}
assert.equal(legacy.cases.length,24);
// Expected predicates and roles are frozen from the reviewed dictionary, not
// obtained from the passive parser's normalization or its predicted score.
const actions=[
 ['pushed','box','CMP:9549f538a6224892d3aff0ea'],
 ['displaced','box','CMP:82dc9c681fbaf7944cb7b85b',['cause','bearer']],
 ['lifted','box','CMP:e1d0059daad4093d8a5ce05c'],
 ['lowered','box','CMP:92464b1ea3c632b343340a05'],
 ['filled','box','CMP:8732bb43e880fb058158e27d'],
 ['emptied','box','CMP:f6a1885a79cc91ee94fb86aa'],
 ['closed','gate',closing,['cause','bearer']],['shut','gate',closing,['cause','bearer']],
 ['pulled','box','CMP:906075e53ffeb8edae29ed9c'],
 ['held','box','CMP:834a56d90e31b430990720ff'],
 ['released','box','CMP:69f57af236cf82c134e3c51a'],
 ['dropped','box','CMP:31da7c021f7da53eed929076'],
 ['deleted','file','erase_stored_object'],['copied','file',copy],['saved','file',save],['stored','file',save],
 ['recalled','route','CMP:aa39f8fdd0d04ee37348de05',['experiencer','target'],{retrieval0:'retrieval'}],
 ['remembered','route','CMP:aa39f8fdd0d04ee37348de05',['experiencer','target'],{retrieval0:'retrieval'}],
 ['repeated','event','CMP:d372748e7d848ebe63c65cd0'],
 ['noticed','signal','CMP:ac9df67396f3632d36b5d078',['experiencer','target']],
 ['spotted','error','CMP:42b9bbf271c7fc2a1193c5ca',['experiencer','target']],
 ['found','file','CMP:ec01f9b5c6eb3c5483bc3b72',['experiencer','target']],
 ['checked','gate','CMP:b72611332d4684a6b7f0bf19'],['inspected','gate','CMP:b72611332d4684a6b7f0bf19'],
 ['rechecked','gate','CMP:ffeb55f462f10014970989a4'],
 ['requested','work','CMP:59400f445c53fdb3333c7943',['source','content']],
 ['opened','gate','CMP:0b0461b1975240868e0bed8d',['cause','bearer']],
 ['reopened','gate','CMP:28e9f477e3bc88111934ddda',['cause','bearer']],
 ['heard','song','CMP:6cb819bd20ef8429225daca3',['experiencer','source']],
 ['seen','gate','CMP:b937ee54b7c000fafe11d338',['experiencer','source']],
 ['made','box','CRE:110',['source','result']]
];
let pairs=0;
async function hear(text,{predicate=save,roles=['actor','target'],scopes=['time_before_speech'],answers={},state=1,act='assertion'}={}){
 const plan=storyReading(text+' ['+state+']',authority,{answers});assert(plan?.events,text+' '+JSON.stringify(plan));
 const result=await scoreStory(plan,authority),m=decodeStoryMidi(result.midi,authority.atoms);
 assert.equal(m.events[0].predicate,predicate,text);assert.deepEqual(m.events[0].arguments.map(a=>a.role),roles,text);
 assert.deepEqual(m.events[0].arguments.map(a=>a.entity),[1,0],text);assert.deepEqual(m.events[0].scopes,scopes,text);
 assert.equal(m.runtime_state,state);assert.equal(m.speech_act,act);
 assert.deepEqual(decodeStoryMidi(expandChordMidi(compactChordMidi(result.midi,authority.atoms),authority.atoms),authority.atoms),m,text);
 pairs++;return {plan,result,meaning:m};
}
for(const [participle,noun,predicate,roles=['actor','target'],answers={}] of actions)for(const state of [0,1,2]){
 for(const [aux,scopes] of [['is',[]],['was',['time_before_speech']],['was not',['time_before_speech','negation']],['will not be',['time_after_speech','negation']],['might not be',['modality_possible','negation']],['cannot be',['negation','ability']]]){
  const {meaning:m}=await hear(`The ${noun} ${aux} ${participle} by Nora.`,{predicate,roles,scopes,answers,state});
  assert.deepEqual(m.entities[0].identity.phonemes,(await encodeName(noun)).phonemes);
  assert.deepEqual(m.entities[1].identity.phonemes,(await encodeName('Nora')).phonemes);
 }
}
for(const state of [0,1,2]){
 await hear('Was the file not saved by the program?',{state,scopes:['time_before_speech','negation'],act:'question'});
 await hear('Will the file be copied by the program?',{state,predicate:copy,scopes:['time_after_speech'],act:'question'});
 await hear('The file is being saved by Nora.',{state,scopes:['aspect_ongoing']});
 await hear('The file was not being copied by Nora.',{state,predicate:copy,scopes:['time_before_speech','negation','aspect_ongoing']});
 await hear('The file might be being saved by Nora.',{state,scopes:['modality_possible','aspect_ongoing']});
 await hear('The file isn\'t being saved by Nora.',{state,scopes:['negation','aspect_ongoing']});
 const plural=await hear('The files were saved by the routine.',{state});assert(plural.meaning.entities[0].plural);
 const we=await hear('We were seen by you.',{state,predicate:'CMP:b937ee54b7c000fafe11d338',roles:['experiencer','source']});
 assert.deepEqual(we.meaning.entities.map(e=>e.identity),[{kind:'deictic',role:'speaker_group'},{kind:'deictic',role:'addressee'}]);
}
const chain=await hear('The file was saved by Nora. They copied it.');
assert.deepEqual(chain.meaning.events[1].arguments.map(a=>a.entity),[1,0]);assert.equal(chain.meaning.events[1].predicate,copy);
const shared=await hear('The box was lifted by Nora and remained cold.',{predicate:'CMP:e1d0059daad4093d8a5ce05c',answers:{condition1:'physical'}});
assert.equal(shared.meaning.events[1].arguments[0].entity,0);
const conditional=await hear('If the file was saved by Nora, the program copied it.');
assert.deepEqual(conditional.meaning.relations,[{kind:'condition',events:[0,1]}]);assert.equal(conditional.meaning.events[1].arguments[1].entity,0);
assert.equal(storyReading('The file was saved by Nora before it was copied by Mira.',authority).question.key,'subject1');
const before=await hear('The file was saved by Nora before it was copied by Mira.',{answers:{subject1:'0'}});
assert.deepEqual(before.meaning.relations,[{kind:'before',events:[0,1]}]);assert.deepEqual(before.meaning.events[1].arguments.map(a=>a.entity),[2,0]);
const modified=await hear('The stored file was saved by the awake robot.');
assert.deepEqual(modified.meaning.events[0].arguments.map(a=>a.properties),[['LIF:001'],['DAT:000']]);
const active=await scoreStory(storyReading('Nora saved the file.',authority),authority);
const passive=await hear('The file was saved by Nora.');
const semanticClaim=meaning=>({...meaning.events[0],arguments:meaning.events[0].arguments.map(a=>({...a,entity:meaning.entities[a.entity].identity}))});
assert.deepEqual(semanticClaim(decodeStoryMidi(active.midi,authority.atoms)),semanticClaim(passive.meaning));
// No-agent states keep their exact meanings; a by-agent storage/closing event
// has the earlier action meaning, without inventing a new state/event alias.
for(const [stateSentence,stateRoot,eventSentence,eventRoot] of [['The file was stored.','DAT:000','The file was stored by Nora.',save],['The gate was closed.','CMP:82a697e83c845e4a7b38b53e','The gate was closed by Nora.',closing]]){
 assert.equal(storyReading(stateSentence,authority).events[0].predicate,stateRoot);
 assert.equal(storyReading(eventSentence,authority).events[0].predicate,eventRoot);
}
for(const text of ['The file was saved by the river.','The file was copied by the table.']){
 const plan=storyReading(text,authority);assert.equal(plan.question.key,'passiveBy0');
 assert.equal(storyReading(text,authority,{answers:{passiveBy0:'other'}}),null);
 assert(storyReading(text,authority,{answers:{passiveBy0:'actor'}})?.events);
}
const personal={word:'saved',forms:['saved'],root:'MIN:011',target:'MIN:011',quality:false,roles:'experiencer/target'};
assert.match(storyReading('The file was saved by Nora.',authority,{preferences:[personal]}).reason,/personally selected verb meaning/);
assert(storyReading('The file was saved by Nora.',authority,{preferences:[{...personal,root:save,target:save}]}).events);
for(const text of ['The stored file was deleted by Nora.','The closed gate was closed by Nora.','The full box was emptied by Nora.'])assert(storyReading(text,authority)?.unsupported,text);
for(const text of ['The file was saved.','The file has been saved by Nora.','The file got saved by Nora.','All the files were saved by Nora.','The file was only saved by Nora.','The box was put by Nora.','The box was kept by Nora.','The box were lifted by Nora.','The files was saved by Nora.','The file was save by Nora.','The gate was saw by Nora.','The box was glorped by Nora.','The file was saved by Nora and copied.']){
 assert(!storyReading(text,authority)?.events,text);
 assert.equal(await scoreSongText(text,authority,()=>{throw Error('No invented fallback');}),null,text);
}
console.log(`PASS ${pairs} independently recovered passive pairs across 31 participles, roles, ordered scopes, runtime 0/1/2, discourse and property binding; 24 frozen active/state performances; unsupported grammar and personal meanings protected.`);
