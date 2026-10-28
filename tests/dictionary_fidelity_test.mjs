import assert from 'node:assert/strict';
import fs from 'node:fs';
import {analyzeEnglish,inferEnglishIntent} from '../pages/english.mjs';
const data=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
for(const input of ['Go home with zibble.','I am not moving.','She arrived at the station.','Pip actively cares for Ada tomorrow.','It is possible that Pip moves.','Send the file.']){
  const result=analyzeEnglish(input,data);
  assert.equal(result.decision.auto_resolution_allowed,false,input);
  assert.equal(result.complete_sentence_unavailable,true,input);
  assert.equal(result.interpretation_scope,'partial_dictionary_reading',input);
  assert(result.decision.reasons.includes('incomplete_sentence_construction'),input);
}
for(const input of ['active care','conscious other','dormant other']){
  const result=analyzeEnglish(input,data);
  assert.equal(result.interpretation_scope,'dictionary_label');
  assert.equal(result.complete_sentence_unavailable,false);
}
assert.equal(inferEnglishIntent('I am not moving.').runtime,1);
assert.equal(inferEnglishIntent('I am never moving.').runtime,1);
assert.equal(inferEnglishIntent('active care',0).runtime,0);
assert.equal(inferEnglishIntent('active care',2).runtime,2);
console.log('Dictionary fidelity: uncomposed sentences remain partial, lexical labels remain available, and negation never infers runtime zero.');
