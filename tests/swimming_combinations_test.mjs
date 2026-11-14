import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,composeSentenceSequence,composeSentenceConjunction,composeSentenceConditional} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {decodeSwimmingMidi} from '../pages/swimming_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),template={authority},results=[];
for(const state of [0,1,2]){
 for(const [explicit,ambiguous] of [['Eli habitually swims.','Eli swims.'],['I habitually swim across the lake.','I swim across the lake.'],['Eli does not habitually swim across the river.','Eli does not swim across the river.'],['Does Eli habitually swim across the river?','Does Eli swim across the river?']]){
  const r=await composeNamedSentence(explicit+` [${state}]`,template),choice=await composeNamedSentence(ambiguous+` [${state}]`,template,{viewpoint:'habitual'});results.push(r);
  assert.deepEqual(r.formal,choice.formal);const d=decodeSwimmingMidi(midiFromFormal(r.formal),authority.atoms);assert.equal(d.runtime_state,state);assert(d.scopes.some(s=>s.operator==='aspect'&&s.aspect==='habitual'));
 }
 for(const [join,compose] of [['sequence',composeSentenceSequence],['all_of',composeSentenceConjunction],['conditional',composeSentenceConditional]]){
  const left=`Eli swims across the river [${state}]`,right=`Nora carries the box [${(state+1)%3}]`;
  const input=join==='sequence'?`${left}, then ${right}.`:join==='conditional'?`If ${left}, then ${right}.`:`${left} and ${right}.`;
  const options=[{viewpoint:'habitual'},{viewpoint:'ongoing'}],r=await compose(input,async()=>template,options);results.push(r);
  assert.deepEqual(r.selected_clauses.map(c=>c.options),options);
  const d=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);
  const habitual=d.tokens.find(t=>t.marker==='aspect_habitual_open'),ongoing=d.tokens.find(t=>t.marker==='aspect_ongoing_open');
  const within=t=>d.tokens.slice(d.tokens.indexOf(t)+1,t.closing_token);
  assert(within(habitual).some(t=>t.root_id==='MAT:101'&&t.runtime_state===state));assert(!within(habitual).some(t=>t.root_id==='MOV:121'));
  assert(within(ongoing).some(t=>t.root_id==='MOV:121'&&t.runtime_state===(state+1)%3));assert(!within(ongoing).some(t=>t.root_id==='MAT:101'));
 }
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:30_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,results.length);
console.log(`PASS ${results.length} explicit swimming habits and mixed-clause scope/state contrasts, with Ruby/MIDI parity.`);
