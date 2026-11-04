// EZFOUND-1 is an additive candidate profile. Existing root addresses are unchanged.
// Draft records require an explicit opt-in and never become dictionary meanings here.
import {canonicalDigest} from './engine.mjs';
const OFFSETS={low:-12,middle:0,high:12,sustained_background:-5};
const KEYS=['profile','definition_version','family_affinity','sound_code','definition','roles','excludes'];
export function foundationPayload(record){return Object.fromEntries(KEYS.map(k=>[k,record[k]]));}
export function foundationPath(code){
 if(!Number.isInteger(code)||code<0||code>6560)throw new Error('Invalid foundation address.');
 return [0,-23,0,...code.toString(3).padStart(8,'0').split('').map(d=>[0,1,-1][Number(d)]),0];
}
export async function validateFoundations(records,{allowDraft=false}={}){
 if(!Array.isArray(records))throw new Error('Invalid foundation registry.');
 records=structuredClone(records);
 const ids=new Set(),codes=new Set();
 for(const r of records){
  if(!r||r.profile!=='EZFOUND-1'||r.definition_version!=='1.0.0'||r.family_affinity!=='MIN'||!['approved',...(allowDraft?['candidate']:[])].includes(r.status)||typeof r.definition!=='string'||r.definition.length<30||!Array.isArray(r.excludes)||!r.excludes.length||r.excludes.some(x=>typeof x!=='string'||!x.trim())||!r.roles||typeof r.roles!=='object'||Array.isArray(r.roles)||!Object.keys(r.roles).length)throw new Error('Invalid or unapproved foundation.');
  for(const [role,types] of Object.entries(r.roles))if(!['experiencer','target','comparison_standard','content'].includes(role)||!Array.isArray(types)||!types.length||new Set(types).size!==types.length||types.some(t=>!['entity','kind','proposition'].includes(t)))throw new Error('Invalid foundation argument types.');
  foundationPath(r.sound_code);
  const digest=await canonicalDigest(foundationPayload(r));
  if(r.content_digest!==digest||r.foundation_id!==`FND:${digest.slice(0,24)}`||ids.has(r.foundation_id)||codes.has(r.sound_code))throw new Error('Foundation identity collision or mismatch.');
  ids.add(r.foundation_id);codes.add(r.sound_code);
 }
 return records;
}
export async function foundationEvent(record,{occurrenceId='p',register='middle',anchor=60,runtimeState=1,allowDraft=false}={}){
 [record]=await validateFoundations([record],{allowDraft});
 if(!Object.hasOwn(OFFSETS,register)||!Number.isInteger(anchor)||![0,1,2].includes(runtimeState)||typeof occurrenceId!=='string'||!occurrenceId)throw new Error('Invalid foundation performance context.');
 const base=anchor+OFFSETS[register],relative=foundationPath(record.sound_code),last=base+relative.at(-1),opening=[0,3,7];
 const tail=runtimeState===0?{code:0,name:'inactive',relative_motion_semitones:-1,absolute_note:last-1,articulation:'sharp_stop',duration_beats:.25}:runtimeState===1?{code:1,name:'active',relative_motion_semitones:0,absolute_note:base,articulation:'firm_return',duration_beats:.5}:{code:2,name:'num',relative_motion_semitones:7,absolute_note:last+7,articulation:'sustain',duration_beats:2};
 if([...opening,...relative].some(n=>base+n<0||base+n>127)||tail.absolute_note<0||tail.absolute_note>127)throw new Error('Foundation pitch outside MIDI range.');
 return {kind:'foundation',occurrence_id:occurrenceId,target_id:record.foundation_id,register,base_midi:base,
  family_qualified_transliteration:`MIN·foundation-${record.sound_code}`,formal_carrier:`si-fen-${record.sound_code.toString(3).padStart(8,'0').split('').map(d=>['ma','ki','nu'][Number(d)]).join('-')}`,
  family_opening_relative_semitones:opening,family_opening_absolute_midi:opening.map(n=>base+n),address_relative_semitones:relative,address_absolute_midi:relative.map(n=>base+n),note_duration_beats:1,runtime_tail:tail};
}
