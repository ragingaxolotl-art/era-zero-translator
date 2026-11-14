import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {canonicalDigest} from '../pages/engine.mjs';
import {contextualContentReference,createContextualContent,validateContextualContent} from '../pages/contextual_content.mjs';
import {midiFromContextualContentDocument,readContextualContentMusic,CONTEXTUAL_CONTENT_KINDS} from '../pages/contextual_content_music.mjs';
import {validatePolarQuestionContent} from '../pages/question_content.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
let count=0;const parity=[],bad=[];
for(const label of ['Nora','"New York"','the map','this map','that map','I','you'])for(const kind of CONTEXTUAL_CONTENT_KINDS){
 const reference=await contextualContentReference(label),doc=await createContextualContent(kind,reference,{allowDraft:true});
 const bytes=await midiFromContextualContentDocument(doc,authority,{allowDraft:true});
 const recovered=readContextualContentMusic(bytes,authority.atoms,{allowDraft:true});
 parity.push({document:doc,midi:Buffer.from(bytes).toString('base64')});
 assert.equal(recovered.content_kind,kind);assert.equal(recovered.assertion_commitment,'none');
 if(reference.name)assert.deepEqual(recovered.anchor.phonemes,reference.name.phonemes);
 else assert.equal(recovered.anchor.role,reference.deictic_role);
 await assert.rejects(()=>validateContextualContent(doc));
 await assert.rejects(()=>midiFromContextualContentDocument(doc,authority));
 await assert.rejects(()=>validatePolarQuestionContent(doc,{allowDraft:true}));count++;
}
for(const text of ['she','three maps','the strange map','maps','this','that','swimming'])await assert.rejects(()=>contextualContentReference(text));
const source=await createContextualContent('topic',await contextualContentReference('the map'),{allowDraft:true});
for(const mutate of [d=>d.assertion_commitment='true',d=>d.answer=true,d=>d.anchor.runtime_state={code:1},d=>d.anchor.reference_mode='distal_nominal',d=>d.anchor.name.events[0].notes[0]++,d=>d.anchor.referent_id='name:wrong',d=>d.anchor.name.semantic_claim=true]){
 const d=structuredClone(source);mutate(d);
 // Rehash malicious documents: rejection must validate semantics, not only hash.
 const {content_id,content_digest,...body}=d,digest=await canonicalDigest(body);
 d.content_digest=digest;d.content_id=`EZCTX:${digest.slice(0,24)}`;
 bad.push(d);await assert.rejects(()=>validateContextualContent(d,{allowDraft:true}));
}
console.log(`PASS ${count} contextual documents through musical inverse; corrupt rehashed semantics, assertion leakage, unresolved anchors and polar-content substitution rejected.`);

const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_contextual_content','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|Base64.strict_encode64(EraZeroContextualContent.midi(d,allow_draft:true))})"],{input:JSON.stringify(parity.map(p=>p.document)),encoding:'utf8'}));
assert.deepEqual(ruby,parity.map(p=>p.midi));
const rejected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_contextual_content','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|begin;EraZeroContextualContent.validate!(d,allow_draft:true);false;rescue StandardError;true;end})"],{input:JSON.stringify(bad),encoding:'utf8'}));
assert.deepEqual(rejected,bad.map(()=>true));
console.log('PASS Ruby byte-identical MIDI for all contextual documents and rejection of rehashed semantic corruption.');
