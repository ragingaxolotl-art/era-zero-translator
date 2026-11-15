import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeInformationPassage,informationPassagePlan,decodeInformationPassageMidi} from '../pages/information_passage.mjs';
import {faultCorrectionPlan} from '../pages/fault_correction.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {songMidi,scoreSongText,needsWholeReading} from '../pages/song_lines.mjs';
import {encodeName} from '../pages/names.mjs';
import {analyzeEnglish} from '../pages/english.mjs';
import {mountSongEditor} from '../pages/song_editor.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../pages/'+p,import.meta.url)));
const a=read('data/index.json');
const load=id=>a.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority:a}:{...read(a.resolution_files[id]).variants['assertion:1'],authority:a};
const phrase='We have found the program. We need to delete it.';
const sentence=await scoreSongText(phrase,a,load);
for(const input of [phrase,'We have found the program we need to delete it', "We've found the program, and we need to delete it."]) {
 const result=await composeInformationPassage(input,a);assert.deepEqual(result.midi,sentence.midi);
}
for(const state of [0,1,2]) {
 const result=await composeInformationPassage(phrase+' ['+state+']',a);
 const d=decodeInformationPassageMidi(result.midi,a.atoms);
 assert.equal(d.runtime_state,state);assert.equal(d.speech_act,'assertion');
 assert.equal(d.discovery.actor.role,'speaker_group');assert.equal(d.requirement.actor.role,'speaker_group');
 assert.equal(d.discovery.present_perfect,true);assert.equal(d.discovery.time,'before_speech');
 assert.equal(d.requirement.mode,'necessary');assert.equal(d.requirement.action,'erase_stored_object');assert.equal(d.requirement.event_asserted,false);
 assert.equal(d.classification,'CMP:2f350e7d8e5dfba4a802d82d');assert.equal(d.discovery.target.reference_mode,'definite_nominal');
 assert.deepEqual(d.discovery.target.phonemes,(await encodeName('program')).phonemes);assert.deepEqual(d.discovery.target,d.requirement.target);
}
const changed=await composeInformationPassage('I found the file. You need to delete it.',a);
const other=decodeInformationPassageMidi(changed.midi,a.atoms);assert.equal(other.discovery.present_perfect,false);
assert.equal(other.discovery.actor.role,'speaker');assert.equal(other.requirement.actor.role,'addressee');
assert.deepEqual(other.discovery.target.phonemes,(await encodeName('file')).phonemes);assert.equal(other.classification,undefined);
for(const t of ['We have found the program. We deleted it.','We have found the program but we might need to delete it.','We have not found the program. We need to delete it.','We have found the file and the program. We need to delete it.','We have found the program. We need to delete the file.','We have found the program. We need to delete it?','We need to delete it.','We have found the program. We need to delete it. Also copy it.']) assert.equal(informationPassagePlan(t),null,t);
const care=await scoreSongText('I care for you.',a,load);assert(care);
const multiple=await scoreSongText('I care for you. I am able to move.',a,load);assert.equal(multiple.meaning.length,2);
assert.equal(await scoreSongText('I care for you. We blorf the program.',a,load),null);
assert.equal(needsWholeReading('active care',analyzeEnglish('active care',a)),false);
assert(needsWholeReading('We found it and need to delete it',analyzeEnglish('We found it and need to delete it',a)));
const lineNotes=bytes=>notesFromMidi(bytes).notes.map(n=>[n.midi,n.start_tick,n.end_tick]);
const first=lineNotes(sentence.midi),next=lineNotes(care.midi),both=lineNotes(songMidi([sentence,care]));
const start=first.at(-1)[2]+960;
assert.deepEqual(both,[...first,...next.map(([p,a,b])=>[p,start+a,start+b])]);
assert.throws(()=>decodeInformationPassageMidi(care.midi,a.atoms));
class Element {
 constructor(){this.children=[];}
 append(...x){this.children.push(...x);}replaceChildren(){this.children=[];}
 setAttribute(){}addEventListener(name,fn){this[name]=fn;}
}
let storageState=new Map(),played,saved,stops=0;
function editor() {
 const ids=new Map(['songLines','songStatus','playSong','exportSong','stopSong','songArrangement'].map(id=>[id,new Element()]));
 ids.get('songArrangement').value='melody';
 const add=mountSongEditor({getAtoms:()=>a.atoms,document:{getElementById:id=>ids.get(id),createElement:()=>new Element()},
  storage:{get length(){return storageState.size},key:i=>[...storageState.keys()][i],getItem:key=>storageState.get(key)??null,setItem:(key,v)=>storageState.set(key,v),removeItem:key=>storageState.delete(key)},
  player:{play:bytes=>{played=bytes;},stop:()=>{stops++;}},download:blob=>{saved=blob;}});
 return {ids,add};
}
let ui=editor();ui.add(phrase,sentence.midi,'Draft passage');ui.add('I care for you.',care.midi,'Complete sentence');
ui=editor();assert.equal(ui.ids.get('songLines').children.length,2);await ui.ids.get('playSong').click();
assert.deepEqual(lineNotes(played),both);ui.ids.get('exportSong').click();
assert.deepEqual(lineNotes(new Uint8Array(await saved.arrayBuffer())),both);
ui.ids.get('songLines').children[0].children[1].click();assert(stops>0);
assert.equal(editor().ids.get('songLines').children.length,1);
// Two tabs can hold different views when their synchronous click handlers run.
const originalSave=JSON.stringify([{text:phrase,label:'Earlier song',bytes:Buffer.from(sentence.midi).toString('base64')}]);
storageState=new Map([['era-zero-song-lines-v1',originalSave]]);
const tabA=editor(),tabB=editor(),oldRemove=tabB.ids.get('songLines').children[0].children[1];
tabA.add('First new line',care.midi,'Care');
tabB.add('Second new line',care.midi,'Care');
oldRemove.click();
const titles=()=>editor().ids.get('songLines').children.map(row=>row.children[0].textContent.split(' · ')[0]);
assert.deepEqual(titles(),['First new line','Second new line']);
tabA.ids.get('songLines').children[1].children[1].click();
assert.deepEqual(titles(),['Second new line']);
assert.equal(storageState.get('era-zero-song-lines-v1'),originalSave);
console.log('PASS two-clause meaning recovered from MIDI alone, role/time/runtime contrasts, unsupported near misses, ordered song playback, export and local persistence.');

