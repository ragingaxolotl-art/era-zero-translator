import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),records=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))).records;
const load=id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:({...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority});
const compose=(s,bindings)=>composeFoundationSentence(s,authority,records,load,{allowDraft:true,...bindings?{bindings}:{}});
let count=0;
for(const state of [0,1,2])for(const [short,long] of [
 ["Nora doesn't prefer tea to coffee.",'Nora does not prefer tea to coffee.'],
 ["Nora didn’t prefer tea to coffee yesterday.",'Nora did not prefer tea to coffee yesterday.'],
 ["Doesn't Nora prefer tea to coffee?",'Does Nora not prefer tea to coffee?'],
 ["I don't want to be tired.",'I do not want to be tired.'],
 ["Nora doesn't want Eli to be happy.",'Nora does not want Eli to be happy.'],
 ["Didn't Nora want Eli to be happy?",'Did Nora not want Eli to be happy?'],
 ["Nora prefers that Eli isn't happy rather than that Eli is tired.",'Nora prefers that Eli is not happy rather than that Eli is tired.']
]){
 const a=await compose(short+` [${state}]`),b=await compose(long+` [${state}]`);assert.deepEqual(a.formal,b.formal);assert.deepEqual(midiFromFormal(a.formal),midiFromFormal(b.formal));
 const d=await decodeFoundationSentenceMidi(midiFromFormal(a.formal),authority.atoms,records,{allowDraft:true});assert.equal(d.meaning.runtime_state,state);assert.equal(d.speech_act,short.includes('?')?'question':'assertion');count++;
}
const resolved=await compose("She doesn't prefer him to Nora.",{ref0:'Ada',ref1:'Eli'}),direct=await compose('Ada does not prefer Eli to Nora.');assert.deepEqual(resolved.formal,direct.formal);
console.log(`PASS ${count} candidate contraction/runtime/negation/question paraphrases and explicit pronoun combination preserve full meaning and music.`);
