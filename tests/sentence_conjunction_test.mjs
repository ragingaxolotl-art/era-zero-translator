import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseSentenceConjunction,composeSentenceConjunction,composeSentenceSequence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const data=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const load=async target=>JSON.parse(fs.readFileSync(new URL(`../pages/${data.resolution_files[target]}`,import.meta.url))).variants['assertion:1'];
for(const input of ['Pip cares for Ada and Ada cares for Sol.','Pip does not care for Ada and Ada is conscious.','Pip cares for "Ada and Sol" and Jun is dormant.']){
 const result=await composeSentenceConjunction(input,load);
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','ir=JSON.parse(STDIN.read);f=EraZeroRenderer.render(ir);puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})'],{cwd:new URL('..',import.meta.url),input:JSON.stringify(result.semantic_ir),encoding:'utf8'}));
 assert.deepEqual(result.formal,ruby.formal);
 assert.deepEqual(Buffer.from(midiFromFormal(result.formal)),Buffer.from(ruby.midi,'base64'));
 assert.equal(result.semantic_ir.nodes.find(node=>node.kind==='coordination').operator,'all_of');
 assert(result.semantic_ir.edges.filter(edge=>edge.type==='member_of').every(edge=>edge.order===undefined));
 assert.equal(scheduledLexicalEvents(result.formal)[0].marker,'coord_all_of_open');
}
const together=await composeSentenceConjunction('Pip cares for Ada and Ada cares for Sol.',load);
const ordered=await composeSentenceSequence('Pip cares for Ada, then Ada cares for Sol.',load);
assert.notDeepEqual(midiFromFormal(together.formal),midiFromFormal(ordered.formal));
for(const input of ['Pip cares for Ada and Sol.','Pip cares for "Ada and Sol".','It is possible that Pip cares for Ada and Ada cares for Sol.','Pip cares for Ada and it is possible that Ada cares for Sol and Jun is dormant.','Pip cares for Ada and Ada cares for Sol tomorrow.','Pip cares for Ada or Ada cares for Sol.'])assert.equal(parseSentenceConjunction(input),null,input);
console.log('Conjoined sentences: full Ruby/browser parity, quoted conjunctions, local negation, and-versus-then sound contrast, and ambiguous-scope rejection pass.');
