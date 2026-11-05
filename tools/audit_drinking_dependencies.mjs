import fs from 'node:fs';
import assert from 'node:assert/strict';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const thirst=authority.compounds.find(c=>c.conventional_meaning?.sense_key==='felt_thirst');
const need=authority.compounds.find(c=>c.conventional_meaning?.sense_key==='felt_bodily_need');
const entries=authority.compounds.filter(c=>['completed_physical_entry','ongoing_physical_entry'].includes(c.conventional_meaning?.sense_key));
assert.equal(authority.atoms.length,324);assert(thirst&&need);assert.equal(entries.length,2);
assert.match(thirst.invariant_definition,/does not.*assert drinking/);
const relevantRoots=['MAT:000','MAT:010','MOV:120','MOV:121'].map(id=>{const a=authority.atoms.find(a=>a.canonical_id===id);assert(a);return {id,title:a.title,definition:a.core_definition};});
const report={scope:'Dependency audit for ordinary literal drinking, not approval of a new root or compound.',root_count:authority.atoms.length,unchanged_roots:true,reusable: [...[thirst,need,...entries].map(c=>({id:c.compound_id,version:c.definition_version,title:c.display_title,definition:c.invariant_definition})),...relevantRoots],
 rejected_substitutions:[{candidate:thirst.compound_id,reason:'A felt demand for water does not assert drinking; drinking need not encode felt thirst.'},{candidate:need.compound_id,reason:'Replenishment demand is a feeling, not consumption.'},{candidate:'physical_entry',reason:'Material entering a region does not alone distinguish drinking from pouring, accidental entry or other routes.'},{candidate:'MAT:010',reason:'An external material object reference does not alone supply liquid kind, consumption route or drinker identity.'}],
 required_contract:['Bind drinker and consumed material independently, without inferring a beverage from a name.','Specify literal drinking as an action category; do not infer consciousness, thirst, enjoyment, ownership or benefit.','Separate ongoing activity, completed quantity/event and habitual readings; do not infer consumption of an entire named amount.','Keep consumed-material reference type explicit: kind, contextual portion or bounded quantity.','Preserve desired versus actual drinking and independent scope/runtime.'],
 implementation_order:['Define and review the literal drinking action contract and participant bindings against counterexamples.','Audit material/portion typing and consumption-route convention; reuse material and motion structures only where their commitments fit.','Build a gated reusable meaning, renderer and inverse together; do not allocate root families to fill inventory slots.','Integrate ordinary wording and object-desire clarification without silently selecting drinking.','Require full-message independent rendering and blind audio contrasts before updating acceptance evidence.'],
 completion_proven:false,new_vocabulary_approved:false};
fs.writeFileSync(new URL('../reports/drinking_dependency_audit.json',import.meta.url),JSON.stringify(report,null,2)+'\n');
console.log('PASS drinking dependency audit pins thirst/need and two entry compounds; 324 roots unchanged, consumption/action gaps remain explicit.');
