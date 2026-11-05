import {canonicalDigest} from './engine.mjs';
import {parseFoundationSentence} from './foundation_sentences.mjs';
import {contextualContentReference,createContextualContent} from './contextual_content.mjs';
import {composePainMeaning} from './pain_meaning.mjs';
import {createPainStimulus} from './pain_stimulus.mjs';
import {createPainComparison,validatePainComparison} from './pain_comparison.mjs';
import {encodeName} from './names.mjs';
import {NOMINAL_MODES} from './references.mjs';
const FOUNDATION='FND:018dd25d713dff83661a76a4';
export function painPreferencePlan(input){
 const p=parseFoundationSentence(input);if(!p||p.type!=='preference'||p.propositionalAlternatives||p.calendarDay!==undefined)return null;
 const read=text=>text.match(/^[Tt]he (more )?painful ([a-z]+)$/);
 const a=read(p.target),b=read(p.standard);if(!a||!b||Boolean(a[1])===Boolean(b[1]))return null;
 return {holder:p.holder,target_head:a[2],standard_head:b[2],more_painful_role:a[1]?'target':'comparison_standard',speech_act:p.speechAct,runtime_state:p.state,scopes:[...(p.speechTime?[{operator:'time',relation:'before_speech'}]:[]),...(p.negated?[{operator:'negation'}]:[])]};
}
export async function validatePainPreference(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Pain preference requires draft opt-in.');
 const d=structuredClone(document),keys=['profile','status','foundation_id','holder','target','comparison_standard','pain_comparison','more_painful_role','restriction_scope','speech_act','scopes','runtime_state','content_id','content_digest'];
 const validScopes=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 if(!d||typeof d!=='object'||Array.isArray(d)||Object.keys(d).length!==keys.length||keys.some(k=>!Object.hasOwn(d,k))||d.profile!=='EZPAIN-PREFERENCE-1'||d.status!=='draft'||d.foundation_id!==FOUNDATION||!['target','comparison_standard'].includes(d.more_painful_role)||d.restriction_scope!=='reference_descriptions_not_preference_polarity'||![0,1,2].includes(d.runtime_state)||!['assertion','question'].includes(d.speech_act)||!validScopes.some(s=>JSON.stringify(s)===JSON.stringify(d.scopes)))throw new Error('Invalid pain preference contract.');
 for(const ref of [d.holder,d.target,d.comparison_standard])await createContextualContent('topic',ref,{allowDraft:true});
 await validatePainComparison(d.pain_comparison,{allowDraft:true});
 const c=d.pain_comparison,more=d[d.more_painful_role],less=d[d.more_painful_role==='target'?'comparison_standard':'target'];
 if(c.relation!=='greater_than'||c.speech_act!=='assertion'||c.scopes.length||await canonicalDigest(c.left.stimulus)!==await canonicalDigest(more)||await canonicalDigest(c.right.stimulus)!==await canonicalDigest(less))throw new Error('Pain description does not bind to preference alternatives.');
 const {content_digest,content_id,...body}=d,hash=await canonicalDigest(body);if(content_digest!==hash||content_id!==`EZPAINPREF:${hash.slice(0,24)}`)throw new Error('Pain preference identity mismatch.');return d;
}
export async function composePainPreference(input,{allowDraft=false,experiencer,interpretation,context,comparisonTarget}={}){
 if(!allowDraft)throw new Error('Pain preference requires draft opt-in.');
 const p=painPreferencePlan(input);if(!p)throw new Error('Unsupported modified pain preference.');
 if(comparisonTarget!=='other_alternative')throw new Error('Confirm that more painful compares with the other preference alternative.');
 if(typeof experiencer!=='string'||!experiencer.trim()||typeof context!=='string'||!context.trim())throw new Error('Identify the pain experiencer and shared context.');
 const refs=[];
 for(const [role,head] of [['target',p.target_head],['comparison_standard',p.standard_head]]){
  const ref=await contextualContentReference(`the ${head}`),name=await encodeName(head,`pain-preference:${role}`);refs.push({...ref,name,referent_id:`nominal:${NOMINAL_MODES.definite_nominal.id}:${name.name_id}`});
 }
 const person=/^(I|me)$/i.test(experiencer)?'I':experiencer,copula=person==='I'?'am':/^you$/i.test(person)?'are':'is';
 const pain=await composePainMeaning(`${person} ${copula} in bodily pain.`,{allowDraft:true});
 const outcomes=[];for(const ref of refs)outcomes.push(await createPainStimulus(ref,pain,{allowDraft:true,relation:interpretation}));
 const more=p.more_painful_role==='target'?0:1,comparison=await createPainComparison(outcomes[more],outcomes[1-more],await contextualContentReference(context),{allowDraft:true,relation:'greater_than'});
 const body={profile:'EZPAIN-PREFERENCE-1',status:'draft',foundation_id:FOUNDATION,holder:await contextualContentReference(p.holder),target:refs[0],comparison_standard:refs[1],pain_comparison:comparison,more_painful_role:p.more_painful_role,restriction_scope:'reference_descriptions_not_preference_polarity',speech_act:p.speech_act,scopes:p.scopes,runtime_state:p.runtime_state},hash=await canonicalDigest(body);
 return validatePainPreference({...body,content_digest:hash,content_id:`EZPAINPREF:${hash.slice(0,24)}`},{allowDraft:true});
}
