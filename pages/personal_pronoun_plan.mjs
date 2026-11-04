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
