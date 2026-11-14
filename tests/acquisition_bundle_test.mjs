import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeLearnedWhether} from '../pages/learned_whether.mjs';
import {createAcquisitionBundle as create,verifyAcquisitionBundle as verify,renderAcquisitionResult} from '../pages/acquisition_bundle.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url))),authority=read('pages/data/index.json'),records=read('pages/data/foundation_preview_candidates.json').records;
const load=id=>({...read('pages/'+authority.resolution_files[id]).variants['assertion:1'],authority});
let baseline;
for(const state of [0,1,2])for(const text of ['Nora learned whether Eli is not conscious.',"Didn't Nora learn whether Eli was conscious?",'Today, Nora learned whether Eli was conscious yesterday.']){
 const result=await composeLearnedWhether(text+` [${state}]`,authority,records,load,{allowDraft:true});
 assert.deepEqual(await renderAcquisitionResult(result.acquisition,authority,{allowDraft:true}),result.result_formal);
 // The exported audio is regenerated even if an unrelated supplied formal is bad.
 result.result_formal.performance.lexical_events=[];
 const bundle=await create(result,authority,{allowDraft:true});assert.equal((await verify(bundle,authority,{allowDraft:true})).grammar_status,'draft');baseline=bundle;
}
await assert.rejects(()=>verify(baseline,authority));
for(const edit of [b=>{b.status='approved'},b=>{b.acquisition.phase_contract.after='holds'},b=>{b.acquisition.transition_runtime.code=0},b=>{b.authority_digest='other'},b=>{b.midi_sha256='00'},b=>{b.formal={}}]){
 const b=structuredClone(baseline);edit(b);delete b.bundle_digest;b.bundle_digest=await canonicalDigest(b);await assert.rejects(()=>verify(b,authority,{allowDraft:true}));
}
console.log('PASS nine acquisition exports regenerate exact result formals and music, preserve draft provenance, ignore untrusted event lists and reject rehashed meaning/audio/authority/provenance tampering.');
