import assert from 'node:assert/strict';
import fs from 'node:fs';
import {dictionaryClausePlan,recognizedClausePredicate} from '../pages/dictionary_clauses.mjs';
import {scoreSongText} from '../pages/song_lines.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {updateWordChoice} from '../pages/dictionary_word_choices.mjs';

const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const load=id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:
  {...JSON.parse(fs.readFileSync(new URL('../pages/'+authority.resolution_files[id],import.meta.url))).variants['assertion:1'],authority};
const unsupported=[
  ['The file was deleted.','deleted'],['The file is deleted.','deleted'],
  ['Nora deleted the file from the folder.','deleted'],['Nora deletes the file from the folder.','deletes'],
  ['Nora is deleting the file from the folder.','deleting'],
  ['Nora copied the file to the folder.','copied'],['Nora will copy the file to the folder.','copy'],
  ['Nora is copying the file to the folder.','copying'],['Nora recalls.','recalls'],
  ['Nora remembers.','remembers'],['The box is full of water.','full'],['The box is empty of water.','empty'],
  ['Nora repaired the gate with a tool.','repaired'],['Mira can repair the gate with a tool.','repair']
];
for(const [text,word] of unsupported){
  assert.equal(recognizedClausePredicate(text,authority),word,text);
  assert.equal(dictionaryClausePlan(text,authority,{offerDefinition:true}),null,text+' must not offer unrelated aliases');
  assert.equal(await scoreSongText(text,authority,load),null,text+' must not drop unsupported details');
}
for(const [text,word] of [['Nora zorbled the file.','zorbled'],['The lamp is glimmerwise.','glimmerwise'],
  ['Nora copieded the file.','copieded'],['Nora recalleded Mira.','recalleded'],['Nora saves the file.','saves']]){
  assert.equal(recognizedClausePredicate(text,authority),null,text);
  const plan=dictionaryClausePlan(text,authority,{offerDefinition:true});
  assert(plan?.needsDefinition,text);assert.equal(plan.readings[0].word,word);
  assert.equal(await scoreSongText(text,authority,load),null,text);
}
for(const [text,word] of [['Nora copied the file.','copied'],['Nora remembers Mira.','remembers'],
  ['Nora is repairing the gate.','repairing'],['Mira might not delete the record.','delete'],
  ['The box is full.','full']])assert.equal(recognizedClausePredicate(text,authority),word,text);

// An explicitly saved personal meaning remains valid when its spelling later
// enters the public dictionary. A mismatched role or part of speech does not.
const withoutRecall={...authority,senses:authority.senses.filter(s=>!s.lemma.includes('recall')&&!(s.surface_forms||[]).some(f=>f.startsWith('recall')))};
const personal=dictionaryClausePlan('Nora recalls.',withoutRecall,{offerDefinition:true});
assert(personal?.needsDefinition);
const row=personal.readings.find(r=>r.root==='LIF:101');assert(row);
const store=new Map(),storage={getItem:k=>store.get(k)??null,setItem:(k,v)=>store.set(k,v)};
const preferences=updateWordChoice(storage,row,personal.preferenceForms);
assert(dictionaryClausePlan('Nora recalls.',authority,{preferences}).preferred>=0);
const selected=await scoreSongText('Nora recalls.',authority,load,preferences);assert(selected);
const decoded=await decodeSupportedMeaningWithDrafts(selected.midi,authority.atoms,[],{allowDraft:true});
assert.equal(decoded.predicate,'LIF:101');
for(const change of [{quality:true},{roles:'source/target'},{forms:['other']}]){
  assert.equal(dictionaryClausePlan('Nora recalls.',authority,{offerDefinition:true,preferences:preferences.map(p=>({...p,...change}))}),null);
}

// Replacing the installed personal lexicon refreshes recognition, just as it
// refreshes predicate parsing. Merely admitting a gap does not supply meaning.
const local={...authority,local_senses:[]};
assert.equal(recognizedClausePredicate('Nora timbrels the gate.',local),null);
local.local_senses=[{...authority.senses.find(s=>s.lemma==='repair'&&s.route==='atom'),lemma:'timbrel',surface_forms:['timbrel']}];
assert.equal(recognizedClausePredicate('Nora timbrels the gate.',local),'timbrels');
console.log('PASS 14 known unsupported constructions, 5 missing/malformed words, recognized forms, saved personal meanings and lexicon refresh.');
