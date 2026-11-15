import assert from 'node:assert/strict';
import fs from 'node:fs';
import {dictionaryClausePlan} from '../pages/dictionary_clauses.mjs';
import {scoreDictionaryClause,decodeDictionaryClauseMidi} from '../pages/dictionary_clause_music.mjs';
import {mountDictionaryClause} from '../pages/dictionary_clause_controls.mjs';
import {readWordChoices,updateWordChoice} from '../pages/dictionary_word_choices.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {scoreSongText} from '../pages/song_lines.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {decodeFaultCorrectionMidi} from '../pages/fault_correction.mjs';
import {emptyLocalCompounds,addLocalCompound} from '../pages/local_compounds.mjs';
import {localVerbPlan,composeLocalVerb,composeLocalAdjective} from '../pages/local_compound_english.mjs';
import {encodeName} from '../pages/names.mjs';

const data=f=>JSON.parse(fs.readFileSync(new URL('../pages/'+f,import.meta.url))),a=data('data/index.json');
const load=id=>a.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority:a}:{...data(a.resolution_files[id]).variants['assertion:1'],authority:a};
const score=(p,i=0)=>scoreDictionaryClause(p,i,a);
const roundtrip=async line=>assert.deepEqual(decodeDictionaryClauseMidi(line.midi,a.atoms),line.meaning);
let n=0;
for(const verb of ['repair','find','notice','approach','damage','create']){
  for(const subject of ['We','I','Ada']){
    for(const object of ['the gate','this sensor']){
      for(const state of [0,1,2]){
        const needs=subject==='Ada'?'needs':'need';
        for(const [modal,scope] of [[needs+' to','modality_necessary'],['might','modality_possible']]){
          const text=subject+' '+modal+' '+verb+' '+object+' ['+state+'].';
          const plan=dictionaryClausePlan(text,a);assert(plan,text);assert.equal(plan.needsDefinition,false);
          const s=await score(plan);await roundtrip(s);assert.equal(s.meaning.runtime_state,state);
          assert.deepEqual(s.meaning.scopes,[scope]);assert.equal(s.meaning.participants.length,2);
          if(subject==='We')assert.equal(s.meaning.participants[0].reference.role,'speaker_group');
          assert.deepEqual(s.meaning.participants[1].reference.phonemes,(await encodeName(object.split(' ')[1])).phonemes);n++;
        }
      }
    }
  }
}
for(const [text,id,roles,scopes,act] of [
  ['I found a compass.','MIN:110',['experiencer','target'],['time_before_speech'],'assertion'],
  ['We need to send the message to Ada.','DAT:111',['source','content','recipient'],['modality_necessary'],'assertion'],
  ['You might not restore the sensor.','REP:111',['source','target'],['modality_possible','negation'],'assertion'],
  ['Do we need to delete the file?','erase_stored_object',['actor','target'],['modality_necessary'],'question'],
  ['Did Aru notice the signal?','MIN:011',['experiencer','target'],['time_before_speech'],'question'],
  ['The robot is sick.','WRN:001',['bearer'],[],'assertion'],
  ['We need to be awake tomorrow.','LIF:001',['bearer'],['time_next_day','modality_necessary'],'assertion']
]){
  const p=dictionaryClausePlan(text,a);assert(p,text);const i=p.readings.findIndex(r=>r.root===id);assert(i>=0,text);
  const s=await score(p,i);await roundtrip(s);assert.deepEqual(s.meaning.participants.map(x=>x.role),roles);assert.deepEqual(s.meaning.scopes,scopes);assert.equal(s.meaning.speech_act,act);
  assert.deepEqual(decodeDictionaryClauseMidi(expandChordMidi(compactChordMidi(s.midi,a.atoms),a.atoms),a.atoms),s.meaning);
  assert.deepEqual(await decodeSupportedMeaningWithDrafts(s.midi,a.atoms,[],{allowDraft:true}),s.meaning);
  if(text.includes('compass'))assert.equal(s.meaning.participants[1].reference.reference_mode,'indefinite_singular');
}
const fix=await scoreSongText('We need to repair the gate.',a,load);
assert.equal(fix.meaning.predicate,'REP:110');
const mixed=await scoreSongText('I found a compass. We need to delete the file.',a,load);
assert.deepEqual(mixed.meaning.map(m=>m.predicate),['MIN:110','erase_stored_object']);
for(const text of ['We need to fix the gate and run.','We need to restore it.','Please fix the sensor.','We might send the extremely bright signal to Ada.','We need to repairs the gate.','We need to delete a child.']){
 assert.equal(dictionaryClausePlan(text,a),null,text);
}
for (const [text,actor,mode] of [['Mira might need to resolve a backup error.','mira','indefinite_singular'],['Do we need to correct this sensor error?','speaker_group','proximal_nominal']]){
 const s=await scoreSongText(text,a,load),d=await decodeFaultCorrectionMidi(s.midi,a.atoms);assert.deepEqual(s.meaning,d);assert.equal(d.fault.reference_mode,mode);
 if(actor==='mira')assert.deepEqual(d.actor.phonemes,(await encodeName(actor)).phonemes);else assert.equal(d.actor.role,actor);
}
const open=await scoreSongText('Aru needs to resolve the "gyroflux" error.',a,load);
assert.deepEqual((await decodeFaultCorrectionMidi(open.midi,a.atoms)).fault.type_label,{phonemes:(await encodeName('gyroflux')).phonemes});

