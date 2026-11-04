import {canonicalDigest} from './engine.mjs';
import {composeCuriosity,validateCuriosity,curiosityInterpretationPlan,curiosityPronounPlan} from './curiosity.mjs';
import {composeUnderstandingContent,validateUnderstandingContent,understandingInterpretationPlan,understandingPronounPlan} from './understanding_content.mjs';
import {composeRouteLearning,validateRouteLearning,routeLearningInterpretationPlan,routeLearningPronounPlan} from './route_learning.mjs';
import {composeCameToUnderstand,validateUnderstandingAcquisition,parseCameToUnderstand} from './understanding_acquisition.mjs';
const VALIDATORS={'EZCURIOSITY-1':validateCuriosity,'EZUNDERSTANDING-CONTENT-1':validateUnderstandingContent,'EZROUTE-LEARNING-1':validateRouteLearning,'EZUNDERSTANDING-ACQUISITION-1':validateUnderstandingAcquisition};
const composer=input=>curiosityInterpretationPlan(input)||curiosityPronounPlan(input)?composeCuriosity:parseCameToUnderstand(input)?composeCameToUnderstand:routeLearningInterpretationPlan(input)||routeLearningPronounPlan(input)?composeRouteLearning:understandingInterpretationPlan(input)||understandingPronounPlan(input)?composeUnderstandingContent:null;
export function cognitiveClauseChoicePlan(input){
 const acquisition=parseCameToUnderstand(input),probe=acquisition?.result_input||input;
 for(const [interpret,pronoun] of [[curiosityInterpretationPlan,curiosityPronounPlan],[routeLearningInterpretationPlan,routeLearningPronounPlan],[understandingInterpretationPlan,understandingPronounPlan]]){
  const references=pronoun(probe),plan=interpret(probe)||references?.interpretation_plan;
  if(plan)return {choices:plan.requires_interpretation?plan.choices:[],selected_reading:plan.selected_reading||null,occurrences:references?.occurrences||[]};
 }
 return null;
}
export function cognitiveConjunctionPlan(input){
 if(typeof input!=='string'||input.trim().endsWith('?'))return null;
 const text=input.trim().replace(/\.$/,''),parts=[];let quoted=false,start=0;
 for(let i=0;i<text.length;i++){
  if(text[i]==='"')quoted=!quoted;
  if(!quoted&&text.slice(i,i+5)===' and '){parts.push(text.slice(start,i));start=i+5;i+=4;}
 }
 parts.push(text.slice(start));
 if(quoted||parts.length<2||parts.length>8||parts.some(p=>!composer(p)))return null;
 return {profile:'EZCOGNITIVE-CONJUNCTION-PLAN-1',clauses:parts,operator:'all_of',speech_act:'assertion'};
}
export async function validateCognitiveConjunction(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Cognitive conjunction requires draft opt-in.');
 const d=structuredClone(document),keys=['profile','status','operator','speech_act','members','content_id','content_digest'];
 if(!d||typeof d!=='object'||Array.isArray(d)||Object.keys(d).length!==keys.length||keys.some(k=>!Object.hasOwn(d,k))||d.profile!=='EZCOGNITIVE-CONJUNCTION-1'||d.status!=='draft'||d.operator!=='all_of'||d.speech_act!=='assertion'||!Array.isArray(d.members)||d.members.length<2||d.members.length>8)throw new Error('Invalid cognitive conjunction.');
 for(const member of d.members){if(!VALIDATORS[member?.profile]||member.speech_act!=='assertion')throw new Error('Conjunction requires supported declarative members.');await VALIDATORS[member.profile](member,{allowDraft:true});}
 const {content_id,content_digest,...body}=d,digest=await canonicalDigest(body);if(content_digest!==digest||content_id!==`EZCOGAND:${digest.slice(0,24)}`)throw new Error('Conjunction identity mismatch.');return d;
}
export async function createCognitiveConjunction(members,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Cognitive conjunction requires draft opt-in.');
 const body={profile:'EZCOGNITIVE-CONJUNCTION-1',status:'draft',operator:'all_of',speech_act:'assertion',members:structuredClone(members)},digest=await canonicalDigest(body);
 return validateCognitiveConjunction({...body,content_digest:digest,content_id:`EZCOGAND:${digest.slice(0,24)}`},{allowDraft:true});
}
export async function composeCognitiveConjunction(input,{allowDraft=false,clauseOptions}={}){
 if(!allowDraft)throw new Error('Cognitive conjunction requires draft opt-in.');
 const plan=cognitiveConjunctionPlan(input);if(!plan)throw new Error('Unsupported cognitive conjunction.');
 if(clauseOptions!==undefined&&(!Array.isArray(clauseOptions)||clauseOptions.length!==plan.clauses.length))throw new Error('Provide one option object per clause.');
 const members=[];
 for(const [index,clause] of plan.clauses.entries()){
  try{members.push(await composer(clause)(clause,{...clauseOptions?.[index],allowDraft:true}));}
  catch(error){error.clause_index=index;throw error;}
 }
 return createCognitiveConjunction(members,{allowDraft:true});
}
