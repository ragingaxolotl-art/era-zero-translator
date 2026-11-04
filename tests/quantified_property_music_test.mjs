import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal,canonicalDigest} from '../pages/engine.mjs';
import {decodeQuantifiedPropertyMidi} from '../pages/quantified_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),sounds=new Set(),drafts=[];
for(const state of [0,1,2])for(const predicateNegated of [false,true])for(const propositionNegated of [false,true]){
 const template=JSON.parse(fs.readFileSync(new URL('../pages/'+authority.resolution_files['MAT:001'],import.meta.url))).variants['assertion:1'];
 const base=await composeNamedSentence(`Exactly three lamps are physically energized [${state}].`,template),formal=structuredClone(base.formal),ir=formal.semantic_ir;
 const q=ir.nodes.find(n=>n.operator==='quantifier'),role=ir.edges.find(e=>e.from===q.node_id&&e.type==='fills_role'),scope=ir.edges.find(e=>e.to===q.node_id&&e.type==='scopes');
 const name=scope.from;q.operator='quantified_predication';role.from='bound';scope.from='p';ir.edges.find(e=>e.type==='centers').from=q.node_id;
 ir.nodes.push({node_id:'bound',kind:'quantified_reference',binder_id:q.node_id,value_type:'entity'});ir.edges.push({edge_id:'restriction',type:'restricts',from:name,to:q.node_id});
 if(predicateNegated){ir.nodes.push({node_id:'negative_property',kind:'scope_operator',operator:'negation'});scope.from='negative_property';ir.edges.push({edge_id:'negative_property',type:'scopes',from:'p',to:'negative_property'});}
 if(propositionNegated){ir.nodes.push({node_id:'negative_count',kind:'scope_operator',operator:'negation'});ir.edges.find(e=>e.type==='centers').from='negative_count';ir.edges.push({edge_id:'negative_count',type:'scopes',from:q.node_id,to:'negative_count'});}
 assert.throws(()=>midiFromFormal(formal),/opt-in/);formal.draft_quantified=true;
 const digest=await canonicalDigest(Object.fromEntries(Object.entries(ir).filter(([k])=>!['utterance_id','serialization'].includes(k))));ir.utterance_id='UTT:'+digest.slice(0,24);ir.serialization={canonical_format:'EZIR-JSON-1',content_digest:digest};drafts.push(formal);
 const bytes=midiFromFormal(formal),d=decodeQuantifiedPropertyMidi(bytes,authority.atoms,{allowDraft:true});
 assert.equal(d.value,'3');assert.equal(d.predicate.runtime_state,state);assert.equal(d.predicate_negated,predicateNegated);assert.equal(d.proposition_negated,propositionNegated);assert.equal(d.predicate.bearer.depth,0);sounds.add(Buffer.from(bytes).toString('base64'));
 const bad=structuredClone(formal);bad.semantic_ir.nodes.find(n=>n.kind==='quantified_reference').binder_id='unknown';assert.throws(()=>midiFromFormal(bad));
}
assert.equal(sounds.size,12);
console.log('PASS 12 counted-property/runtime/negation musical contrasts recover noun restriction and bound bearer from MIDI; draft scheduling requires opt-in. English admission remains pending.');

const rendered=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|begin;EraZeroRenderer.render(ir);raise 'draft admitted without opt-in';rescue EraZeroRenderer::RenderError;end;f=EraZeroRenderer.render(ir,allow_draft_quantified:true);EraZeroRenderer.decode(f,allow_draft_quantified:true);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,allow_draft_quantified:true))}})"],{cwd:new URL('..',import.meta.url),input:JSON.stringify(drafts.map(f=>f.semantic_ir)),encoding:'utf8',maxBuffer:20_000_000}));
for(const [i,r] of rendered.entries()){
 assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),r.midi);
 assert.deepEqual(midiFromFormal(drafts[i]),midiFromFormal(r.formal));
 assert.equal(r.formal.draft_quantified,true);
}
console.log('PASS 12 valid draft formal identities round-trip through opt-in Ruby rendering and decoding, with complete Ruby/browser MIDI equality; default rendering rejects.');
