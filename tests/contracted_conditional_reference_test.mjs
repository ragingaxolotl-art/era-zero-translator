import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseSentenceConditional,composeSentenceConditional} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const load=async id=>authority.compound_plans[id]?{authority}:JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'];
const results=[];
for(const state of [0,1,2])for(const apostrophe of ["'",'’'])for(const destination of ['toward','to']){
 const input=`If the box isn't restored [${state}], don${apostrophe}t carry it ${destination} Ada [${(state+1)%3}].`;
 const explicit=`If the box is not restored [${state}], do not carry the box ${destination} Ada [${(state+1)%3}].`;
 const choices=destination==='to'?[{},{destination:'spatial'}]:undefined;
 const a=await composeSentenceConditional(input,load,choices),b=await composeSentenceConditional(explicit,load,choices);results.push(a);assert.deepEqual(a.formal,b.formal);
 assert.equal(a.semantic_ir.nodes.find(n=>n.node_id==='s000_a').referent_id,a.semantic_ir.nodes.find(n=>n.node_id==='s001_b').referent_id);
 const d=decodeStrictMusicMidi(midiFromFormal(a.formal),authority.atoms);assert.equal(d.speech_act,'command');assert.equal(d.tokens.filter(t=>t.marker==='negation_open').length,2);
 assert(d.tokens.some(t=>t.root_id==='REP:001'&&t.runtime_state===state));assert(d.tokens.some(t=>t.root_id===(destination==='to'?'MOV:110':'MOV:121')&&t.runtime_state===(state+1)%3));
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:30_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
for(const input of ["If exactly three boxes are damaged, don't carry it to Ada.","If Nora is repairing the box, don't carry it to Ada.","If it is damaged, don't carry it to Ada."])assert.equal(parseSentenceConditional(input),null);
console.log('PASS 12 contracted conditional reference/state/destination cases with full paraphrase and Ruby/MIDI parity; ambiguous antecedents remain unresolved.');
