import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedCareSentence,composeNamedCareSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const data=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const file=data.resolution_files['LIF:211'];
const document=JSON.parse(fs.readFileSync(new URL(`../pages/${file}`,import.meta.url)));
const template=document.variants['assertion:1'];
const outputs=[];
for(const text of ['Pip cares for Ada.','Ada cares for Pip.','Mira is caring for Sol.','Jun cares for Tavi.']){
  const result=await composeNamedCareSentence(text,template);
  const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-e','ir=JSON.parse(STDIN.read);puts JSON.generate(EraZeroRenderer.render(ir))'],{cwd:new URL('..',import.meta.url),input:JSON.stringify(result.semantic_ir),encoding:'utf8',stdio:['pipe','pipe','pipe']}));
  assert.deepEqual(result.formal,ruby);
  outputs.push(result);
}
assert.notEqual(outputs[0].semantic_ir.utterance_id,outputs[1].semantic_ir.utterance_id);
assert.notDeepEqual(midiFromFormal(outputs[0].formal),midiFromFormal(outputs[1].formal));
for(const text of ['Pip does not care for Ada.','Pip cares for Ada and Sol.','Pip barely cares for Ada.','Pip cares for a curious Ada.','Pip cares for Ada tomorrow.'])assert.equal(parseNamedCareSentence(text),null,text);
console.log('Named sentences: four full compositions match Ruby rendering; role reversal changes sound; unsupported additions never match.');
