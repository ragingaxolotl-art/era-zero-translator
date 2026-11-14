import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeCognitiveConjunction,validateCognitiveConjunction} from '../pages/cognitive_conjunction.mjs';
import {midiFromCognitiveConjunction} from '../pages/cognitive_conjunction_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_preview_candidates.json',import.meta.url))).records,parity=[];
const recovered=[];
for(const runtime of [0,1,2]){
 const texts=[`It is not true that Orin is curious about the map [${runtime}] and Eli understands Nora’s reasons [${2-runtime}].`,`Orin is not curious about the map [${runtime}] and Eli does not understand Nora’s reasons [${2-runtime}].`,`It is not true that Orin is not curious about the map [${runtime}] and Eli understands Nora’s reasons [${2-runtime}].`],sounds=[];
 for(const [i,text] of texts.entries()){
  const d=await composeCognitiveConjunction(text,{allowDraft:true}),bytes=await midiFromCognitiveConjunction(d,authority,records,{allowDraft:true}),r=await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,records,{allowDraft:true});
  assert.equal(!!r.scopes,i!==1);assert.equal(r.members[0].scopes.some(s=>s.operator==='negation'),i!==0);assert.equal(r.members[1].scopes.some(s=>s.operator==='negation'),i===1);assert.equal(r.members[0].runtime_state,runtime);assert.equal(r.members[1].runtime_state,2-runtime);
  parity.push({document:d,midi:Buffer.from(bytes).toString('base64')});sounds.push(parity.at(-1).midi);if(runtime===1)recovered.push(r);
 }
 assert.equal(new Set(sounds).size,3);
}
// Independent truth assignments expose the not-both versus neither contrast.
const evaluate=(meaning,a,b)=>{const values=[a,b].map((v,i)=>meaning.members[i].scopes.some(s=>s.operator==='negation')?!v:v);const all=values.every(Boolean);return meaning.scopes?!all:all;};
for(const [a,b] of [[true,true],[true,false],[false,true],[false,false]]){
 assert.equal(evaluate(recovered[0],a,b),!(a&&b));assert.equal(evaluate(recovered[1],a,b),!a&&!b);assert.equal(evaluate(recovered[2],a,b),!(!a&&b));
}
assert.notEqual(evaluate(recovered[0],true,false),evaluate(recovered[1],true,false));
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_cognitive_conjunction','-rbase64','-e',"p=JSON.parse(STDIN.read);puts JSON.generate(p['cases'].map{|c|Base64.strict_encode64(EraZeroCognitiveConjunction.midi(c['document'],p['records'],allow_draft:true))})"],{input:JSON.stringify({cases:parity,records}),encoding:'utf8'}));assert.deepEqual(ruby,parity.map(p=>p.midi));
const bad=structuredClone(parity[0].document);bad.scopes=[{operator:'negation'},{operator:'negation'}];const {content_id,content_digest,...body}=bad,digest=await canonicalDigest(body);bad.content_digest=digest;bad.content_id=`EZCOGAND:${digest.slice(0,24)}`;await assert.rejects(()=>validateCognitiveConjunction(bad,{allowDraft:true}));
console.log('PASS nine full conjunction-scope meanings with Ruby/MIDI parity; independent truth assignments distinguish not-both, neither and outer-plus-inner negation without treating runtime as truth.');
