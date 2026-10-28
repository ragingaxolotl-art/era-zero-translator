import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal,svgFromFormal} from '../pages/engine.mjs';
import {visemePlanFromFormal} from '../pages/visemes.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const root=new URL('..',import.meta.url),index=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const cases=['Nora is physically repairing the radio.','Nora is physically repairing "radio".','The robot is moving toward the station.','Did Nora physically repair the radio yesterday?','I care for the child.','Nora does not care for the child.'];
const results=[];
for(const input of cases){
 const parsed=parseNamedSentence(input);assert.ok(parsed,input);
 const document=JSON.parse(fs.readFileSync(new URL('pages/'+index.resolution_files[parsed.predicate],root)));
 const result=await composeNamedSentence(input,document.variants['assertion:1']);
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e','ir=JSON.parse(STDIN.read);f=EraZeroRenderer.render(ir);puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f)),svg:EraZeroPresentation.svg(f)})'],{cwd:root,input:JSON.stringify(result.semantic_ir),encoding:'utf8'}));
 assert.deepEqual(result.formal,ruby.formal);
 assert.deepEqual(Buffer.from(midiFromFormal(result.formal)),Buffer.from(ruby.midi,'base64'));
 assert.equal(svgFromFormal(result.formal),ruby.svg);
 const nominals=result.semantic_ir.nodes.filter(n=>n.reference_mode==='definite_nominal');
 assert.equal(scheduledLexicalEvents(result.formal).filter(e=>e.kind==='reference_marker').length,nominals.length);
 const cues=visemePlanFromFormal(result.formal,{mode:'strict'}).cues.filter(c=>c.section==='reference_marker');
 assert.equal(cues.length,nominals.length*4);assert(cues.every(c=>c.nucleus_viseme==='REST'));
 results.push(result);
}
assert.equal(results[0].semantic_ir.nodes.find(n=>n.reference_mode).name.normalized_label,'radio');
assert.notDeepEqual(midiFromFormal(results[0].formal),midiFromFormal(results[1].formal));
assert.equal(results[2].semantic_ir.nodes.filter(n=>n.reference_mode).length,2);
for(const input of ['Nora is physically repairing the broken radio.','Nora is physically repairing a radio.','Nora is physically repairing two radios.','Nora loves the radio.'])assert.equal(parseNamedSentence(input),null,input);
for(const patch of [{kind:'deictic_reference'},{reference_mode:'indefinite_nominal'},{referent_id:'unresolved' }]){
 const ir=structuredClone(results[0].semantic_ir);Object.assign(ir.nodes.find(n=>n.reference_mode),patch);
 const errors=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_semantic_validation','-e','puts JSON.generate(EraZeroSemanticValidation.validate(JSON.parse(STDIN.read)))'],{cwd:root,input:JSON.stringify(ir),encoding:'utf8'}));
 assert.ok(errors.includes('invalid_nominal_reference'));
}
console.log('Definite noun references: six full compositions preserve reference frames, names remain distinct, Ruby/browser output agrees, malformed references fail.');
