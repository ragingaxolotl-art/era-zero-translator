import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {validateFoundationIR} from '../pages/foundation_ir.mjs';
import {canonicalDigest,midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationMusicMidi} from '../pages/foundation_decoder.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url)));
const data=read('pages/data/index.json'),old=read('reviews/foundation_extension_candidates.json').records,cognitive=read('reviews/cognitive_foundation_candidates.json').records,records=[...old,...cognitive];
const load=id=>({...read('pages/'+data.resolution_files[id]).variants['assertion:1'],authority:data});
const fixtures=[];
for(const state of [0,1,2]){
 const base=await composeFoundationSentence(`Nora wants Eli to be conscious [${state}].`,data,old,load,{allowDraft:true});
 const ir=structuredClone(base.semantic_ir),occ=ir.nodes.find(n=>n.target_type==='foundation'),content=ir.nodes.find(n=>n.clause_type==='content');
 occ.target_id=cognitive[0].foundation_id;content.value_type='question';content.question_kind='polar';
 delete ir.serialization;delete ir.utterance_id;const digest=await canonicalDigest(ir);ir.utterance_id=`UTT:${digest.slice(0,24)}`;ir.serialization={canonical_format:'EZIR-JSON-1',content_digest:digest};
 await validateFoundationIR(ir,records,{allowDraft:true});fixtures.push(ir);
}
const malformed=[];
for(const edit of [ir=>{ir.nodes.find(n=>n.clause_type==='content').value_type='proposition'},ir=>{delete ir.nodes.find(n=>n.clause_type==='content').question_kind},ir=>{ir.nodes.find(n=>n.clause_type==='content').question_kind='who'},ir=>{ir.nodes.find(n=>n.target_type==='foundation').target_id=old[0].foundation_id},ir=>{const c=ir.nodes.find(n=>n.clause_type==='content');ir.edges.push({edge_id:'leak',type:'coordinates',from:c.node_id,to:ir.root_clause})}]){
 const ir=structuredClone(fixtures[0]);edit(ir);await assert.rejects(()=>validateFoundationIR(ir,records,{allowDraft:true}));malformed.push(ir);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"x=JSON.parse(STDIN.read);puts JSON.generate({valid:x['valid'].map{|ir|f=EraZeroRenderer.render(ir,foundation_records:x['records'],allow_draft_foundations:true);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,foundation_records:x['records'],allow_draft_foundations:true))}},invalid:x['invalid'].map{|ir|begin;EraZeroFoundationIR.validate!(ir,x['records'],allow_draft:true);false;rescue ArgumentError;true;end}})"],{cwd:new URL('..',import.meta.url),input:JSON.stringify({valid:fixtures,invalid:malformed,records}),encoding:'utf8',maxBuffer:5_000_000}));
assert.deepEqual(ruby.invalid,malformed.map(()=>true));
for(const {formal,midi} of ruby.valid){
 const bytes=midiFromFormal(formal);assert.equal(Buffer.from(bytes).toString('base64'),midi);
 const observed=await decodeFoundationMusicMidi(bytes,data.atoms,records,{allowDraft:true,allowDraftQuestionContent:true}),flat=observed.tokens;
 assert.equal(flat.filter(n=>n.marker==='polar_content_open').length,1);assert.equal(flat.filter(n=>n.marker==='proposition_content_open').length,0);
 assert.equal(flat.find(n=>n.kind==='foundation').foundation_id,cognitive[0].foundation_id);
 await assert.rejects(()=>decodeFoundationMusicMidi(bytes,data.atoms,records,{allowDraft:true}));
}
console.log('PASS typed question arguments across runtime 0/1/2, five invalid scope/type cases with Ruby parity, and byte-identical bound cognitive MIDI.');
