import assert from 'node:assert/strict';
import fs from 'node:fs';
import {createHash} from 'node:crypto';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {readSongLine} from '../pages/song_readback.mjs';
import {scoreSongText} from '../pages/song_lines.mjs';
const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const hash=b=>createHash('sha256').update(b).digest('hex');
const legacy=JSON.parse(fs.readFileSync(new URL('./story_requirement_legacy_2026_11_23.json',import.meta.url)));
for(const row of legacy.cases){
 const {midi}=await scoreStory(storyReading(row.input,a,{answers:row.answers}),a);
 assert.equal(hash(midi),row.melody_sha256,row.input);
 assert.equal(hash(compactChordMidi(midi,a.atoms)),row.chords_sha256,row.input);
 assert.deepEqual(decodeStoryMidi(midi,a.atoms),row.meaning,row.input);
}
assert.equal(legacy.cases.length,24);
const save='CMP:58cfa479709294b9809be1b7',open='CMP:0b0461b1975240868e0bed8d';
let pairs=0;
async function hear(text,{mode='obligated',scopes=['modality_obligated'],predicate=save,roles=['actor','target'],state=1,act='assertion',answers={},q=null,negative=false}={}){
 const plan=storyReading(text+' ['+state+']',a,{answers:{requirement0:mode,...answers}});
 assert(plan?.events,text+' '+JSON.stringify(plan));
 const {midi,description}=await scoreStory(plan,a),m=decodeStoryMidi(midi,a.atoms),e=m.events[0];
 assert.equal(e.predicate,predicate,text);assert.deepEqual(e.scopes,scopes,text);
 assert.deepEqual(e.arguments.map(v=>v.role),roles);assert.deepEqual(e.arguments.map(v=>v.entity),roles.map((_,i)=>i));
 assert.equal(e.quantifier,q);assert.equal(e.negated_quantifier,negative);
 assert.equal(m.runtime_state,state);assert.equal(m.speech_act,act);
 const chords=compactChordMidi(midi,a.atoms);
 assert.deepEqual(decodeStoryMidi(expandChordMidi(chords,a.atoms),a.atoms),m);
 const reading=await readSongLine(chords,a.atoms,a.compounds,true);
 assert.deepEqual(reading.meaning,m);
 assert(description.includes(mode==='obligated'?'rule, duty or commitment':'required'));
 assert(reading.summary.includes(mode==='obligated'?'rule, duty or commitment':'required'));
 pairs++;return {meaning:m,midi,description,summary:reading.summary};
}
// Expectations are stated independently of the requirement normalizer. Scope
// order is outermost first and is recovered from music without the source text.
const forms=[
 ['Nora must save the file.',[]],['Nora must not save the file.',['inside']],
 ["Nora mustn't save the file.",['inside']],['Nora has to save the file.',[]],
 ['We have to save the file.',[]],['The programs have to save the file.',[]],
 ['Nora has to not save the file.',['inside']],
 ['Nora does not have to save the file.',['negation']],
 ["Nora doesn't have to save the file.",['negation']],
 ['We do not have to save the file.',['negation']],
 ['Nora had to save the file.',['time_before_speech']],
 ['Nora did not have to save the file.',['time_before_speech','negation']],
 ['Nora will have to save the file.',['time_after_speech']],
 ['Nora will not have to save the file.',['time_after_speech','negation']],
 ['Nora might have to save the file.',['modality_possible']],
 ['Nora might not have to save the file.',['modality_possible','negation']],
 ['Nora must be saving the file.',['ongoing']],
 ['Must Nora save the file?',[],'question'],['Does Nora have to save the file?',[],'question'],
 ['Did Nora not have to save the file?',['time_before_speech','negation'],'question']
];
for(const state of [0,1,2])for(const mode of ['obligated','necessary'])for(const [text,outer,act='assertion'] of forms){
 const scopes=[...outer.filter(s=>!['inside','ongoing'].includes(s)),'modality_'+mode,
  ...(outer.includes('inside')?['negation']:[]),...(outer.includes('ongoing')?['aspect_ongoing']:[])];
 assert.equal(storyReading(text,a).question.key,'requirement0',text);
 await hear(text,{mode,scopes,state,act});
}
for(const state of [0,1,2]){
 for(const [text,predicate,roles] of [
  ['Nora must open the hatch.',open,['cause','bearer']],
  ['Nora must not delete the file.','erase_stored_object',['actor','target']],
  ['Nora must put the box at the gate.','CMP:64574c1a25d72a89aafc46ef',['actor','target','destination']],
  ['The gate must be closed.','CMP:82a697e83c845e4a7b38b53e',['bearer']],
  ['The file must be stored.','DAT:000',['bearer']],
  ['The box must be full.','CMP:d03beca450a29869aa6fd980',['bearer']]
 ])await hear(text,{state,predicate,roles,scopes:text.includes('not')?['modality_obligated','negation']:['modality_obligated']});
 const kept=await hear('Nora must keep the file stored.',{state,predicate:'CMP:cac584a394535e4912c75b5a',roles:['cause','bearer']});
 assert.equal(kept.meaning.events[0].condition,'DAT:000');
 const modified=await hear('Nora must save the stored file.',{state});assert.deepEqual(modified.meaning.events[0].arguments[1].properties,['DAT:000']);
 for(const answer of ['event','claim'])await hear('Nora must save the file tomorrow.',{state,scopes:answer==='event'?['modality_obligated','time_next_day']:['time_next_day','modality_obligated'],answers:{timeScope0:answer}});
 await hear('Every program must not save the file.',{state,q:'all',scopes:['modality_obligated','negation']});
 await hear('Every program does not have to save the file.',{state,q:'all',scopes:['negation','modality_obligated'],answers:{quantityScope0:'each'}});
 await hear('Every program does not have to save the file.',{state,q:'all',negative:true,answers:{quantityScope0:'not_all'}});
}
const prohibited=await hear('Nora must not open the hatch.',{predicate:open,roles:['cause','bearer'],scopes:['modality_obligated','negation']});
const optional=await hear('Nora does not have to open the hatch.',{predicate:open,roles:['cause','bearer'],scopes:['negation','modality_obligated']});
// Admissible situations model obligation, not whether the action actually
// happened. Optional opening differs from required non-opening in a mixed set.
function truth(scopes,worlds){
 const evalAt=(rest,world)=>!rest.length?world:rest[0]==='negation'?!evalAt(rest.slice(1),world):
  rest[0]==='modality_obligated'?worlds.every(w=>evalAt(rest.slice(1),w)):(()=>{throw Error('Unexpected test scope');})();
 return evalAt(scopes,true);
}
for(const [worlds,expected] of [[[true],[false,false]],[[false],[true,true]],[[true,false],[false,true]]]){
 assert.deepEqual([prohibited,optional].map(r=>truth(r.meaning.events[0].scopes,worlds)),expected);
}
assert(prohibited.summary.includes('required by a rule, duty or commitment that the event or condition'));
assert(optional.summary.includes('not required by a rule, duty or commitment'));
const necessary=await hear('Nora must not open the hatch.',{mode:'necessary',predicate:open,roles:['cause','bearer'],scopes:['modality_necessary','negation']});
assert.equal(new Set([prohibited,optional,necessary].map(r=>hash(r.midi))).size,3);
const paragraph=await hear('Nora must save the file. They have to copy it.',{answers:{requirement1:'necessary'}});
assert.equal(paragraph.meaning.events[1].predicate,'CMP:9ea919967152aa85bc1c7169');
assert.deepEqual(paragraph.meaning.events[1].arguments.map(a=>a.entity),[0,1]);
assert.deepEqual(paragraph.meaning.events[1].scopes,['modality_necessary']);
const preference={word:'notice',forms:['notice'],target:'MIN:011',root:'MIN:011',quality:false,roles:'experiencer/target'};
for(const mode of ['obligated','necessary']){
 const plan=storyReading('Nora must notice the signal.',a,{answers:{requirement0:mode},preferences:[preference]});
 assert(plan?.events);const {midi}=await scoreStory(plan,a),m=decodeStoryMidi(midi,a.atoms);
 assert.equal(m.events[0].predicate,'MIN:011');assert.deepEqual(m.events[0].scopes,['modality_'+mode]);
 assert.deepEqual(m.events[0].arguments.map(v=>v.role),['experiencer','target']);
 assert.deepEqual(decodeStoryMidi(expandChordMidi(compactChordMidi(midi,a.atoms),a.atoms),a.atoms),m);pairs++;
}
assert(storyReading('Nora must save the file.',a,{answers:{requirement0:'other'}}).unsupported);
assert.equal(storyReading('Nora must save the file tomorrow.',a,{answers:{requirement0:'obligated'}}).question.options[1].label,'When the obligation applies');
for(const text of [
 'Nora have to save the file.','We has to save the file.','The programs has to save the file.',
 'Nora do not have to save the file.','We does not have to save the file.','Nora must saves the file.',
 'Nora must saved the file.','Nora must have saved the file.','Nora must have been saving the file.',
 'The file must be saved by Nora.','Nora should save the file.','Nora ought to save the file.',
 "Mustn't Nora save the file?",'Nora must quickly save the file.','Nora must save.',
 'Nora must open the gate before Mira returns.','Nora must save the file and copy it.',
 'If Mira waits, Nora must save the file.','Every robot must make a box.',
 'Nora might have to save the file tomorrow.','Every program must save the file tomorrow.',
 'Nora must glorp the file.'
]){
 assert(!storyReading(text,a,{answers:{requirement0:'obligated',timeScope0:'event'}})?.events,text);
 assert.equal(await scoreSongText(text,a,()=>{throw Error('No invented fallback');}),null,text);
}
assert.equal(await scoreSongText('Nora must save the file.',a,()=>{throw Error('A meaning choice is still needed');}),null);
console.log(`PASS ${pairs} independent requirement melody/chord pairs, source-free readback, duty/necessity and inner/outer-negative scope, truth counterexamples, references, questions and runtime 0/1/2; 24 older performances preserved.`);
