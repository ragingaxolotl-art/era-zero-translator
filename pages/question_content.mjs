// Draft epistemic content, not a speech act or an assertion of either answer.
// This wrapper supplements the ordinary IR validator; it does not replace it.
import {canonicalDigest} from './engine.mjs';
import {parseNamedSentence,composeNamedSentence} from './sentences.mjs';
const PROFILE='EZQUESTION-CONTENT-1';
const keys=(value,allowed)=>value&&typeof value==='object'&&!Array.isArray(value)&&Object.keys(value).every(key=>allowed.includes(key))&&allowed.every(key=>Object.hasOwn(value,key));
export async function validatePolarQuestionContent(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Question content requires explicit draft opt-in.');
 document=structuredClone(document);
 if(!keys(document,['profile','status','content_id','content_digest','question_kind','assertion_commitment','proposition']))throw new Error('Invalid question content fields.');
 const {content_id,content_digest,...body}=document;
 if(body.profile!==PROFILE||body.status!=='draft'||body.question_kind!=='polar'||body.assertion_commitment!=='neither_answer')throw new Error('Invalid polar question contract.');
 const ir=body.proposition;
 if(!ir||ir.speech_act!=='assertion'||!Array.isArray(ir.nodes)||!Array.isArray(ir.edges)||!ir.nodes.some(n=>n.node_id===ir.root_clause&&n.kind==='clause'))throw new Error('Question content requires an embedded proposition IR.');
 if(ir.nodes.some(n=>n.target_type==='foundation'||n.operator==='quantified_predication'||n.kind==='quantified_reference'))throw new Error('Nested draft grammars require separate admission.');
 const {utterance_id,serialization,...semantic}=ir,digest=await canonicalDigest(semantic);
 if(serialization?.canonical_format!=='EZIR-JSON-1'||serialization.content_digest!==digest||utterance_id!==`UTT:${digest.slice(0,24)}`)throw new Error('Embedded proposition identity mismatch.');
 const expected=await canonicalDigest(body);
 if(content_digest!==expected||content_id!==`EZQ:${expected.slice(0,24)}`)throw new Error('Question content identity mismatch.');
 return structuredClone(document);
}
export async function createPolarQuestionContent(proposition,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Question content requires explicit draft opt-in.');
 const body={profile:PROFILE,status:'draft',question_kind:'polar',assertion_commitment:'neither_answer',proposition:structuredClone(proposition)};
 const digest=await canonicalDigest(body),document={...body,content_digest:digest,content_id:`EZQ:${digest.slice(0,24)}`};
 return validatePolarQuestionContent(document,{allowDraft:true});
}
export async function composePolarQuestionContent(input,loadTemplate,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Question content requires explicit draft opt-in.');
 // “Whether P” requests polar content. Bare topic labels do not invent P.
 const match=typeof input==='string'&&input.trim().match(/^[Ww]hether\s+(.+)$/);
 if(!match)throw new Error('Specify polar content with “whether” and a complete proposition.');
 const parsed=parseNamedSentence(match[1]);
 if(!parsed)throw new Error('Unsupported embedded proposition.');
 const result=await composeNamedSentence(match[1],await loadTemplate(parsed.predicate));
 if(result.semantic_ir.speech_act!=='assertion')throw new Error('An embedded question body must be a proposition, not a speech act.');
 return createPolarQuestionContent(result.semantic_ir,{allowDraft:true});
}
// Logical answer alternatives only. This is not a claim that a holder knows,
// believes, understands or can discover the answer. Runtime never supplies truth.
export function polarAnswerAlternatives(propositionTruth){
 if(![true,false,null].includes(propositionTruth))throw new Error('Supply true, false or unknown (null), not a runtime state.');
 return {positive:propositionTruth,negative:propositionTruth===null?null:!propositionTruth};
}