// Exercise the same translator result buttons that forward a scored passage to the song editor.
const {default:vm}=await import('node:vm');
const {compactChordMidi,expandChordMidi}=await import('../pages/compact_chords.mjs');
const app=fs.readFileSync(new URL('../pages/app.js',import.meta.url),'utf8');
class ResultElement extends Element {
 constructor(){super();this.value='';this.classList={add(){},remove(){}};}
 scrollIntoView(){}
}
const fields=Object.fromEntries(['sourceInput','output','phraseCoverage','resolutionPanel','results','decisionSummary','candidateList'].map(id=>[id,new ResultElement()]));
fields.sourceInput.value=phrase;
let forwarded=[],playedLine;
const {storyReading}=await import('../pages/story_readings.mjs');
const ctx=vm.createContext({storyReading,faultCorrectionPlan,informationPassagePlan,composeInformationPassage,scoreSongText,compactChordMidi,
 state:{data:a,mode:'general',wordSelections:new Map()},$:id=>fields[id],sentenceTemplate:load,document:{createElement:()=>new ResultElement()},
 savedCompoundPlayer:{play:async(bytes,options)=>{playedLine={bytes,options};},stop(){}},toast(){},download(){},
 addPerformance:(text,midi,label)=>forwarded.push({text,midi,label})});
const snippet=(start,end)=>app.slice(app.indexOf(start),app.indexOf(end,app.indexOf(start)+start.length));
vm.runInContext(snippet('function songButton(','state.song='),ctx);
vm.runInContext(snippet('async function showWholePassage(', "$('sourceInput').addEventListener"),ctx);
assert.equal(await ctx.showWholePassage(phrase),true);
const card=fields.candidateList.children[0],control=name=>card.children.find(e=>e.textContent===name);
await control('Play whole passage').click();assert.deepEqual(lineNotes(playedLine.bytes),first);
await control('Play compact chords').click();assert.equal(playedLine.options.chords,true);assert.deepEqual(lineNotes(expandChordMidi(playedLine.bytes,a.atoms)),first);
control('Add to song').click();assert.equal(forwarded[0].text,phrase);assert.deepEqual(lineNotes(forwarded[0].midi),first);
fields.sourceInput.value='We found the program. We deleted it.';control('Add to song').click();assert.equal(forwarded.length,1);
assert.equal(await ctx.showWholePassage(fields.sourceInput.value),false);
console.log('PASS whole passage, chord preview and Add to song buttons use the scored notes and discard stale readings.');

fields.sourceInput.value='we need to resolve the redundancy error';
assert.equal(await ctx.showWholePassage(fields.sourceInput.value),true);
const faultCard=fields.candidateList.children[0],faultButton=name=>faultCard.children.find(e=>e.textContent===name);
assert.equal(faultCard.children[1].textContent,'Our group needs to correct the redundancy fault. “redundancy” names the kind of fault.');
await faultButton('Play whole sentence').click();
faultButton('Add to song').click();
assert.equal(forwarded[1].text,fields.sourceInput.value);
assert.deepEqual(lineNotes(forwarded[1].midi),lineNotes(playedLine.bytes));
await faultButton('Play compact chords').click();
assert.deepEqual(lineNotes(expandChordMidi(playedLine.bytes,a.atoms)),lineNotes(forwarded[1].midi));
console.log('PASS the submitted sentence plays and enters the song directly from its whole-sentence controls.');
