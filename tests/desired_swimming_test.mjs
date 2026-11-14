import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),records=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))).records;
const load=id=>authority.compound_plans[id]?{authority}:{...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority};
const compose=s=>composeFoundationSentence(s,authority,records,load,{allowDraft:true}),results=[];
for(const outer of [0,1,2])for(const inner of [0,1,2])for(const negative of [false,true]){
 const r=await compose(`Nora wants ${negative?'not ':''}to swim [${inner}] [${outer}].`);results.push(r);
 const d=await decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true}),content=d.meaning.arguments.content;
 assert.equal(d.meaning.runtime_state,outer);assert.equal(content.content_status,'intensional');assert.equal(content.proposition.runtime_state,inner);
 assert.equal(content.proposition.arguments.actor.reference.binding,'parent_desire_experiencer');assert.deepEqual(content.proposition.predicate.convention_codes,[21,20]);
 assert.equal(content.proposition.meaning.medium,'water');assert.equal(content.proposition.meaning.arrival_asserted,false);
 assert.deepEqual(content.proposition.scopes,[...negative?[{operator:'negation'}]:[],{operator:'aspect',aspect:'bounded'}]);
}
for(const s of ['Nora wants to be swimming.','Nora wants Eli to swim.','Does Nora want to swim?','Nora does not want to swim.']){
 const r=await compose(s);results.push(r);await decodeFoundationSentenceMidi(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true});
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};puts JSON.generate(x['irs'].map{|ir|f=EraZeroRenderer.render(ir,**o);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,**o))}})"],{cwd:root,input:JSON.stringify({irs:results.map(r=>r.semantic_ir),records}),encoding:'utf8',maxBuffer:30_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.slice(0,18).map(r=>r.midi)).size,18);
await assert.rejects(()=>compose('Nora wants to swim across the river.'));
console.log('PASS 22 desired swimming cases: bound/explicit actors, independent runtime, inner/outer negation and questions; Ruby parity and MIDI-only meaning recovery.');
const {validateFoundationIR}=await import('../pages/foundation_ir.mjs');
const bad=structuredClone(results[0].semantic_ir);bad.nodes.find(n=>n.target_id==='CMP:1e2ec87e1feff0da19aadc3b').compound_bindings[0].slot_path=['s-actor'];
await assert.rejects(validateFoundationIR(bad,records,{allowDraft:true}));
