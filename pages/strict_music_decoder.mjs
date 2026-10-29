import {notesFromMidi} from './performance_codec.mjs';
import {PHONEMES} from './names.mjs';
import {ROLE_ORDER} from './roles.mjs';
// This inverse receives MIDI and a shared atom dictionary, never source IR,
// formal events, a sentence template or an expected utterance digest.
const MODES=['possible','necessary','permitted','obligated','intended','predicted','counterfactual'];
const QUANTIFIERS=['exact','at_least','at_most','all','some','none'];
const COMPARISONS=['equal','greater_than','less_than','at_least','at_most','not_equal'];
const UNITS=['1','second','minute','hour','day','meter','kilometer','gram','kilogram','degree','radian','bit','byte'];
const CONDITIONS=['open','satisfied','unsatisfied','counterfactual'];
const OFFSETS=new Map([[-12,'low'],[0,'middle'],[12,'high'],[-5,'sustained_background']]);
const equal=(a,b)=>a.length===b.length&&a.every((n,i)=>n===b[i]);
const fail=message=>{throw new Error(`Strict music inverse: ${message}`)};
const frames=[];
const frame=(marker,path)=>frames.push({marker,path});
for(const side of ['open','close']){
 const sign=side==='open'?-1:1;
 frame(`negation_${side}`,[0,sign,sign,0]);
 MODES.forEach((mode,i)=>frame(`modality_${mode}_${side}`,[0,sign*(i+2),sign*(i+2),0]));
 ['all_of','any_of','exactly_one'].forEach((mode,i)=>frame(`coord_${mode}_${side}`,[0,sign*11,sign*(i+1),0]));
 for(const [name,code] of [['before_speech',-1],['at_speech',0],['after_speech',1],['previous_day',-2],['current_day',2],['next_day',3]])frame(`time_${name}_${side}`,[0,sign*12,code,sign*12,0]);
 frame(`measurement_${side}`,[0,sign*13,sign,0]);
 QUANTIFIERS.forEach((name,i)=>frame(`quantifier_${name}_${side}`,[0,sign*14,i+1,0]));
 ROLE_ORDER.forEach((role,i)=>frame(`role_${role}_${side}`,[0,sign*15,...i.toString(3).padStart(3,'0').split('').map(d=>[0,1,-1][Number(d)]),0]));
 CONDITIONS.forEach((name,i)=>frame(`conditional_${name}_${side}`,[0,sign*16,i,0]));
 COMPARISONS.slice(1).forEach((name,i)=>frame(`measure_compare_${name}_${side}`,[0,sign*17,i+1,0]));
 COMPARISONS.forEach((name,i)=>frame(`property_mass_${name}_${side}`,[0,sign*18,1,i,0]));
}
ROLE_ORDER.forEach((role,i)=>frame(`role_reference_${role}`,[0,-20,...i.toString(3).padStart(3,'0').split('').map(d=>[0,1,-1][Number(d)]),0]));
frame('confidence_open',[0,9,0,9]);frame('confidence_close',[0,-9,0,-9]);
frame('decimal_point',[0,10,-1,0]);frame('coord_member',[0,11,0,11]);frame('conditional_then',[0,16,0,16]);frame('measurement_negative',[0,-13,0,-13]);
for(let digit=0;digit<10;digit++)frame(`digit_${digit}`,[0,10,Math.floor(digit/4),digit%4,0]);
UNITS.forEach((_,i)=>frame(`measurement_unit_${i+1}`,[0,13,i+1,13,0]));

