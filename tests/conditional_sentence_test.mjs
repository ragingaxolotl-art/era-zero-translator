import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseSentenceConditional,composeSentenceConditional} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const data=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const load=async target=>JSON.parse(fs.readFileSync(new URL(`../pages/${data.resolution_files[target]}`,import.meta.url))).variants['assertion:1'];
for(const input of ['If Pip cares for Ada, then Ada cares for Sol.','If Pip does not care for Ada, then Ada is conscious.','If Pip cares for "Ada then Sol", then Jun is dormant.','If Pip is conscious [2], then Ada is dormant [0].','If Pip was conscious, then Ada is conscious.']){
 const result=await composeSentenceConditional(input,load);
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','ir=JSON.parse(STDIN.read);f=EraZeroRenderer.render(ir);puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})'],{cwd:new URL('..',import.meta.url),input:JSON.stringify(result.semantic_ir),encoding:'utf8'}));
 assert.deepEqual(result.formal,ruby.formal);
 assert.deepEqual(Buffer.from(midiFromFormal(result.formal)),Buffer.from(ruby.midi,'base64'));
 if(input.includes('[2]'))assert.deepEqual(result.semantic_ir.nodes.filter(node=>node.kind==='lexical_occurrence').map(node=>node.runtime_state.code),[2,0]);
 if(input.includes('was'))assert.equal(result.semantic_ir.edges.find(edge=>edge.type==='time_relation').to,'s000_c');
 assert.equal(result.semantic_ir.edges.find(edge=>edge.type==='condition_of').condition_status,'open');
 assert.equal(scheduledLexicalEvents(result.formal)[0].marker,'conditional_open_open');
}
for(const input of ['If Pip cares for Ada, then repair it.','If Pip cares for Ada then Ada is conscious.','If Pip cares for Ada, then Ada is conscious, then Jun is dormant.','If Pip cares for Ada, then is Ada conscious?','If Pip cares for Ada, then Ada is hot.'])assert.equal(parseSentenceConditional(input),null,input);
const forward=await composeSentenceConditional('If Pip is conscious, then Ada is dormant.',load);
const reverse=await composeSentenceConditional('If Ada is dormant, then Pip is conscious.',load);
assert.notDeepEqual(midiFromFormal(forward.formal),midiFromFormal(reverse.formal));
console.log('English conditionals: five full Ruby/browser parity cases, reversed condition contrast, explicit runtime and past scopes, quoted name, and incomplete-clause rejection pass.');
