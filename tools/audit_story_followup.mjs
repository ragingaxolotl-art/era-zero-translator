// Run one previously sealed cohort at a time. Expected English never enters the listener.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {isDeepStrictEqual} from 'node:util';
import {scoreSongText} from '../pages/song_lines.mjs';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory} from '../pages/story_music.mjs';
import {storyWords} from '../pages/story_words.mjs';
import {dictionaryClausePlan} from '../pages/dictionary_clauses.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {encodeName} from '../pages/names.mjs';
const read=f=>JSON.parse(fs.readFileSync(new URL('../'+f,import.meta.url)));
const cohort=process.argv[2];
assert(['initial','reserve'].includes(cohort),'Supply initial or reserve.');
const a=read('pages/data/index.json'),ledger=read('tests/story_followup_intentions.json');
const records=read('pages/data/foundation_preview_candidates.json').records;
const word=w=>storyWords.find(r=>r.word===w)?.id??w;
const template=k=>a.compound_plans[k]?.expanded.nodes.some(n=>n.kind==='slot')?{authority:a}:{...read('pages/'+a.resolution_files[k]).variants['assertion:1'],authority:a};
async function expectedStory(spec){
 if(!spec.events)return null;
 const entities=await Promise.all(spec.entities.map(async e=>({
   identity:e.mode==='deictic'?{kind:'deictic',role:e.label}:{kind:'phonemic',reference_mode:e.mode,phonemes:(await encodeName(e.label)).phonemes,instance_code:null},
   owner:e.owner??null,plural:false
 })));
 return {profile:'EZ-STORY-1',status:'draft',runtime_state:1,speech_act:spec.speech_act,entities,
   events:spec.events.map(e=>({predicate:word(e.predicate),arguments:e.arguments.map(([role,entity])=>({role,entity,properties:[]})),scopes:e.scopes,quantifier:null,negated_quantifier:false})),relations:spec.relations};
}
const outcomes=[];
for(const entry of ledger[cohort]){
 const questions=[],answers={};
 let p=storyReading(entry.input,a),scored;
 const first=p;
 while(p?.question&&questions.length<5){
   const q=p.question,answer=entry.answers?.[q.key];
   questions.push({prompt:q.prompt,options:q.options.map(o=>o.label),answer:answer??null});
   if(!answer||Object.hasOwn(answers,q.key))break;
   answers[q.key]=answer.startsWith('meaning:')?word(answer.slice(8)):answer;
   p=storyReading(entry.input,a,{answers});
 }
 if(first)scored=p&&!p.question?await scoreStory(p,a):null;
 else scored=await scoreSongText(entry.input,a,template);
 const result={key:entry.key,questions};
 if(scored){
   // Only bytes and shared public roots go to the inverse; no original entities, text, or score metadata.
   let heard;try{heard=await decodeSupportedMeaningWithDrafts(scored.midi,a.atoms,records,{allowDraft:true});}
   catch(error){result.decoder_error=error.message;result.score_label=scored.label;outcomes.push(result);console.log(entry.key,'score without unique decoding');continue;}
   result.heard=heard;
   const target=await expectedStory(entry.meaning);
   result.matches_preregistered_meaning=target?isDeepStrictEqual(heard,target):null;
 }else if(!first){
   const plan=dictionaryClausePlan(entry.input,a,{offerDefinition:true});
   if(plan)result.dictionary_prompt={word:plan.readings[0]?.word,asks_for_new_definition:plan.needsDefinition,
     // Unrelated customizable meanings do not count as a resolution.
     available:plan.readings.map(r=>({meaning:r.sense.lemma,target:r.root}))};
 }
 outcomes.push(result);
 console.log(entry.key,questions.length+' question(s)',!result.heard?(result.dictionary_prompt?'dictionary proposal only':'no score'):result.matches_preregistered_meaning===true?'exact match':result.matches_preregistered_meaning===false?'different reading':'compare scored meaning to written requirements');
}
const output=new URL('../reports/story_followup_'+cohort+'.json',import.meta.url);
fs.writeFileSync(output,JSON.stringify({cohort,results:outcomes},null,2)+'\n');
