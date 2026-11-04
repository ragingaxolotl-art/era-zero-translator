import assert from 'node:assert/strict';
import {evaluateQuantifiedPredication as evaluate} from '../pages/quantified_predication.mjs';
const options={quantifier:'exact',value:'3',domainComplete:true};
const domain=(n,energized)=>Array.from({length:n},(_,i)=>({id:`lamp${i}`,restriction:true,predicate:i<energized}));
assert.equal(evaluate({...options,members:domain(6,3),predicateNegated:true}).truth,true);
assert.equal(evaluate({...options,members:domain(6,3),propositionNegated:true}).truth,false);
assert.equal(evaluate({...options,members:domain(4,2),predicateNegated:true}).truth,false);
assert.equal(evaluate({...options,members:domain(4,2),propositionNegated:true}).truth,true);
// Independent finite-completion oracle: enumerate every assignment of unknown
// membership/property values, apply ordinary set filtering, then compare counts.
function completions(members){
 const unknown=members.flatMap((m,i)=>['restriction','predicate'].filter(k=>m[k]===null).map(k=>[i,k]));
 return Array.from({length:2**unknown.length},(_,mask)=>{const copy=structuredClone(members);unknown.forEach(([i,k],bit)=>copy[i][k]=!!(mask&(1<<bit)));return copy;});
}
let checks=0;
for(let encoding=0;encoding<3**6;encoding++){
 let remaining=encoding;const members=Array.from({length:3},(_,i)=>{const restriction=[false,true,null][remaining%3];remaining=Math.floor(remaining/3);const predicate=[false,true,null][remaining%3];remaining=Math.floor(remaining/3);return {id:String(i),restriction,predicate};});
 for(const quantifier of ['exact','at_least','at_most'])for(const value of ['0','2','4'])for(const predicateNegated of [false,true])for(const propositionNegated of [false,true]){
  const outcomes=completions(members).map(list=>{const count=list.filter(m=>m.restriction&&(predicateNegated?!m.predicate:m.predicate)).length;const result=quantifier==='exact'?count===Number(value):quantifier==='at_least'?count>=Number(value):count<=Number(value);return propositionNegated?!result:result;});
  const expected=outcomes.every(Boolean)?true:outcomes.every(v=>!v)?false:null;
  assert.equal(evaluate({quantifier,value,members,domainComplete:true,predicateNegated,propositionNegated}).truth,expected);checks++;
 }
}
assert.equal(evaluate({...options,members:domain(3,3),domainComplete:false}).truth,null);
assert.equal(evaluate({...options,members:domain(4,4),domainComplete:false}).truth,false);
assert.equal(evaluate({...options,quantifier:'at_least',members:domain(3,3),domainComplete:false}).truth,true);
assert.equal(evaluate({...options,quantifier:'at_most',members:domain(0,0),domainComplete:false}).truth,null);
assert.throws(()=>evaluate({...options,members:[...domain(1,1),...domain(1,1)]}),/unique identity/);
assert.throws(()=>evaluate({...options,members:[{id:'a',restriction:1,predicate:true}]}));
console.log(`PASS ${checks} finite-model checks against independently enumerated completions; predicate/whole-proposition negation, unknown domains and unique identities distinguished. No parser/music coverage is claimed.`);
