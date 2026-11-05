// Draft ownership status under an explicit normative framework. Not custody.
import {canonicalDigest} from './engine.mjs';
import {createContextualContent} from './contextual_content.mjs';
export const OWNERSHIP_CONTRACT=Object.freeze({
 predicate:'framework_relative_ownership',
 relation:'owner_has_ownership_status_for_object_under_framework',
 framework_scope:'inside_proposition',
 framework_rules:'not_encoded_by_reference_label',
 physical_custody:'not_entailed',
 physical_control:'not_entailed',
 acquisition_or_transfer:'not_entailed',
 unlimited_use_or_disposal:'not_entailed',
 exclusive_ownership:'not_entailed',
 fractional_share:'unspecified',
 universal_agreement:'not_entailed',
 other_framework_status:'not_asserted'
});
const scopes=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
export async function validateOwnershipMeaning(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Ownership requires draft opt-in.');
 const d=structuredClone(document),keys=['profile','status',...Object.keys(OWNERSHIP_CONTRACT),'owner','object','framework','speech_act','scopes','runtime_state','content_id','content_digest'];
 if(!d||typeof d!=='object'||Array.isArray(d)||Object.keys(d).length!==keys.length||keys.some(k=>!Object.hasOwn(d,k))||d.profile!=='EZOWNERSHIP-MEANING-1'||d.status!=='draft'||Object.entries(OWNERSHIP_CONTRACT).some(([k,v])=>d[k]!==v)||!['assertion','question'].includes(d.speech_act)||![0,1,2].includes(d.runtime_state)||!scopes.some(s=>JSON.stringify(s)===JSON.stringify(d.scopes)))throw new Error('Invalid ownership meaning contract.');
 for(const role of ['owner','object','framework'])await createContextualContent('topic',d[role],{allowDraft:true});
 // Framework reference is explicit, not an unspoken default or a speaker role.
 if(d.framework.kind!=='phonemic_reference')throw new Error('Identify the ownership framework explicitly.');
 const {content_id,content_digest,...body}=d,hash=await canonicalDigest(body);
 if(content_digest!==hash||content_id!==`EZOWN:${hash.slice(0,24)}`)throw new Error('Ownership identity mismatch.');
 return d;
}
export async function createOwnershipMeaning(owner,object,framework,{allowDraft=false,speechAct='assertion',scopes=[],runtimeState=1}={}){
 if(!allowDraft)throw new Error('Ownership requires draft opt-in.');
 if(!framework)throw new Error('Identify the ownership framework explicitly.');
 const body={profile:'EZOWNERSHIP-MEANING-1',status:'draft',...OWNERSHIP_CONTRACT,owner:structuredClone(owner),object:structuredClone(object),framework:structuredClone(framework),speech_act:speechAct,scopes:structuredClone(scopes),runtime_state:runtimeState},hash=await canonicalDigest(body);
 return validateOwnershipMeaning({...body,content_digest:hash,content_id:`EZOWN:${hash.slice(0,24)}`},{allowDraft:true});
}
