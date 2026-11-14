import assert from 'node:assert/strict';
import fs from 'node:fs';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {encodeName} from '../pages/names.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {scoreSongText} from '../pages/song_lines.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {storyWords} from '../pages/story_words.mjs';
import {everydayMeaning,routeName} from '../pages/everyday.mjs';
import {addLocalCompound,emptyLocalCompounds} from '../pages/local_compounds.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const vocab=new Map(storyWords.map(w=>[w.word,w.id]));
const read=(s,answers={})=>storyReading(s,authority,{answers});
const hear=async (text,answers={})=>{
  const scored=await scoreStory(read(text,answers),authority);
  const heard=decodeStoryMidi(scored.midi,authority.atoms);
  assert.deepEqual(heard,scored.meaning,text);
  assert.deepEqual(decodeStoryMidi(expandChordMidi(compactChordMidi(scored.midi,authority.atoms),authority.atoms),authority.atoms),heard,text);
  return {...scored,heard};
};
for(const [person,object,property] of [['Pip','bell','cracked'],['Aru','gate','broken'],['Mira','radio','faulty']]){
 for(const state of [0,1,2]){
  const text=person+' found a '+property+' '+object+'. They repaired it before Ada arrived. ['+state+']';
  const {heard,midi}=await hear(text);
  assert.equal(heard.runtime_state,state);
  assert.deepEqual(heard.entities.map(e=>e.identity.phonemes),await Promise.all([person,object,'Ada'].map(async name=>(await encodeName(name)).phonemes)));
  assert.deepEqual(heard.entities.map(e=>e.identity.reference_mode),['name','indefinite_singular','name']);
  assert.deepEqual(heard.events.map(e=>e.predicate),[vocab.get('find'),'REP:110','MOV:110']);
  assert.deepEqual(heard.events.map(e=>e.arguments.map(a=>[a.role,a.entity])),[[['experiencer',0],['target',1]],[['source',0],['target',1]],[['actor',2]]]);
  assert.deepEqual(heard.events.map(e=>e.arguments.map(a=>a.properties)),[[[],[vocab.get(property)]],[[],[]],[[]]]);
  assert.deepEqual(heard.events.map(e=>e.scopes),Array(3).fill(['time_before_speech']));
  assert.deepEqual(heard.relations,[{kind:'before',events:[1,2]}]);
  assert.deepEqual((await scoreSongText(text,authority,()=>assert.fail('unexpected single-entry lookup'))).midi,midi);
 }
}
const signature=await hear('Pip found a cracked bell. They repaired it before Ada arrived.');
assert.deepEqual(await decodeSupportedMeaningWithDrafts(signature.midi,authority.atoms,[],{allowDraft:true}),signature.heard);
for(const [text,edges] of [
 ['Aru repaired a faulty gate after Mira arrived.',[[1,0]]],
 ['Before Mira arrived, Aru repaired a faulty gate.',[[1,0]]],
 ['After Mira arrived, Aru repaired a faulty gate.',[[0,1]]]
])assert.deepEqual((await hear(text)).heard.relations.map(r=>r.events),edges);
const together=(await hear('Aru found a cracked gate and repaired it.')).heard;
assert.deepEqual(together.relations,[{kind:'and',events:[0,1]}]);assert.equal(together.events[1].arguments[0].entity,0);
for(const action of ['rang','vibrated','recurred']){
 const notAll=(await hear('Not all the bells '+action+'.')).heard,none=(await hear('None of the bells '+action+'.')).heard;
 assert.deepEqual(notAll.events[0].quantifier,'all');assert.equal(notAll.events[0].negated_quantifier,true);
 assert.deepEqual(none.events[0].quantifier,'none');assert.equal(none.events[0].negated_quantifier,false);
 assert.equal(none.entities[0].plural,true);
 const truth=(event,memberResults)=>event.negated_quantifier?!memberResults.every(Boolean):!memberResults.some(Boolean);
 for(const [outcomes,weak,strong] of [[[false,false],true,true],[[true,false],true,false],[[true,true],false,false], [[],false,true]]){
  assert.equal(truth(notAll.events[0],outcomes),weak);assert.equal(truth(none.events[0],outcomes),strong);
 }
}
const ambiguous='Pip noticed Ada. They repaired a cracked bell.';
const q=read(ambiguous).question;assert(q.prompt.includes('They'));assert.equal(q.options.length,2);
for(const [answer,i] of [['0',0],['1',1]])assert.equal((await hear(ambiguous,{[q.key]:answer})).heard.events[1].arguments[0].entity,i);
const pair='Pip found a bell. Ada found a bell. Mira repaired it.';
const two=read(pair).question;assert.equal(two.options.length,2);
const selected=(await hear(pair,{[two.key]:two.options[1].value})).heard;
assert.equal(selected.events[2].arguments[1].entity,selected.events[1].arguments[1].entity);
assert.notEqual(selected.events[1].arguments[1].entity,selected.events[0].arguments[1].entity);
const owned=(await hear('Her phone vibrated.',{subject0Owner:'new:Ada'})).heard;
assert.equal(owned.entities[1].owner,0);assert.deepEqual(owned.entities[0].identity.phonemes,(await encodeName('Ada')).phonemes);
assert.equal(owned.events[0].predicate,vocab.get('vibrate'));
for(const [s,p] of [['The bell is cracked.','cracked'],['The handle is broken.','broken'],['A faulty radio rang.','ring']]){
 const heard=(await hear(s)).heard;assert.equal(heard.events[0].predicate,vocab.get(p));
}
for(const text of ['We might ring and wait.','Pip repaired the bell before Ada arrived and Mira waited.','Pip repaired the barely cracked bell.','Pip found a cracked bell. They repaired it before Ada arrived. Extra words.'])assert.equal(read(text),null,text);
assert.equal(read('Pip returned.').question.options.length,2);
assert.equal(read('The arrival repeated it.').question.allowName,true);
assert.equal(read('Find it!').question.allowName,true);
const lib=await addLocalCompound(emptyLocalCompounds(),{label:'chime back',definition:'A second resonant response.',part_of_speech:'verb',components:[{relation:'head',target_id:vocab.get('ring')},{relation:'qualifies',target_id:vocab.get('recur')}],roles:[]},authority);
assert.equal(lib.entries.length,1);
assert.equal(authority.atoms.length,324);
const ids=[...authority.atoms.map(x=>x.canonical_id),...authority.compounds.map(x=>x.compound_id)];
assert.equal(new Set(ids).size,ids.length);
for(const key of ids){const gloss=everydayMeaning(authority,key);assert(gloss.length>5,key);assert(!gloss.includes(key),key);}
for(const sense of [...authority.senses,...authority.game_story_senses]){
 assert(everydayMeaning(authority,sense),sense.sense_id);assert(routeName(sense.route));
 if(!sense.target_id)assert.notEqual(everydayMeaning(authority,sense),sense.definition,sense.sense_id);
}
assert.notEqual(everydayMeaning(authority,'REP:111'),everydayMeaning(authority,'REP:110'));
assert.notEqual(everydayMeaning(authority,authority.senses.find(s=>s.lemma==='before')),everydayMeaning(authority,authority.senses.find(s=>s.lemma==='after')));
console.log('PASS story referents, adjective attachments, ambiguity, order, quantifier truth, nested vocabulary, everyday choices and blind compact MIDI.');
