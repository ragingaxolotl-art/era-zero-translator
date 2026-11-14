import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeSwimmingMidi} from '../pages/swimming_decoder.mjs';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {encodeName} from '../pages/names.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),results=[];
for(const state of [0,1,2])for(const [input,actor,region] of [
 ['Eli is swimming across the river.','Eli','river'],
 ['Nora is swimming across the lake.','Nora','lake'],
 ['Eli is not swimming across the river.','Eli','river'],
 ['Is Eli swimming across the river?','Eli','river'],
 ['Eli was swimming across the river yesterday.','Eli','river'],
 ['I am swimming across the lake.','I','lake']
]){
 const r=await composeNamedSentence(input+` [${state}]`,{authority}),d=decodeSwimmingMidi(midiFromFormal(r.formal),authority.atoms);results.push(r);
 assert.equal(d.predicate,'ongoing_swimming_across_region');assert.equal(d.runtime_state,state);assert.deepEqual(d.convention_codes,[22,21,20]);
 assert.equal(d.path.relation,'across');assert.equal(d.path.phase,'ongoing');assert.equal(d.path.completion_asserted,false);assert.equal(d.meaning.arrival_asserted,false);
 assert.deepEqual(d.path.region.phonemes,(await encodeName(region)).phonemes);
 if(actor==='I')assert.deepEqual(d.actor,{kind:'deictic',role:'speaker'});else assert.deepEqual(d.actor.phonemes,(await encodeName(actor)).phonemes);
 assert.equal(d.speech_act,input.startsWith('Is ')?'question':'assertion');assert.deepEqual(d.scopes,input.includes('not')?[{operator:'negation'}]:input.includes('yesterday')?[{operator:'time',relation:'previous_day'}]:[]);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:20_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,18);
execFileSync('ruby',['-Itools/lib','-rera_zero_validation','-e',"v=EraZeroValidation;d=v.load_yaml('lexicon/compound_dictionary.yaml')['entries'];m=v.load_yaml('migrations/swimming_across_2026_11_04.yaml');old=d.select{|e|m['previous_compound_ids'].include?(e['compound_id'])};raise 'Prior meanings changed' unless old.length==54&&v.fingerprint(old)==m['before_dictionary_fingerprint']"],{cwd:root});
console.log('PASS 18 swimming-across participant/state/scope contrasts, Ruby/MIDI parity and independent region/actor recovery; all 54 prior compounds unchanged.');

const missing=structuredClone(results[0].formal);
missing.semantic_ir.nodes.find(n=>n.kind==='lexical_occurrence').compound_bindings=missing.semantic_ir.nodes.find(n=>n.kind==='lexical_occurrence').compound_bindings.filter(b=>b.slot_path.join('/')!=='s-region');
await assert.rejects(renderLexicalOccurrences(missing.semantic_ir,authority));
