import {scheduledLexicalEvents} from './scheduler.mjs';
import{visemePlanFromFormal}from'./visemes.mjs';

// EZREC-PERF-1 is an optional performance channel. It never changes the formal IR.
export const PERFORMANCE_FORMAT='EZREC-PERF-1';
const PPQ=480,TICKS_PER_SECOND=960;
const u16=n=>[(n>>>8)&255,n&255];
const u32=n=>[(n>>>24)&255,(n>>>16)&255,(n>>>8)&255,n&255];
function vlq(n){if(!Number.isSafeInteger(n)||n<0)throw new Error('Invalid MIDI delta.');const out=[n&127];while((n>>=7)>0)out.unshift((n&127)|128);return out}

export function midiFromPerformance(formal,registry,mode='recognition'){
  const plan=visemePlanFromFormal(formal,{mode,recognitionRegistry:registry});
  const events=[];
  for(const cue of plan.cues){
    const start=Math.round(cue.start*TICKS_PER_SECOND),end=Math.max(start+1,Math.round((cue.start+cue.duration)*TICKS_PER_SECOND));
    events.push([start,1,[0x90,cue.note,88]],[end,0,[0x80,cue.note,0]]);
  }
  events.sort((a,b)=>a[0]-b[0]||a[1]-b[1]||a[2][1]-b[2][1]);
  const track=[0,0xff,0x51,3,0x07,0xa1,0x20,0,0xc0,0];
  let previous=0;
  for(const[at,,bytes]of events){track.push(...vlq(at-previous),...bytes);previous=at}
  track.push(0,0xff,0x2f,0);
  return new Uint8Array([...'MThd'].map(c=>c.charCodeAt(0)).concat(u32(6),u16(0),u16(1),u16(PPQ),[...'MTrk'].map(c=>c.charCodeAt(0)),u32(track.length),track));
}

export function notesFromMidi(input){
  const data=input instanceof Uint8Array?input:new Uint8Array(input);
  let at=0;
  const take=n=>{if(n<0||at+n>data.length)throw new Error('Truncated MIDI file.');const bytes=data.slice(at,at+n);at+=n;return bytes};
  const number=n=>{let value=0;for(const byte of take(n))value=value*256+byte;return value};
  const tag=n=>String.fromCharCode(...take(n));
  const variable=()=>{let value=0;for(let i=0;i<4;i++){const byte=number(1);value=(value<<7)|(byte&127);if(!(byte&128))return value}throw new Error('Invalid MIDI variable-length value.')};
  if(tag(4)!=='MThd')throw new Error('Not a Standard MIDI file.');
  const headerLength=number(4),format=number(2),trackCount=number(2),division=number(2);
  if(headerLength<6||trackCount<1||trackCount>32||format>1||division&0x8000)throw new Error('Unsupported MIDI header.');
  take(headerLength-6);
  const notes=[],tempos=[];
  for(let trackIndex=0;trackIndex<trackCount;trackIndex++){
    if(tag(4)!=='MTrk')throw new Error('Missing MIDI track.');
    const length=number(4),end=at+length;if(end>data.length)throw new Error('Truncated MIDI track.');
    let tick=0,status=0;
    const active=new Map();
    while(at<end){
      tick+=variable();let lead=number(1);
      if(lead&0x80){status=lead}else{if(!status)throw new Error('Missing MIDI running status.');at--;lead=status}
      if(lead===0xff){const kind=number(1),length=variable(),payload=take(length);if(kind===0x51&&length===3)tempos.push({tick,value:(payload[0]<<16)|(payload[1]<<8)|payload[2]});continue}
      if(lead===0xf0||lead===0xf7){take(variable());status=0;continue}
      const command=lead&0xf0,channel=lead&0x0f;
      if(command<0x80||command>0xe0)throw new Error('Unsupported MIDI event.');
      const pitch=number(1),velocity=(command===0xc0||command===0xd0)?0:number(1);
      if(command!==0x90&&command!==0x80)continue;
      const key=`${channel}:${pitch}`;
      if(command===0x90&&velocity){if(active.has(key))throw new Error('Overlapping duplicate MIDI note.');active.set(key,tick)}
      else{const start=active.get(key);if(start===undefined)throw new Error('MIDI note-off without note-on.');notes.push({midi:pitch,start_tick:start,end_tick:tick,track:trackIndex});active.delete(key)}
    }
    if(at!==end||active.size)throw new Error('Incomplete MIDI track.');
  }
  if(at!==data.length)throw new Error('Trailing MIDI bytes.');
  notes.sort((a,b)=>a.start_tick-b.start_tick||a.track-b.track||a.midi-b.midi);
  if(notes.some((note,index)=>index&&note.start_tick<notes[index-1].end_tick))throw new Error('Polyphonic MIDI cannot be checked as a single Era Zero voice.');
  return{format:'SMF',division,tempos,notes};
}

