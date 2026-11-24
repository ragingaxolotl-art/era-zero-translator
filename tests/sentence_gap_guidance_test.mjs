import assert from 'node:assert/strict';
import fs from 'node:fs';
import {analyzeEnglish} from '../pages/english.mjs';
import {sentenceGapGuidance} from '../pages/sentence_gap_guidance.mjs';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreSongText} from '../pages/song_lines.mjs';
const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
function inspect(text){
 const original={...analyzeEnglish(text,a),complete_sentence_unavailable:true},before=JSON.stringify(original);
 const result=sentenceGapGuidance(original);assert.equal(JSON.stringify(original),before,'Do not mutate the lexical analysis');
 return result;
}
for(const text of ['Both workers waited.','Both the workers waited.','Three workers waited.','3 workers waited.','Two children waited.','One worker waited.']){
 const r=inspect(text),noun=r.term_coverage.find(v=>['workers','worker','children'].includes(v.term));
 assert(r.sentence_gap,text);assert.equal(noun.status,'phonemic_label');assert.equal(noun.semantic_kind,null);
 assert(r.term_coverage[0].unscored_scope);assert.equal(r.decision.auto_resolution_allowed,false);
 assert(r.complete_sentence_unavailable);assert(!storyReading(text,a)?.events,text);
 assert.equal(await scoreSongText(text,a,()=>{throw Error('No new sentence composer');}),null,text);
}
for(const text of ['Three workers zorbled the box.','Both workers glorp the box.']){
 const r=inspect(text),verb=r.term_coverage.find(v=>['zorbled','glorp'].includes(v.term));
 assert.equal(verb.status,'unresolved_semantic');assert.equal(verb.semantic_kind,'verb');assert(r.sentence_gap);
}
for(const [text,word] of [['The box is very heavy.','very'],['The gate was still closed.','still'],['The lamp is very glimmerwise.','very']]){
 const r=inspect(text);assert(r.sentence_gap);assert(r.term_coverage.find(v=>v.term===word).unscored_scope);
 assert.equal(r.term_coverage.find(v=>v.term===word).status,'function_word');
 if(text.includes('glimmerwise')){const missing=r.term_coverage.find(v=>v.term==='glimmerwise');assert.equal(missing.status,'unresolved_semantic');assert.equal(missing.semantic_kind,'descriptor');}
 assert.equal(await scoreSongText(text,a,()=>{throw Error('Degree or continuation must not be dropped');}),null,text);
}
for(const text of ['Nora zorbled the box.','The lamp is glimmerwise.','Nora saved the file.','Both waited.','Three saved the file.','"Both" saved the file.','The gate is "Still".','very','both']){
 const r={...analyzeEnglish(text,a),complete_sentence_unavailable:true};assert.equal(sentenceGapGuidance(r),r,text);
}
const resolved=analyzeEnglish('The box is very heavy.',a);resolved.complete_sentence_unavailable=false;
assert.equal(sentenceGapGuidance(resolved),resolved,'Only decorate the explicitly unavailable sentence flow');
console.log('PASS quantity nouns, real missing verbs/adjectives, degree/continuation scope, unchanged names and single words; no new sentence or musical meaning is asserted.');
