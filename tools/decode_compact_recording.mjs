// Only the WAV and public language enter this listener. The reference voice has a
// fixed 120 BPM clock. Reject ambiguous performances instead of choosing a story.
import fs from 'node:fs';
import {createHash} from 'node:crypto';
import {fileURLToPath} from 'node:url';
import {execFileSync} from 'node:child_process';
import {midiFromNoteTimeline} from '../pages/performance_codec.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';

const file=process.argv[2];
if(!file||process.argv.length!==3)throw Error('Supply one PCM WAV recording of a compact song line.');
const observed=JSON.parse(execFileSync('python3',[fileURLToPath(new URL('./compact_recording.py',import.meta.url)),file],
  {encoding:'utf8',maxBuffer:16000000,env:{...process.env,OPENBLAS_NUM_THREADS:'1'}}));
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const records=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_preview_candidates.json',import.meta.url))).records;
async function readPerformance(observation){
const frames=observation.frames;
const same=(a,b)=>a?.length===b?.length&&a.every((v,i)=>v===b[i]);
const steady=(start,length,tones)=>tones&&length>0&&start+length<=frames.length&&frames.slice(start,start+length).every(f=>same(f,tones));
const note=(midi,from,to)=>({midi,start_tick:from*120,end_tick:to*120});
const midi=notes=>midiFromNoteTimeline(notes,480,500000);
function readChords(from,end){
  const paths=new Map([[end,[[]]]]);
  for(let i=end-8;i>=from;i--){
    const family=frames[i],address=frames[i+4];
    if(family.length!==3||address.length!==3||!steady(i,4,family)||!steady(i+4,4,address))continue;
    const solutions=[];
    for(const [runtime,duration] of [[null,0],[0,1],[1,2],[2,8]]){
      const next=i+8+duration,suffixes=paths.get(next);
      if(!suffixes)continue;
      const top=[address[2]-1,family[0]+12,address[2]+7][runtime];
      if(duration&&!steady(i+8,duration,[address[0],address[1],top]))continue;
      const local=[...family.map(p=>note(p,0,4)),...address.map((p,lane)=>note(p,4,lane===2?8:8+duration))];
      if(duration)local.push(note(top,8,8+duration));
      try{expandChordMidi(midi(local),authority.atoms);}catch{continue;}
      const slice=local.map(n=>({...n,start_tick:n.start_tick+i*120,end_tick:n.end_tick+i*120}));
      for(const suffix of suffixes)solutions.push([...slice,...suffix]);
      if(solutions.length>1)break;
    }
    if(solutions.length)paths.set(i,solutions);
  }
  const result=paths.get(from);
  if(result?.length!==1)throw Error('The acoustic chord span at beat '+from/4+' has no unique complete reading.');
  return result[0];
}
function readMono(from,end){
  const rows=[];
  if(end===frames.length){
    if(end-from!==4||!steady(from,2,frames[from])||!steady(from+2,2,frames[from+2]))throw Error('Incomplete speech-act ending.');
    return [note(frames[from][0],from,from+2),note(frames[from+2][0],from+2,end)];
  }
  for(let i=from;i<end;){
    const p=frames[i][0],base=p+12;
    if(steady(i,4,[p])&&steady(i+4,4,[base])&&steady(i+8,4,[base-5])){
      let j=i;
      for(;j+4<=end&&steady(j,4,frames[j]);j+=4){
        rows.push(note(frames[j][0],j,j+4));
        if(j>=i+20&&frames[j][0]===p&&frames[j-4][0]===base&&frames[j-8][0]===base-5){j+=4;break;}
      }
      i=j;
    }else{rows.push(note(p,i,i+1));i++;}
  }
  return rows;
}
const notes=[];
let chordSpans=0;
for(let i=0;i<frames.length;){
  const voices=frames[i].length;
  if(!voices){i++;continue;}
  if(voices!==1&&voices!==3)throw Error('Uncertain pitches at beat '+i/4+'.');
  let end=i+1;
  while(end<frames.length&&frames[end].length===voices)end++;
  if(voices===3){notes.push(...readChords(i,end));chordSpans++;}
  else notes.push(...readMono(i,end));
  i=end;
}
const recovered=await decodeSupportedMeaningWithDrafts(expandChordMidi(midi(notes),authority.atoms),authority.atoms,records,{allowDraft:true});
return {profile:observation.profile,onset_seconds:observation.onset_seconds,compact_chord_spans:chordSpans,
  notes:notes.length,meaning:recovered,performance:notes};
}
// Two measured room-noise thresholds handle weak bass without filling rests.
// Both must agree whenever both yield a complete performance.
const accepted=new Map();
for(const candidate of observed){
  try{
    const result=await readPerformance(candidate);
    accepted.set(JSON.stringify(result.performance),result);
  }catch{}
}
if(accepted.size!==1)throw Error('The recording does not give one complete, supported musical reading.');
const {performance,...result}=accepted.values().next().value;
const timeline=performance.map(n=>[n.start_tick,n.end_tick,n.midi]).sort((a,b)=>a[0]-b[0]||a[2]-b[2]||a[1]-b[1]);
result.note_sha256=createHash('sha256').update(JSON.stringify(timeline)).digest('hex');
console.log(JSON.stringify(result,null,2));
