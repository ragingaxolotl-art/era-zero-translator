import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeFoundationSentence,parseFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),records=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))).records;
const load=id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:({...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority});
const compose=s=>composeFoundationSentence(s,authority,records,load,{allowDraft:true});
let count=0;
for(const state of [0,1,2])for(const stem of ['Does Nora prefer tea to coffee','Does Nora want Eli to be happy','Does Nora prefer that Eli is happy rather than that Eli is tired']){
 const before=await compose(`${stem}? [${state}]`),after=await compose(`${stem} [${state}]?`),both=await compose(`${stem}? [${state}]?`);
 assert.deepEqual(before.formal,after.formal);assert.deepEqual(before.formal,both.formal);
 assert.equal(before.semantic_ir.speech_act,'question');
 const decoded=await decodeFoundationSentenceMidi(midiFromFormal(before.formal),authority.atoms,records,{allowDraft:true});
 assert.equal(decoded.speech_act,'question');assert.equal(decoded.meaning.runtime_state,state);count++;
 for(const suffix of ['.', '!'])assert.equal(parseFoundationSentence(`${stem}? [${state}]${suffix}`),null);
}
console.log(`PASS ${count} candidate preference/desire question/runtime cases preserve question contour at either punctuation position; conflicting punctuation rejected.`);
