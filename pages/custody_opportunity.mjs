// Draft practical opportunity, building on the existing custody-acquisition event.
import {canonicalDigest} from './engine.mjs';
import {createContextualContent} from './contextual_content.mjs';
export const CUSTODY_OPPORTUNITY_CONTRACT=Object.freeze({
 predicate:'contextual_practical_custody_opportunity',
 activity_compound:'CMP:c332d2e89b9f6177486fc93b',
 activity:'acquisition_of_practical_physical_custody',
 activity_binding:'prospective_holder_acquires_same_resource',
 opportunity:'contextual_circumstances_admit_realization_of_activity',
 activity_status:'possible_not_asserted',
 activity_time:'prospective_relative_to_opportunity',
 access_context_scope:'inside_opportunity_proposition',
 context_rules:'not_encoded_by_reference_label',
 prior_custody_if_realized:false,
 custody_at_culmination_if_realized:true,
 current_custody:'not_entailed',
 ownership:'not_entailed',
 normative_permission:'not_entailed',
 intention_or_willingness:'not_entailed',
 actual_acquisition:'not_entailed',
 ongoing_acquisition:'not_entailed',
 availability_for_other_activities:'not_asserted'
});
const allowedScopes=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
export async function validateCustodyOpportunity(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Custody opportunity requires draft opt-in.');
 const d=structuredClone(document),keys=['profile','status',...Object.keys(CUSTODY_OPPORTUNITY_CONTRACT),'prospective_holder','resource','access_context','speech_act','scopes','runtime_state','content_id','content_digest'];
 if(!d||typeof d!=='object'||Array.isArray(d)||Object.keys(d).length!==keys.length||keys.some(k=>!Object.hasOwn(d,k))||d.profile!=='EZCUSTODY-OPPORTUNITY-1'||d.status!=='draft'||Object.entries(CUSTODY_OPPORTUNITY_CONTRACT).some(([k,v])=>d[k]!==v)||!['assertion','question'].includes(d.speech_act)||![0,1,2].includes(d.runtime_state)||!allowedScopes.some(s=>JSON.stringify(s)===JSON.stringify(d.scopes)))throw new Error('Invalid custody opportunity contract.');
 for(const role of ['prospective_holder','resource','access_context'])await createContextualContent('topic',d[role],{allowDraft:true});
 if(d.access_context.kind!=='phonemic_reference')throw new Error('Identify the access context explicitly.');
 if(d.prospective_holder.referent_id===d.resource.referent_id)throw new Error('Custody requires distinct holder and resource references.');
 const {content_id,content_digest,...body}=d,hash=await canonicalDigest(body);
 if(content_digest!==hash||content_id!==`EZCUSTOP:${hash.slice(0,24)}`)throw new Error('Custody opportunity identity mismatch.');return d;
}
export async function createCustodyOpportunity(prospectiveHolder,resource,accessContext,{allowDraft=false,speechAct='assertion',scopes=[],runtimeState=1}={}){
 if(!allowDraft)throw new Error('Custody opportunity requires draft opt-in.');
 if(!accessContext)throw new Error('Identify the access context explicitly.');
 const body={profile:'EZCUSTODY-OPPORTUNITY-1',status:'draft',...CUSTODY_OPPORTUNITY_CONTRACT,prospective_holder:structuredClone(prospectiveHolder),resource:structuredClone(resource),access_context:structuredClone(accessContext),speech_act:speechAct,scopes:structuredClone(scopes),runtime_state:runtimeState},hash=await canonicalDigest(body);
 return validateCustodyOpportunity({...body,content_digest:hash,content_id:`EZCUSTOP:${hash.slice(0,24)}`},{allowDraft:true});
}
