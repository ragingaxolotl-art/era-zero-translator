import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeSentenceSequence,composeSentenceConjunction,composeSentenceConditional,composeSentenceDisjunction} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeSupportedMeaningMidi} from '../pages/semantic_music_dispatch.mjs';
import {decodeContextualGroupMidi} from '../pages/contextual_group_decoder.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {notesFromMidi,midiFromNoteTimeline} from '../pages/performance_codec.mjs';
import {readSongLine} from '../pages/song_readback.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const load=async id=>JSON.parse(fs.readFileSync(new URL('../pages/'+authority.resolution_files[id],import.meta.url))).variants['assertion:1'];
const width={interpretation:'width_standard',standard:{kind:'contextual',dimension:'physical_width'}};
const hot={interpretation:'thermal_standard',standard:{kind:'contextual',dimension:'thermodynamic_temperature'}};
const choices=[width,width],sounds=new Set();let checked=0,example;
for(const runtime of [0,1,2])for(const negated of [false,true]){
 const first=`The gate was ${negated?'not ':''}wide [${runtime}]`,second=`the board is narrow [${runtime}]`;
 for(const [operator,compose,text] of [
  ['sequence',composeSentenceSequence,first+', then '+second+'.'],
  ['all_of',composeSentenceConjunction,first+' and '+second+'.'],
  ['conditional',composeSentenceConditional,'If '+first+', then '+second+'.'],
  ['any_of',(t,l,c)=>composeSentenceDisjunction(t,l,c,{disjunction:'any_of'}),first+' or '+second+'.'],
  ['exactly_one',(t,l,c)=>composeSentenceDisjunction(t,l,c,{disjunction:'exactly_one'}),first+' or '+second+'.']
 ]){
  const result=await compose(text,load,choices),midi=midiFromFormal(result.formal);
  const heard=decodeContextualGroupMidi(midi,authority.atoms);assert.equal(heard.operator,operator);
  assert.equal(heard.members.length,2);assert.deepEqual(heard.members.map(m=>m.standard.norm),['wide','narrow']);
  assert.deepEqual(heard.members.map(m=>m.runtime_state),[runtime,runtime]);
  assert.deepEqual(heard.members[0].scopes,[{operator:'time',relation:'before_speech'},...(negated?[{operator:'negation'}]:[])]);
  assert.deepEqual(heard.members[1].scopes,[]);assert.notDeepEqual(heard.members[0].bearer,heard.members[1].bearer);
  assert(!heard.members.some(m=>'speech_act' in m),'Embedded content must not claim separate assertions');
  assert.deepEqual(decodeSupportedMeaningMidi(midi,authority.atoms),heard);
  assert.deepEqual(decodeSupportedMeaningMidi(expandChordMidi(compactChordMidi(midi,authority.atoms),authority.atoms),authority.atoms),heard);
  if(operator==='conditional')assert.equal(heard.condition_status,'open');
  sounds.add(Buffer.from(midi).toString('base64'));checked++;
  if(operator==='sequence'&&runtime===1&&!negated)example={result,midi,heard};
 }
}
assert.equal(sounds.size,30);
const reversed=await composeSentenceSequence('The board is narrow, then the gate was wide.',load,choices);
assert.deepEqual(decodeContextualGroupMidi(midiFromFormal(reversed.formal),authority.atoms).members.map(m=>m.standard.norm),['narrow','wide']);
const mixed=await composeSentenceConjunction('The gate is wide and the board is hot.',load,[width,hot]);
assert.deepEqual(decodeContextualGroupMidi(midiFromFormal(mixed.formal),authority.atoms).members.map(m=>m.dimension),['physical_width','thermodynamic_temperature']);
const three=await composeSentenceSequence('The gate is wide, then the board is narrow, then the box is wide.',load,[width,width,width]);
assert.equal(decodeContextualGroupMidi(midiFromFormal(three.formal),authority.atoms).members.length,3);
// Outer scope stays on the relationship, not on each member.
const outer=structuredClone(mixed.formal),center=outer.semantic_ir.edges.find(e=>e.type==='centers'&&e.to===outer.semantic_ir.root_clause),inside=center.from;
outer.semantic_ir.nodes.push({node_id:'outside_negation',kind:'scope_operator',operator:'negation'});
center.from='outside_negation';outer.semantic_ir.edges.push({edge_id:'outside_scope',type:'scopes',from:inside,to:'outside_negation'});
const scoped=decodeContextualGroupMidi(midiFromFormal(outer),authority.atoms);
assert.deepEqual(scoped.scopes,[{operator:'negation'}]);assert(scoped.members.every(m=>m.scopes.length===0));
// The final contour scopes a question over the complete group.
const questionNotes=notesFromMidi(example.midi);questionNotes.notes.at(-1).midi+=2;
const question=decodeContextualGroupMidi(midiFromNoteTimeline(questionNotes.notes,questionNotes.division,questionNotes.tempos[0].value),authority.atoms);
assert.equal(question.speech_act,'question');assert(!question.members.some(m=>'speech_act' in m));
const readback=await readSongLine(compactChordMidi(example.midi,authority.atoms),authority.atoms,[],true);
assert.match(readback.summary,/temporal order/);assert.match(readback.summary,/Clause 1 content/);assert.match(readback.summary,/wide/);

