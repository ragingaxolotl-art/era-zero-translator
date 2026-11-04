import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),records=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))).records;
const load=id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:({...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority});
const compose=s=>composeFoundationSentence(s,authority,records,load,{allowDraft:true});
let count=0;
for(const pronoun of ['She','He','It','They','We','Her','Him','Them','Us','Herself','Themselves','This','Those','Mine','Yours']){
 for(const text of [`${pronoun} prefers tea to coffee.`,`Nora prefers ${pronoun} to tea.`,`Nora prefers tea to ${pronoun}.`]){
  await assert.rejects(compose(text),e=>e.code==='pronoun_referents_required',text);count++;
 }
}
for(const text of ['Nora prefers her to him.','Nora prefers herself to tea.','Nora wants She to be happy.'])await assert.rejects(compose(text),e=>e.code==='pronoun_referents_required'||/Unsupported|complete|supported|Specify the desired proposition/.test(e.message));
for(const state of [0,1,2]){
 const r=await compose(`"She" prefers tea to coffee [${state}].`);
 const d=await decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true});
 assert.equal(d.meaning.runtime_state,state);assert(r.semantic_ir.nodes.some(n=>n.kind==='phonemic_reference'&&n.name.normalized_label==='she'));
 const speaker=await compose(`Nora prefers me to you [${state}].`);
 assert(speaker.semantic_ir.nodes.some(n=>n.kind==='deictic_reference'&&n.deictic_role==='speaker'));
 assert(speaker.semantic_ir.nodes.some(n=>n.kind==='deictic_reference'&&n.deictic_role==='addressee'));
}
console.log(`PASS ${count} unresolved pronoun role cases rejected; explicit quoted labels and speaker/addressee references preserved across runtime states.`);
