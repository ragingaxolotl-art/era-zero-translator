// Draft literal-drinking convention. No canonical admission or music code yet.
import {canonicalDigest} from './engine.mjs';
import {createContextualContent} from './contextual_content.mjs';
import {validateMaterialReference} from './material_reference.mjs';
export const DRINKING_CONTRACT=Object.freeze({predicate:'literal_drinking',action_category:'oral_intake_of_liquid_as_drink',participant_binding:'drinker_performs_intake_of_material',material_classification_scope:'within_drinking_content_not_global_label_fact',thirst_commitment:'not_entailed',ownership_commitment:'not_entailed',pleasure_commitment:'not_entailed',benefit_commitment:'not_entailed',intention_commitment:'not_entailed',whole_amount_consumption:'not_asserted'});
export const DRINKING_VIEWPOINTS=Object.freeze({ongoing:'Drinking activity is in progress; no completed intake amount or completed event is asserted.',bounded:'A bounded drinking event is presented as a whole; some intake belongs to that event, but no entire contextual portion or numeric amount is asserted.',habitual:'Drinking is a recurring or characteristic activity; no particular occurrence at speech time is asserted.'});
const allowedScopes=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
export async function validateDrinkingMeaning(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Drinking requires draft opt-in.');
 const d=structuredClone(document),keys=['profile','status',...Object.keys(DRINKING_CONTRACT),'drinker','material','viewpoint','viewpoint_contract','speech_act','scopes','runtime_state','content_id','content_digest'];
 if(!d||typeof d!=='object'||Array.isArray(d)||Object.keys(d).length!==keys.length||keys.some(k=>!Object.hasOwn(d,k))||d.profile!=='EZDRINKING-MEANING-1'||d.status!=='draft'||Object.entries(DRINKING_CONTRACT).some(([k,v])=>d[k]!==v)||!Object.hasOwn(DRINKING_VIEWPOINTS,d.viewpoint)||d.viewpoint_contract!==DRINKING_VIEWPOINTS[d.viewpoint]||!['assertion','question'].includes(d.speech_act)||![0,1,2].includes(d.runtime_state)||!allowedScopes.some(s=>JSON.stringify(s)===JSON.stringify(d.scopes)))throw new Error('Invalid drinking meaning contract.');
 await createContextualContent('topic',d.drinker,{allowDraft:true});await validateMaterialReference(d.material,{allowDraft:true});
 const {content_id,content_digest,...body}=d,hash=await canonicalDigest(body);
 if(content_digest!==hash||content_id!==`EZDRINK:${hash.slice(0,24)}`)throw new Error('Drinking identity mismatch.');return d;
}
export async function createDrinkingMeaning(drinker,material,{allowDraft=false,viewpoint,speechAct='assertion',scopes=[],runtimeState=1}={}){
 if(!allowDraft)throw new Error('Drinking requires draft opt-in.');
 if(!Object.hasOwn(DRINKING_VIEWPOINTS,viewpoint))throw new Error('Choose an ongoing, bounded or habitual drinking viewpoint.');
 const body={profile:'EZDRINKING-MEANING-1',status:'draft',...DRINKING_CONTRACT,drinker:structuredClone(drinker),material:structuredClone(material),viewpoint,viewpoint_contract:DRINKING_VIEWPOINTS[viewpoint],speech_act:speechAct,scopes:structuredClone(scopes),runtime_state:runtimeState},hash=await canonicalDigest(body);
 return validateDrinkingMeaning({...body,content_digest:hash,content_id:`EZDRINK:${hash.slice(0,24)}`},{allowDraft:true});
}
