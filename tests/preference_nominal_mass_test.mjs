import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url)));
const authority=read('pages/data/index.json'),records=read('reviews/foundation_extension_candidates.json').records;
const load=id=>({...read('pages/'+authority.resolution_files[id]).variants['assertion:1'],authority});
const sounds=new Set(),results=[];
for(const state of [0,1,2])for(const reverse of [false,true])for(const form of ['assertion','negation','question']){
 const a=reverse?'light':'heavy',b=reverse?'heavy':'light';
 const text=(form==='question'?`Does Nora prefer the ${a} box to the ${b} box?`:`Nora ${form==='negation'?'does not prefer':'prefers'} the ${a} box to the ${b} box.`)+` [${state}]`;
 const result=await composeFoundationSentence(text,authority,records,load,{allowDraft:true,contextualMassModifiers:true});
 results.push(result);
 const refs=result.semantic_ir.nodes.filter(n=>n.property_restriction);
 assert.equal(refs.length,2);assert(refs.every(n=>n.name.normalized_label==='box'));assert.notEqual(refs[0].referent_id,refs[1].referent_id);
 const bytes=midiFromFormal(result.formal),decoded=await decodeFoundationSentenceMidi(bytes,authority.atoms,records,{allowDraft:true});
 assert.equal(decoded.meaning.arguments.target.reference.property.norm,a);
 assert.equal(decoded.meaning.arguments.comparison_standard.reference.property.norm,b);
 assert.equal(decoded.meaning.runtime_state,state);assert.equal(decoded.speech_act,form==='question'?'question':'assertion');
 assert.equal(decoded.meaning.scopes.some(s=>s.operator==='negation'),form==='negation');sounds.add(Buffer.from(bytes).toString('base64'));
}
assert.equal(sounds.size,18);
await assert.rejects(composeFoundationSentence('Nora prefers the heavy box to the light box.',authority,records,load,{allowDraft:true}),/Select the contextual/);
console.log('PASS 18 modified preference contrasts preserve noun labels, independent restriction occurrences, direction, scope and runtime through MIDI.');

const parity=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rjson','-rbase64','-e',"x=JSON.parse(STDIN.read);o={foundation_records:x['records'],allow_draft_foundations:true};puts JSON.generate(x['irs'].map{|ir|f=EraZeroRenderer.render(ir,**o);{midi:Base64.strict_encode64(EraZeroPresentation.midi(f,**o))}})"],{input:JSON.stringify({records,irs:results.map(r=>r.semantic_ir)}),encoding:'utf8',maxBuffer:12000000}));
for(const [i,r] of results.entries())assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),parity[i].midi);
console.log('PASS independent Ruby MIDI parity for all 18 modified preferences.');