const storage=new Map(),store={getItem:k=>storage.get(k)??null,setItem:(k,v)=>storage.set(k,v)};
for(const text of ['Back up the file.','Please pick up the radio.','Turn off the sensor.']){
 const p=dictionaryClausePlan(text,a,{offerDefinition:true});
 assert.equal(p.speechAct,'command',text);assert(p.needsDefinition,text);
 assert.equal(p.readings[0].word.toLowerCase(),text.toLowerCase().replace(/^please /,'').split(' ').slice(0,2).join(' '));
 assert(p.readings.every(r=>r.participants[0].text==='you'));
 assert.equal(await scoreSongText(text,a,load),null,'No music before a meaning is supplied.');
}
const wake=dictionaryClausePlan('Power on.',a,{offerDefinition:true});
const wakeIndex=wake.readings.findIndex(r=>r.root==='LIF:101');assert(wakeIndex>=0);
const command=await score(wake,wakeIndex);
const commandMeaning=await decodeSupportedMeaningWithDrafts(expandChordMidi(compactChordMidi(command.midi,a.atoms),a.atoms),a.atoms,[],{allowDraft:true});
assert.deepEqual(commandMeaning,command.meaning);
assert.equal(commandMeaning.speech_act,'command');assert.equal(commandMeaning.participants[0].reference.role,'addressee');
const savedPhrase=updateWordChoice(store,wake.readings[wakeIndex],wake.preferenceForms);
for(const [text,act] of [['Power on.','command'],['Mira powers on.','assertion'],['Did Mira power on?','question']]){
 const performed=await scoreSongText(text,a,load,savedPhrase);
 assert.equal(decodeDictionaryClauseMidi(performed.midi,a.atoms).speech_act,act);
}
updateWordChoice(store,wake.readings[wakeIndex],wake.preferenceForms,true);
assert.equal(dictionaryClausePlan('Backed up the file.',a,{offerDefinition:true}),null);
assert.equal(dictionaryClausePlan('We backed up the file.',a,{offerDefinition:true}).readings[0].word,'backed up');
const unknown='We need to glimmerseal the hatch.';assert.equal(await scoreSongText(unknown,a,load),null);
const pick=dictionaryClausePlan(unknown,a,{offerDefinition:true});assert(pick.needsDefinition);
class El{
  children=[];listeners={};value='';isConnected=true;
  append(...x){this.children.push(...x);}replaceChildren(...x){this.children=x;}
  addEventListener(type,fn){this.listeners[type]=fn;}
}
let added,played,status,current=true;
function mount(plan){
 const container=new El();
 const work=mountDictionaryClause(container,plan,a,{document:{createElement:()=>new El()},player:{play:b=>{played=b;},stop(){}},add:(...args)=>{added=args;},download(){},
   remember:(r,forms,forget)=>updateWordChoice(store,r,forms,forget),onStatus:msg=>{status=msg;},isCurrent:()=>current,onError:e=>assert.fail(e.message)});
 return work.then(()=>{const card=container.children[0],output=card.children.at(-1),sel=card.children.find(e=>e.children.some(c=>'value' in c))?.children[0];
 return {sel,output,button:name=>output.children.find(e=>e.textContent===name)?.listeners.click};});
}
const ui=await mount(pick);assert.equal(ui.sel.value,'');assert.match(status,/Choose a meaning/);assert.equal(ui.button('Add to song'),undefined);
const idx=pick.readings.findIndex(r=>r.root==='REP:110');assert(idx>=0);ui.sel.value=String(idx);await ui.sel.listeners.change();assert.match(status,/Whole sentence ready/);assert(ui.sel.children.some(o=>o.textContent.includes('repair')&&o.textContent.includes('REP:110')));
await ui.button('Play whole sentence')();await ui.button('Add to song')();assert.deepEqual(played,added[1]);assert.equal(added[0],unknown);
const old=ui.button('Add to song');await ui.button('Use this meaning next time')();
const prefs=readWordChoices(store);
for(const t of ['You might glimmerseal a valve.','Mira glimmerseals this radio.','Aru glimmersealed the door.']){
 const plan=dictionaryClausePlan(t,a,{preferences:prefs});assert(plan.preferred>=0,t);
 const s=await scoreSongText(t,a,load,prefs);await roundtrip(s);assert.equal(s.meaning.predicate,'REP:110',t);
}
const localAuthority={...a,local_senses:[{...a.senses.find(s=>s.lemma==='repair'&&s.route==='atom'),sense_id:'LOCAL:exact',local_review:true,lemma:'timbrel',surface_forms:['timbrel'],target_id:'REP:110'}]};
const prior=await scoreSongText('Ada might timbrel this radio.',localAuthority,load);
assert.equal(prior.meaning.predicate,'REP:110');
const oldStyle=prefs.map(({root,...rest})=>rest);
assert.equal((await scoreSongText('You might glimmerseal the gate.',a,load,oldStyle)).meaning.predicate,prefs[0].target);
const other=pick.readings.findIndex(r=>r.root==='WRN:111');ui.sel.value=String(other);await ui.sel.listeners.change();added=null;await old();assert.equal(added,null);await ui.button('Add to song')();assert.equal(decodeDictionaryClauseMidi(added[1],a.atoms).predicate,'WRN:111');
const poly=dictionaryClausePlan('We change the record.',a);assert(poly.readings.length>=3);let chords=[];
for(let i=0;i<poly.readings.length;i++){const s=await score(poly,i);chords.push(Buffer.from(compactChordMidi(s.midi,a.atoms)).toString('hex'));}assert.equal(new Set(chords).size,chords.length);
const userDefined={label:'glowmend',definition:'A saved restoration with a light qualifier.',part_of_speech:'verb',roles:[{role:'actor',definition:'Who does it'},{role:'target',definition:'What receives it'}],components:[{relation:'head',target_id:'REP:111'},{relation:'qualifies',target_id:'MAT:001'}]};
const reg=await addLocalCompound(emptyLocalCompounds(),userDefined,a);
const line='We might not need to glowmend this sensor. [2]';
const local=await localVerbPlan(line,reg,a);assert(local);const scoped=await composeLocalVerb(line,reg,a,{subjectRole:'actor',objectRole:'target'});
assert.equal(scoped.meaning.compound_id,reg.entries[0].compound_id);assert.deepEqual(scoped.meaning.scopes.map(s=>s.mode||s.operator),['possible','negation','necessary']);assert.equal(scoped.meaning.bindings[0].reference.deictic_role,'speaker_group');assert(scoped.events.some(e=>e.marker==='speaker_group_open'));
const adj=await addLocalCompound(reg,{...userDefined,label:'glowsteady',part_of_speech:'adjective',roles:[{role:'bearer',definition:'Who has the quality'}]},a);
const quality=await composeLocalAdjective('We need to be glowsteady.',adj,a);assert.equal(quality.meaning.bindings[0].reference.deictic_role,'speaker_group');
console.log('PASS '+n+' interchangeable dictionary sentences plus transfer, question, negation, adjective, new and remembered verbs, saved compounds and MIDI inverses.');
