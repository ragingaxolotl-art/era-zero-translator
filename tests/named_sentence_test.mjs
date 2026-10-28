import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence,needsSentenceComposition} from '../pages/sentences.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const data=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const outputs=[];
const cases=[['Pip cares for Ada.','LIF:211'],['Ada cares for Pip.','LIF:211'],['Mira is caring for Sol.','LIF:211'],['Jun cares for Tavi.','LIF:211'],
  ['Pip is awakening Ada.','LIF:111'],['Mira is restoring Sol.','REP:111'],['Jun is damaging Tavi.','WRN:111'],
  ['Pip is physically repairing "the machine".','CMP:2816a7eeb356c2148b26beca'],
  ['"Repair unit" is physically repairing "blue pump".','CMP:2816a7eeb356c2148b26beca'],['Pip does not care for Ada.','LIF:211'],['Pip is not restoring Ada.','REP:111'],
  ['Pip is conscious.','LIF:011'],['Pip is dormant.','LIF:012'],['Pip is not conscious.','LIF:011'],['"the creature" is dormant.','LIF:012'],
  ['It is possible that Pip cares for Ada.','LIF:211'],
  ['It is necessary that Pip cares for Ada.','LIF:211'],
  ['It is possible that Pip does not care for Ada.','LIF:211'],
  ['It is not possible that Pip cares for Ada.','LIF:211'],
  ['It is possible that Pip is conscious.','LIF:011'],
  ['It is possible that it is necessary that Pip cares for Ada.','LIF:211']];
for(const [text,target] of cases){
  assert.equal(parseNamedSentence(text).predicate,target);
  const file=data.resolution_files[target];
  const document=JSON.parse(fs.readFileSync(new URL(`../pages/${file}`,import.meta.url)));
  const result=await composeNamedSentence(text,document.variants['assertion:1']);
  const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-e','ir=JSON.parse(STDIN.read);puts JSON.generate(EraZeroRenderer.render(ir))'],{cwd:new URL('..',import.meta.url),input:JSON.stringify(result.semantic_ir),encoding:'utf8',stdio:['pipe','pipe','pipe']}));
  assert.deepEqual(result.formal,ruby);
  outputs.push(result);
}
assert.notEqual(outputs[0].semantic_ir.utterance_id,outputs[1].semantic_ir.utterance_id);
assert.notDeepEqual(midiFromFormal(outputs[0].formal),midiFromFormal(outputs[1].formal));
assert.equal(outputs[7].semantic_ir.nodes.find(node=>node.node_id==='p').target_type,'compound');
assert.deepEqual(outputs[7].formal.performance.lexical_events.filter(event=>event.occurrence_id==='p').map(event=>event.target_id),['MAT:111','REP:111']);
for(const text of ['Pip never cares for Ada.','Pip cares for Ada and Sol.','Pip barely cares for Ada.','Pip cares for a curious Ada.','Pip cares for Ada tomorrow.','Pip is not restoring Ada tomorrow.','Pip is damaging Ada and Sol.','Pip was awakening Ada.','Pip is physically repairing the broken machine.','Pip is physically repairing "pump" tomorrow.']){
  assert.equal(parseNamedSentence(text),null,text);
  assert.equal(needsSentenceComposition(text),true,text);
}
for(const text of ['Pip is very conscious.','Pip was dormant.','Pip is dormant tomorrow.']){
  assert.equal(parseNamedSentence(text),null);
  assert.equal(needsSentenceComposition(text),true);
}
const conscious=outputs[11],dormant=outputs[12],notConscious=outputs[13];
assert.equal(conscious.semantic_ir.edges.find(edge=>edge.type==='fills_role').role,'bearer');
assert.equal(conscious.semantic_ir.nodes.filter(node=>node.kind==='phonemic_reference').length,1);
assert.equal(conscious.interpretation,'Pip is conscious.');
assert.equal(notConscious.interpretation,'Pip is not conscious.');
assert.notDeepEqual(midiFromFormal(conscious.formal),midiFromFormal(dormant.formal));
assert.notDeepEqual(midiFromFormal(notConscious.formal),midiFromFormal(dormant.formal));
assert.equal(parseNamedSentence('Pip is tired.'),null);
assert.equal(parseNamedSentence('Pip is asleep.'),null);
const modalMarkers=result=>scheduledLexicalEvents(result.formal).filter(event=>event.kind==='grammar_marker').map(event=>event.marker);
assert.deepEqual(modalMarkers(outputs[17]),['modality_possible_open','negation_open','negation_close','modality_possible_close']);
assert.deepEqual(modalMarkers(outputs[18]),['negation_open','modality_possible_open','modality_possible_close','negation_close']);
assert.notDeepEqual(midiFromFormal(outputs[17].formal),midiFromFormal(outputs[18].formal));
assert.notDeepEqual(midiFromFormal(outputs[15].formal),midiFromFormal(outputs[16].formal));
assert.deepEqual(modalMarkers(outputs[20]),['modality_possible_open','modality_necessary_open','modality_necessary_close','modality_possible_close']);
assert.equal(parseNamedSentence('It is possible that '.repeat(18)+'Pip cares for Ada.'),null);
assert.equal(parseNamedSentence('It is possible that Pip cares for Ada tomorrow.'),null);
assert.equal(needsSentenceComposition('It is possible that Pip moves.'),true);
assert.equal(needsSentenceComposition('active care'),false);
assert.equal(needsSentenceComposition('Pip cares for Ada.'),false);
console.log(`Named sentences: ${cases.length} full compositions match Ruby rendering; role reversal changes sound; unsupported additions never match.`);
