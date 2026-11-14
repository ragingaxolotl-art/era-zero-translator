import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const root=new URL('..',import.meta.url),index=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const cases=[['Nora is repairing exactly three radios.','exact','3','radio','target'],['Nora is repairing at least 4 radios.','at_least','4','radio','target'],['Nora is repairing at most 2 radios [2].','at_most','2','radio','target'],['Exactly three robots are repairing the radio.','exact','3','robot','actor'],['Exactly three children are conscious.','exact','3','child','bearer'],['It is possible that Nora is repairing exactly three radios.','exact','3','radio','target']];
const results=[];
for(const [input,mode,count,head,role] of cases){
 const parsed=parseNamedSentence(input);assert.ok(parsed,input);
 const template=JSON.parse(fs.readFileSync(new URL('pages/'+index.resolution_files[parsed.predicate],root))).variants['assertion:1'];
 const result=await composeNamedSentence(input,template),ir=result.semantic_ir;
 const quantified=ir.nodes.find(n=>n.operator==='quantifier'),reference=ir.nodes.find(n=>n.reference_mode==='nominal_class');
 assert.equal(quantified.quantifier,mode);assert.equal(quantified.value,count);assert.equal(reference.name.normalized_label,head);
 assert(ir.edges.some(e=>e.type==='scopes'&&e.from===reference.node_id&&e.to===quantified.node_id));
 assert(ir.edges.some(e=>e.type==='fills_role'&&e.from===quantified.node_id&&e.role===role));
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e','f=EraZeroRenderer.render(JSON.parse(STDIN.read));puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})'],{cwd:root,input:JSON.stringify(ir),encoding:'utf8'}));
 assert.deepEqual(result.formal,ruby.formal);assert.deepEqual(Buffer.from(midiFromFormal(result.formal)),Buffer.from(ruby.midi,'base64'));
 const events=scheduledLexicalEvents(result.formal);assert.equal(events.filter(e=>e.kind==='phonemic_label'&&e.label===head).length,1);
 assert(events.some(e=>e.marker===`quantifier_${mode}_open`));assert(events.some(e=>e.reference_mode==='nominal_class'));
 assert.equal(ir.nodes.find(n=>n.kind==='lexical_occurrence').runtime_state.code,input.includes('[2]')?2:1);
 results.push(result);
}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,6);
for(const input of ['Nora is not repairing exactly three radios.','Exactly three robots are repairing exactly two radios.','Nora is repairing exactly three broken radios.','Nora loves exactly three radios.'])assert.equal(parseNamedSentence(input),null,input);
console.log('Counted noun phrases preserve quantifier, cardinality, noun label and participant role without repeating the predicate; Ruby/browser parity verified.');

assert.equal(scheduledLexicalEvents(results.at(-1).formal)[0].marker,'modality_possible_open');
assert.equal(scheduledLexicalEvents(results.at(-1).formal).at(-1).marker,'modality_possible_close');
