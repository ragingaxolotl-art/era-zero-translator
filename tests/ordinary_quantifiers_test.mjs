import assert from 'node:assert/strict';
import fs from 'node:fs';
import {createHash} from 'node:crypto';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {scoreSongText} from '../pages/song_lines.mjs';
import {encodeName} from '../pages/names.mjs';
const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const hash=b=>createHash('sha256').update(b).digest('hex');
const legacy=JSON.parse(fs.readFileSync(new URL('./ordinary_quantifier_legacy_2026_11_23.json',import.meta.url)));
for(const row of legacy.cases){
 const {midi}=await scoreStory(storyReading(row.input,a),a);
 assert.equal(hash(midi),row.melody_sha256,row.input);
 assert.equal(hash(compactChordMidi(midi,a.atoms)),row.chords_sha256,row.input);
 assert.deepEqual(decodeStoryMidi(midi,a.atoms),row.meaning,row.input);
}
assert.equal(legacy.cases.length,36);
const wait='CMP:e17374fbc08546afa196b2cd',save='CMP:58cfa479709294b9809be1b7';
let pairs=0;
async function hear(text,{predicate=wait,roles=['actor'],scopes=['time_before_speech'],q='all',negative=false,noun='worker',state=1,act='assertion',answers={}}={}){
 const plan=storyReading(text+' ['+state+']',a,{answers});assert(plan?.events,text+' '+JSON.stringify(plan));
 const {midi,description}=await scoreStory(plan,a),m=decodeStoryMidi(midi,a.atoms),e=m.events[0];
 assert.equal(e.predicate,predicate,text);assert.deepEqual(e.scopes,scopes,text);
 assert.equal(e.quantifier,q);assert.equal(e.negated_quantifier,negative);
 assert.deepEqual(e.arguments.map(v=>v.role),roles);assert.deepEqual(e.arguments.map(v=>v.entity),roles.map((_,i)=>i));
 assert.equal(m.entities[0].identity.reference_mode,'nominal_class');assert(m.entities[0].plural);
 assert.deepEqual(m.entities[0].identity.phonemes,(await encodeName(noun)).phonemes);
 assert.equal(m.runtime_state,state);assert.equal(m.speech_act,act);assert.deepEqual(m.relations,[]);
 assert.deepEqual(decodeStoryMidi(expandChordMidi(compactChordMidi(midi,a.atoms),a.atoms),a.atoms),m);
 // A question or negative must not gain an appended assertion that everyone acted.
 assert(!description.includes('Every member performed this action.'));
 pairs++;return {meaning:m,midi};
}
for(const state of [0,1,2])for(const [prefix,q,negative] of [['Every','all',false],['Each','all',false],['No','none',false],['Not every','all',true]]){
 for(const [body,noun,predicate,roles,scopes] of [
  ['worker waited.','worker',wait,['actor'],['time_before_speech']],
  ['robot saves the file.','robot',save,['actor','target'],[]],
  ['program will save the record.','program',save,['actor','target'],['time_after_speech']],
  ['gate was closed.','gate','CMP:82a697e83c845e4a7b38b53e',['bearer'],['time_before_speech']],
  ['box is full.','box','CMP:d03beca450a29869aa6fd980',['bearer'],[]],
  ['file is stored.','file','DAT:000',['bearer'],[]]
 ])await hear(prefix+' '+body,{state,q,negative,noun,predicate,roles,scopes});
}
for(const state of [0,1,2]){
 await hear('No workers waited.',{state,q:'none',noun:'workers'});
 await hear('No programs save the file.',{state,q:'none',noun:'programs',predicate:save,roles:['actor','target'],scopes:[]});
 await hear('No gates are closed.',{state,q:'none',noun:'gates',predicate:'CMP:82a697e83c845e4a7b38b53e',roles:['bearer'],scopes:[]});
 await hear('Did every worker wait?',{state,act:'question'});
 await hear('Does no program save the file?',{state,act:'question',q:'none',noun:'program',predicate:save,roles:['actor','target'],scopes:[]});
 await hear('Was every gate closed?',{state,act:'question',noun:'gate',predicate:'CMP:82a697e83c845e4a7b38b53e',roles:['bearer']});
 for(const prefix of ['Every','Each'])for(const [verb,each,notAll] of [
  ['will not',['time_after_speech','negation'],['time_after_speech']],
  ['cannot',['negation','ability'],['ability']],
  ['does not need to',['negation','modality_necessary'],['modality_necessary']]
 ]){
  const text=prefix+' program '+verb+' save the file.';
  assert.equal(storyReading(text,a).question.key,'quantityScope0');
  assert(storyReading(text,a,{answers:{quantityScope0:'other'}}).unsupported);
  const all=await hear(text,{state,noun:'program',predicate:save,roles:['actor','target'],scopes:each,answers:{quantityScope0:'each'}});
  const partial=await hear(text,{state,noun:'program',predicate:save,roles:['actor','target'],scopes:notAll,negative:true,answers:{quantityScope0:'not_all'}});
  assert.notEqual(hash(all.midi),hash(partial.midi));
 }
}
const every=await hear('Every worker waited.'),none=await hear('No worker waited.',{q:'none'}),partial=await hear('Not every worker waited.',{negative:true});
const eachNegative=await hear('Every worker did not wait.',{scopes:['time_before_speech','negation'],answers:{quantityScope0:'each'}});
const partialNegative=await hear('Every worker did not wait.',{answers:{quantityScope0:'not_all'},negative:true});
assert.deepEqual(partial.meaning,partialNegative.meaning);
function truth(meaning,members){
 const e=meaning.events[0],values=members.map(value=>e.scopes.includes('negation')?!value:value);
 const positive=e.quantifier==='none'?!values.some(Boolean):values.every(Boolean);
 return e.negated_quantifier?!positive:positive;
}
for(const [members,expected] of [[[],[true,true,false,true]],[[false,false],[false,true,true,true]],[[true,false],[false,false,true,false]],[[true,true],[true,false,false,false]]]){
 assert.deepEqual([every,none,partial,eachNegative].map(r=>truth(r.meaning,members)),expected);
}
assert.equal(new Set([every,none,partial,eachNegative].map(r=>hash(r.midi))).size,4);
const modified=await hear('Every robot saved the stored file.',{noun:'robot',predicate:save,roles:['actor','target']});
assert.deepEqual(modified.meaning.events[0].arguments[1].properties,['DAT:000']);
const maintained=await hear('Every robot kept the box cold.',{noun:'robot',predicate:'CMP:cac584a394535e4912c75b5a',roles:['cause','bearer'],answers:{condition0:'physical'}});
assert.deepEqual(maintained.meaning.events[0].condition,{contextual_norm:'cold'});
const noNegative=await hear('No worker did not wait.',{q:'none',scopes:['time_before_speech','negation']});
assert(truth(noNegative.meaning,[true,true]));assert(!truth(noNegative.meaning,[true,false]));
const possible=await hear('Every program might not save the file.',{noun:'program',predicate:save,roles:['actor','target'],scopes:['modality_possible','negation']});
assert(!possible.meaning.events[0].negated_quantifier,'Do not move a negative across possibility');
for(const text of [
 'Every workers waited.','Each programs save the file.','Every worker were waiting.','Every robot save the file.',
 'No robots saves the file.','Every tired worker waited.','Not every cold gate was closed.',
 'Every worker waited and returned.','Every worker waited. They returned.',
 'No worker saved the file yesterday.','Every file was stored today.',
 'Nora copied every file.','Both workers waited.','Three workers waited.','Every worker glorped the file.'
]){
 assert(!storyReading(text,a)?.events,text);
 assert.equal(await scoreSongText(text,a,()=>{throw Error('No invented fallback');}),null,text);
}
assert((await scoreSongText('Every robot saved the file.',a,()=>{throw Error('No single-word fallback');})).midi);
console.log(`PASS ${pairs} independent quantifier melody/chord pairs, class references, scope alternatives, empty/mixed/full truth tables, questions, agreement and runtime 0/1/2; 36 older performances preserved.`);
