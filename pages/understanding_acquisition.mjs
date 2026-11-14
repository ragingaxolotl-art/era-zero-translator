// Completed entry into a comprehension state, not a new understanding sense.
import {canonicalDigest} from './engine.mjs';
import {composeUnderstandingContent,validateUnderstandingContent,understandingInterpretationPlan,understandingPronounPlan} from './understanding_content.mjs';
import {validAcquisitionScopes} from './acquisition_scopes.mjs';
const exact=(v,fields)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===fields.length&&fields.every(k=>Object.hasOwn(v,k));
export async function validateUnderstandingAcquisition(input,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Understanding acquisition requires draft opt-in.');
 const d=structuredClone(input);
 if(!exact(d,['profile','status','transition_root','transition_runtime','speech_act','event_scopes','result_assertion','phase_contract','result_state','content_digest','acquisition_id']))throw new Error('Invalid comprehension acquisition fields.');
 if(d.profile!=='EZUNDERSTANDING-ACQUISITION-1'||d.status!=='draft'||d.transition_root!=='ORI:110'||d.result_assertion!=='at_culmination_only'||await canonicalDigest(d.phase_contract)!==await canonicalDigest({before:'does_not_hold',culmination:'holds',after:'unspecified'}))throw new Error('Invalid comprehension acquisition contract.');
 if(!exact(d.transition_runtime,['code'])||![0,1,2].includes(d.transition_runtime.code)||!['assertion','question'].includes(d.speech_act)||!validAcquisitionScopes(d.event_scopes))throw new Error('Invalid acquisition runtime, act or scope.');
 const result=await validateUnderstandingContent(d.result_state,{allowDraft:true});
 if(result.speech_act!=='assertion'||result.scopes.length)throw new Error('Acquisition needs a positive result state at culmination, without separate matrix time.');
 const {content_digest,acquisition_id,...body}=d,digest=await canonicalDigest(body);
 if(content_digest!==digest||acquisition_id!==`EZUACQ:${digest.slice(0,24)}`)throw new Error('Understanding acquisition identity mismatch.');
 return d;
}
export async function createUnderstandingAcquisition(result,{allowDraft=false,runtimeState=1,speechAct='assertion',eventScopes=[]}={}){
 if(!allowDraft)throw new Error('Understanding acquisition requires draft opt-in.');
 const body={profile:'EZUNDERSTANDING-ACQUISITION-1',status:'draft',transition_root:'ORI:110',transition_runtime:{code:runtimeState},speech_act:speechAct,event_scopes:structuredClone(eventScopes),result_assertion:'at_culmination_only',phase_contract:{before:'does_not_hold',culmination:'holds',after:'unspecified'},result_state:structuredClone(result)},digest=await canonicalDigest(body);
 return validateUnderstandingAcquisition({...body,content_digest:digest,acquisition_id:`EZUACQ:${digest.slice(0,24)}`},{allowDraft:true});
}
export function parseCameToUnderstand(input){
 if(typeof input!=='string')return null;
 let text=input.trim(),runtime=1;const tag=text.match(/\s*\[([012])\]([.!?]?)$/);
 if(tag){runtime=Number(tag[1]);text=text.slice(0,tag.index).trim();const before=text.match(/[.!?]$/)?.[0];if(before&&tag[2]&&before!==tag[2])return null;if(!before)text+=tag[2];}
 const question=text.endsWith('?');text=text.replace(/[.!?]$/,'');
 let m=text.match(/^(.+?) (came to understand|did not come to understand|didn['’]t come to understand) (.+)$/),negative;
 if(question){const q=text.match(/^[Dd]id (.+?) (not )?come to understand (.+)$/);if(q){m=[q[0],q[1],q[2]?'did not come to understand':'came to understand',q[3]];}}
 if(!m)return null;negative=m[2]!=='came to understand';
 const result_input=`${m[1]} understands ${m[3]}`;
 if(!understandingInterpretationPlan(result_input)&&!understandingPronounPlan(result_input))return null;
 return {result_input,runtime,speechAct:question?'question':'assertion',eventScopes:['before_speech',...(negative?['negation']:[])]};
}
export async function composeCameToUnderstand(input,{allowDraft=false,interpretation,bindings,resultRuntime=1}={}){
 if(!allowDraft)throw new Error('Understanding acquisition requires draft opt-in.');
 const parsed=parseCameToUnderstand(input);if(!parsed)throw new Error('Unsupported comprehension acquisition sentence.');
 if(![0,1,2].includes(resultRuntime))throw new Error('Invalid result runtime.');
 const result=await composeUnderstandingContent(`${parsed.result_input} [${resultRuntime}].`,{allowDraft:true,interpretation,...(bindings?{bindings}:{})});
 return createUnderstandingAcquisition(result,{allowDraft:true,runtimeState:parsed.runtime,speechAct:parsed.speechAct,eventScopes:parsed.eventScopes});
}
