import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const template=JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files['MAT:001'],root))).variants['assertion:1'],results=[];
for(const state of [0,1,2])for(const sentence of ['The lamp is physically energized.','The lamp is not physically energized.','Is the lamp physically energized?','Exactly three lamps are physically energized.','At least two lamps are physically energized.','At most four lamps are physically energized.','It is possible that exactly three lamps are physically energized.']){
 const r=await composeNamedSentence(sentence+` [${state}]`,template),d=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);results.push(r);
 const roots=d.tokens.filter(t=>t.kind==='root');assert.equal(roots.length,1);assert.equal(roots[0].root_id,'MAT:001');assert.equal(roots[0].runtime_state,state);
 assert.equal(d.speech_act,sentence.startsWith('Is ')?'question':'assertion');assert.equal(d.tokens.some(t=>t.marker==='negation_open'),sentence.includes('not'));
 const q=r.semantic_ir.nodes.find(n=>n.operator==='quantifier');
 if(q){assert(d.tokens.some(t=>t.marker===`quantifier_${q.quantifier}_open`));assert(d.tokens.some(t=>t.marker===`digit_${q.value}`));assert.equal(q.value,sentence.includes('three')?'3':sentence.includes('two')?'2':'4');}
 assert.equal(d.tokens.filter(t=>t.kind==='phonemic').length,1);
 assert.equal(d.tokens.some(t=>t.marker==='modality_possible_open'),sentence.startsWith('It is possible'));
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:20_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,results.length);
for(const sentence of ['Exactly three lamps are active.','Exactly three lamps are not physically energized.','The lamp is switched on.'])assert.equal(parseNamedSentence(sentence),null);
console.log(`PASS ${results.length} energized bearer/count/state/scope cases, independent MIDI checks and Ruby parity; ambiguous active remains unresolved.`);
