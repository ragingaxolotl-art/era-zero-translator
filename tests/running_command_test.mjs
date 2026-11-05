import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,composeSentenceConditional,needsSentenceComposition} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeRunningMidi} from '../pages/running_decoder.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),template={authority},results=[];
const load=async id=>authority.compound_plans[id]?template:{...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority};
for(const state of [0,1,2])for(const [input,kind] of [
 ['Run.','activity'],['Do not run.','activity'],['Run toward the gate.','approach'],['Do not run toward the gate.','approach'],['Run to the gate.','arrival'],['Do not run to the gate.','arrival'],['Run to Nora!','arrival']
]){
 const r=await composeNamedSentence(`${input} [${state}]`,template),d=decodeRunningMidi(midiFromFormal(r.formal),authority.atoms);results.push(r);
 assert.equal(d.speech_act,'command');assert.equal(d.runtime_state,state);assert.deepEqual(d.actor,{kind:'deictic',role:'addressee'});
 assert.deepEqual(d.scopes,input.startsWith('Do not')?[{operator:'negation'}]:[]);
 assert.equal(d.predicate,kind==='activity'?'ongoing_bodily_running':kind==='approach'?'ongoing_destination_running':'completed_destination_running');
 assert.equal(d.meaning.arrival_asserted,kind==='arrival');assert(!r.semantic_ir.edges.some(e=>e.type==='time_relation'));
 assert.equal(d.destination?.reference_mode,kind==='activity'?undefined:input.includes('Nora')?'name':'definite_nominal');
 assert.match(r.semantic_note,/does not assert that running or arrival occurred/);
}
for(const text of ['Run','Run toward the gate','Run to the gate']){
 const explicit=await composeNamedSentence('Do not '+text.toLowerCase()+'.',template),contracted=await composeNamedSentence("Don't "+text.toLowerCase()+'.',template);
 assert.deepEqual(contracted.formal,explicit.formal);assert.deepEqual(midiFromFormal(contracted.formal),midiFromFormal(explicit.formal));
}
for(const state of [0,1,2]){
 const r=await composeSentenceConditional(`If Orin is conscious [${state}], run to the gate [${(state+1)%3}].`,load);results.push(r);
 const d=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);assert.equal(d.speech_act,'command');
 assert.equal(d.tokens.find(t=>t.root_id==='LIF:011').runtime_state,state);assert.equal(d.tokens.find(t=>t.root_id==='MOV:110').runtime_state,(state+1)%3);
 const thenIndex=d.tokens.findIndex(t=>t.marker==='conditional_then');assert(thenIndex>0);
 assert(d.tokens.slice(thenIndex).some(t=>t.kind==='deictic'&&t.deictic_role==='addressee'));
 assert(!r.semantic_ir.edges.some(e=>e.type==='time_relation'));
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:40_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,results.length);
for(const input of ['Run the program.','Run to the conclusion.','Run quickly.','Run to exactly two gates.','Run to the gate tomorrow.']){assert.equal(parseNamedSentence(input),null,input);assert(needsSentenceComposition(input),input);}
const statement=await composeNamedSentence('you ran to the gate.',template),command=await composeNamedSentence('Run to the gate.',template);
assert.notDeepEqual(midiFromFormal(statement.formal),midiFromFormal(command.formal));
console.log(`PASS ${results.length} running command/state/negation/conditional cases with Ruby formal/MIDI parity, independent addressee/speech-act recovery and three contraction equivalents.`);
