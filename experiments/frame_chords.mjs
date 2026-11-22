// Research transport only. Keeps roots, runtime endings, names and scope semantics.
// The inverse takes only performed notes and the frozen shared public frame alphabet.
import fs from 'node:fs';
import {notesFromMidi,midiFromNoteTimeline} from '../pages/performance_codec.mjs';
import {expandChordMidi,compactChordMidi} from '../pages/compact_chords.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
export const alphabet=JSON.parse(fs.readFileSync(new URL('./frame_chords_v1.json',import.meta.url)));
const byMarker=new Map(alphabet.entries.map(e=>[e.marker,e]));
const drafts={allowDraftQuantified:true,allowDraftQuestionContent:true,allowDraftAcquisition:true,
 allowDraftContextualContent:true,allowDraftContextualInquiry:true,allowDraftCuriosity:true,
 allowDraftPain:true,allowDraftPainStimulus:true,allowDraftPainComparison:true,allowDraftPainPreference:true,
 allowDraftDrinking:true,allowDraftDesiredDrinking:true,allowDraftOwnership:true,allowDraftDesiredOwnership:true,
 allowDraftDesiredAvailability:true,allowDraftCustodyOpportunity:true,allowDraftInformationPassage:true};
const note=(midi,start_tick,end_tick)=>({midi,start_tick,end_tick});
const header=[-24,-12,-5,4,12];
const pitches=(digit,anchor)=>{const base=anchor-24+digit%12;return [base,base+12,base+12+(digit<12?4:3),base+19];};
const parse=bytes=>{const p=notesFromMidi(bytes,{allowPolyphony:true});if(p.division%4||p.tempos.some(t=>t.tick!==0))throw Error('Fixed tempo and sixteenth-note grid required.');return {...p,tempo:p.tempos[0]?.value||500000};};
export function packFrames(melody,atoms,{beats=.25}={}){
 if(![.25,.5].includes(beats))throw Error('Use sixteenth or eighth notes.');
 const observed=decodeStrictMusicMidi(melody,atoms,drafts);
 const compact=compactChordMidi(melody,atoms),p=parse(compact);
 // Find the same exact fixed-frame pitches in the compact score, in token order.
 const out=header.map(offset=>note(observed.anchor_midi+offset,0,p.division/4));
 let cursor=0,shift=p.division/4,replaced=0;
 for(const token of observed.tokens){
  // Non-frame spans may change size under root compression. Search strictly forward
  // only when the full public frame pattern is present, with its quarter-beat timing.
  const frame=byMarker.get(token.marker);if(!frame)continue;
  let position=-1;
  for(let i=cursor;i<p.notes.length;i++){
   if(frame.path.every((pitch,j)=>{const n=p.notes[i+j];return n&&n.midi===observed.anchor_midi+pitch&&n.end_tick-n.start_tick===p.division/4&&(!j||n.start_tick===p.notes[i+j-1].end_tick);})) {position=i;break;}
  }
  if(position<0)throw Error('No complete frame after prior frame.');
  for(const n of p.notes.slice(cursor,position))out.push(note(n.midi,n.start_tick+shift,n.end_tick+shift));
  const start=p.notes[position].start_tick+shift;
  for(const [i,digit] of [Math.floor(frame.code/24),frame.code%24].entries())
   for(const pitch of pitches(digit,observed.anchor_midi))out.push(note(pitch,start+i*beats*p.division,start+(i+1)*beats*p.division));
  shift+=2*beats*p.division-frame.path.length*p.division/4;
  cursor=position+frame.path.length;replaced++;
 }
 for(const n of p.notes.slice(cursor))out.push(note(n.midi,n.start_tick+shift,n.end_tick+shift));
 if(out.some(n=>n.midi<0||n.midi>127))throw Error('Experimental register out of range.');
 return {midi:midiFromNoteTimeline(out,p.division,p.tempo),replaced};
}
export function unpackFrames(bytes,atoms){
 const p=parse(bytes),groups=[];
 for(const n of p.notes){if(groups.at(-1)?.[0].start_tick!==n.start_tick)groups.push([]);groups.at(-1).push(n);}
 const first=groups.shift(),anchor=first?.[0].midi+24;
 if(first?.length!==5||first.some((n,i)=>n.midi!==anchor+header[i]||n.start_tick!==0||n.end_tick!==p.division/4))throw Error('Not the experimental profile.');
 const out=[];let shift=-p.division/4;
 for(let i=0;i<groups.length;i++){
  const g=groups[i];
  if(g.length!==4){for(const n of g)out.push(note(n.midi,n.start_tick+shift,n.end_tick+shift));continue;}
  const next=groups[++i],beats=(g[0].end_tick-g[0].start_tick)/p.division;
  if(![.25,.5].includes(beats)||next?.length!==4||next[0].start_tick!==g[0].end_tick)throw Error('Truncated or irregular frame chord pair.');
  const digit=group=>{
   const candidate=Array.from({length:24},(_,n)=>n).filter(d=>pitches(d,anchor).every((pitch,j)=>group[j].midi===pitch&&group[j].end_tick===group[0].start_tick+beats*p.division));
   if(candidate.length!==1)throw Error('Unknown frame chord voicing.');return candidate[0];
  };
  const code=digit(g)*24+digit(next),frame=alphabet.entries[code];if(!frame)throw Error('Unassigned frame chord code.');
  const start=g[0].start_tick+shift;
  frame.path.forEach((pitch,j)=>out.push(note(anchor+pitch,start+j*p.division/4,start+(j+1)*p.division/4)));
  shift+=frame.path.length*p.division/4-2*beats*p.division;
 }
 return expandChordMidi(midiFromNoteTimeline(out,p.division,p.tempo),atoms);
}