function expectedPatterns(formal,registry){
  const strict=visemePlanFromFormal(formal,{mode:'strict',recognitionRegistry:registry});
  const full=visemePlanFromFormal(formal,{mode:'recognition',recognitionRegistry:registry});
  const events=scheduledLexicalEvents(formal);
  const group=cues=>{const result=new Map();for(const cue of cues){if(!result.has(cue.event_index))result.set(cue.event_index,[]);result.get(cue.event_index).push(cue)}return result};
  const strictByEvent=group(strict.cues),fullByEvent=group(full.cues);
  const paths=events.map((event,index)=>{
    const s=(strictByEvent.get(index)||[]).map(cue=>cue.note);
    const r=(fullByEvent.get(index)||[]).filter(cue=>cue.section==='recognition_phrase').map(cue=>cue.note);
    const prefix=(fullByEvent.get(index)||[]).filter(cue=>cue.section!=='runtime_ending'&&cue.section!=='recognition_phrase').map(cue=>cue.note);
    const runtime=(fullByEvent.get(index)||[]).filter(cue=>cue.section==='runtime_ending').map(cue=>cue.note);
    if(s.join(',')!==[...prefix,...runtime].join(','))throw new Error('Strict and recognition note paths disagree.');
    return{target_id:event.target_id,prefix,recognition:r,runtime};
  });
  return{paths,contour:strict.cues.filter(cue=>cue.section==='sentence_contour').map(cue=>cue.note)};
}

export function verifyPerformanceNotes(formal,registry,observed){
  const values=observed.map(note=>typeof note==='number'?note:note.midi);
  if(values.some(note=>!Number.isInteger(note)||note<0||note>127))throw new Error('Invalid MIDI pitch in observed performance.');
  const {paths,contour}=expectedPatterns(formal,registry);
  // Keep one best path per observed offset rather than enumerate every
  // checksum-presence combination. Try exact matching first, so long valid
  // performances need only the offsets consistent with their actual notes.
  function search(exactOnly){
    let states=new Map([[0,{cost:0,parent:null,mode:null,segment:[]}]]),work=0;
    for(const path of paths){
      const options=[{mode:'absent',notes:[...path.prefix,...path.runtime]}];
      if(path.recognition.length)options.push({mode:'present',notes:[...path.prefix,...path.recognition,...path.runtime]});
      const next=new Map();
      for(const [offset,state] of states){
        for(const option of options){
          if(++work>1000000)throw new Error('Performance verification exceeds its search work limit.');
          let cost=state.cost;
          for(let i=0;i<option.notes.length;i++)if(values[offset+i]!==option.notes[i])cost++;
          if(exactOnly&&cost)continue;
          const end=offset+option.notes.length,previous=next.get(end);
          if(!previous||cost<previous.cost)next.set(end,{cost,parent:state,mode:option.mode,segment:option.notes});
        }
      }
      states=next;
      if(!states.size)return null;
    }
    let winner=null;
    for(const [offset,state] of states){
      let difference=state.cost+Math.max(0,values.length-offset-contour.length);
      for(let i=0;i<contour.length;i++)if(values[offset+i]!==contour[i])difference++;
      if(exactOnly&&difference)continue;
      if(!winner||difference<winner.difference)winner={state,difference};
    }
    if(!winner)return null;
    const segments=[],checksumModes=[];
    for(let state=winner.state;state.parent;state=state.parent){segments.push(state.segment);checksumModes.push(state.mode)}
    return{expected:segments.reverse().flat().concat(contour),checksumModes:checksumModes.reverse(),difference:winner.difference};
  }
  const best=search(true)||search(false);
  const valid=best.difference===0;
  const mismatch=best.expected.findIndex((note,index)=>values[index]!==note);
  return{format:PERFORMANCE_FORMAT,status:valid?(best.checksumModes.every(mode=>mode==='absent')?'valid_strict_absence':'valid_checksum'):'checksum_or_path_mismatch',semantic_content:false,semantic_identity_changed:false,formal_id:formal.formal_id,targets:paths.map((path,index)=>({target_id:path.target_id,checksum:best.checksumModes[index]})),observed_note_count:values.length,expected_note_count:best.expected.length,first_mismatch:valid?null:mismatch<0?best.expected.length:mismatch};
}

export function verifyPerformanceMidi(formal,registry,bytes){return verifyPerformanceNotes(formal,registry,notesFromMidi(bytes).notes)}
