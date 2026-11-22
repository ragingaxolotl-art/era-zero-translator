import assert from 'node:assert/strict';
import fs from 'node:fs';
import {analyzeEnglish} from '../pages/english.mjs';
import {wordScorePlan} from '../pages/word_score.mjs';
import {scoreSongText} from '../pages/song_lines.mjs';

const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const load=id=>({...JSON.parse(fs.readFileSync(new URL('../pages/'+authority.resolution_files[id],import.meta.url))).variants['assertion:1'],authority});
for(const text of ['Nora copied only the file.','Only Nora copied the file.','Nora only copied the file.',
  'Nora holds only the rope.','Nora repaired only the gate.','Nora copied only the file [2].']){
  const coverage=analyzeEnglish(text,authority).term_coverage;
  const only=coverage.find(row=>row.term==='only');
  assert.equal(only.status,'function_word',text);assert.equal(only.unscored_scope,true,text);
  const plan=wordScorePlan(coverage,new Map(),authority);
  assert(plan.omitted.includes('only'),text);assert(!plan.playable.some(row=>row.term==='only'),text);
  assert.equal(await scoreSongText(text,authority,load),null,text+' must not discard restrictive scope');
}
for(const text of ['Nora copied "Only".','Nora copied “Only”.',"Nora copied 'Only'."]){
  const row=analyzeEnglish(text,authority).term_coverage.find(row=>row.term==='only');
  assert.equal(row.status,'phonemic_label',text);assert.equal(row.unscored_scope,undefined,text);
}
const repeated=analyzeEnglish('Nora copied only "Only".',authority).term_coverage.filter(row=>row.term==='only');
assert.deepEqual(repeated.map(row=>row.status),['function_word','phonemic_label']);
for(const [text,word,kind] of [['We blorf the archive.','blorf','verb'],['The lamp is glimmerwise.','glimmerwise','descriptor']]){
  const row=analyzeEnglish(text,authority).term_coverage.find(row=>row.term===word);
  assert.equal(row.status,'unresolved_semantic');assert.equal(row.semantic_kind,kind);
}
console.log('PASS six restrictive-scope boundaries, quoted names, repeated tokens and missing verb/adjective help.');
