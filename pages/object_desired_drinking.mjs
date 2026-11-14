import {resolveObjectDesireInput} from './object_desire.mjs';
import {composeDesiredDrinking} from './desired_drinking.mjs';
import {midiFromDesiredDrinking} from './desired_drinking_music.mjs';
import {decodeSupportedMeaningWithDrafts} from './semantic_music_dispatch.mjs';
import {encodeName} from './names.mjs';
// Explicitly selected drinking outcome; never the default meaning of wants tea.
export async function composeObjectDesiredDrinking(input,authority,{allowDraft=false,desiredProposition,interpretation,viewpoint,materialReading}={}){
 if(!allowDraft)throw new Error('Object desire requires draft opt-in.');
 const {plan,content,resolved}=resolveObjectDesireInput(input,desiredProposition);
 const meaning=await composeDesiredDrinking(resolved,{allowDraft:true,interpretation,viewpoint,materialReading});
 const ref=meaning.content.material.reference,expected=(await encodeName(plan.head)).normalized_label;
 if(ref.name.normalized_label!==expected||(plan.reference_mode!=='unspecified_nominal'&&ref.reference_mode!==plan.reference_mode))throw new Error('The drinking material must preserve the original object reference.');
 // Check the full shared inverse before offering this as a ready clarification.
 await decodeSupportedMeaningWithDrafts(await midiFromDesiredDrinking(meaning,authority,{allowDraft:true}),authority.atoms,[],{allowDraft:true});
 return {meaning,source_input:input,resolved_input:resolved,object_desire_resolution:{object:plan.object,desired_proposition:content,relation_source:'explicit_user_clarification'}};
}
