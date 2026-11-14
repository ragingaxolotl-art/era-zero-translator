import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {canonicalDigest,midiFromFormal} from '../pages/engine.mjs';
import {encodeName} from '../pages/names.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),records=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))).records;
async function kind(id,label){const name=await encodeName(label);return {node_id:id,kind:'phonemic_reference',value_type:'entity',reference_mode:'nominal_class',referent_id:`nominal:class:${name.name_id}`,name};}
const base={ir_version:'1.0.0',root_clause:'main',speech_act:'assertion',discourse_constraints:{},nodes:[{node_id:'main',kind:'clause'},{node_id:'prefer',kind:'lexical_occurrence',target_type:'foundation',target_id:records[1].foundation_id,foundation_version:'1.0.0',runtime_state:{code:1}},{node_id:'holder',kind:'deictic_reference',value_type:'entity',deictic_role:'speaker',referent_id:'discourse:speaker'},await kind('tea','tea'),await kind('coffee','coffee')],edges:[{edge_id:'center',type:'centers',from:'prefer',to:'main'},...['experiencer','target','comparison_standard'].map((role,i)=>({edge_id:`role-${i}`,type:'fills_role',from:['holder','tea','coffee'][i],to:'prefer',role}))]};
async function render(ir,anchor=60){const digest=await canonicalDigest(ir);ir.utterance_id='UTT:'+digest.slice(0,24);ir.serialization={content_digest:digest};return JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rjson','-e',"x=JSON.parse(STDIN.read);puts JSON.generate(EraZeroRenderer.render(x['ir'],anchor_midi:x['anchor'],foundation_records:x['records'],allow_draft_foundations:true))"],{cwd:root,input:JSON.stringify({ir,records,anchor}),encoding:'utf8'}));}
const decode=bytes=>decodeFoundationSentenceMidi(bytes,authority.atoms,records,{allowDraft:true});
let count=0;const meanings=[];let valid;
for(const reverse of [false,true])for(const state of [0,1,2])for(const negated of [false,true]){
 const ir=structuredClone(base);ir.nodes[1].runtime_state.code=state;
 if(reverse){ir.edges[2].from='coffee';ir.edges[3].from='tea';}
 if(negated){ir.nodes.push({node_id:'neg',kind:'scope_operator',operator:'negation'});ir.edges[0].from='neg';ir.edges.push({edge_id:'scope',type:'scopes',from:'prefer',to:'neg'});}
 const formal=await render(ir),bytes=midiFromFormal(formal),d=await decode(bytes);valid=formal;
 assert.equal(d.meaning.runtime_state,state);assert.deepEqual(d.meaning.scopes,negated?[{operator:'negation'}]:[]);
 assert.equal(d.meaning.arguments.experiencer.reference.role,'speaker');
 for(const role of ['target','comparison_standard'])assert.equal(d.meaning.arguments[role].type,'kind');
 const expected=ir.nodes.find(n=>n.node_id===(reverse?'coffee':'tea')).name.phonemes;
 assert.deepEqual(d.meaning.arguments.target.reference.phonemes,expected);
 meanings.push(JSON.stringify(d.meaning));count++;
}
assert.equal(new Set(meanings).size,12);
for(const anchor of [48,72]){const f=await render(structuredClone(base),anchor);assert.equal(JSON.stringify((await decode(midiFromFormal(f))).meaning),meanings[2]);}
await assert.rejects(decodeFoundationSentenceMidi(midiFromFormal(valid),authority.atoms,records));
// A balanced but wrongly typed argument is not a valid preference sentence.
const bad=structuredClone(valid);bad.semantic_ir.edges.find(e=>e.role==='experiencer').from='tea';bad.semantic_ir.edges.find(e=>e.role==='comparison_standard').from='holder';
await assert.rejects(decode(midiFromFormal(bad)));
// A balanced extra role must not disappear from recovered meaning.
const extra=structuredClone(valid);extra.semantic_ir.edges.push({edge_id:'extra',type:'fills_role',from:'holder',to:'prefer',role:'beneficiary'});
await assert.rejects(decode(midiFromFormal(extra)));
console.log(`PASS ${count} MIDI-only preference contrasts: direction, kind arguments, negation and runtime remain distinct; wrong types and extra roles reject.`);
