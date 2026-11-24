import {fileURLToPath} from 'node:url';
// Adjudication of the frozen written intentions, kept separate from the listener.
// These checks were authored after observing the outputs; the written intentions
// were not changed. This is an engineering diagnostic, not independent judging.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {encodeName} from '../../pages/names.mjs';
import {storyWords} from '../../pages/story_words.mjs';
const read=p=>JSON.parse(fs.readFileSync(p.startsWith('/')?p:new URL('../../'+p,import.meta.url)));
const prefix=fileURLToPath(new URL('./',import.meta.url));
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

const physical=event('lower',[['actor',0],['target',1]]);physical.arguments[0].properties=['CMP:3c13b9c619d95f1c40ea5da5'];physical.arguments[1].properties=['CMP:7e3cdc51fe00e1c61e5e9f12'];
await story(3,[['worker','definite_nominal'],['box','definite_nominal']],[physical]);
await story(11,noraHatch,[event('open',[['cause',0],['bearer',1]],['modality_obligated','negation'])]);
await story(12,noraHatch,[event('open',[['cause',0],['bearer',1]],['negation','modality_obligated'])]);
await story(16,[...noraHatch,['Mira','name']],[event('open',[['cause',0],['bearer',1]],[]),event('MOV:101',[['actor',2]],['time_after_speech'])],{relations:[{kind:'condition',events:[0,1]}]});
for(const [number,quantifier,negative] of [[19,'all',true],[20,'none',false]]){
 const r=observations.get('audit-'+number),m=r.heard;
 assert.deepEqual(m.entities,[{identity:{kind:'phonemic',reference_mode:'nominal_class',phonemes:(await encodeName('worker')).phonemes,instance_code:null},plural:true,owner:null}]);
 const expected=event('wait',[['actor',0]]);expected.quantifier=quantifier;expected.negated_quantifier=negative;
 assert.deepEqual(m.events,[expected]);assert.deepEqual(m.relations,[]);assert.equal(m.runtime_state,1);assert.equal(m.speech_act,'assertion');
}
await story(29,[['Nora','name'],['box','definite_nominal']],[event('pull',[['actor',0],['target',1]])]);
await story(31,[['Nora','name'],['box','definite_nominal']],[event('drop',[['actor',0],['target',1]])]);
await story(39,[['Nora','name'],['record','definite_nominal']],[event('CMP:9ea919967152aa85bc1c7169',[['actor',0],['target',1]])]);
await story(40,[['Nora','name'],['record','definite_nominal']],[event('erase_stored_object',[['actor',0],['target',1]])]);
const comparison=observations.get('audit-27').heard;
assert.equal(comparison.profile,'EZPROPERTYCOMPARE-1');assert.equal(comparison.dimension,'thermodynamic_temperature');assert.equal(comparison.relation,'less_than');assert.deepEqual(comparison.scopes,[]);
assert.deepEqual(comparison.participants,{bearer:{kind:'phonemic',reference_mode:'definite_nominal',phonemes:(await encodeName('water')).phonemes},comparison_standard:{kind:'phonemic',reference_mode:'definite_nominal',phonemes:(await encodeName('air')).phonemes}});
assert.equal(comparison.runtime_state,1);assert.equal(comparison.speech_act,'assertion');
const love=observations.get('audit-44').heard;assert.equal(love.profile,'EZLOVE-INVERSE-1');assert.equal(love.predicate,'CMP:44718c92b66443c0c0f03ad7');assert.equal(love.runtime_state,2);assert.equal(love.speech_act,'assertion');assert.deepEqual(love.scopes,[]);
assert.deepEqual(love.participants,{actor:{kind:'deictic',role:'speaker'},target:{kind:'deictic',role:'addressee'}});assert.deepEqual(love.meaning,{established_life_bond:true,self_awakening_facet:true,preserved_unexpressed_self_facet:true,qualifiers_are_separate_events:false,poetic_reading:'never_finished_becoming'});
const matches=new Set([1,2,3,5,6,7,8,9,10,11,12,13,14,16,19,20,24,25,26,27,29,31,39,40,44,46,48,49]);
const ambiguous=observations.get('audit-23');assert(!ambiguous.heard);assert(ambiguous.final.buttons.some(b=>b.text==='Nora (reference 1)'));assert(ambiguous.final.buttons.some(b=>b.text==='Mira (reference 2)'));
const notes={
 4:'Causing fear with an attributed subject still needs a whole-sentence construction.',
 15:'Until needs endpoint/continuation scope.',17:'Pair quantification is unsupported; the diagnostic also misclassifies workers as a missing verb.',18:'Restrictive only remains unsupported.',21:'Exact cardinality is unsupported; the diagnostic also misclassifies workers as a missing verb.',22:'Location and ordinal attachment remain unsupported.',
 28:'Very needs degree scope; asking for a new adjective definition is misleading.',30:'Placement beside a reference needs its spatial relation.',32:'The physical lifting alternative is correctly rejected; restriction removal is still missing.',
 33:'The undefined adjective remains unresolved.',34:'The undefined verb remains unresolved.',35:'The desired/needed contrast still fails after opening its preview.',36:'Knowledge of an embedded past proposition remains unsupported.',37:'Belief in an embedded past proposition remains unsupported.',38:'Promise needs commitment and future-content structure.',
 41:'The reduced deleting clause and distinct object need binding and event ordering.',42:'Continuation, future relevance and the speaker/listener relationships remain unsupported; remain itself has an indexed use.',43:'Preservation without imposed future determination remains unsupported.',45:'The available recall choice differs from retained memory; another meaning is correctly left unscored.',
 47:'A request noun phrase needs fuller nominal interpretation.',50:'An attributed record noun phrase needs fuller nominal interpretation.',51:'Ability, perception and the possessive reference remain unsupported.',52:'Path relation, returned outcome and negated permission remain unsupported.',53:'Continuation of possibility remains unsupported; remained itself has an indexed use.',54:'Requested restoration content and former preparation remain unsupported.',55:'Still and second need continuation/ordinal scope, rather than a new descriptor alias.',56:'Smaller allocation needs comparison and the returned object.',57:'Maintaining a described boundary needs the intended physical or nonphysical sense.',58:'Reference shortening and repetition remain unsupported.'};
const results=corpus.cases.map(entry=>{
 const r=observations.get(entry.id),number=Number(entry.id.slice(-2));let status='unsupported_whole_meaning';
 if(matches.has(number))status=r.answers.length?'intended_after_clarification':'intended_direct';
 else if(number===23)status='appropriate_referent_question';
 else if([33,34].includes(number))status='appropriate_definition_required';
 if(matches.has(number)){assert(r.heard);assert(r.chords_same_meaning&&r.chords_same_notes,entry.id);assert(!r.error&&r.errors.length===0,entry.id);}
 else assert(!r.heard,'Unexpected ungraded score '+entry.id);
 return {id:entry.id,text:entry.text,intended:entry.intended,status,note:notes[number]||'Recovered meaning matches the frozen intention; all specified roles, scopes, runtime and speech act were checked.',source:entry.source,final_summary:r.final.summary,horizontal_overflow:r.final.page_width>390};
});
const counts={};for(const r of results)counts[r.status]=(counts[r.status]||0)+1;
assert.equal(results.length,58);assert.equal(matches.size,28);
const report={revision:read(prefix+'initial.json').revision,method:'Original 58 written intentions unchanged; engineering checks updated after observation. No intended meaning or original text enters the decoder. Purposive diagnostic, not representative coverage or independent adjudication.',counts,results};
fs.writeFileSync(prefix+'adjudication.json',JSON.stringify(report,null,2)+'\n');console.log(counts);
