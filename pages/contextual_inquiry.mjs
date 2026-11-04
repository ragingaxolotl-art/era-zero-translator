// A contextual inquiry selects questions about a topic, not answers or interest.
import {canonicalDigest} from './engine.mjs';
import {createContextualContent,validateContextualContent} from './contextual_content.mjs';
const CONTRACT={profile:'EZCONTEXTUAL-INQUIRY-1',status:'draft',content_kind:'contextual_question_set',resolution_scope:'local_context',question_selection:'contextually_relevant_unresolved',answer_commitment:'none',specific_question_supplied:false};
export async function validateContextualInquiry(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Contextual inquiry requires draft opt-in.');
 const d=structuredClone(document),keys=[...Object.keys(CONTRACT),'topic','content_digest','content_id'];
 if(!d||typeof d!=='object'||Array.isArray(d)||Object.keys(d).length!==keys.length||keys.some(k=>!Object.hasOwn(d,k))||Object.entries(CONTRACT).some(([k,v])=>d[k]!==v))throw new Error('Invalid contextual inquiry contract.');
 await validateContextualContent(d.topic,{allowDraft:true});
 if(d.topic.content_kind!=='topic'||Object.hasOwn(d.topic,'selection'))throw new Error('Inquiry requires a topic, not a message, answer or explanation.');
 const {content_digest,content_id,...body}=d,digest=await canonicalDigest(body);
 if(content_digest!==digest||content_id!==`EZINQUIRY:${digest.slice(0,24)}`)throw new Error('Inquiry identity mismatch.');
 return d;
}
export async function createContextualInquiry(anchor,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Contextual inquiry requires draft opt-in.');
 const body={...CONTRACT,topic:await createContextualContent('topic',anchor,{allowDraft:true})},digest=await canonicalDigest(body);
 return validateContextualInquiry({...body,content_digest:digest,content_id:`EZINQUIRY:${digest.slice(0,24)}`},{allowDraft:true});
}
