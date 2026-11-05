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
 const probe=substitutePersonalPronouns(input,occurrences,Object.fromEntries(occurrences.map(o=>[o.key,`"reference ${String.fromCharCode(97+Number(o.key.slice(3)))}"`])));
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
 const resolved=substitutePersonalPronouns(input,plan.occurrences,chosen);
 return {resolved,chosen};
}

// Resolve singular they's English agreement without changing predicate meaning.
// Only supported present-tense verbs/auxiliaries are normalized; past verbs and
// modals remain untouched. Reference number is validated before actual resolution.
export function substitutePersonalPronouns(input,occurrences,chosen){
 const edits=occurrences.map(o=>({start:o.start,end:o.end,text:chosen[o.key]}));
 for(const o of occurrences){
  if(!/^they$/i.test(o.pronoun))continue;
  const ref=chosen[o.key],first=/^(I|me)$/.test(ref),second=/^you$/i.test(ref),third=!first&&!second;
  const agree=verb=>{const lower=verb.toLowerCase();let word=lower;
   const negative={"aren't":'are',"weren't":'were',"haven't":'have',"don't":'do',"didn't":'did',"can't":'can',"couldn't":'could',"won't":'will',"wouldn't":'would',"shouldn't":'should',"mustn't":'must'}[lower.replace('’',"'")];
   if(negative)return agree((/^[A-Z]/.test(verb)?negative[0].toUpperCase()+negative.slice(1):negative))+' not';
   if(['did','can','could','will','would','should','must','may','might'].includes(lower))return verb;
   if(lower==='are')word=first?'am':second?'are':'is';
   else if(lower==='were')word=second?'were':'was';
   else if(third&&lower==='have')word='has';
   else if(third&&lower==='do')word='does';
   else if(third)word=/[^aeiou]y$/.test(lower)?lower.slice(0,-1)+'ies':/(s|sh|ch|x|z|o)$/.test(lower)?lower+'es':lower+'s';
   return /^[A-Z]/.test(verb)?word[0].toUpperCase()+word.slice(1):word;
  };
  const before=input.slice(0,o.start).match(/\b(aren['’]t|weren['’]t|haven['’]t|don['’]t|didn['’]t|can['’]t|couldn['’]t|won['’]t|wouldn['’]t|shouldn['’]t|mustn['’]t|Are|Were|Do|Have|Did|Can|Could|Will|Would|Should|Must|May|Might) $/i);
  const after=input.slice(o.end).match(/^ (aren['’]t|weren['’]t|haven['’]t|don['’]t|didn['’]t|are|were|have|do|care|run|swim|carry|enter|prefer|know|want|understand|drink)\b/i);
  const habitual=input.slice(o.end).match(/^ habitually (drink|run|swim|carry|enter)\b/i);
  if(habitual&&!before)edits.push({start:o.end+12,end:o.end+12+habitual[1].length,text:agree(habitual[1])});
  if(after&&!before)edits.push({start:o.end+1,end:o.end+1+after[1].length,text:agree(after[1])});
  if(before){const normalized=agree(before[1]),negative=normalized.endsWith(' not');edits.push({start:o.start-before[0].length,end:o.start-1,text:negative?normalized.slice(0,-4):normalized});if(negative)edits.find(e=>e.start===o.start&&e.end===o.end).text+=' not';}
 }
 let output=input;for(const edit of edits.sort((a,b)=>b.start-a.start))output=output.slice(0,edit.start)+edit.text+output.slice(edit.end);
 return output;
}
