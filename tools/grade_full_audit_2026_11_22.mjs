// Adjudication of the frozen written intentions, kept separate from the listener.
// These checks were authored after observing the outputs; the written intentions
// were not changed. This is an engineering diagnostic, not independent judging.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {encodeName} from '../pages/names.mjs';
import {storyWords} from '../pages/story_words.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url)));
const prefix='reports/full_audit_2026_11_22/';
const corpus=read('tests/full_audit_2026_11_22_intentions.json');
const observations=new Map(read(prefix+'initial.json').results.map(r=>[r.id,r]));
for(const r of read(prefix+'clarified.json').results)observations.set(r.id,r);
const word=w=>storyWords.find(x=>x.word===w)?.id||w;
const past=['time_before_speech'];
const event=(predicate,roles,scopes=past,condition)=>({predicate:word(predicate),
 arguments:roles.map(([role,entity])=>({role,entity,properties:[]})),scopes,
 quantifier:null,negated_quantifier:false,...(condition?{condition:word(condition)}:{})});
async function story(number,names,events,{runtime=1,act='assertion',relations=[]}={}){
 const id='audit-'+String(number).padStart(2,'0'),m=observations.get(id).heard;
 assert(m,id);assert.equal(m.profile,'EZ-STORY-1');
 assert.deepEqual(m.entities,await Promise.all(names.map(async([label,mode])=>({
  identity:{kind:'phonemic',reference_mode:mode,phonemes:(await encodeName(label)).phonemes,instance_code:null},plural:false,owner:null}))));
 assert.deepEqual(m.events,events,id);assert.deepEqual(m.relations,relations,id);
 assert.equal(m.runtime_state,runtime,id);assert.equal(m.speech_act,act,id);
 assert(observations.get(id).chords_same_meaning&&observations.get(id).chords_same_notes,id);
}
const hatch=[['hatch','definite_nominal']],noraHatch=[['Nora','name'],...hatch];
await story(1,hatch,[event('stay',[['bearer',0]],past,'closed')]);
await story(2,noraHatch,[event('keep',[['cause',0],['bearer',1]],past,'closed')]);
await story(5,[['Nora','name'],['Mira','name']],[event('push',[['actor',0],['target',1]])]);
await story(6,[['Mira','name'],['Nora','name']],[event('push',[['actor',0],['target',1]])]);
await story(7,hatch,[event('stay',[['bearer',0]],['modality_possible'],'closed')]);
await story(8,noraHatch,[event('keep',[['cause',0],['bearer',1]],[...past,'negation'],'closed')]);
await story(9,noraHatch,[event('keep',[['cause',0],['bearer',1]],past,'closed')],{act:'question'});
await story(10,noraHatch,[event('keep',[['cause',0],['bearer',1]],['modality_possible','negation'],'closed')],{runtime:2});
for(const [number,order] of [[13,[0,1]],[14,[1,0]]])await story(number,[...noraHatch,['Mira','name']],
 [event('CMP:0b0461b1975240868e0bed8d',[['cause',0],['bearer',1]]),event('MOV:110',[['actor',2]])],{relations:[{kind:'before',events:order}]});
await story(24,[['Nora','name'],['box','definite_nominal']],[event('find',[['experiencer',0],['target',1]]),event('lift',[['actor',0],['target',1]])]);
await story(48,[['Latch','name'],['result','definite_nominal'],['context','definite_nominal']],
 [event('find',[['experiencer',0],['target',1]]),event('find',[['experiencer',0],['target',2]])]);