export function decodeStrictMusicMidi(bytes,atoms,{maxNotes=100000,maxTokens=100000}={}){
 if(!Number.isInteger(maxNotes)||maxNotes<1||!Number.isInteger(maxTokens)||maxTokens<1)fail('invalid limits');
 const {notes,division}=notesFromMidi(bytes);
 if(!division||notes.length<3||notes.length>maxNotes||notes[0].start_tick!==0)fail('invalid note count or start');
 // The final contour is separated from the payload and has half-beat notes.
 let end=notes.length-1;
 while(end>0&&notes[end].start_tick===notes[end-1].end_tick)end--;
 const contour=notes.slice(end),anchor=contour[0].midi;
 const contourPath=contour.map(n=>n.midi-anchor);
 const speechAct=Object.entries({assertion:[0,0],question:[0,2],command:[0,-4],definition:[0,2,0],possibility:[0,-2,2]}).find(([,path])=>equal(contourPath,path))?.[0];
 if(!speechAct||contour.some(n=>n.end_tick-n.start_tick!==division/2)||end===0||contour[0].start_tick-notes[end-1].end_tick!==division/2)fail('missing or malformed final contour');
 if(!Array.isArray(atoms)||atoms.length===0)fail('missing atom dictionary');
 const rootsByPath=new Map(),lengths=new Set();
 for(const atom of atoms){
  const path=[...atom.harmonic_signature_semitones,...atom.note_path_semitones],key=path.join(',');
  if(!rootsByPath.has(key))rootsByPath.set(key,[]);
  rootsByPath.get(key).push(atom);lengths.add(path.length);
 }
 const match=(i,path,base,beats)=>i+path.length<=end&&path.every((pitch,j)=>{const n=notes[i+j];return n.midi===base+pitch&&n.end_tick-n.start_tick===division*beats&&(!j||n.start_tick===notes[i+j-1].end_tick)});
 const make=(i,length,value)=>({next:i+length,token:{...value,start_tick:notes[i].start_tick,end_tick:notes[i+length-1].end_tick}});
 function candidates(i){
  const out=[],base=notes[i].midi;
  for(const f of frames)if(match(i,f.path,anchor,.25))out.push(make(i,f.path.length,{kind:'grammar',marker:f.marker}));
  if(match(i,[0],anchor,.25)&&Math.abs(notes[i+1]?.midi-anchor)===19&&i+11<=end){
   const path=notes.slice(i,i+11).map(n=>n.midi-anchor),digits=path.slice(2,10).map(n=>[0,1,-1].indexOf(n));
   if(path[10]===0&&digits.every(n=>n>=0)&&match(i,path,anchor,.25)){
    const code=digits.reduce((a,d)=>a*3+d,0),side=path[1]<0?'open':'close';
    out.push(make(i,11,{kind:'grammar',marker:`convention_${code}_${side}`,sound_code:code}));
   }
  }
  if(OFFSETS.has(base-anchor)){
   for(const [code,role] of [[-1,'speaker'],[1,'addressee'],[2,'definite_nominal'],[3,'nominal_class']])if(match(i,[0,12,code,0],base,.25))out.push(make(i,4,{kind:Math.abs(code)===1?'deictic':'reference_mode',...(Math.abs(code)===1?{deictic_role:role}:{reference_mode:role}),register:OFFSETS.get(base-anchor)}));
   for(const length of lengths){
    const path=notes.slice(i,i+length).map(n=>n.midi-base),roots=rootsByPath.get(path.join(','));
    if(!roots||!match(i,path,base,1))continue;
    for(const root of roots){
     const value={kind:'root',root_id:root.canonical_id,register:OFFSETS.get(base-anchor),runtime_state:null};
     out.push(make(i,length,value));
     const tail=notes[i+length],last=path.at(-1);
     if(tail&&i+length<end&&tail.start_tick===notes[i+length-1].end_tick){
      const pitch=tail.midi-base,beats=(tail.end_tick-tail.start_tick)/division;
      const state=pitch===last-1&&beats===.25?0:pitch===0&&beats===.5?1:pitch===last+7&&beats===2?2:null;
      if(state!==null)out.push(make(i,length+1,{...value,runtime_state:state}));
     }
    }
   }
  }
  const nameBase=base+12,register=OFFSETS.get(nameBase-anchor);
  if(register&&match(i,[-12,0,-5],nameBase,1)){
   let j=i+3;const phonemes=[];let instance=[];
   while(j<end){
    if(phonemes.length&&notes[j].start_tick===notes[j-1].end_tick&&match(j,[-5,0,-12],nameBase,1)){out.push(make(i,j+3-i,{kind:'phonemic',register,phonemes:[...phonemes],instance_code:instance.length?instance.join(''):null}));break;}
    if(phonemes.length&&notes[j].start_tick===notes[j-1].end_tick&&match(j,[12,5,12],nameBase,1)){
     const values=notes.slice(j+3,j+11).map(n=>n.midi-nameBase-16);
     if(notes[j+3]?.start_tick!==notes[j+2].end_tick||values.length!==8||values.some(n=>!Number.isInteger(n)||n<0||n>15)||!match(j+3,values.map(n=>n+16),nameBase,1))break;
     instance=values.map(n=>n.toString(16));j+=11;
     if(notes[j]?.start_tick===notes[j-1].end_tick&&match(j,[-5,0,-12],nameBase,1))out.push(make(i,j+3-i,{kind:'phonemic',register,phonemes:[...phonemes],instance_code:instance.join('')}));
     break;
    }
    const row=(notes[j].midi-nameBase+8)/3,column=notes[j+1]?.midi-nameBase-8,code=row*8+column;
    if(!Number.isInteger(row)||row<0||row>4||!Number.isInteger(column)||column<0||column>7||!PHONEMES[code]||!match(j,[row*3-8,column+8],nameBase,1))break;
    if(notes[j].start_tick!==notes[j-1].end_tick)break;
    phonemes.push(PHONEMES[code]);j+=2;
   }
  }
  return out.filter(({next})=>next===end||[0,division/2,division].includes(notes[next].start_tick-notes[next-1].end_tick));
 }
 // A persistent suffix chain avoids quadratic copies. Retain two alternatives;
 // ambiguous tokenization is an explicit failure, never a guessed reading.
 const suffix=new Map([[end,[null]]]);
 for(let i=end-1;i>=0;i--){
  const options=[];
  for(const candidate of candidates(i))for(const tail of suffix.get(candidate.next)||[]){options.push({token:candidate.token,tail});if(options.length===2)break;}
  if(options.length)suffix.set(i,options.slice(0,2));
 }
 const choices=suffix.get(0)||[];if(choices.length!==1)fail(choices.length?'ambiguous tokenization':'unrecognized or malformed payload');
 const tokens=[];for(let item=choices[0];item;item=item.tail){tokens.push(item.token);if(tokens.length>maxTokens)fail('token limit exceeded');}
 const stack=[];
 for(let i=0;i<tokens.length;i++){
  const token=tokens[i];token.boundary_after_beats=((tokens[i+1]?.start_tick??contour[0].start_tick)-token.end_tick)/division;
  if(token.kind==='grammar'){
   const scope=token.marker.match(/^(.*)_(open|close)$/);
   if(scope){
    if(scope[2]==='open'){stack.push({key:scope[1],index:i});if(stack.length>128)fail('scope depth exceeded');}
    else{const opening=stack.pop();if(opening?.key!==scope[1])fail('mismatched scope frame');token.opening_token=opening.index;tokens[opening.index].closing_token=i;}
   }
  }
  token.enclosing_scopes=stack.map(s=>s.index);
 }
 if(stack.length)fail('unclosed scope frame');
 return {profile:'EZSTRICT-OBSERVATION-1',anchor_midi:anchor,speech_act:speechAct,tokens,
  semantic_status:'audible_structure_only',limitations:['No complete semantic IR reconstruction or original node IDs.','Phonemes and instance code do not uniquely recover spelling or external identity.','Compound identity and predicate attachment require dictionary interpretation; timing alone is not a semantic proof.','Balanced grammar frames do not prove that every grammatical combination is valid.']};
}
