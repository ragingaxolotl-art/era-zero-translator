// Intents were committed before running each cohort. A declared gap passes the
// regression test but is still counted as a gap in the human-readable report.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {scoreSongText} from '../pages/song_lines.mjs';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {storyWords} from '../pages/story_words.mjs';
import {encodeName} from '../pages/names.mjs';
const file=path=>new URL('../'+path,import.meta.url);
const data=path=>JSON.parse(fs.readFileSync(file(path)));
const a=data('pages/data/index.json'),inputs=data('tests/story_reading_intentions.json');
const id=word=>storyWords.find(w=>w.word===word)?.id??word;
const lens=id=>a.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority:a}:{...data('pages/'+a.resolution_files[id]).variants['assertion:1'],authority:a};
const gap=note=>({grade:'Gap',note});
const ask=(key,word,answer,predicate,note)=>({grade:'Clarification',key,word,answer,predicate,note});
const full=(heads,bindings,note)=>({grade:'Preserved',heads,bindings,note});
const verdicts=[
 ask('subject0Owner','Her','new:Ada','vibrate','The possessor is requested. Supplying Ada binds the phone to Ada. Vibration does not assert ringing.'),
 gap('Pointing out the particular faulty chair is missing from the score.'),
 full(['cease'],[[0]],'The pulse stops. No permanent deletion is asserted.'),
 full(['recur'],[[0]],'The retries occur again with no agent or exact count.'),
 ask('word0','meaning',id('recur'),'recur','Offers occurrence again and motion back to an earlier place. The recurrence choice fits the passage.'),
 ask('object0','it','new:the pulse','repeat','Requests the pattern to be repeated. The arrival remains the actor.'),
 gap('The spoken reassurance has no whole-message reading.'),
 full(['wait'],[[0]],'The counter defers an action.'),
 full(['find','REP:110','MOV:110'],[[0,1],[0,1],[2]],'The discovery introduces the cracked bell. Pip repairs that bell before Ada arrives.'),
 full(['ring'],[[0]],'Negation encloses all of the specified bells. Zero ringing bells is compatible.'),
 full(['ring'],[[0]],'The specified group has zero members that rang.'),
 gap('The path and the sense of accessible or open both need context.'),
 ask('object0','it','new:the record','find','Asks for the object while keeping the listener as the commanded finder.'),
 ask('subject0','It','new:the request','recur','Asks what recurred. The reading introduces no causal agent.'),
 ask('object0','notice','new:the signal','MIN:011','Asks what was noticed. The resulting dictionary reading generalizes noticing to representing the target.'),
 gap('Withdrawal from contact is outside the scored construction.'),
 {...full(['MIN:011','REP:110'],[[0,1],[0,1]],'The radio alone is cracked. Both actions share Ada and the radio. The noticing verb is generalized to awareness of the target.'),grade:'Partial'},
 full(['ring','MOV:110'],[[0],[1]],'Mira arrives before the bell rings.'),
 full(['cease'],[[0]],'The request stops without implying destruction.'),
 full(['find'],[[0,1]],'Latch discovers the specific result.'),
 full(['wait'],[[0]],'The Council is the named participant that defers action.'),
 full(['repeat'],[[0,1]],'The child causes another occurrence of the same tone.'),
 ask('subject0','He','new:Elias','wait','Requests the participant. The score then binds Elias as the one who waits.'),
 gap('Returning excess allocation to another participant is missing.'),
 gap('The expectation and its embedded repetition have no complete joint reading.'),
 full(['REP:110','wait'],[[0,1],[0]],'The speaker is shared by restoration and waiting. And adds no strict ordering.'),
 full(['recur'],[[0]],'A further occurrence of the same tone has no specified producer.'),
 ask('object0','it','new:the pattern','repeat','Asks for the pattern, then keeps the narrator as the actor.'),
 gap('Returning a numeric result from a calculation has no complete score.')
];
const rows=[],counts={};
let index=0;
for(const [cohort,entries] of Object.entries(inputs)){
 if(cohort==='source_revision')continue;
 for(const entry of entries){
  const expectation=verdicts[index++],source=entry.input||entry.line;
  const plan=storyReading(source,a);
  if(expectation.grade==='Gap'){
    assert(!plan||!plan.question,source);assert.equal(await scoreSongText(source,a,lens),null,source);
  }else if(expectation.grade==='Clarification'){
    assert.equal(plan?.question?.key,expectation.key,source);
    assert(plan.question.prompt.includes(expectation.word),source);
    assert.equal(await scoreSongText(source,a,lens),null,source);
    const selected=storyReading(source,a,{answers:{[expectation.key]:expectation.answer}});
    const scored=await scoreStory(selected,a), recovered=decodeStoryMidi(scored.midi,a.atoms);
    assert.deepEqual(recovered,scored.meaning,source);assert.equal(recovered.events[0].predicate,id(expectation.predicate),source);
    if(source==='Find it!')assert.equal(recovered.speech_act,'command');
    if(source.startsWith('Her phone'))assert.equal(recovered.entities[1].owner,0);
  }else{
    const scored=await scoreSongText(source,a,lens);assert(scored,source);const heard=decodeStoryMidi(scored.midi,a.atoms);
    assert.deepEqual(heard,scored.meaning,source);
    assert.deepEqual(heard.events.map(e=>e.predicate),expectation.heads.map(id),source);
    assert.deepEqual(heard.events.map(e=>e.arguments.map(r=>r.entity)),expectation.bindings,source);
    if(source.includes('cracked'))assert.deepEqual(heard.events[0].arguments[1].properties,[id('cracked')],source);
    if(source.startsWith('Pip found'))assert.deepEqual(heard.relations,[{kind:'before',events:[1,2]}]);
    if(source.includes('after Mira'))assert.deepEqual(heard.relations,[{kind:'before',events:[1,0]}]);
    if(source.startsWith('Not all')){assert.equal(heard.events[0].quantifier,'all');assert.equal(heard.events[0].negated_quantifier,true);}
    if(source.startsWith('None'))assert.equal(heard.events[0].quantifier,'none');
    if(source.includes(' and '))assert.deepEqual(heard.relations,[{kind:'and',events:[0,1]}]);
    if(source.startsWith('Latch'))assert.deepEqual(heard.entities[0].identity.phonemes,(await encodeName('Latch')).phonemes);
  }
  const src=entry.source.includes('/')?'[Manuscript](https://github.com/ragingaxolotl-art/cyber-pet-lore/blob/'+inputs.source_revision+'/sources/'+entry.source+')':entry.source;
  rows.push({cohort,source,src,intended:entry.intended,...expectation});counts[expectation.grade]=(counts[expectation.grade]||0)+1;
 }
}
assert.equal(index,verdicts.length);
const doc=['# Story and dialogue listening audit','',
 'Run the [story grammar tests](../tests/story_readings_test.mjs) for melody and compact-chord MIDI. The [clean-WAV test](../tests/story_acoustic_test.mjs) plays the Pip passage and both bell-count messages through the calibrated monophonic audio transport and compares the listener’s recovered meaning. Physical speaker-to-microphone recordings and polyphonic audio decoding remain untested.','',
 'Each intended reading was written before the translator saw that group. The inverse received the musical notes and the shared dictionary. Clarification cases were also played and decoded after supplying the missing detail. Partial marks an audible loss. Gap marks an unavailable whole-line score. A word sketch earns neither full nor partial credit here.','',
 'The original development baseline scored 0 of 11 complete lines. The first seven reserved cases produced two scores, one useful question and four gaps. Closer comparison found that one of those two scores preserved the participants but generalized noticing. Follow-up work added an intransitive reading of *repeat* and a question for an omitted target. A second reserve exposed a broad default for *found* even with the precise discovery compound available. The simple subject–verb–object path now uses that discovery meaning. The four final reserved lines were tested after these changes. These are authored checks on this corpus.','',
 rows.length+' lines in the current evaluation. '+Object.entries(counts).map(([k,v])=>v+' '+k.toLowerCase()).join(', ')+'.','',
 'The original scope, before-run intentions and first reserved results are available in the [completion plan](../docs/translator-completion.md), [intention ledger](../tests/story_reading_intentions.json), [development baseline](story_reading_baseline.json) and [first reserved run](story_reserved_first_run.json).',''];
for(const [key,title] of [['development','Development lines'],['reserved','First reserve after follow-up'],['second_reserve','Second reserve after follow-up'],['final_reserve','Final reserve, first run']]){
 doc.push('## '+title,'','| Line | Intended meaning | Current result | Source |','| --- | --- | --- | --- |');
 for(const r of rows.filter(x=>x.cohort===key))doc.push('| '+r.source+' | '+r.intended+' | **'+r.grade+'**. '+r.note+' | '+r.src+' |');
 doc.push('');
}
fs.writeFileSync(file('reports/story_readings.md'),doc.join('\n'));
console.log('PASS story audit. '+JSON.stringify(counts));
