import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeFoundationSentence,foundationPronounPlan} from '../pages/foundation_sentences.mjs';
import {composeLearnedWhether,learnedWhetherPronounPlan} from '../pages/learned_whether.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {midiFromKnowledgeAcquisition} from '../pages/knowledge_acquisition_music.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url))),authority=read('pages/data/index.json'),records=read('pages/data/foundation_preview_candidates.json').records;
const load=id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:{...read('pages/'+authority.resolution_files[id]).variants['assertion:1'],authority};
const one=referent=>({referent,number:'singular'});let count=0;
for(const state of [0,1,2])for(const [pronoun,named,bindings] of [
 ['They prefer tea to coffee.','Nora prefers tea to coffee.',{ref0:one('Nora')}],
 ['They want Eli to swim.','Nora wants Eli to swim.',{ref0:one('Nora')}],
 ['They know whether she is conscious.','Nora knows whether Eli is conscious.',{ref0:one('Nora'),ref1:'Eli'}],
 ['Nora prefers them to Eli.','Nora prefers Orin to Eli.',{ref0:one('Orin')}]
]){
 assert(foundationPronounPlan(pronoun,{allowCognitive:true}));
 const a=await composeFoundationSentence(`${pronoun} [${state}]`,authority,records,load,{allowDraft:true,allowCognitive:true,bindings}),b=await composeFoundationSentence(`${named} [${state}]`,authority,records,load,{allowDraft:true,allowCognitive:true});
 assert.deepEqual(a.semantic_ir,b.semantic_ir);assert.deepEqual(midiFromFormal(a.formal),midiFromFormal(b.formal));count++;
}
for(const state of [0,1,2]){
 const phrase=`They learned whether he is conscious [${state}].`;assert(learnedWhetherPronounPlan(phrase));
 const a=await composeLearnedWhether(phrase,authority,records,load,{allowDraft:true,bindings:{ref0:one('Nora'),ref1:'Eli'}}),b=await composeLearnedWhether(`Nora learned whether Eli is conscious [${state}].`,authority,records,load,{allowDraft:true});
 assert.deepEqual(a.acquisition,b.acquisition);assert.deepEqual(await midiFromKnowledgeAcquisition(a.acquisition,a.result_formal,authority,{allowDraft:true}),await midiFromKnowledgeAcquisition(b.acquisition,b.result_formal,authority,{allowDraft:true}));count++;
}
for(const value of ['Nora',{referent:'Nora',number:'plural'},{referent:'Nora',number:'singular',gender:'female'}])await assert.rejects(()=>composeFoundationSentence('They prefer tea to coffee.',authority,records,load,{allowDraft:true,bindings:{ref0:value}}),e=>e.code==='pronoun_referents_required');
await assert.rejects(()=>composeLearnedWhether('They learned whether Nora is conscious.',authority,records,load,{allowDraft:true,bindings:{ref0:{referent:'Eli',number:'plural'}}}),e=>e.code==='pronoun_referents_required');
console.log(`PASS ${count} neutral cognitive reference cases: named-equivalent full meanings/music, explicit number, no gender field or plural-to-singular coercion.`);
