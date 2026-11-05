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
const NEG={operator:'negation'},POSSIBLE={operator:'modality',mode:'possible'};
export function validCognitiveOuterScopes(scopes){return [[NEG],[POSSIBLE],[NEG,POSSIBLE],[POSSIBLE,NEG]].some(s=>JSON.stringify(s)===JSON.stringify(scopes));}
export function cognitiveScopeDescription(scopes){
 if(!scopes?.length)return '';
 if(scopes.length===1&&scopes[0].operator==='negation')return 'The whole conjunction is negated: it is not the case that all clauses hold. This does not say that every clause is false. ';
 if(scopes.length===1)return 'It is possible for all clauses to hold together; they are not asserted as actual. ';
 if(scopes[0].operator==='negation')return 'It is not possible for all clauses to hold together. This does not claim each clause is individually impossible. ';
 return 'It is possible that not all clauses hold. This does not assert that the conjunction is actually false. ';
}
export function cognitiveConjunctionPlan(input){
 if(typeof input!=='string')return null;
 let text=input.trim(),speechAct='assertion';const question=text.match(/^[Ii]s it (true|not true|possible|not possible) that (.+)\?$/);
 if(question){speechAct='question';text=(question[1]==='true'?'':'It is '+question[1]+' that ')+question[2];}else if(text.endsWith('?'))return null;
 text=text.replace(/\.$/,'');let outerScopes=[];
 for(let i=0;i<2;i++){const prefix=text.match(/^[Ii]t is (not true|not possible|possible) that /);if(!prefix)break;outerScopes.push(...(prefix[1]==='not true'?[NEG]:prefix[1]==='possible'?[POSSIBLE]:[NEG,POSSIBLE]));text=text.slice(prefix[0].length);}
 if(outerScopes.length&&!validCognitiveOuterScopes(outerScopes))return null;const outerNegation=outerScopes.length===1&&outerScopes[0].operator==='negation';
 const parts=[];let quoted=false,start=0;
 for(let i=0;i<text.length;i++){
  if(text[i]==='"')quoted=!quoted;
  if(!quoted&&text[i]==='?')return null;
  if(!quoted&&text.slice(i,i+5)===' and '){parts.push(text.slice(start,i));start=i+5;i+=4;}
 }
 parts.push(text.slice(start));
 if(quoted||parts.length<2||parts.length>8||parts.some(p=>!composer(p)))return null;
 return {profile:'EZCOGNITIVE-CONJUNCTION-PLAN-1',clauses:parts,operator:'all_of',speech_act:speechAct,outerNegation,outerScopes,scope_description:(speechAct==='question'?'This asks whether the combined meaning holds; neither answer is asserted. ':'')+cognitiveScopeDescription(outerScopes)};
}
export async function validateCognitiveConjunction(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Cognitive conjunction requires draft opt-in.');
 const d=structuredClone(document),keys=['profile','status','operator','speech_act','members','content_id','content_digest',...(Object.hasOwn(document||{},'scopes')?['scopes']:[])];
 if(!d||typeof d!=='object'||Array.isArray(d)||Object.keys(d).length!==keys.length||keys.some(k=>!Object.hasOwn(d,k))||d.profile!=='EZCOGNITIVE-CONJUNCTION-1'||d.status!=='draft'||d.operator!=='all_of'||!['assertion','question'].includes(d.speech_act)||!Array.isArray(d.members)||d.members.length<2||d.members.length>8)throw new Error('Invalid cognitive conjunction.');
 if(Object.hasOwn(d,'scopes')&&!validCognitiveOuterScopes(d.scopes))throw new Error('Unsupported outer conjunction scope.');
 for(const member of d.members){if(!VALIDATORS[member?.profile]||member.speech_act!=='assertion')throw new Error('Conjunction requires supported declarative members.');await VALIDATORS[member.profile](member,{allowDraft:true});}
 const {content_id,content_digest,...body}=d,digest=await canonicalDigest(body);if(content_digest!==digest||content_id!==`EZCOGAND:${digest.slice(0,24)}`)throw new Error('Conjunction identity mismatch.');return d;
}
export async function createCognitiveConjunction(members,{allowDraft=false,outerNegation=false,outerScopes,speechAct='assertion'}={}){
 if(!allowDraft)throw new Error('Cognitive conjunction requires draft opt-in.');
 if(outerScopes!==undefined&&(!validCognitiveOuterScopes(outerScopes)||outerNegation))throw new Error('Invalid or conflicting outer scope choices.');
 if(typeof outerNegation!=='boolean')throw new Error('Invalid outer negation choice.');
 const body={profile:'EZCOGNITIVE-CONJUNCTION-1',status:'draft',operator:'all_of',speech_act:speechAct,members:structuredClone(members),...(outerScopes?{scopes:structuredClone(outerScopes)}:outerNegation?{scopes:[{operator:'negation'}]}:{})},digest=await canonicalDigest(body);
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
 return createCognitiveConjunction(members,{allowDraft:true,speechAct:plan.speech_act,...(plan.outerScopes.length?{outerScopes:plan.outerScopes}:{})});
}
