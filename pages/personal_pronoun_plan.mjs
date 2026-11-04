// Shared occurrence positions; quoted labels are never resolved as pronouns.
export function personalPronounPlan(input,accepts,{includeNeutral=false}={}){
 if(typeof input!=='string')return null;
 const occurrences=[];let quoted=false;
 for(let i=0;i<input.length;){
  if(input[i]==='"'){quoted=!quoted;i++;continue;}
  const match=!quoted&&(i===0||!/[A-Za-z]/.test(input[i-1]))?input.slice(i).match(includeNeutral?/^(she|he|her|him|it|they|them)\b/i:/^(she|he|her|him|it)\b/i):null;
  if(match&&/^it is (?:not )?(?:(?:possible|necessary) that|the case that)\b/i.test(input.slice(i))){i+=match[0].length;continue;}
  if(match){occurrences.push({key:`ref${occurrences.length}`,pronoun:match[0],start:i,end:i+match[0].length});i+=match[0].length;}else i++;
 }
 if(quoted||!occurrences.length||occurrences.length>16)return null;
 let probe=input;for(const o of [...occurrences].reverse())probe=probe.slice(0,o.start)+`"reference ${String.fromCharCode(97+Number(o.key.slice(3)))}"`+probe.slice(o.end);
 return accepts(probe)?{input,occurrences}:null;
}

// Number belongs to reference resolution, not gender or an inferred name trait.
// Group composition remains separate; never coerce plural they to one entity.
export function resolvePersonalPronouns(input,plan,bindings,validReferent){
 const fail=message=>{const error=new Error(message);error.code='pronoun_referents_required';throw error;};
 if(!bindings||typeof bindings!=='object'||Array.isArray(bindings)||Object.keys(bindings).length!==plan.occurrences.length)fail('Identify each pronoun explicitly.');
 const chosen={};
 for(const o of plan.occurrences){
  const value=bindings[o.key],neutral=/^(they|them)$/i.test(o.pronoun);
  if(neutral){
   if(!value||typeof value!=='object'||Array.isArray(value)||Object.keys(value).length!==2||!Object.hasOwn(value,'referent')||!Object.hasOwn(value,'number')||!['singular','plural'].includes(value.number))fail('Specify whether they/them refers to one individual or a group.');
   if(value.number==='plural')fail('Group reference requires plural participant binding, which is not implemented in this draft yet.');
  }
  const referent=neutral?value.referent:value;
  if(!validReferent(referent))fail('Use an explicit name, noun reference, or I/you for each pronoun.');chosen[o.key]=referent;
 }
 let resolved=input;for(const o of [...plan.occurrences].reverse())resolved=resolved.slice(0,o.start)+chosen[o.key]+resolved.slice(o.end);
 return {resolved,chosen};
}
