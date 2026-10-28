import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence,needsSentenceComposition} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const data=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const outputs=[];
const cases=[['Pip cares for Ada.','LIF:211'],['Ada cares for Pip.','LIF:211'],['Mira is caring for Sol.','LIF:211'],['Jun cares for Tavi.','LIF:211'],
  ['Pip is awakening Ada.','LIF:111'],['Mira is restoring Sol.','REP:111'],['Jun is damaging Tavi.','WRN:111']];
for(const [text,target] of cases){
  assert.equal(parseNamedSentence(text).predicate,target);
  const file=data.resolution_files[target];
  const document=JSON.parse(fs.readFileSync(new URL(`../pages/${file}`,import.meta.url)));
  const result=await composeNamedSentence(text,document.variants['assertion:1']);
  const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-e','ir=JSON.parse(STDIN.read);puts JSON.generate(EraZeroRenderer.render(ir))'],{cwd:new URL('..',import.meta.url),input:JSON.stringify(result.semantic_ir),encoding:'utf8',stdio:['pipe','pipe','pipe']}));
  assert.deepEqual(result.formal,ruby);
  outputs.push(result);
}
assert.notEqual(outputs[0].semantic_ir.utterance_id,outputs[1].semantic_ir.utterance_id);
assert.notDeepEqual(midiFromFormal(outputs[0].formal),midiFromFormal(outputs[1].formal));
for(const text of ['Pip does not care for Ada.','Pip cares for Ada and Sol.','Pip barely cares for Ada.','Pip cares for a curious Ada.','Pip cares for Ada tomorrow.','Pip is not restoring Ada.','Pip is damaging Ada and Sol.','Pip was awakening Ada.']){
  assert.equal(parseNamedSentence(text),null,text);
  assert.equal(needsSentenceComposition(text),true,text);
}
assert.equal(needsSentenceComposition('active care'),false);
assert.equal(needsSentenceComposition('Pip cares for Ada.'),false);
console.log('Named sentences: seven full compositions match Ruby rendering; role reversal changes sound; unsupported additions never match.');
