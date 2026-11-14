import {resolveObjectDesireInput} from './object_desire.mjs';
import {composeDesiredOwnership} from './desired_ownership.mjs';
import {midiFromDesiredOwnership} from './desired_ownership_music.mjs';
import {decodeSupportedMeaningWithDrafts} from './semantic_music_dispatch.mjs';
import {encodeName} from './names.mjs';
// Ownership is explicitly selected, never inferred from wanting an object.
export async function composeObjectDesiredOwnership(input,authority,{allowDraft=false,desiredProposition,framework}={}){
 if(!allowDraft)throw new Error('Object desire requires draft opt-in.');
 const {plan,content,resolved}=resolveObjectDesireInput(input,desiredProposition);
 const meaning=await composeDesiredOwnership(resolved,{allowDraft:true,framework});
 const ref=meaning.content.object,expected=(await encodeName(plan.head)).normalized_label;
 const mode=ref.reference_mode||'name';
 if(ref.kind!=='phonemic_reference'||ref.name.normalized_label!==expected||(plan.reference_mode==='unspecified_nominal'?!ref.reference_mode:mode!==plan.reference_mode))throw new Error('The ownership object must preserve the original object reference.');
 await decodeSupportedMeaningWithDrafts(await midiFromDesiredOwnership(meaning,authority,{allowDraft:true}),authority.atoms,[],{allowDraft:true});
 return {meaning,source_input:input,resolved_input:resolved,object_desire_resolution:{object:plan.object,desired_proposition:content,relation_source:'explicit_user_clarification'}};
}
