// Optional performance of complete, isolated dictionary roots. All other note
// runs pass through verbatim, including names, grammar and the speech-act contour.
import {notesFromMidi,midiFromNoteTimeline} from './performance_codec.mjs';

const laneOffsets=[0,5,12],tritMotion=[0,2,-2];
const cache=new WeakMap();
const durations=[.25,.5,2];
const tailPitch=(runtime,last,base)=>[last-1,base,last+7][runtime];
const chordTail=(runtime,top,base)=>[top-1,base+12,top+7][runtime];
const equal=(a,b)=>a.length===b.length&&a.every((value,i)=>b[i]===value);
const note=(midi,start_tick,end_tick)=>({midi,start_tick,end_tick});

function dictionary(atoms) {
  if (cache.has(atoms)) return cache.get(atoms);
  const paths=new Map(),families=new Map(),byId=new Map();
  for (const atom of atoms) {
    const [family,address]=atom.canonical_id.split(':');
    if (!/^[012]{3}$/.test(address)) continue;
    const opening=atom.harmonic_signature_semitones;
    const familyChord=[opening[0],opening[1],opening.at(-1)],familyKey=familyChord.join(',');
    if (families.has(familyKey)&&families.get(familyKey)!==family) throw Error('Two families share a chord.');
    families.set(familyKey,family);
    const path=[...opening,...atom.note_path_semitones],key=path.join(',');
    if (paths.has(key)||byId.has(atom.canonical_id)) throw Error('Two roots share a pitch path or address.');
    const entry={familyChord,addressChord:[...address].map((d,i)=>laneOffsets[i]+tritMotion[Number(d)]),path};
    paths.set(key,entry);byId.set(atom.canonical_id,entry);
  }
  if (!byId.size) throw Error('A root dictionary is required.');
  const result={paths,families,byId};cache.set(atoms,result);return result;
}
function clock(bytes,allowPolyphony) {
  const parsed=notesFromMidi(bytes,{allowPolyphony});
  if(parsed.division%4||!parsed.division||parsed.tempos.some(t=>t.tick!==0||t.value!==parsed.tempos[0].value)) throw Error('Compact performance requires a single fixed tempo and quarter-beat ticks.');
  return {...parsed,tempo:parsed.tempos[0]?.value??500000};
}
function identify(run,dict,division) {
  if(run.length<7||run.length>9)return null;
  const base=run[0].midi,last=run.at(-1),duration=(last.end_tick-last.start_tick)/division;
  const tail=durations.indexOf(duration);
  const pathNotes=tail<0?run:run.slice(0,-1);
  if(pathNotes.some(n=>n.end_tick-n.start_tick!==division))return null;
  const entry=dict.paths.get(pathNotes.map(n=>n.midi-base).join(','));
  if (!entry || (tail>=0&&last.midi!==tailPitch(tail,pathNotes.at(-1).midi,base)))return null;
  return {entry,base,tail};
}

export function compactChordMidi(bytes,atoms) {
  const {notes,division,tempo}=clock(bytes,false),dict=dictionary(atoms),out=[];
  let saved=0;
  for(let i=0;i<notes.length;) {
    let end=i+1;
    while(end<notes.length&&notes[end-1].end_tick===notes[end].start_tick)end++;
    const run=notes.slice(i,end),root=identify(run,dict,division),start=run[0].start_tick-saved;
    i=end;
    if (!root || root.base+21>127 || root.base-2<0) {
      for(const n of run)out.push(note(n.midi,n.start_tick-saved,n.end_tick-saved));
      continue;
    }
    const {entry,base,tail}=root,at=start+division,addressEnd=at+division;
    const release=addressEnd+(tail<0?0:durations[tail]*division);
    for (const pitch of entry.familyChord)out.push(note(base+pitch,start,at));
    const address=entry.addressChord.map(p=>p+base);
    address.forEach((pitch,lane)=>out.push(note(pitch,at,lane===2?addressEnd:release)));
    if(tail>=0)out.push(note(chordTail(tail,address[2],base),addressEnd,release));
    saved+=run.at(-1).end_tick-run[0].start_tick-(release-start);
  }
  return midiFromNoteTimeline(out,division,tempo);
}

// Expand from the played notes and the shared dictionary. No source score,
// expected word, input text, instrument IDs or metadata carries a word identity.
export function expandChordMidi(bytes,atoms) {
  const {notes,division,tempo}=clock(bytes,true),dict=dictionary(atoms),out=[],attacks=[];
  for(const n of notes){
    if(attacks.at(-1)?.[0].start_tick!==n.start_tick)attacks.push([]);
    attacks.at(-1).push(n);
  }
  let added=0,previousEnd=0;
  const fail=()=>{throw Error('Unrecognized or malformed compact chord.');};
  for(let i=0;i<attacks.length;i++) {
    const opening=attacks[i],start=opening[0].start_tick;
    if(start<previousEnd)fail();
    if(opening.length===1){const n=opening[0];out.push(note(n.midi,start+added,n.end_tick+added));previousEnd=n.end_tick;continue;}
    const base=opening[0].midi,family=dict.families.get(opening.map(n=>n.midi-base).join(','));
    if(!family||opening.length!==3||opening.some(n=>n.end_tick!==start+division))fail();
    const address=attacks[++i];
    if(address?.length!==3||address[0].start_tick!==start+division)fail();
    const digits=address.map((n,lane)=>tritMotion.indexOf(n.midi-base-laneOffsets[lane]));
    const entry=dict.byId.get(family+':'+digits.join(''));
    if(!entry||!equal(entry.addressChord,address.map(n=>n.midi-base)))fail();
    const addressEnd=start+2*division,release=address[0].end_tick;
    if(address[2].end_tick!==addressEnd||address[1].end_tick!==release||release<addressEnd)fail();
    let tick=start+added;
    for(const offset of entry.path){out.push(note(base+offset,tick,tick+division));tick+=division;}
    if(release>addressEnd){
      const tail=durations.indexOf((release-addressEnd)/division),ending=attacks[++i];
      if(tail<0||ending?.length!==1||ending[0].start_tick!==addressEnd||ending[0].end_tick!==release||ending[0].midi!==chordTail(tail,address[2].midi,base))fail();
      out.push(note(tailPitch(tail,base+entry.path.at(-1),base),tick,tick+release-addressEnd));tick+=release-addressEnd;
    }
    added+=tick-(release+added);previousEnd=release;
  }
  return midiFromNoteTimeline(out,division,tempo);
}
