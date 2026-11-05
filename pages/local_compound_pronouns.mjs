import {personalPronounPlan,resolvePersonalPronouns} from './personal_pronoun_plan.mjs';
import {validateLocalCompounds} from './local_compounds.mjs';
import {validReferent} from './pronouns.mjs';
import {localAdjectivePlan,localVerbCandidates,composeLocalAdjective,composeLocalVerb} from './local_compound_english.mjs';
export async function localWordPronounPlan(input,registry,authority){
 let probe;
 const plan=personalPronounPlan(input,value=>{probe=value;return true;},{includeNeutral:true});if(!plan)return null;
 const checked=await validateLocalCompounds(registry,authority);
 let normalized=input;
 const subject=plan.occurrences.find(o=>o.start===0&&/^they$/i.test(o.pronoun));
 if(subject){
  const tail=input.slice(subject.end),matches=checked.entries.filter(e=>e.definition.part_of_speech==='verb'&&tail.toLowerCase().startsWith(' '+e.definition.label.toLowerCase())&&/^[\s.!?\[]?$/.test(tail.slice(e.definition.label.length+1,e.definition.label.length+2)));
  if(matches.length){
   // A direct neutral subject uses the base form. Never reinterpret an ambiguous
   // base/past spelling as past merely because the probe is singular.
   if(matches.some(e=>e.definition.english_forms?.past.toLowerCase()===e.definition.label.toLowerCase()))return null;
   normalized=input.slice(0,subject.end)+' do'+input.slice(subject.end);
   personalPronounPlan(normalized,value=>{probe=value;return true;},{includeNeutral:true});
  }
 }
 const adjective=await localAdjectivePlan(probe,checked,authority),verbs=adjective?[]:await localVerbCandidates(probe,checked,authority);
 return adjective||verbs.length?{...plan,normalized_input:normalized,kind:adjective?'adjective':'verb'}:null;
}
export async function resolveLocalWordPronouns(input,registry,authority,pronounBindings){
 const plan=await localWordPronounPlan(input,registry,authority);if(!plan)throw new Error('No supported saved-word pronoun construction.');
 const normalized=plan.normalized_input,normalizedPlan=personalPronounPlan(normalized,()=>true,{includeNeutral:true});
 const {resolved,chosen}=resolvePersonalPronouns(normalized,normalizedPlan,pronounBindings,validReferent);
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
