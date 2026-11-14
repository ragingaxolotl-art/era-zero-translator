import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {analyzeEnglish} from '../pages/english.mjs';
import {decodeFaultCorrectionMidi,faultCorrectionPlan} from '../pages/fault_correction.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {scoreSongText} from '../pages/song_lines.mjs';
import {scoreSelectedWords,wordScorePlan} from '../pages/word_score.mjs';

const read = f => JSON.parse(fs.readFileSync(new URL('../pages/'+f,import.meta.url)));
const a = read('data/index.json'), load = id => read(a.resolution_files[id]);
const noLookup = () => assert.fail('This sentence needs no choice of dictionary candidate.');
const phrase = 'we need to resolve the redundancy error';
const original = await scoreSongText(phrase,a,noLookup);
const recover = bytes => decodeFaultCorrectionMidi(bytes,a.atoms);
const decoded = await recover(original.midi);
assert.equal(decoded.actor.role,'speaker_group');
assert.deepEqual(decoded.scopes,['necessary']);
assert.equal(decoded.action.kind,'correct_fault');
assert.equal(decoded.action.event_asserted,false);
assert.equal(decoded.fault.reference_mode,'definite_nominal');
assert.equal(decoded.fault.type_label,'redundancy');
assert.deepEqual(decoded,original.meaning);
assert.deepEqual(await decodeSupportedMeaningWithDrafts(original.midi,a.atoms,[],{allowDraft:true}),decoded);
await assert.rejects(decodeSupportedMeaningWithDrafts(original.midi,a.atoms,[]));
for (const state of [0,1,2]) {
  const s=await scoreSongText(phrase+' ['+state+'].',a,noLookup);
  assert.equal((await recover(s.midi)).runtime_state,state);
  const chords=compactChordMidi(s.midi,a.atoms);
  assert.deepEqual(await recover(expandChordMidi(chords,a.atoms)),s.meaning);
}
for (const [text,actor,scope,mode,type] of [
  ['I need to fix this timing fault.','speaker',['necessary'],'proximal_nominal','timing'],
  ['We might need to resolve the redundancy error.','speaker_group',['possible','necessary'],'definite_nominal','redundancy'],
  ['You need to correct that error.','addressee',['necessary'],'distal_nominal',null],
  ['We don’t need to resolve the redundancy error.','speaker_group',['negation','necessary'],'definite_nominal','redundancy'],
  ['We need to not resolve the redundancy error.','speaker_group',['necessary','negation'],'definite_nominal','redundancy']
]) {
  const s=await scoreSongText(text,a,noLookup), recovered=await recover(s.midi);
  assert.deepEqual(recovered,s.meaning);
  assert.equal(recovered.actor.role,actor);
  assert.deepEqual(recovered.scopes,scope);
  assert.equal(recovered.fault.reference_mode,mode);
  assert.equal(recovered.fault.type_label,type);
  assert.notDeepEqual(s.midi,original.midi);
}
assert.deepEqual((await scoreSongText('We need to fix the redundancy fault.',a,noLookup)).midi,original.midi);
for (const text of ['We resolved the redundancy error.',
 'We need to resolve the redundancy error?','We need to resolve two redundancy errors.','We need to resolve the critical error.',
 'They need to resolve the redundancy error.','We need to resolve the redundancy error and leave.']) {
  assert.equal(faultCorrectionPlan(text),null,text);
  assert.equal(await scoreSongText(text,a,noLookup),null,text);
}
const two=await scoreSongText('We need to resolve the redundancy error. You need to fix the timing fault.',a,noLookup);
assert.deepEqual(two.meaning.map(s=>s.fault.type_label),['redundancy','timing']);
assert(two.label.includes('draft'));
const changedText='we change then change tomorrow', result=analyzeEnglish(changedText,a);
const rows=result.term_coverage, choices=new Map();
const recommended=wordScorePlan(rows,choices,a);
assert.deepEqual(recommended.playable.map(w=>w.term),['change','change']);
assert.deepEqual(recommended.omitted,['we','then','tomorrow']);
const alternative=rows[3].matches.find(m=>m.route==='atom' && m.target_id!==recommended.playable[1].target);
choices.set(3,alternative.sense_id);
const revised=wordScorePlan(rows,choices,a);
assert.equal(revised.playable[0].target,recommended.playable[0].target);
assert.equal(revised.playable[1].target,alternative.target_id);
const initialMidi=await scoreSelectedWords(recommended,1,load), revisedMidi=await scoreSelectedWords(revised,1,load);
assert.notDeepEqual(initialMidi,revisedMidi);
assert.notDeepEqual(await scoreSelectedWords(revised,0,load),await scoreSelectedWords(revised,2,load));
const unknown=wordScorePlan(analyzeEnglish('we blorf the small archive',a).term_coverage,new Map(),a);
assert.deepEqual(unknown.playable,[{term:'archive',kind:'name'}]);
assert(unknown.omitted.includes('blorf')&&unknown.omitted.includes('small'));

// Exercise the actual result buttons, including an edit while a template is loading.
const app=fs.readFileSync(new URL('../pages/app.js',import.meta.url),'utf8');
class Element {
  children=[];handlers={};value='';
  append(...items){this.children.push(...items);}
  contains(item){return this.children.includes(item);}
  replaceChildren(...items){this.children=items;}
  addEventListener(type,fn){this.handlers[type]=fn;}
}
const box=new Element(), source=new Element();source.value=changedText;
let played,added,loadTemplate=load;
const state={analysis:result,wordSelections:new Map(),data:a};
const context=vm.createContext({state,document:{createElement:()=>new Element()},
  $:id=>id==='wordScore'?box:source,wordScorePlan,scoreSelectedWords,
  resolutionDocument:id=>loadTemplate(id),addPerformance:(...args)=>{added=args;},
  savedCompoundPlayer:{play:b=>{played=b;},stop(){}},toast:msg=>assert.fail(msg)});
vm.runInContext(app.slice(app.indexOf('function updateWordScore('),app.indexOf('function dictionaryRecord(')),context);
const click=text=>box.children.find(el=>el.textContent===text).handlers.click();
context.updateWordScore(result);
await click('Play word sketch');assert.deepEqual(played,initialMidi);
state.wordSelections.set(3,alternative.sense_id);
context.updateWordScore(result);
await click('Add word sketch to song');assert.deepEqual(added,[changedText,revisedMidi,'Word sketch']);
let release;
const gate=new Promise(resolve=>{release=resolve;});
loadTemplate=async id=>{await gate;return load(id);};
added=null;const pending=click('Add word sketch to song');
state.wordSelections.clear();context.updateWordScore(result);
release();await pending;assert.equal(added,null);
source.value='another sentence';await click('Add word sketch to song');assert.equal(added,null);
console.log('PASS whole correction recovered from melody and chords, runtime and scope contrasts, per-word choices and stale UI events.');
