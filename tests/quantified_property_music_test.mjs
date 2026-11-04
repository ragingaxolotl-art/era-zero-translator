import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeQuantifiedPropertyMidi} from '../pages/quantified_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),sounds=new Set();
for(const state of [0,1,2])for(const predicateNegated of [false,true])for(const propositionNegated of [false,true]){
 const template=JSON.parse(fs.readFileSync(new URL('../pages/'+authority.resolution_files['MAT:001'],import.meta.url))).variants['assertion:1'];
 const base=await composeNamedSentence(`Exactly three lamps are physically energized [${state}].`,template),formal=structuredClone(base.formal),ir=formal.semantic_ir;
 const q=ir.nodes.find(n=>n.operator==='quantifier'),role=ir.edges.find(e=>e.from===q.node_id&&e.type==='fills_role'),scope=ir.edges.find(e=>e.to===q.node_id&&e.type==='scopes');
 const name=scope.from;q.operator='quantified_predication';role.from='bound';scope.from='p';ir.edges.find(e=>e.type==='centers').from=q.node_id;
 ir.nodes.push({node_id:'bound',kind:'quantified_reference',binder_id:q.node_id,value_type:'entity'});ir.edges.push({edge_id:'restriction',type:'restricts',from:name,to:q.node_id});
 if(predicateNegated){ir.nodes.push({node_id:'negative_property',kind:'scope_operator',operator:'negation'});scope.from='negative_property';ir.edges.push({edge_id:'negative_property',type:'scopes',from:'p',to:'negative_property'});}
 if(propositionNegated){ir.nodes.push({node_id:'negative_count',kind:'scope_operator',operator:'negation'});ir.edges.find(e=>e.type==='centers').from='negative_count';ir.edges.push({edge_id:'negative_count',type:'scopes',from:q.node_id,to:'negative_count'});}
 assert.throws(()=>midiFromFormal(formal),/opt-in/);formal.draft_quantified=true;
 const bytes=midiFromFormal(formal),d=decodeQuantifiedPropertyMidi(bytes,authority.atoms,{allowDraft:true});
 assert.equal(d.value,'3');assert.equal(d.predicate.runtime_state,state);assert.equal(d.predicate_negated,predicateNegated);assert.equal(d.proposition_negated,propositionNegated);assert.equal(d.predicate.bearer.depth,0);sounds.add(Buffer.from(bytes).toString('base64'));
 const bad=structuredClone(formal);bad.semantic_ir.nodes.find(n=>n.kind==='quantified_reference').binder_id='unknown';assert.throws(()=>midiFromFormal(bad));
}
assert.equal(sounds.size,12);
console.log('PASS 12 counted-property/runtime/negation musical contrasts recover noun restriction and bound bearer from MIDI; draft scheduling requires opt-in. Canonical IR and Ruby rendering integration remain pending.');
