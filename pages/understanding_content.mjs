// Draft interpretation/meaning contract. No musical predicate or canonical
// vocabulary admission is implied by creating this document.
import {canonicalDigest} from './engine.mjs';
import {contextualContentReference,createContextualContent,validateContextualContent} from './contextual_content.mjs';
import {expandNegativeContractions} from './contractions.mjs';
const REF='(?:I|[Mm]e|[Yy]ou|[A-Z][a-z]+|"[^"\\n]+"|(?:[Tt]he|[Tt]his|[Tt]hat) [a-z]+)';
export const UNDERSTANDING_READINGS=Object.freeze({
 communicated_content:'Grasps the intended meaning of contextually selected content conveyed by the anchor; does not assert that the conveyed claims are true.',
 reasons:'Grasps contextually selected explanatory reasons concerning the anchor, to the contextual standard of explanatory adequacy; does not assert approval or shared motives.',
 perspective:'Grasps the contextually selected standpoint or experiences of the anchor, to the contextual standard of perspective understanding; does not assert shared feelings, agreement or approval.'
});
export function understandingInterpretationPlan(input){
 if(typeof input!=='string')return null;
 let text=input.trim(),runtime=1;
 const tag=text.match(/\s*\[([012])\]([.!?]?)$/);
 if(tag){runtime=Number(tag[1]);text=text.slice(0,tag.index).trim();const before=text.match(/[.!?]$/)?.[0];if(before&&tag[2]&&before!==tag[2])return null;if(!before)text+=tag[2];}
 text=expandNegativeContractions(text,`(${REF})`);
 const question=text.endsWith('?');text=text.replace(/[.!?]$/,'');
 let m=text.match(new RegExp(`^(${REF}) (understands|understand|understood|does not understand|do not understand|did not understand) (.+)$`));
 if(question){const q=text.match(new RegExp(`^([Dd]oes|[Dd]o|[Dd]id) (${REF}) (not )?understand (.+)$`));if(q)m=[q[0],q[2],q[1].toLowerCase()==='did'?(q[3]?'did not understand':'understood'):(q[3]?'does not understand':'understand'),q[4]];}
 if(!m)return null;
 let target=m[3],kind=null;
 const expressed=target.match(new RegExp(`^(${REF})['’]s communicated content$`));
 const explicit=target.match(new RegExp(`^(${REF})['’]s (reasons|perspective)$`));
 if(expressed){target=expressed[1];kind='communicated_content';}
 else if(explicit){target=explicit[1];kind=explicit[2];}
 else if(!new RegExp(`^${REF}$`).test(target))return null;
 const scopes=[];if(/^(understood|did)/.test(m[2]))scopes.push({operator:'time',relation:'before_speech'});if(m[2].includes('not'))scopes.push({operator:'negation'});
 return {profile:'EZUNDERSTANDING-INTERPRETATION-1',status:'draft',experiencer:m[1],anchor:target,runtime_state:runtime,speech_act:question?'question':'assertion',scopes,selected_reading:kind,choices:kind?[]:Object.entries(UNDERSTANDING_READINGS).map(([id,description])=>({id,description})),requires_interpretation:!kind};
}
const exact=(v,fields)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===fields.length&&fields.every(k=>Object.hasOwn(v,k));
export async function validateUnderstandingContent(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Understanding content requires explicit draft opt-in.');
 document=structuredClone(document);
 if(!exact(document,['profile','status','predicate','criterion','experiencer','content','speech_act','scopes','runtime_state','content_id','content_digest']))throw new Error('Invalid understanding document fields.');
 const {content_id,content_digest,...body}=document,kind=body.content?.content_kind;
 if(body.profile!=='EZUNDERSTANDING-CONTENT-1'||body.status!=='draft'||body.predicate!=='content_comprehension'||!Object.hasOwn(UNDERSTANDING_READINGS,kind)||body.criterion!==UNDERSTANDING_READINGS[kind]||!['assertion','question'].includes(body.speech_act)||![0,1,2].includes(body.runtime_state))throw new Error('Invalid understanding contract.');
 await validateContextualContent(body.content,{allowDraft:true});
 // Reuse exact entity-reference validation without mistaking the experiencer
 // for an understood topic or asserting any content about that experiencer.
 await createContextualContent('topic',body.experiencer,{allowDraft:true});
 const allowed=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 if(!allowed.some(s=>JSON.stringify(s)===JSON.stringify(body.scopes)))throw new Error('Unsupported understanding scope.');
 const digest=await canonicalDigest(body);if(content_digest!==digest||content_id!==`EZUND:${digest.slice(0,24)}`)throw new Error('Understanding identity mismatch.');
 return document;
}
export async function composeUnderstandingContent(input,{allowDraft=false,interpretation}={}){
 if(!allowDraft)throw new Error('Understanding content requires explicit draft opt-in.');
 const plan=understandingInterpretationPlan(input);if(!plan)throw new Error('Unsupported understanding sentence.');
 const kind=plan.selected_reading||interpretation;
 if(!Object.hasOwn(UNDERSTANDING_READINGS,kind)||(plan.selected_reading&&interpretation&&plan.selected_reading!==interpretation)){
  const error=new Error('Choose communicated meaning, explanatory reasons, or perspective understanding.');error.code='understanding_interpretation_required';error.plan=plan;throw error;
 }
 const experiencer=await contextualContentReference(plan.experiencer),content=await createContextualContent(kind,await contextualContentReference(plan.anchor),{allowDraft:true});
 const body={profile:'EZUNDERSTANDING-CONTENT-1',status:'draft',predicate:'content_comprehension',criterion:UNDERSTANDING_READINGS[kind],experiencer,content,speech_act:plan.speech_act,scopes:plan.scopes,runtime_state:plan.runtime_state},digest=await canonicalDigest(body);
 return validateUnderstandingContent({...body,content_digest:digest,content_id:`EZUND:${digest.slice(0,24)}`},{allowDraft:true});
}
