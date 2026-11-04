import {validateFoundations,foundationPath} from './foundations.mjs';
import {decodeStrictMusicMidi} from './strict_music_decoder.mjs';

// Shared registry supplies identity, never expected source IR or participant roles.
// This observes sound tokens; lexical identity alone does not validate a sentence.
export async function decodeFoundationMusicMidi(bytes,atoms,foundations,{allowDraft=false}={}){
 foundations=await validateFoundations(foundations,{allowDraft});
 const identities=new Map(foundations.map(r=>[r.foundation_id,r]));
 if(atoms.some(a=>identities.has(a.canonical_id)))throw new Error('Foundation conflicts with root identity.');
 const dictionary=[...atoms,...foundations.map(r=>({canonical_id:r.foundation_id,harmonic_signature_semitones:[0,3,7],note_path_semitones:foundationPath(r.sound_code)}))];
 const observed=decodeStrictMusicMidi(bytes,dictionary);
 return {...observed,profile:'EZFOUND-OBSERVATION-1',tokens:observed.tokens.map(t=>{
  if(t.kind!=='root'||!identities.has(t.root_id))return t;
  const {root_id,...rest}=t,r=identities.get(root_id);
  return {...rest,kind:'foundation',foundation_id:root_id,definition_version:r.definition_version,registry_status:r.status};
 }),semantic_status:'audible_structure_only',limitations:[...observed.limitations,'Foundation identity does not validate argument types, intensional scope or full-sentence meaning.','Draft vocabulary requires explicit opt-in and is not canonical translator coverage.']};
}
