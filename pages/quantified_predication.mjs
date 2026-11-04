// Semantic reference model for the pending quantified-predicate construction.
// This is not a renderer or an English parser. No new sound is admitted here.
const truth=value=>value===true||value===false||value===null;
const negate=value=>value===null?null:!value;
export function evaluateQuantifiedPredication({quantifier,value,members,domainComplete,predicateNegated=false,propositionNegated=false}){
 if(!['exact','at_least','at_most'].includes(quantifier)||typeof value!=='string'||!/^(?:0|[1-9][0-9]*)$/.test(value)||value.length>1024)throw new Error('Invalid cardinality.');
 if(!Array.isArray(members)||typeof domainComplete!=='boolean'||typeof predicateNegated!=='boolean'||typeof propositionNegated!=='boolean')throw new Error('Explicit domain and negation scope are required.');
 const ids=new Set();let lower=0n,upper=0n;
 for(const member of members){
  if(!member||typeof member.id!=='string'||!member.id||ids.has(member.id)||!truth(member.restriction)||!truth(member.predicate)||Object.keys(member).some(k=>!['id','restriction','predicate'].includes(k)))throw new Error('Each domain member needs a unique identity and explicit restriction/predicate truth values.');
  ids.add(member.id);
  const p=predicateNegated?negate(member.predicate):member.predicate;
  // The same member is tested against both nominal restriction and predicate.
  const satisfies=member.restriction===false||p===false?false:member.restriction===true&&p===true?true:null;
  if(satisfies===true)lower++;
  if(satisfies!==false)upper++;
 }
 const threshold=BigInt(value),maximum=domainComplete?upper:null;
 let result;
 if(quantifier==='exact')result=lower>threshold||(maximum!==null&&maximum<threshold)?false:maximum===lower&&lower===threshold?true:null;
 else if(quantifier==='at_least')result=lower>=threshold?true:maximum!==null&&maximum<threshold?false:null;
 else result=lower>threshold?false:maximum!==null&&maximum<=threshold?true:null;
 if(propositionNegated)result=negate(result);
 return {truth:result,minimum_satisfying:lower.toString(),maximum_satisfying:maximum===null?null:maximum.toString(),domain_complete:domainComplete};
}
