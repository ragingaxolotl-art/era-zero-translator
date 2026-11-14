import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodePropertyComparisonMidi} from '../pages/property_comparison_decoder.mjs';
import {decodeRunningMidi} from '../pages/running_decoder.mjs';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {nominalMarker} from '../pages/references.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),results=[];
const load=id=>authority.compound_plans[id]?{authority}:{...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority};
for(const state of [0,1,2])for(const [a,b] of [['This','that'],['That','this'],['The','this'],['This','the']]){
 const input=`${a} lamp has a higher luminance than ${b} lamp. [${state}]`,r=await composeNamedSentence(input,load(parseNamedSentence(input).predicate));results.push(r);
 const d=decodePropertyComparisonMidi(midiFromFormal(r.formal)),mode=x=>({this:'proximal_nominal',that:'distal_nominal',the:'definite_nominal'}[x.toLowerCase()]);
 assert.equal(d.participants.bearer.reference_mode,mode(a));assert.equal(d.participants.comparison_standard.reference_mode,mode(b));
 assert.deepEqual(d.participants.bearer.phonemes,d.participants.comparison_standard.phonemes);assert.equal(d.runtime_state,state);
 assert.equal(d.dimension,'luminance');assert.equal(d.relation,'greater_than');
 const refs=r.semantic_ir.nodes.filter(n=>n.kind==='phonemic_reference');assert.notEqual(refs[0].referent_id,refs[1].referent_id);assert(refs.every(n=>n.name.normalized_label==='lamp'));
}
for(const state of [0,1,2])for(const text of ['This robot is running toward that gate.','That robot is running toward this gate.','This robot ran to that gate.','Run to that gate.']){
 const r=await composeNamedSentence(text+` [${state}]`,{authority});results.push(r);const d=decodeRunningMidi(midiFromFormal(r.formal),authority.atoms);
 assert.equal(d.runtime_state,state);assert.equal(d.destination.reference_mode,text.includes('this gate')?'proximal_nominal':'distal_nominal');
 if(text.startsWith('Run'))assert.deepEqual(d.actor,{kind:'deictic',role:'addressee'});else assert.equal(d.actor.reference_mode,text.startsWith('This')?'proximal_nominal':'distal_nominal');
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:40_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,results.length);
for(const bad of ['This robots is running.','These robots are running.','That hot lamp is conscious.','This clock-tower is conscious.'])assert.equal(parseNamedSentence(bad),null,bad);
const quoted=await composeNamedSentence('"This lamp" is running.',{authority});assert(!quoted.semantic_ir.nodes.some(n=>n.reference_mode));
const corrupt=structuredClone(results[12].semantic_ir);corrupt.nodes.find(n=>n.reference_mode==='proximal_nominal').reference_mode='distal_nominal';
await assert.rejects(renderLexicalOccurrences(corrupt,authority));
const rejected=execFileSync('ruby',['-Itools/lib','-rera_zero_semantic_validation','-e',"puts EraZeroSemanticValidation.validate(JSON.parse(STDIN.read)).include?('invalid_nominal_reference')"],{cwd:root,input:JSON.stringify(corrupt),encoding:'utf8'}).trim();assert.equal(rejected,'true');
const paths=['definite_nominal','nominal_class','proximal_nominal','distal_nominal'].map(reference_mode=>nominalMarker({node_id:'r',reference_mode},'middle').address_relative_semitones);
assert.equal(new Set(paths.map(JSON.stringify)).size,4);
assert.deepEqual(paths.slice(0,2),[[0,12,2,0],[0,12,3,0]]);
console.log(`PASS ${results.length} demonstrative reference/state/comparison/journey cases with independent recovery and Ruby formal/MIDI parity; noun sounds and previous reference markers preserved; mismatched identity rejected.`);
