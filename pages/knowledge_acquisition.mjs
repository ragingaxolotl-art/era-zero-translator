// Draft result-state binding convention, not a new root or approved compound.
import {canonicalDigest} from './engine.mjs';
import {validateFoundationIR} from './foundation_ir.mjs';
const PROFILE='EZKNOWLEDGE-ACQUISITION-1';
const fields=['profile','status','transition_root','result_assertion','phase_contract','result_state','vocabulary','content_digest','acquisition_id'];
export async function validateKnowledgeAcquisition(input,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Knowledge acquisition requires draft opt-in.');
 const document=structuredClone(input);
 if(!document||fields.some(k=>!Object.hasOwn(document,k))||Object.keys(document).some(k=>!fields.includes(k)))throw new Error('Invalid acquisition fields.');
 if(document.profile!==PROFILE||document.status!=='draft'||document.transition_root!=='ORI:110'||document.result_assertion!=='at_culmination_only'||await canonicalDigest(document.phase_contract)!==await canonicalDigest({before:'does_not_hold',culmination:'holds',after:'unspecified'}))throw new Error('Invalid acquisition phase contract.');
 const ir=document.result_state,records=document.vocabulary;
 await validateFoundationIR(ir,records,{allowDraft:true});
 const node=ir.nodes.find(n=>n.node_id===ir.edges.find(e=>e.type==='centers'&&e.to===ir.root_clause)?.from);
 const definition=records.find(r=>r.foundation_id===node?.target_id);
 if(ir.speech_act!=='assertion'||node?.target_type!=='foundation'||definition?.foundation_id!=='FND:fe36cb2a6d649151067c7754'||await canonicalDigest(definition.roles)!==await canonicalDigest({experiencer:['entity'],content:['question']}))throw new Error('Acquisition result must be the positive polar-answer knowledge relation.');
 if(ir.edges.some(e=>e.type==='time_relation'&&e.to===ir.root_clause))throw new Error('Result time is supplied by culmination, not an independent speech-time assertion.');
 const {utterance_id,serialization,...semantic}=ir,semanticDigest=await canonicalDigest(semantic);
 if(utterance_id!==`UTT:${semanticDigest.slice(0,24)}`||serialization?.content_digest!==semanticDigest||serialization.canonical_format!=='EZIR-JSON-1')throw new Error('Result semantic identity mismatch.');
 const {content_digest,acquisition_id,...body}=document,digest=await canonicalDigest(body);
 if(content_digest!==digest||acquisition_id!==`EZACQ:${digest.slice(0,24)}`)throw new Error('Acquisition identity mismatch.');
 return document;
}
export async function createKnowledgeAcquisition(result,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Knowledge acquisition requires draft opt-in.');
 const body={profile:PROFILE,status:'draft',transition_root:'ORI:110',result_assertion:'at_culmination_only',phase_contract:{before:'does_not_hold',culmination:'holds',after:'unspecified'},result_state:structuredClone(result.semantic_ir),vocabulary:structuredClone(result.vocabulary?.records)};
 const digest=await canonicalDigest(body);
 return validateKnowledgeAcquisition({...body,content_digest:digest,acquisition_id:`EZACQ:${digest.slice(0,24)}`},{allowDraft:true});
}
// Tests a declared completed-transition witness, not knowledge from a truth bit.
// The caller must independently establish whether the SAME knowledge relation
// holds at each phase. Merely observing P's truth or a correct guess cannot do so.
export function evaluateKnowledgeAcquisition({before,culmination,transitionCompleted}){
 if(![true,false,null].includes(before)||![true,false,null].includes(culmination)||![true,false,null].includes(transitionCompleted))throw new Error('Explicit phase truth and transition completion required; runtime is not truth.');
 if(before===true||culmination===false||transitionCompleted===false)return false;
 return before===false&&culmination===true&&transitionCompleted===true?true:null;
}
