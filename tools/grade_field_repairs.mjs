// Grade observed browser downloads against the written intentions. Names below
// identify the expected sound only. They do not enter the music listener.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {encodeName} from '../pages/names.mjs';
import {storyWords} from '../pages/story_words.mjs';
const read=path=>JSON.parse(fs.readFileSync(path));
const local=file=>new URL('../'+file,import.meta.url);
const intentions=read(local('tests/field_audit/intentions.json')).cases;
const fresh=read(local('tests/field_audit/repair_reserve.json')).map((r,i)=>({...r,id:'fresh-'+(i+1),group:'reserve'}));
const repairAnswers=read(local('tests/field_audit/repair_answers.json'));
const word=name=>storyWords.find(w=>w.word===name)?.id||name;
const past=['time_before_speech'], denied=[...past,'negation'], uncertain=['modality_possible','negation'];
const participant=async text=>{
  const roles={I:'speaker',we:'speaker_group',you:'addressee'};
  if(roles[text])return {kind:'deictic',role:roles[text]};
  if(text[0]==='@')return {kind:'domain',domain:text.slice(1)};
  const prefix=text.split(' ')[0],mode={the:'definite_nominal',a:'indefinite_singular',class:'nominal_class',some:'indefinite_plural'}[prefix];
  return {kind:'phonemic',reference_mode:mode||'name',phonemes:(await encodeName(mode?text.slice(prefix.length+1):text)).phonemes,instance_code:null};
};
const event=(predicate,args,scopes=past,quantifier=null,negated_quantifier=false)=>({
  predicate:word(predicate),arguments:args.split(' ').map(item=>{
    const [role,index,props='',alternative]=item.split('/');
    return {role,entity:Number(index),properties:props?props.split('+').map(word):[],...(alternative?{coordination:'any_of',alternatives:[{entity:Number(alternative),properties:[]}]}:{})};
  }),scopes,quantifier,negated_quantifier
});
const story=(names,events,relations=[])=>({names:names.split('|'),events,relations});
const before=(a,b)=>({kind:'before',events:[a,b]});
const and={kind:'and',events:[0,1]}, condition={kind:'condition',events:[0,1]};
const findAgain=(agent,first,second)=>story([agent,first,second].join('|'),[event('find','experiencer/0 target/1'),event('find','experiencer/0 target/2')]);
const spotting=(agent,obj,quality)=>story(agent+'|a '+obj,[event('spot','experiencer/0 target/1/'+quality),event('REP:110','source/0 target/1')]);
const passage=spotting('the routine','gate','blocked');
const conditional=(cause,consequence)=>story('the '+cause+'|the '+consequence,[event('reopen','bearer/0',[]),event('wait','actor/1',['time_after_speech'])],[condition]);
const either=(agent,one,two)=>story(agent+'|the '+one+'|the '+two,[event('notice','experiencer/0 target/1//2')]);
const request=agent=>story('the '+agent,[event('request completion','source/0')]);
const make=result=>story('I|a '+result+'|you',[event('CRE:110','source/0 result/1 recipient/2',['ability'])]);
const f={
 'leave-home':story('I|the home',[event('MOV:101','actor/0 source/1',['time_at_speech','aspect_ongoing'])]),
 'approach-question':story('the robots|the bridge',[event('MOV:111','actor/0 destination/1',['aspect_ongoing'])]),
 'not-moving':story('I',[event('MOV:121','actor/0',['negation','aspect_ongoing'])]),
 'few':story('@contextual',[event('wait','actor/0',past,'few')]),
 'few-robots':story('class robots',[event('wait','actor/0',past,'few')]),
 'no-one':story('@people',[event('wait','actor/0',past,'none')]),
 latch:findAgain('Latch','the result','the context'),
 'work-handoffs':story('Latch|the handoffs',[event('hand off work','source/0 content/1')]),
 'not-all':story('the radios',[event('ring','source/0/faulty',past,'all',true)]),
 none:story('the radios',[event('ring','source/0/faulty',past,'none')]),
 'two-names':story('Pip|Mira',[event('notice','experiencer/0 target/1'),event('wait','actor/1')]),
 'program-subject':passage,'paragraph-break':passage,
 paired:{...spotting('Pip','bell','cracked+faulty'),relations:[and]},
 negated:story('Pip|a bell',[event('spot','experiencer/0 target/1/cracked',denied)]),
 'possible-negated':story('Pip|a bell',[event('spot','experiencer/0 target/1/cracked',uncertain)]),
 'negated-reopen':story('the gate',[event('reopen','bearer/0',denied)]),
 'open-file':story('the file',[event('open for use','bearer/0')]),
 'open-path':story('the path',[event('passable','bearer/0')]),
 'resume-meeting':story('the meeting',[event('resume','bearer/0')]),
 'transitive-reopen':story('the pilot|the gate',[event('reopen','cause/0 bearer/1')]),
 disjunction:either('Pip','bell','gate'),conditional:conditional('gate','routine'),
 hear:story('I|the bell',[event('hear','experiencer/0 source/1',['ability'])]),
 see:story('I|the bell',[event('see','experiencer/0 source/1',['ability'])]),
 'numeric-name':story('Pip|Gate 2',[event('notice','experiencer/0 target/1')]),
 lowercase:story('Pip|a bell',[event('spot','experiencer/0 target/1/cracked')]),
 question:story('Pip|the gate',[event('spot','experiencer/0 target/1')]),
 'newline-clause':spotting('Pip','bell','cracked'),
 'nothing-followed':story('@things',[event('follow','bearer/0',past,'none')]),
 'requested-completion':request('worker'),
 'checked-again':story('Latch|the store',[event('recheck','actor/0 target/1')]),
 'remained-valid':story('the result',[event('remain valid','bearer/0')]),
 'make-replay':make('replay'),
 'have-replays':story('we|some replays',[event('have','bearer/0 target/1',[])]),
 'door-opened':story('the door',[event('open','bearer/0')]), wrong:story('we',[event('wrong','bearer/0')]),
 'fresh-1':story('class lanterns',[event('ring','source/0',past,'few')]),
 'fresh-2':story('@people',[event('wait','actor/0',past,'none')]),
 'fresh-3':findAgain('the resolver','the report','the log'),
 'fresh-5':story('the compiler|the assignments',[event('hand off work','source/0 content/1')]),
 'fresh-6':story('Nora|the alarm',[event('notice','experiencer/0 target/1',uncertain)]),
 'fresh-7':story('Nora|a radio',[event('notice','experiencer/0 target/1/faulty')]),
 'fresh-9':story('the engineer|the tunnel',[event('reopen','cause/0 bearer/1')]),
 'fresh-10':story('the worker|the log',[event('recheck','actor/0 target/1')]),
 'fresh-11':story('the permit',[event('remain valid','bearer/0')]),
 'fresh-12':request('service'),'fresh-13':make('map'),'fresh-14':conditional('tunnel','monitor'),
 'fresh-15':either('Nora','lamp','bell'),'fresh-17':story('the file',[event('open for use','bearer/0')]),
 'fresh-18':spotting('Nora','radio','cracked')
};
for(const runtime of [0,1,2])f['reopen-'+runtime]=story('the gate',[event('reopen','bearer/0')]);
for(const [key,relation] of [['before',before(0,1)],['after',before(1,0)]])
  f[key]=story('Pip|a bell|Mira',[event('REP:110','source/0 target/1/cracked'),event('MOV:110','actor/2')],[relation]);
