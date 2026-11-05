import {personalPronounPlan,resolvePersonalPronouns} from './personal_pronoun_plan.mjs';
import {validReferent} from './pronouns.mjs';
import {localAdjectivePlan,localVerbCandidates,composeLocalAdjective,composeLocalVerb} from './local_compound_english.mjs';
export async function localWordPronounPlan(input,registry,authority){
 let probe;
 const plan=personalPronounPlan(input,value=>{probe=value;return true;},{includeNeutral:true});if(!plan)return null;
 const adjective=await localAdjectivePlan(probe,registry,authority),verbs=adjective?[]:await localVerbCandidates(probe,registry,authority);
 return adjective||verbs.length?{...plan,kind:adjective?'adjective':'verb'}:null;
}
export async function resolveLocalWordPronouns(input,registry,authority,pronounBindings){
 const plan=await localWordPronounPlan(input,registry,authority);if(!plan)throw new Error('No supported saved-word pronoun construction.');
 const {resolved,chosen}=resolvePersonalPronouns(input,plan,pronounBindings,validReferent);
 // Validate again after actual references replace probes, including agreement.
 const adjective=await localAdjectivePlan(resolved,registry,authority),verbs=adjective?[]:await localVerbCandidates(resolved,registry,authority);
 if(!adjective&&!verbs.length)throw new Error('Resolved references do not form a supported saved-word sentence.');
 return {source_input:input,resolved_input:resolved,pronoun_bindings:chosen,kind:adjective?'adjective':'verb'};
}
export async function composeLocalWordWithPronouns(input,registry,authority,{pronounBindings,...options}={}){
 const resolution=await resolveLocalWordPronouns(input,registry,authority,pronounBindings);
 const result=resolution.kind==='adjective'?await composeLocalAdjective(resolution.resolved_input,registry,authority,options):await composeLocalVerb(resolution.resolved_input,registry,authority,options);
 return {...result,source_input:input,pronoun_resolution:resolution};
}
