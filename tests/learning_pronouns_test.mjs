import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeLearnedWhether as compose,learnedWhetherPronounPlan as plan} from '../pages/learned_whether.mjs';
import {midiFromKnowledgeAcquisition as midi} from '../pages/knowledge_acquisition_music.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url))),data=read('pages/data/index.json'),records=read('pages/data/foundation_preview_candidates.json').records;
const load=id=>({...read('pages/'+data.resolution_files[id]).variants['assertion:1'],authority:data});
for(const state of [0,1,2])for(const negative of [false,true]){
 const input=`She ${negative?'did not learn':'learned'} whether he was conscious [${state}].`,named=`Nora ${negative?'did not learn':'learned'} whether Eli was conscious [${state}].`;
 const p=plan(input);assert.deepEqual(p.occurrences.map(o=>input.slice(o.start,o.end)),['She','he']);
 for(const bindings of [undefined,{ref0:'Nora'},{ref0:'Nora',ref1:'he'},{ref0:'Nora',ref1:'Eli',extra:'Orin'}])await assert.rejects(()=>compose(input,data,records,load,{allowDraft:true,bindings}),e=>e.code==='pronoun_referents_required');
 const chosen={ref0:'Nora',ref1:'Eli'},pending=compose(input,data,records,load,{allowDraft:true,bindings:chosen});chosen.ref1='Orin';
 const resolved=await pending,explicit=await compose(named,data,records,load,{allowDraft:true});assert.deepEqual(resolved.acquisition,explicit.acquisition);assert.deepEqual(resolved.result_formal,explicit.result_formal);assert.equal(resolved.source_input,input);assert.equal(resolved.resolved_input,named);
 assert.deepEqual(await midi(resolved.acquisition,resolved.result_formal,data,{allowDraft:true}),await midi(explicit.acquisition,explicit.result_formal,data,{allowDraft:true}));
}
assert.equal(plan('"She" learned whether "He" was conscious.'),null);
console.log('PASS six learning pronoun/state/scope cases: explicit identities, immutable binding snapshots, full acquisition/formal/MIDI equivalence and quoted-label preservation.');