const named={'reverse-a':['Mira','Pip'],'reverse-b':['Pip','Mira'],'arrive-station':['Mira','the station'],'fresh-8':['Mira','Nora']};
async function gradeMeaning(id,m){
  assert.equal(m.runtime_state,/^reopen-([012])$/.test(id)?Number(id.at(-1)):1);
  assert.equal(m.speech_act,['approach-question','question','fresh-7'].includes(id)?'question':'assertion');
  if(f[id]){
    const {names,events,relations}=f[id];assert.equal(m.profile,'EZ-STORY-1');
    const entities=await Promise.all(names.map(async name=>({identity:await participant(name),owner:null,
      plural:name==='we'||name.startsWith('@')||/^(?:class|some) /.test(name)||['the handoffs','the robots','the radios','the assignments'].includes(name)})));
    assert.deepEqual(m.entities,entities);assert.deepEqual(m.events,events);assert.deepEqual(m.relations,relations);
  }else if(named[id]){
    const [from,to]=named[id],arrival=id==='arrive-station';
    assert.equal(m.predicate,arrival?'MOV:110':'REP:110');assert.deepEqual(m.participants,{actor:await participant(from),[arrival?'destination':'target']:await participant(to)});
    assert.deepEqual(m.scopes,[{operator:'time',relation:'before_speech'}]);
  }else if(['fault','verb-paraphrase','fresh-16'].includes(id)){
    assert.deepEqual(m.actor,await participant('we'));assert.deepEqual(m.scopes,['necessary']);
    assert.deepEqual(m.action,{kind:'correct_fault',restoration_root:'REP:110',event_asserted:false});
    assert.deepEqual(m.fault,{class_root:'WRN:000',reference_mode:'definite_nominal',type_label:{fault:'redundancy','verb-paraphrase':'duplicate','fresh-16':'checksum'}[id]});
  }else if(id==='found-delete'){
    const group=await participant('we'),program=await participant('the program');
    assert.deepEqual(m.discovery,{actor:group,target:program,time:'before_speech',present_perfect:true});assert.equal(m.classification,'CMP:2f350e7d8e5dfba4a802d82d');
    assert.deepEqual(m.requirement,{actor:group,mode:'necessary',target:program,action:'erase_stored_object',event_asserted:false});
  }else if(id==='negative-need'||id==='need-negative'){
    assert.equal(m.predicate,'erase_stored_object');assert.deepEqual(m.scopes,id==='negative-need'?['negation','modality_necessary']:['modality_necessary','negation']);
    assert.deepEqual(m.participants,[{role:'actor',reference:await participant('we')},{role:'target',reference:await participant('the program')}]);
  }else if(id==='fresh-4'){
    assert.equal(m.predicate,'physical_carrying');assert.deepEqual(m.participants,{carrier:await participant('the porter'),load:await participant('the crate')});
    assert.deepEqual(m.scopes,[{operator:'time',relation:'before_speech'},{operator:'aspect',aspect:'bounded'}]);assert.equal(m.meaning.same_load,true);assert.equal(m.meaning.arrival_asserted,false);
  }else if(id==='know-want'){
    assert.equal(m.discourse,'then');assert.deepEqual(m.knowledge,{kind:'knows_answer',knower:await participant('I'),scopes:['negation'],
      question:{kind:'identity',additional:true,restriction:{kind:'wanted_by',wanter:await participant('you'),scopes:[],relation_to_value:'unspecified'}}});
  }else throw Error('No grading criteria for '+id);
}
const [out,...files]=process.argv.slice(2);
if(!out||!files.length)throw Error('Supply output JSON followed by browser observation JSON files from the same site.');
const cases=new Map(),sites=new Set();
for(const file of files){
  const observation=read(file);assert.deepEqual(observation.errors,[]);sites.add(new URL(observation.site).href);
  observation.results.forEach(row=>cases.set(row.id,row));
}
assert.equal(sites.size,1);const results=[];
for(const test of [...intentions,...fresh]){
 const row=cases.get(test.id);assert(row,'No browser result for '+test.id);
 try{
   const selected=(repairAnswers[test.id]||test.answers||[]).map(a=>a.button||a.referent);
   assert.deepEqual(row.answers,selected);assert(row.meaning,'No unique whole-line reading');
   await gradeMeaning(test.id,row.meaning);
   assert(row.chords_restore_melody&&row.chords_restore_reading);assert(row.chords.three_note_attacks>0);
   assert(row.chords.seconds<row.melody.seconds);
   const display=row.final.explanation.toLowerCase();
   if(['negated','negated-reopen'].includes(test.id))assert(display.includes('does not hold'));
   if(['possible-negated','fresh-6'].includes(test.id))assert(display.includes('possible')&&display.includes('does not hold'));
   if(test.id==='negative-need')assert(display.includes('not required'));
   if(test.id==='need-negative')assert(display.includes('required')&&display.includes('does not hold'));
   results.push({id:test.id,group:test.group,text:test.text,intended:test.intended,choice:selected,
     result:'intended meaning recovered',melody_seconds:row.melody.seconds,chord_seconds:row.chords.seconds,three_note_attacks:row.chords.three_note_attacks});
 }catch(error){console.error(test.id,error.message.slice(0,500));results.push({id:test.id,result:'failed',reason:error.message});}
}
fs.writeFileSync(out,JSON.stringify({site:[...sites][0],results},null,2)+'\n');
const failures=results.filter(r=>r.result==='failed');
console.log(results.length-failures.length,'of',results.length,'intended readings recovered');
if(failures.length)process.exitCode=1;
