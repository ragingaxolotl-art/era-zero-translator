// Draft intensity comparison over existing pain-stimulus meanings.
import {canonicalDigest} from './engine.mjs';
import {validatePainStimulus} from './pain_stimulus.mjs';
import {createContextualContent} from './contextual_content.mjs';
const CONTRACT={dimension:'felt_bodily_pain_intensity',basis:'same_experiencer_and_selected_context',scale:'ordinal_no_numeric_score',operand_scope:'governed_by_comparison_and_matrix_scope'};
const validScopes=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
export async function validatePainComparison(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Pain comparison requires draft opt-in.');
 const d=structuredClone(document),keys=['profile','status',...Object.keys(CONTRACT),'relation','left','right','context','speech_act','scopes','runtime_state','content_digest','content_id'];
 if(!d||typeof d!=='object'||Array.isArray(d)||Object.keys(d).length!==keys.length||keys.some(k=>!Object.hasOwn(d,k))||d.profile!=='EZPAIN-COMPARISON-1'||d.status!=='draft'||Object.entries(CONTRACT).some(([k,v])=>d[k]!==v)||!['greater_than','less_than','equal'].includes(d.relation)||![0,1,2].includes(d.runtime_state)||!['assertion','question'].includes(d.speech_act)||!validScopes.some(s=>JSON.stringify(s)===JSON.stringify(d.scopes)))throw new Error('Invalid pain comparison contract.');
 for(const operand of [d.left,d.right]){
  await validatePainStimulus(operand,{allowDraft:true});
  if(operand.speech_act!=='assertion'||operand.scopes.length)throw new Error('Comparison operands must be positive unscoped contents.');
 }
 if(d.left.relation!==d.right.relation)throw new Error('Pain outcomes require the same actual/expected/dispositional reading.');
 if(await canonicalDigest(d.left.outcome.experiencer)!==await canonicalDigest(d.right.outcome.experiencer))throw new Error('Cross-experiencer pain scales need an explicit separate comparison convention.');
 await createContextualContent('topic',d.context,{allowDraft:true});
 const {content_id,content_digest,...body}=d,hash=await canonicalDigest(body);
 if(content_digest!==hash||content_id!==`EZPAINCMP:${hash.slice(0,24)}`)throw new Error('Pain comparison identity mismatch.');return d;
}
export async function createPainComparison(left,right,context,{allowDraft=false,relation,speechAct='assertion',scopes=[],runtimeState=1}={}){
 if(!allowDraft)throw new Error('Pain comparison requires draft opt-in.');
 const body={profile:'EZPAIN-COMPARISON-1',status:'draft',...CONTRACT,relation,left:structuredClone(left),right:structuredClone(right),context:structuredClone(context),speech_act:speechAct,scopes:structuredClone(scopes),runtime_state:runtimeState},hash=await canonicalDigest(body);
 return validatePainComparison({...body,content_digest:hash,content_id:`EZPAINCMP:${hash.slice(0,24)}`},{allowDraft:true});
}
