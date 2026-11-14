import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal,canonicalDigest} from '../pages/engine.mjs';
import {decodeRunningMidi} from '../pages/running_decoder.mjs';
import {strictSemanticReader} from '../pages/strict_semantic_reader.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),results=[];
const time=relation=>({operator:'time',relation}),possible={operator:'modality',mode:'possible'},necessary={operator:'modality',mode:'necessary'},neg={operator:'negation'};
const cases=[
 ['It is possible that Nora ran to the gate.',[possible,time('before_speech')]],
 ['It is necessary that Nora ran to the gate.',[necessary,time('before_speech')]],
 ['It is not possible that Nora ran to the gate.',[neg,possible,time('before_speech')]],
 ['It is possible that Nora did not run to the gate.',[possible,time('before_speech'),neg]],
 ['It is not the case that Nora ran to the gate.',[neg,time('before_speech')]],
 ['It is not the case that Nora did not run to the gate.',[neg,time('before_speech'),neg]],
 ['It is possible that Nora ran to the gate yesterday.',[possible,time('previous_day')]],
 ['It is possible that Nora ran to the gate today.',[possible,time('current_day'),time('before_speech')]],
 ['It is possible that Nora did not run to the gate yesterday.',[possible,time('previous_day'),neg]],
 ['It is not the case that it is possible that Nora ran to the gate yesterday.',[neg,possible,time('previous_day')]],
 ['It is possible that it is not the case that Nora ran to the gate.',[possible,neg,time('before_speech')]],
 ['It is necessary that it is possible that Nora ran to the gate.',[necessary,possible,time('before_speech')]],
 ['With 62.5% confidence, it is possible that Nora ran to the gate.',[{...possible,strength:'0.625'},time('before_speech')]]
];
for(const state of [0,1,2])for(const [text,scopes] of cases){
 const r=await composeNamedSentence(text+` [${state}]`,{authority}),d=decodeRunningMidi(midiFromFormal(r.formal),authority.atoms);results.push(r);
 assert.deepEqual(d.scopes,scopes);assert.equal(d.runtime_state,state);assert.equal(d.predicate,'completed_destination_running');
 assert.deepEqual(d.actor.phonemes,['N','AO','R','AE']);assert.equal(d.destination.reference_mode,'definite_nominal');
 const ir=r.semantic_ir,times=ir.edges.filter(e=>e.type==='time_relation');assert.equal(times.length,scopes.filter(s=>s.operator==='time').length);assert(times.every(e=>e.to!==ir.root_clause));
 assert(!ir.nodes.some(n=>n.temporalClause||n.operator==='temporalClause'));
}
// The same construction works for existing atomic predicates, not just running.
for(const [text,base,scopes] of [
 ['It is possible that Nora cared for Eli.','Nora cared for Eli.',[possible,time('before_speech')]],
 ['It is possible that Nora restored Eli.','Nora restored Eli.',[possible,time('before_speech')]],
 ['It is possible that Pip will care for Ada tomorrow.','Pip will care for Ada tomorrow.',[possible,time('next_day')]],
 ['It is possible that Nora cared for Eli yesterday.','Nora cared for Eli yesterday.',[possible,time('previous_day')]],
 ['It is not the case that Orin was conscious yesterday.','Orin was conscious yesterday.',[neg,time('previous_day')]]
]){
 const target=parseNamedSentence(base).predicate,template=JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[target],root))).variants['assertion:1'];
 const options=parseNamedSentence(text).requiredInterpretation?{interpretation:'future_assertion'}:{};
 if(options.interpretation)await assert.rejects(()=>composeNamedSentence(text,{...template,authority}),e=>e.code==='future_interpretation_required');
 const r=await composeNamedSentence(text,{...template,authority},options);results.push(r);
 const reader=strictSemanticReader(midiFromFormal(r.formal),authority.atoms,'Bad time scope');assert.deepEqual(reader.unwrapScopes(n=>n.kind==='root').scopes,scopes);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:50_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,results.length);
// An otherwise identical outer-time IR must produce a different scope and MIDI.
const swapped=structuredClone(results[0].semantic_ir);swapped.edges.find(e=>e.type==='time_relation').to=swapped.root_clause;
delete swapped.serialization;delete swapped.utterance_id;const hash=await canonicalDigest(swapped);swapped.utterance_id='UTT:'+hash.slice(0,24);swapped.serialization={canonical_format:'EZIR-JSON-1',content_digest:hash};
const alternative=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-e','puts JSON.generate(EraZeroRenderer.render(JSON.parse(STDIN.read)))'],{cwd:root,input:JSON.stringify(swapped),encoding:'utf8'}));
assert.deepEqual(decodeRunningMidi(midiFromFormal(alternative),authority.atoms).scopes,[time('before_speech'),possible]);
assert.notDeepEqual(midiFromFormal(alternative),midiFromFormal(results[0].formal));
console.log(`PASS ${results.length} temporal proposition cases with independent scope recovery and Ruby formal/MIDI parity; reversed temporal scope is musically distinct.`);

// Countermodel: available possibilities change with time. In this finite model,
// past(possible(P)) is true while possible(past(P)) is false. Scope order matters
// to meaning, independently of parser structure and event byte equality.
const facts=[[false,false],[true,false]];
function evaluate(scopes,world=0,tick=1){
 if(!scopes.length)return facts[world][tick];
 const [scope,...inside]=scopes;
 if(scope.operator==='time')return evaluate(inside,world,0);
 if(scope.operator==='modality'&&scope.mode==='possible')return (tick===1?[0]:[0,1]).some(w=>evaluate(inside,w,tick));
 throw new Error('Unexpected countermodel operator');
}
assert.equal(evaluate(decodeRunningMidi(midiFromFormal(results[0].formal),authority.atoms).scopes),false);
assert.equal(evaluate(decodeRunningMidi(midiFromFormal(alternative),authority.atoms).scopes),true);
console.log('PASS finite temporal-modal countermodel distinguishes the two decoded scope orders.');