await story(49,[['worker','definite_nominal']],[event('request completion',[['source',0]])]);
for(const [number,predicate,quality] of [[25,'happy_felt_mood','glad_or_content_mood'],[26,'sad_felt_mood','sorrow_or_low_spirits']]){
 const r=observations.get('audit-'+number),m=r.heard;
 assert.equal(m.predicate,predicate);assert.equal(m.meaning.quality,quality);assert.deepEqual(m.scopes,[]);
 assert.equal(m.runtime_state,1);assert.equal(m.speech_act,'assertion');
 assert.deepEqual(m.participants.experiencer.phonemes,(await encodeName('Nora')).phonemes);
 assert(r.chords_same_meaning&&r.chords_same_notes);
}
const sleep=observations.get('audit-46');assert.equal(sleep.heard.predicate,'LIF:002');assert.equal(sleep.heard.runtime_state,1);
assert.deepEqual(sleep.heard.participants.map(x=>[x.role,x.reference.phonemes]),[['bearer',(await encodeName('program')).phonemes]]);
assert.deepEqual(sleep.heard.scopes,[]);assert.equal(sleep.heard.speech_act,'assertion');assert(sleep.chords_same_meaning);
const matches=new Set([1,2,5,6,7,8,9,10,13,14,24,25,26,46,48,49]);
const notes={
 3:'The new state/adjective construction still stops when empty is added to the object.',
 5:'Physical sense confirmed. Picker uses the example Mira pushed the gate as its button label, rather than describing this sentence.',
 6:'Physical sense confirmed; the recovered actor/target order differs from audit-05.',
 16:'Conditional future will leave becomes modality_possible, with no time_after_speech. The song preserves a weaker proposition.',
 23:'Correctly presents both Nora and Mira as possible referents. This intentionally ambiguous test is not answered.',
 29:'Unknown physical pull offers find/search/see/care ahead of the builder; none is the intended action.',
 31:'Unknown dropping action is not supplied by adding an alias for lowering or pushing.',
 32:'Another meaning correctly stops the physical lifting score, but the restriction-removal meaning is missing.',
 33:'Undefined adjective is not translated automatically; unrelated adjective suggestions and wide picker remain UX problems.',
 34:'Undefined verb is not translated automatically; unrelated verb suggestions and wide picker remain UX problems.',
 35:'Preview draft translation ends with Nothing was translated; adding the contrast to the desire phrase exposes a composition gap.',
 39:'Existing copy-related vocabulary does not provide this whole-sentence reading.',
 40:'The special we need to delete it construction does not generalize to this past-tense subject/object sentence.',
 44:'Add to song succeeds; the general MIDI meaning decoder has no unique supported interpretation. Lexical love is retained; general sentence inverse coverage is missing.',
 45:'Memory vocabulary does not generalize to this subject/verb/object sentence.',
 46:'The approved dormant-self reading is preserved with runtime 1. This does not claim biological sleep physiology.',
 48:'Context explicitly identifies It as Latch; both finding events and distinct objects are retained.',
 49:'Existing request-completion convention supplies the requested outcome without asserting actual completion.'
};
const results=corpus.cases.map(entry=>{
 const r=observations.get(entry.id),number=Number(entry.id.slice(-2));let status='unsupported_whole_meaning';
 if(matches.has(number))status=r.answers.length?'intended_after_clarification':'intended_direct';
 else if(number===16)status='changed_meaning';
 else if(number===23)status='appropriate_referent_question';
 else if([33,34].includes(number))status='appropriate_definition_required';
 else if(number===44)status='song_without_general_meaning_decode';
 return {id:entry.id,group:entry.group,text:entry.text,intended:entry.intended,status,
  note:notes[number]||(!matches.has(number)?'No complete song matching the written intention was produced.':
   'Recovered participants, predicate, time/scope, runtime and speech act match the written intention.'),
  source:entry.source,initial_summary:r.initial.summary,final_summary:r.final.summary,
  horizontal_overflow:r.final.page_width>390};
});
const counts={};for(const r of results)counts[r.status]=(counts[r.status]||0)+1;
const report={method:'Written intentions frozen before the first run; post-run engineering adjudication, with explicit checks for recovered positive meanings. No grading data enters the listener. Purposive diagnostic, not representative accuracy or independent held-out validation.',counts,results};
fs.writeFileSync(new URL('../'+prefix+'adjudication.json',import.meta.url),JSON.stringify(report,null,2)+'\n');
const lines=['# Whole-input audit ledger — 2026-11-22','','See [audit findings](../full_language_music_audit_2026_11_22.md) for scope and limitations.','','| Case | Input | Result | Evidence / next action |','|---|---|---|---|'];
for(const r of results)lines.push(`| ${r.id} | ${r.text.replaceAll('|','\\|')} | ${r.status.replaceAll('_',' ')} | ${r.note} |`);
fs.writeFileSync(new URL('../'+prefix+'case_ledger.md',import.meta.url),lines.join('\n')+'\n');
console.log(counts);
