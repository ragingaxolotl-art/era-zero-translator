import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {strictSemanticReader} from '../pages/strict_semantic_reader.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const template=JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files['MAT:001'],root))).variants['assertion:1'],results=[];
const base='exactly three lamps are physically energized.';
for(const state of [0,1,2])for(const [sentence,scopes] of [
 [base,[]],
 ['It is not the case that '+base,[{operator:'negation'}]],
 ['It is possible that it is not the case that '+base,[{operator:'modality',mode:'possible'},{operator:'negation'}]],
 ['It is not the case that it is possible that '+base,[{operator:'negation'},{operator:'modality',mode:'possible'}]],
 ['It is not the case that it is not the case that '+base,[{operator:'negation'},{operator:'negation'}]]
]){
 const r=await composeNamedSentence(sentence+` [${state}]`,template),reader=strictSemanticReader(midiFromFormal(r.formal),authority.atoms,'Invalid count negation'),d=reader.unwrapScopes(n=>n.marker==='role_bearer_open');results.push(r);
 assert.deepEqual(d.scopes,scopes);assert.equal(d.current.length,2);
 const [role,predicate]=d.current;assert.equal(role.marker,'role_bearer_open');assert.equal(role.children.length,1);
 const quantity=role.children[0];assert.equal(quantity.marker,'quantifier_exact_open');assert.equal(quantity.children[0].marker,'digit_3');
 assert.equal(quantity.children.filter(n=>n.kind==='phonemic').length,1);
 reader.exactRoot(predicate,'MAT:001','middle',state);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})"],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:20_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi);}
assert.equal(new Set(ruby.map(r=>r.midi)).size,results.length);
for(const sentence of ['Exactly three lamps are not physically energized.','It is not the case that is the lamp physically energized?','It is not the case that repair the radio.'])assert.equal(parseNamedSentence(sentence),null);
console.log(`PASS ${results.length} proposition/count/negation/modal/runtime contrasts with complete MIDI scope recovery and Ruby parity.`);
