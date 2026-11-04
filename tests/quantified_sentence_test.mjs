import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeQuantifiedPropertySentence as compose,parseQuantifiedPropertySentence as parse} from '../pages/quantified_sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeQuantifiedPropertyMidi} from '../pages/quantified_decoder.mjs';
import {evaluateQuantifiedPredication as evaluate} from '../pages/quantified_predication.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const load=id=>JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],results=[];
for(const state of [0,1,2])for(const [text,quantifier,value,inner,outer,act] of [
 ['Exactly three lamps are not physically energized.','exact','3',true,false,'assertion'],
 ['It is not the case that exactly three lamps are physically energized.','exact','3',false,true,'assertion'],
 ['At least two radios are not damaged.','at_least','2',true,false,'assertion'],
 ['At most four robots are restored.','at_most','4',false,false,'assertion'],
 ['Are exactly three children not conscious?','exact','3',true,false,'question'],
 ['It is not the case that exactly three lamps are not physically energized.','exact','3',true,true,'assertion']
]){
 const r=await compose(text+` [${state}]`,load,{allowDraft:true}),d=decodeQuantifiedPropertyMidi(midiFromFormal(r.formal),authority.atoms,{allowDraft:true});results.push(r);
 assert.equal(d.quantifier,quantifier);assert.equal(d.value,value);assert.equal(d.predicate_negated,inner);assert.equal(d.proposition_negated,outer);assert.equal(d.speech_act,act);assert.equal(d.predicate.runtime_state,state);
 if(text.includes('lamps')){
  const members=Array.from({length:6},(_,i)=>({id:String(i),restriction:true,predicate:i<3}));
  assert.equal(evaluate({quantifier:d.quantifier,value:d.value,predicateNegated:d.predicate_negated,propositionNegated:d.proposition_negated,members,domainComplete:true}).truth,inner&&!outer);
 }
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir,allow_draft_quantified:true);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,allow_draft_quantified:true))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:25_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
await assert.rejects(()=>compose('Exactly three lamps are not physically energized.',load),/opt-in/);
for(const s of ['Exactly three lamps are active.','Exactly three lamps are not physically energized yesterday.','Exactly three lamps are not physically energized?','Exactly three lamps are not physically energized? [1].'])assert.equal(parse(s),null);
console.log('PASS 18 English counted-property cases with full browser/Ruby formal/MIDI parity, independent scope recovery and decoded finite-model counterexamples. UI admission remains pending.');