// Deleting a temporal boundary must not turn juxtaposition into a sequence.
const observed=decodeStrictMusicMidi(example.midi,authority.atoms),boundary=observed.tokens.find(t=>t.boundary_after_beats===1);
assert(boundary);
const timeline=notesFromMidi(example.midi),cut=boundary.end_tick;
const mutated=timeline.notes.map(n=>n.start_tick>cut?{...n,start_tick:n.start_tick-timeline.division/2,end_tick:n.end_tick-timeline.division/2}:n);
assert.throws(()=>decodeContextualGroupMidi(midiFromNoteTimeline(mutated,timeline.division,timeline.tempos[0].value),authority.atoms));

// Replacing a material head with a different, well-formed root is rejected.
const other=midiFromFormal((await load('DAT:000')).formal),otherTimeline=notesFromMidi(other);
const otherRoot=decodeStrictMusicMidi(other,authority.atoms).tokens.find(t=>t.kind==='root');
const head=observed.tokens.find(t=>t.kind==='root');
const replacement=otherTimeline.notes.filter(n=>n.start_tick>=otherRoot.start_tick&&n.end_tick<=otherRoot.end_tick)
 .map(n=>({...n,start_tick:n.start_tick-otherRoot.start_tick+head.start_tick,end_tick:n.end_tick-otherRoot.start_tick+head.start_tick}));
const headDelta=replacement.at(-1).end_tick-head.end_tick;
const changedHead=timeline.notes.filter(n=>n.start_tick<head.start_tick||n.end_tick>head.end_tick).map(n=>n.start_tick>head.end_tick?{...n,start_tick:n.start_tick+headDelta,end_tick:n.end_tick+headDelta}:n).concat(replacement).sort((a,b)=>a.start_tick-b.start_tick);
const changedMidi=midiFromNoteTimeline(changedHead,timeline.division,timeline.tempos[0].value);
assert(decodeStrictMusicMidi(changedMidi,authority.atoms).tokens.some(t=>t.root_id==='DAT:000'));
assert.throws(()=>decodeContextualGroupMidi(changedMidi,authority.atoms));

const mixedPredicate=await composeSentenceConjunction('The gate is wide and Nora is conscious.',load,[width,{}]);
assert.throws(()=>decodeContextualGroupMidi(midiFromFormal(mixedPredicate.formal),authority.atoms));
const union=midiFromFormal(mixed.formal),unionNotes=notesFromMidi(union);
const separator=decodeStrictMusicMidi(union,authority.atoms).tokens.find(t=>t.marker==='coord_member');
const delta=separator.end_tick-separator.start_tick+unionNotes.division/2;
const missingSeparator=unionNotes.notes.filter(n=>n.start_tick<separator.start_tick||n.end_tick>separator.end_tick)
 .map(n=>n.start_tick>separator.end_tick?{...n,start_tick:n.start_tick-delta,end_tick:n.end_tick-delta}:n);
const missingBytes=midiFromNoteTimeline(missingSeparator,unionNotes.division,unionNotes.tempos[0].value);
decodeStrictMusicMidi(missingBytes,authority.atoms);
assert.throws(()=>decodeContextualGroupMidi(missingBytes,authority.atoms));
console.log('PASS '+checked+' independently decoded groups, five relationships, all runtimes, scope/bearer order, compact parity, mixed physical dimensions and malformed boundaries/heads/separators.');
