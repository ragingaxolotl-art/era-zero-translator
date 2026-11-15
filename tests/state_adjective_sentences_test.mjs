import assert from 'node:assert/strict';
import fs from 'node:fs';
import {storyWords} from '../pages/story_words.mjs';
import {feltProperties} from '../pages/story_qualities.mjs';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
import {notesFromMidi,midiFromNoteTimeline} from '../pages/performance_codec.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {storyAdjectiveLibrary} from '../pages/story_saved_adjectives.mjs';
import {addLocalCompound,emptyLocalCompounds} from '../pages/local_compounds.mjs';
import {analyzeEnglish} from '../pages/english.mjs';
import {encodeName} from '../pages/names.mjs';

const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const word=name=>storyWords.find(w=>w.word===name)?.id||feltProperties[name];
const qualities=name=>({role:'bearer',definition:name});
const definition={label:'glowsteady',definition:'The source gives an even glow.',part_of_speech:'adjective',
  components:[{target_id:'MAT:000',relation:'qualifies'},{target_id:'LIF:001',relation:'head'}],
  roles:[qualities('The steady source')]};
let registry=await addLocalCompound(emptyLocalCompounds(),definition,authority);
const base=registry.entries[0].compound_id;
registry=await addLocalCompound(registry,{...definition,label:'star bright',definition:'A steady source lights a target.',
  components:[{target_id:base,relation:'head'},{target_id:'MAT:211',relation:'qualifies'}],
  roles:[...definition.roles,{role:'target',definition:'The illuminated participant'}],
  role_links:[{outer_role:'bearer',component_path:[0],role:'bearer'}]},authority);
const adjectives=await storyAdjectiveLibrary(registry,authority);
for(const e of adjectives.byId.values())assert(!e.unavailable,e.unavailable);
let checks=0;
async function heard(text,answers={},library){
  const plan=storyReading(text,authority,{answers,adjectives:library});
  assert(plan?.events,text+' '+JSON.stringify(plan?.question));
  const {midi}=await scoreStory(plan,authority);
  const melody=decodeStoryMidi(midi,authority.atoms,library);
  const compact=decodeStoryMidi(expandChordMidi(compactChordMidi(midi,authority.atoms),authority.atoms),authority.atoms,library);
  assert.deepEqual(compact,melody,text);checks++;
  return {midi,meaning:melody,event:melody.events[0]};
}
const identities=async (m,labels)=>assert.deepEqual(m.entities.map(e=>e.identity.phonemes),await Promise.all(labels.map(async l=>(await encodeName(l)).phonemes)));
for(const state of [0,1,2]){
  for(const [text,verb,condition,roles,entities] of [
    ['The gate was open.','passable',null,['bearer'],['gate']],
    ['The gate stayed open.','stay','passable',['bearer'],['gate']],
    ['Mira kept the gate open.','keep','passable',['cause','bearer'],['Mira','gate']],
    ['The hatch remained shut.','stay','closed',['bearer'],['hatch']],
    ['Nora kept the tool available.','keep','available for use',['cause','bearer'],['Nora','tool']],
    ['Mira pushed the gate.','push',null,['actor','target'],['Mira','gate']],
    ['Mira lifted the box.','lift',null,['actor','target'],['Mira','box']],
    ['Mira lowered the box.','lower',null,['actor','target'],['Mira','box']]]){
    const {event,meaning}=await heard(text+' ['+state+']',{condition0:'selected'});
    assert.equal(meaning.runtime_state,state);assert.equal(event.predicate,word(verb));
    assert.equal(event.condition,condition?word(condition):undefined);
    assert.deepEqual(event.scopes,['time_before_speech']);assert.deepEqual(event.arguments.map(a=>a.role),roles);
    assert.deepEqual(event.arguments.map(a=>a.entity),entities.map((_,i)=>i));await identities(meaning,entities);
  }
}
for(const [text,scopes,act] of [['The gate might stay open.',['modality_possible'],'assertion'],
  ['Did Nora not keep the box closed?',['time_before_speech','negation'],'question'],
  ['They kept the path open.',['time_before_speech'],'assertion'],
  ['Keep the hatch closed.',[],'command']]){
  const {event,meaning}=await heard(text,{subject0:'new:the routine'});assert.deepEqual(event.scopes,scopes);assert.equal(meaning.speech_act,act);
  assert.equal(event.condition,/open/.test(text)?word('passable'):word('closed'));
}
assert.equal((await heard('The permit remained valid.')).event.predicate,word('remain valid'));
for(const [text,role,adjective] of [['The curious child waited.','actor','curious'],
 ['The resumed stream waited.','actor','resume'],['The hungry child waited.','actor','hungry'],
 ['The tired child waited.','actor','tired'],['Mira noticed the thirsty child.','target','thirsty']]){
  const {event}=await heard(text,{property0Subjectcurious:'selected'});
  assert.deepEqual(event.arguments.find(a=>a.role===role).properties,[word(adjective)]);
}
const described=await heard('The hungry child lifted the closed box.');
assert.deepEqual(described.event.arguments.map(a=>a.properties),[[word('hungry')],[word('closed')]]);
const children=await heard('The hungry child noticed the tired child.');
assert.deepEqual(children.event.arguments.map(a=>[a.entity,...a.properties]),[[0,word('hungry')],[1,word('tired')]]);
const ambiguous=storyReading('Mira lifted the ban.',authority);
assert.match(ambiguous.question.prompt,/physical/);assert.equal(storyReading('Mira lifted the ban.',authority,{answers:{physical0:'other'}}),null);
const story=await heard('The curious child found the box. They lowered it.',{property0Subjectcurious:'selected'});
assert.equal(story.meaning.events[1].arguments[0].entity,story.event.arguments[0].entity);
assert.deepEqual(story.event.arguments[0].properties,[word('curious')]);
for(const [text,forbidden] of [['I will keep it.','keep'],['Keep listening.','keep'],['I will stay until you answer.','stay'],['Mira lifted the ban.','lift']]){
  const lookup=analyzeEnglish(text,authority);
  assert(!lookup.term_coverage.some(term=>term.matches?.some(m=>m.target_id===word(forbidden))),text);
}
const custom=await heard('The glowsteady lamp waited.',{},adjectives);
assert.deepEqual(custom.event.arguments[0].properties,[{local_id:base,bindings:[0]}]);
assert.throws(()=>decodeStoryMidi(custom.midi,authority.atoms),'A shared personal dictionary is required.');
// An intact dictionary ID cannot authenticate changed pitches inside its pronunciation.
const observed=decodeStrictMusicMidi(custom.midi,authority.atoms,{allowDraftInformationPassage:true});
const localMarker=observed.tokens.findIndex(t=>t.local_code);
const root=observed.tokens.slice(localMarker+1).find(t=>t.kind==='root');
const altered=notesFromMidi(custom.midi),attack=altered.notes.findIndex(n=>n.start_tick===root.start_tick);
altered.notes[attack+2].midi+=1;
assert.throws(()=>decodeStoryMidi(midiFromNoteTimeline(altered.notes,altered.division,altered.tempos[0].value),authority.atoms,adjectives));

