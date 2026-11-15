import fs from 'node:fs';
import assert from 'node:assert/strict';
import {compactChordMidi,compactChordPerformance,expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi,midiFromNoteTimeline} from '../pages/performance_codec.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {composeInformationPassage,decodeInformationPassageMidi} from '../pages/information_passage.mjs';
import {scoreSongText,songMidi} from '../pages/song_lines.mjs';
import {decodeStoryMidi} from '../pages/story_music.mjs';
import {encodeName,midiFromName} from '../pages/names.mjs';
const data=file=>JSON.parse(fs.readFileSync(new URL('../pages/'+file,import.meta.url)));
const a=data('data/index.json');
const notes=(bytes,poly=false)=>notesFromMidi(bytes,{allowPolyphony:poly}).notes.map(({midi,start_tick,end_tick})=>[midi,start_tick,end_tick]);
const seen=new Set();
for(const atom of a.atoms){
 const variants=data(a.resolution_files[atom.canonical_id]).variants;
 for(const state of [0,1,2]){
  const mono=midiFromFormal(variants['assertion:'+state].formal);
  const chord=compactChordMidi(mono,a.atoms),score=notes(chord,true);
  assert.equal(score.filter(n=>n[1]===0).length,3,atom.canonical_id);
  assert.deepEqual(notes(expandChordMidi(chord,a.atoms)),notes(mono),atom.canonical_id+'/'+state);
  assert(score.at(-1)[2]<notes(mono).at(-1)[2]);seen.add(JSON.stringify(score));
 }
}
assert.equal(seen.size,972);
const text='We have found the program. We need to delete it.';
const {midi}=await composeInformationPassage(text,a),compact=compactChordMidi(midi,a.atoms);
const expanded=expandChordMidi(compact,a.atoms);
assert.deepEqual(notes(expanded),notes(midi));assert.deepEqual(decodeInformationPassageMidi(expanded,a.atoms),decodeInformationPassageMidi(midi,a.atoms));
const load=id=>a.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority:a}:{...data(a.resolution_files[id]).variants['assertion:1'],authority:a};
for(const text of ['I care for you.','I do not care for you. [0]','Does Nora care for Eli?','It is possible that I am moving away from the bench.','I am registering acoustic input from Keshet.']){
 const line=await scoreSongText(text,a,load);assert(line,text);
 const song=songMidi([{midi},line]);assert.deepEqual(notes(expandChordMidi(compactChordMidi(song,a.atoms),a.atoms)),notes(song),text);
}
// These saved scores contain roots with no rest between components. The previously
// released arranger returned identical monophonic music for every runtime of reopen.
const joined=[];
for(const state of [0,1,2]){
  const text='The gate reopened. ['+state+']';
  const scored=await scoreSongText(text,a,load);
  const arrangement=compactChordPerformance(scored.midi,a.atoms,{preview:true});
  assert.equal(arrangement.rootCount,5);
  const attacks=Map.groupBy(notes(arrangement.midi,true),n=>n[1]);
  assert.equal([...attacks.values()].filter(group=>group.length===3).length,10);
  assert(arrangement.chordSeconds<.8*arrangement.melodySeconds);
  const expanded=expandChordMidi(arrangement.midi,a.atoms);
  assert.deepEqual(notes(expanded),notes(scored.midi));
  assert.equal(decodeStoryMidi(expanded,a.atoms).runtime_state,state);
  assert.deepEqual(notes(expandChordMidi(arrangement.firstRoot.chords,a.atoms)),notes(arrangement.firstRoot.melody));
  joined.push(scored);
}
const namesOnly=midiFromName(await encodeName('Gate 2'));
assert.equal(compactChordPerformance(namesOnly,a.atoms,{preview:true}).firstRoot,null);
assert.deepEqual(notes(compactChordMidi(namesOnly,a.atoms)),notes(namesOnly));
const mixed=songMidi([joined[2],{midi:namesOnly},joined[0]]);
const combination=compactChordPerformance(mixed,a.atoms,{preview:true});
assert.equal(combination.rootCount,10);
assert.deepEqual(notes(expandChordMidi(combination.midi,a.atoms)),notes(mixed));
const sample=compactChordMidi(midiFromFormal(data(a.resolution_files['MOV:101']).variants['assertion:2'].formal),a.atoms);
const attacks=notesFromMidi(sample,{allowPolyphony:true}).notes;
assert.throws(()=>expandChordMidi(midiFromNoteTimeline(attacks.slice(1)),a.atoms));
assert.throws(()=>expandChordMidi(midiFromNoteTimeline(attacks.map(n=>n.start_tick===960?{...n,midi:n.midi-1}:n)),a.atoms));
assert.throws(()=>notesFromMidi(sample),/Polyphonic/);
console.log('PASS all 324 roots × 3 runtime endings produce distinct chords. Notes and durations round-trip for all 972 words and full messages, including role frames, scope, names and contours.');
