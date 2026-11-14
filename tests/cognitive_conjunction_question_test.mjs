import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeCognitiveConjunction,cognitiveConjunctionPlan,createCognitiveConjunction,validateCognitiveConjunction} from '../pages/cognitive_conjunction.mjs';
import {midiFromCognitiveConjunction} from '../pages/cognitive_conjunction_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_preview_candidates.json',import.meta.url))).records,parity=[];
const pairs=[['Is it true that ',''],['Is it not true that ','It is not true that '],['Is it possible that ','It is possible that '],['Is it not possible that ','It is not possible that '],['Is it possible that it is not true that ','It is possible that it is not true that ']];
for(const runtime of [0,1,2])for(const [question,assertion] of pairs){
 const content=`Orin is not curious about the map [${runtime}] and Eli came to understand what Nora said [${2-runtime}]`;
 const d=await composeCognitiveConjunction(question+content+'?',{allowDraft:true}),a=await composeCognitiveConjunction(assertion+content+'.',{allowDraft:true});
 assert.equal(d.speech_act,'question');assert.deepEqual(d.members,a.members);assert.deepEqual(d.scopes,a.scopes);assert.notEqual(d.content_id,a.content_id);
 const bytes=await midiFromCognitiveConjunction(d,authority,records,{allowDraft:true}),asserted=await midiFromCognitiveConjunction(a,authority,records,{allowDraft:true});
 const r=await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,records,{allowDraft:true}),ar=await decodeSupportedMeaningWithDrafts(asserted,authority.atoms,records,{allowDraft:true});
 assert.equal(r.speech_act,'question');assert.deepEqual(r.members,ar.members);assert.deepEqual(r.scopes,ar.scopes);assert.notDeepEqual(bytes,asserted);
 assert.deepEqual(notesFromMidi(bytes).notes.slice(0,-2),notesFromMidi(asserted).notes.slice(0,-2));
 parity.push({document:d,midi:Buffer.from(bytes).toString('base64')});
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_cognitive_conjunction','-rbase64','-e',"p=JSON.parse(STDIN.read);puts JSON.generate(p['cases'].map{|c|Base64.strict_encode64(EraZeroCognitiveConjunction.midi(c['document'],p['records'],allow_draft:true))})"],{input:JSON.stringify({cases:parity,records}),encoding:'utf8'}));assert.deepEqual(ruby,parity.map(p=>p.midi));
const bad=structuredClone(parity[0].document);bad.speech_act='command';const {content_digest,content_id,...body}=bad,digest=await canonicalDigest(body);bad.content_digest=digest;bad.content_id=`EZCOGAND:${digest.slice(0,24)}`;await assert.rejects(()=>validateCognitiveConjunction(bad,{allowDraft:true}));
const member=structuredClone(parity[0].document.members[0]);member.speech_act='question';await assert.rejects(()=>createCognitiveConjunction([member,parity[0].document.members[1]],{allowDraft:true,speechAct:'question'}));
for(const text of ['Is it true that Orin is curious about the map and Eli understands Nora.','Orin is curious about the map and Eli understands Nora?','Is it true that Orin is curious about the map? and Eli understands Nora?'])assert.equal(cognitiveConjunctionPlan(text),null);
console.log('PASS 15 whole-message questions with independent member meaning/scope recovery, assertion contrasts, unchanged payload notes and Ruby regeneration; command and embedded-question misuse reject.');