const object=await heard('Mira lifted the glowsteady lamp.',{},adjectives);
assert.deepEqual(object.event.arguments[1].properties,[{local_id:base,bindings:[1]}]);
const paired=await heard('The glowsteady and closed gate reopened.',{},adjectives);
assert.deepEqual(paired.event.arguments[0].properties,[{local_id:base,bindings:[0]},word('closed')]);
const customState=await heard('Nora kept the lamp glowsteady.',{},adjectives);
assert.deepEqual(customState.event.condition,{local_id:base,bindings:[1]});
const question=storyReading('The star bright lamp waited.',authority,{adjectives}).question;
assert(question.allowName);assert.match(question.prompt,/target/);
const related=await heard('The star bright lamp waited.',{[question.key]:'new:Ada'},adjectives);
assert.deepEqual(related.event.arguments[0].properties,[{local_id:registry.entries[1].compound_id,bindings:[0,1]}]);
await identities(related.meaning,['lamp','Ada']);
const shadow=await addLocalCompound(registry,{...definition,label:'closed',definition:'A private meaning for a closed circuit.'},authority);
const shadowLibrary=await storyAdjectiveLibrary(shadow,authority);
const ask=storyReading('The closed gate waited.',authority,{adjectives:shadowLibrary}).question;
assert.match(ask.prompt,/Which meaning/);
assert.deepEqual((await heard('The closed gate waited.',{[ask.key]:'dictionary'},shadowLibrary)).event.arguments[0].properties,[word('closed')]);
assert.deepEqual((await heard('The closed gate waited.',{[ask.key]:'saved'},shadowLibrary)).event.arguments[0].properties,[{local_id:shadow.entries.at(-1).compound_id,bindings:[0]}]);
console.log('PASS '+checks+' whole-sentence melody and compact-chord readings, including nested saved adjectives.');
