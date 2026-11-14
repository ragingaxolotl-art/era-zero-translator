import assert from 'node:assert/strict';
import fs from 'node:fs';
import {encodeName,notesForName} from '../pages/names.mjs';
import {deicticReference,deicticEvent,nominalMarker} from '../pages/references.mjs';
import {CONTEXTUAL_CONTENT_KINDS,contextualContentMusicFrames,contextualContentMusicEvent,midiFromContextualContent,readContextualContentMusic} from '../pages/contextual_content_music.mjs';
import {strictGrammarFrameInventory,decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {questionContentMusicFrames} from '../pages/question_music_frames.mjs';
import {acquisitionMusicFrames} from '../pages/acquisition_music_frames.mjs';
import {quantifiedMusicFrames} from '../pages/quantified_music.mjs';
import {midiFromScheduledEvents} from '../pages/engine.mjs';
const {atoms}=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const paths=contextualContentMusicFrames().map(f=>f.path.join(','));
assert.equal(new Set(paths).size,8);
assert(![...strictGrammarFrameInventory(),...questionContentMusicFrames(),...acquisitionMusicFrames(),...quantifiedMusicFrames()].some(f=>paths.includes(f.path.join(','))));
let cases=0;
for(const anchor of [48,60,72]){
 const name=await encodeName('Nora'),event={family_opening_absolute_midi:[],address_absolute_midi:notesForName(name).map(n=>n+anchor-60),note_duration_beats:1};
 const references=[[event],...['definite_nominal','proximal_nominal','distal_nominal'].map(reference_mode=>[nominalMarker({reference_mode,node_id:'r'},'middle',anchor),event]),...['speaker','addressee'].map(role=>[deicticEvent(deicticReference(role,'r'),'middle',anchor)])];
 const sounds=new Set();
 for(const kind of CONTEXTUAL_CONTENT_KINDS)for(const reference of references){
  const bytes=midiFromContextualContent(kind,reference,atoms,{allowDraft:true,anchor});
  assert.throws(()=>decodeStrictMusicMidi(bytes,atoms));
  assert.throws(()=>readContextualContentMusic(bytes,atoms));
  const result=readContextualContentMusic(bytes,atoms,{allowDraft:true});
  assert.equal(result.content_kind,kind);assert.equal(result.assertion_commitment,'none');
  if(reference.at(-1)===event)assert.deepEqual(result.anchor.phonemes,name.phonemes);
  sounds.add(Buffer.from(bytes).toString('base64'));cases++;
 }
 assert.equal(sounds.size,24);
 for(const payload of [[],[event,event],[nominalMarker({reference_mode:'nominal_class',node_id:'r'},'middle',anchor),event]])assert.throws(()=>midiFromContextualContent('topic',payload,atoms,{allowDraft:true,anchor}));
 const open=contextualContentMusicEvent('topic','open',anchor),close=contextualContentMusicEvent('reasons','close',anchor);
 assert.throws(()=>readContextualContentMusic(midiFromScheduledEvents([open,event,close],anchor,[0,0]),atoms,{allowDraft:true}));
 assert.throws(()=>readContextualContentMusic(midiFromScheduledEvents([open,event,contextualContentMusicEvent('topic','close',anchor)],anchor,[0,2]),atoms,{allowDraft:true}));
}
assert.throws(()=>midiFromContextualContent('topic',[],atoms));
console.log(`PASS ${cases} contextual selector musical inverses; distinct kinds and reference modes, collision checks, nonassertion, malformed payload and draft rejection.`);
