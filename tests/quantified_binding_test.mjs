import {execFileSync} from 'node:child_process';
import assert from 'node:assert/strict';
import {validateQuantifiedBindings as validate} from '../pages/quantified_binding.mjs';
const fixture=()=>({nodes:[
 {node_id:'q',kind:'scope_operator',operator:'quantified_predication',quantifier:'exact',value:'3'},
 {node_id:'class',kind:'phonemic_reference',value_type:'entity',reference_mode:'nominal_class'},
 {node_id:'x',kind:'quantified_reference',binder_id:'q',value_type:'entity'},
 {node_id:'neg',kind:'scope_operator',operator:'negation'},
 {node_id:'p',kind:'lexical_occurrence',target_type:'atom',target_id:'MAT:001',runtime_state:{code:1}}
],edges:[{type:'restricts',from:'class',to:'q'},{type:'scopes',from:'neg',to:'q'},{type:'scopes',from:'p',to:'neg'},{type:'fills_role',from:'x',to:'p',role:'bearer'}]});
assert.deepEqual(validate(fixture()),{profile:'EZCOUNT-BIND-1',binder_count:1,reference_count:1});
// Bound identity follows the semantic graph, not spelling or a hard-coded role.
for(const role of ['bearer','actor','target']){const f=fixture();f.edges.at(-1).role=role;assert.equal(validate(f).binder_count,1);}
const compound=fixture();compound.edges.pop();compound.nodes.at(-1).compound_bindings=[{slot_path:['h','s-actor'],argument_id:'x'}];assert.equal(validate(compound).reference_count,1);
// Nested binders retain separate identities. An outer variable may be used in
// the inner predicate, but the inner variable may not escape to the outer one.
const nested=fixture();nested.nodes.push({node_id:'q2',kind:'scope_operator',operator:'quantified_predication',quantifier:'at_least',value:'2'},{node_id:'class2',kind:'phonemic_reference',reference_mode:'nominal_class',value_type:'entity'},{node_id:'y',kind:'quantified_reference',binder_id:'q2',value_type:'entity'},{node_id:'p2',kind:'lexical_occurrence'},{node_id:'both',kind:'coordination',operator:'all_of'});
nested.edges.find(e=>e.to==='q'&&e.type==='scopes').from='both';nested.edges.push({type:'member_of',from:'neg',to:'both'},{type:'member_of',from:'q2',to:'both'},{type:'restricts',from:'class2',to:'q2'},{type:'scopes',from:'p2',to:'q2'},{type:'fills_role',from:'y',to:'p2',role:'target'},{type:'fills_role',from:'x',to:'p2',role:'actor'});assert.equal(validate(nested).binder_count,2);
const escaped=structuredClone(nested);escaped.edges.push({type:'fills_role',from:'y',to:'p',role:'actor'});assert.throws(()=>validate(escaped));
const corruptions=[
 f=>f.nodes.find(n=>n.node_id==='x').binder_id='missing',
 f=>f.nodes.find(n=>n.node_id==='x').value_type='event',
 f=>f.nodes.find(n=>n.node_id==='x').runtime_state={code:0},
 f=>f.nodes.find(n=>n.node_id==='class').reference_mode='definite_nominal',
 f=>f.edges.splice(0,1),f=>f.edges.push({...f.edges[0]}),
 f=>f.nodes.push({...f.nodes[0]}),f=>f.nodes[0].value='03',
 f=>f.edges.push({type:'scopes',from:'q',to:'p'}),
 f=>{f.nodes.push({node_id:'outside',kind:'lexical_occurrence'});f.edges.push({type:'fills_role',from:'x',to:'outside',role:'bearer'});},
 f=>{f.nodes.push({node_id:'outside',kind:'clause'});f.edges.push({type:'centers',from:'p',to:'outside'});},
 f=>f.edges.pop(),f=>f.edges.push({type:'corefers_with',from:'x',to:'class'})
];
const cases=[fixture(),compound,nested,escaped];
for(const corrupt of corruptions){const f=fixture();corrupt(f);assert.throws(()=>validate(f));cases.push(f);}
console.log('PASS draft counted-predicate binding: nominal restriction, scoped shared identity, compound argument, nested binding and 14 capture/escape/malformed rejections. Rendering remains unimplemented.');

// Node IDs and serialization order cannot carry hidden binding meaning.
const renamed=cases.map(ir=>{
 const copy=structuredClone(ir),names=new Map(copy.nodes.map((n,i)=>[n.node_id,`renamed_${i}`]));
 for(const node of copy.nodes){node.node_id=names.get(node.node_id);if(node.binder_id&&names.has(node.binder_id))node.binder_id=names.get(node.binder_id);for(const b of node.compound_bindings||[])b.argument_id=names.get(b.argument_id)||b.argument_id;}
 for(const edge of copy.edges){edge.from=names.get(edge.from);edge.to=names.get(edge.to);}
 copy.nodes.reverse();copy.edges.reverse();return copy;
});
const outcome=ir=>{try{return {valid:true,result:validate(ir)}}catch{return {valid:false}}};
assert.deepEqual(renamed.map(outcome),cases.map(outcome));cases.push(...renamed);
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_quantified_binding','-rjson','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|begin;{valid:true,result:EraZeroQuantifiedBinding.validate!(ir)};rescue ArgumentError;{valid:false};end})"],{cwd:new URL('..',import.meta.url),input:JSON.stringify(cases),encoding:'utf8'}));
const js=cases.map(ir=>{try{return {valid:true,result:validate(ir)}}catch{return {valid:false}}});
assert.deepEqual(ruby,js);
console.log(`PASS Ruby/JavaScript binding-validation parity for ${cases.length} valid and malformed graphs.`);
