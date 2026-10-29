import {notesFromMidi} from './performance_codec.mjs';

// Independent inverse of the strict EZPROPERTYCOMPARE-1 material-property profile.
// Accepts MIDI bytes only: no source sentence, formal plan, or semantic IR.
const MODES=['possible','necessary','permitted','obligated','intended','predicted','counterfactual'];
const RELATIONS=['equal','greater_than','less_than','at_least','at_most','not_equal'];
const PHONEMES=['AA','AE','AH','AO','AW','AY','B','CH','D','DH','EH','ER','EY','F','G','HH','IH','IY','JH','K','L','M','N','NG','OW','OY','P','R','S','SH','T','TH','UH','UW','V','W','Y','Z','ZH','WB'];
const ROLES=['actor','source','cause','experiencer','bearer','predicate','target','result','destination','instrument','material','content','recipient','location','environment','condition','persistent_condition','time','manner','quantity','comparison_standard','beneficiary'];
const fail=()=>{throw new Error('Unsupported or malformed strict property-comparison music.');};
const same=(a,b)=>a.length===b.length&&a.every((v,i)=>v===b[i]);
export function decodePropertyComparisonMidi(bytes){
 const {notes,division}=notesFromMidi(bytes);
 if(!division||!notes.length||notes.length>100000||notes[0].start_tick!==0)fail();
 const segments=[];
 for(const note of notes){
  const previous=segments.at(-1)?.at(-1);
  if(!previous||note.start_tick>previous.end_tick){
   if(previous&&note.start_tick-previous.end_tick!==division/2)fail();
   segments.push([]);
  }else if(note.start_tick!==previous.end_tick)fail();
  segments.at(-1).push(note);
 }
 let cursor=0;
 const take=()=>segments[cursor++]||fail();
 const relative=(segment,anchor)=>segment.map(n=>n.midi-anchor);
 const duration=(segment,beats)=>segment.every(n=>n.end_tick-n.start_tick===division*beats);
 let first=take();const anchor=first[0].midi,scopes=[],closings=[];
 while(true){
  const pitches=relative(first,anchor),distance=-pitches[1];
  if(!duration(first,.25)||pitches.length!==4||!same(pitches,[0,-distance,-distance,0])||!Number.isInteger(distance)||distance<1||distance>8)break;
  if(scopes.length>=128)fail();
  scopes.push(distance===1?{operator:'negation'}:{operator:'modality',mode:MODES[distance-2]});
  closings.push([0,distance,distance,0]);first=take();
  if(same(relative(first,anchor),[0,9,0,9])){
   if(!duration(first,.25)||distance===1||!['possible','necessary','predicted'].includes(scopes.at(-1).mode))fail();
   let strength='';
   while(true){
    const token=take(),code=relative(token,anchor);
    if(!duration(token,.25))fail();
    if(same(code,[0,-9,0,-9]))break;
    if(same(code,[0,10,-1,0]))strength+='.';
    else{
     if(code.length!==5||code[0]!==0||code[1]!==10||code[4]!==0||!Number.isInteger(code[2])||code[2]<0||code[2]>2||!Number.isInteger(code[3])||code[3]<0||code[3]>3||code[2]*4+code[3]>9)fail();
     strength+=String(code[2]*4+code[3]);
    }
    if(strength.length>1024)fail();
   }
   if(!/^(?:0|1|0\.[0-9]*[1-9])$/.test(strength))fail();
   scopes.at(-1).strength=strength;first=take();
  }
 }
 const opening=relative(first,anchor);
 if(!duration(first,.25)||opening.length!==5||!same([opening[0],opening[1],opening[4]],[0,-18,0])||![1,2].includes(opening[2])||!RELATIONS[opening[3]])fail();
 const dimension=opening[2]===1?'mass':'thermodynamic_temperature';
 const relation=RELATIONS[opening[3]];
 const roleFrame=(segment,side)=>{
  const pitches=relative(segment,anchor);
  if(!duration(segment,.25)||pitches.length!==6||pitches[0]!==0||pitches[1]!== (side==='open'?-15:15)||pitches[5]!==0)fail();
  let code=0;for(const pitch of pitches.slice(2,5)){const trit=[0,1,-1].indexOf(pitch);if(trit<0)fail();code=code*3+trit;}
  return ROLES[code]||fail();
 };
 const decodeReference=()=>{
  let segment=take(),path=relative(segment,anchor),mode='name';
  if(duration(segment,.25)){
   if(same(path,[0,12,-1,0]))return {kind:'deictic',role:'speaker'};
   if(same(path,[0,12,1,0]))return {kind:'deictic',role:'addressee'};
   if(!same(path,[0,12,2,0]))fail();
   mode='definite_nominal';segment=take();path=relative(segment,anchor);
  }
  if(!duration(segment,1)||!same(path.slice(0,3),[-12,0,-5])||!same(path.slice(-3),[-5,0,-12]))fail();
  const payload=path.slice(3,-3),phonemes=[];if(!payload.length||payload.length%2)fail();
  for(let i=0;i<payload.length;i+=2){
   const row=(payload[i]+8)/3,column=payload[i+1]-8,code=row*8+column;
   if(!Number.isInteger(row)||row<0||row>4||!Number.isInteger(column)||column<0||column>7||!PHONEMES[code])fail();
   phonemes.push(PHONEMES[code]);
  }
  return {kind:'phonemic',reference_mode:mode,phonemes};
 };
 const participants={};
 for(let i=0;i<2;i++){
  const role=roleFrame(take(),'open');
  if(!['bearer','comparison_standard'].includes(role)||participants[role])fail();
  participants[role]=decodeReference();if(roleFrame(take(),'close')!==role)fail();
 }
 const lexical=take(),path=relative(lexical,anchor);
 if(lexical.length!==8||!duration(lexical.slice(0,-1),1)||!same(path.slice(0,3),[0,7,12]))fail();
 const address=path.slice(3,7),root=same(address,[0,0,0,0])?'MAT:000':same(address,[0,0,2,2])?'MAT:010':fail();
 const last=lexical.at(-1),ending=path.at(-1),lastAddress=address.at(-1),beats=(last.end_tick-last.start_tick)/division;
 const runtime=ending===lastAddress-1&&beats===.25?0:ending===0&&beats===.5?1:ending===lastAddress+7&&beats===2?2:fail();
 const close=take();if(!duration(close,.25)||!same(relative(close,anchor),[0,18,opening[2],opening[3],0]))fail();
 for(const expected of closings.reverse()){const segment=take();if(!duration(segment,.25)||!same(relative(segment,anchor),expected))fail();}
 const contour=take(),contours={assertion:[0,0],question:[0,2],command:[0,-4],definition:[0,2,0],possibility:[0,-2,2]};
 const speechAct=Object.entries(contours).find(([,p])=>same(relative(contour,anchor),p))?.[0];
 if(!speechAct||!duration(contour,.5)||cursor!==segments.length)fail();
 return {profile:'EZPROPERTYCOMPARE-1',dimension,relation,scopes,participants,material_root:root,runtime_state:runtime,speech_act:speechAct,
   reference_resolution:'Phonemes recover audible labels, not original spelling or external referent identity.'};
}
