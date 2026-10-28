import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence,needsSentenceComposition,confidenceFromPercent} from '../pages/sentences.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const data=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const outputs=[];
const calendarCases=[['Nora cared for Eli yesterday.','LIF:211'],['Nora did not care for Eli yesterday.','LIF:211'],['I was conscious yesterday.','LIF:001'],['Nora will care for Eli tomorrow.','LIF:211'],['Nora is conscious today.','LIF:011']];
const pastCases=[
 ['Nora was restoring Eli.','REP:111'],['Nora restored Eli.','REP:110'],
 ['Nora was physically repairing "the radio".','CMP:2816a7eeb356c2148b26beca'],
 ['Nora physically repaired "the radio".','CMP:22f8ddc4d9b2d1a818d38e9f'],
 ['Nora did not restore Eli.','REP:110'],['Nora was not restoring Eli.','REP:111'],
 ['Nora awakened Eli yesterday.','LIF:110'],['Nora damaged "the radio" today.','WRN:110'],
 ['I was conscious.','LIF:001'],['You were dormant.','LIF:012'],['Pip was awakening Ada.','LIF:111'],['Pip was dormant.','LIF:012']
];
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
  ['It is possible that it is necessary that Pip cares for Ada.','LIF:211'],
  ['Pip is moving toward Ada.','MOV:111'],
  ['Pip is moving away from Ada.','MOV:101'],
  ['Pip is moving relative to Ada.','MOV:121'],
  ['Pip is not moving toward "the station".','MOV:111'],
  ['It is possible that Pip is moving away from "the station".','MOV:101'],
  ['Data "the record" is being transferred from Pip to Ada.','DAT:111'],
  ['Data "the record" is being transferred from Ada to Pip.','DAT:111'],
  ['Data "the record" is not being transferred from Pip to Ada.','DAT:111'],
  ['It is possible that data "the record" is being transferred from Pip to Ada.','DAT:111'],
  ['With 70% confidence, it is possible that Pip cares for Ada.','LIF:211'],
  ['With 80% confidence, it is possible that Pip cares for Ada.','LIF:211'],
  ['With 0.1% confidence, it is possible that Pip does not care for Ada.','LIF:211'],
  ['Pip is paying attention to Ada.','MIN:211'],
  ['Pip is revising a mental representation of Ada.','MIN:111'],
  ['Pip is able to pay attention.','MIN:201'],
  ['Pip is not paying attention to Ada.','MIN:211'],
  ['It is possible that Pip is revising a mental representation of Ada.','MIN:111'],
  ['Is Orin conscious?','LIF:011'],['Does Nora care for Eli?','LIF:211'],
  ['Is Pip not moving toward Ada?','MOV:111'],['Does Nora not care for Eli?','LIF:211'],
  ['I care for you.','LIF:211'],['You care for me.','LIF:211'],['I am conscious.','LIF:001'],['You are conscious.','LIF:011'],
  ['Care for Eli.','LIF:211'],['Do not care for Eli.','LIF:211'],['Physically repair "the radio".','CMP:2816a7eeb356c2148b26beca'],
  ['Do you care for me?','LIF:211'],['"you" cares for "me".','LIF:211'],['I care for "you".','LIF:211'],
  ['Data "the map" is being transferred from me to you.','DAT:111'],
  ['I love you.','CMP:44718c92b66443c0c0f03ad7'],['You love me.','CMP:44718c92b66443c0c0f03ad7'],
  ['Nora loves Eli.','CMP:44718c92b66443c0c0f03ad7'],['I love you [2].','CMP:44718c92b66443c0c0f03ad7'],
  ['I do not love you.','CMP:44718c92b66443c0c0f03ad7'],['I care for you [0].','LIF:211'],['I care for you [2].','LIF:211']];
for(const [text,target] of [...cases,...calendarCases,...pastCases]){
  assert.equal(parseNamedSentence(text).predicate,target);
  const file=data.resolution_files[target];
  const document=JSON.parse(fs.readFileSync(new URL(`../pages/${file}`,import.meta.url)));
  const result=await composeNamedSentence(text,document.variants['assertion:1']);
  const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_semantic_validation','-e','ir=JSON.parse(STDIN.read);errors=EraZeroSemanticValidation.validate(ir);abort errors.join(",") unless errors.empty?;puts JSON.generate(EraZeroRenderer.render(ir))'],{cwd:new URL('..',import.meta.url),input:JSON.stringify(result.semantic_ir),encoding:'utf8',stdio:['pipe','pipe','pipe']}));
  assert.deepEqual(result.formal,ruby);
  outputs.push(result);
}
assert.notEqual(outputs[0].semantic_ir.utterance_id,outputs[1].semantic_ir.utterance_id);
assert.notDeepEqual(midiFromFormal(outputs[0].formal),midiFromFormal(outputs[1].formal));
assert.equal(outputs[7].semantic_ir.nodes.find(node=>node.node_id==='p').target_type,'compound');
assert.deepEqual(outputs[7].formal.performance.lexical_events.filter(event=>event.occurrence_id==='p').map(event=>event.target_id),['MAT:111','REP:111']);
for(const text of ['Pip never cares for Ada.','Pip cares for Ada and Sol.','Pip barely cares for Ada.','Pip cares for a curious Ada.','Pip cares for Ada tomorrow.','Pip is not restoring Ada tomorrow.','Pip is damaging Ada and Sol.','Pip is physically repairing the broken machine.','Pip is physically repairing "pump" tomorrow.']){
  assert.equal(parseNamedSentence(text),null,text);
  assert.equal(needsSentenceComposition(text),true,text);
}
for(const text of ['Pip is very conscious.','Pip is dormant tomorrow.']){
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
for(const [index,role,register] of [[21,'destination','high'],[22,'source','low'],[23,'environment','sustained_background']]){
  const result=outputs[index];
  assert.equal(result.semantic_ir.edges.find(edge=>edge.from==='b').role,role);
  assert.equal(result.formal.performance.lexical_events.find(event=>event.occurrence_id==='b').register,register);
}
assert.equal(new Set(outputs.slice(21,24).map(result=>Buffer.from(midiFromFormal(result.formal)).toString('base64'))).size,3);
for(const input of ['Pip is moving toward Ada quickly.','Pip is moving away from Ada toward Sol.','Pip is moving toward Ada and Sol.']){
  assert.equal(parseNamedSentence(input),null);
  assert.equal(needsSentenceComposition(input),true);
}
const transfer=outputs[26];
assert.deepEqual(transfer.semantic_ir.edges.filter(edge=>edge.type==='fills_role').map(edge=>edge.role),['source','content','target']);
assert.deepEqual(transfer.formal.performance.lexical_events.filter(event=>event.kind==='phonemic_label').map(event=>[event.label,event.register]),[['pip','low'],['the record','middle'],['ada','high']]);
assert.notDeepEqual(midiFromFormal(transfer.formal),midiFromFormal(outputs[27].formal));
assert.notDeepEqual(midiFromFormal(transfer.formal),midiFromFormal(outputs[28].formal));
assert.equal(outputs[30].semantic_ir.nodes.find(node=>node.operator==='modality').strength,'0.7');
assert.equal(outputs[32].semantic_ir.nodes.find(node=>node.operator==='modality').strength,'0.001');
assert.notDeepEqual(midiFromFormal(outputs[30].formal),midiFromFormal(outputs[31].formal));
for(const [percent,decimal] of [['0','0'],['100','1'],['100.00','1'],['70','0.7'],['0070.00','0.7'],['0.001','0.00001'],['12.3456789','0.123456789']])assert.equal(confidenceFromPercent(percent),decimal);
for(const percent of ['101','100.01','-1','1e1','NaN','.7'])assert.equal(confidenceFromPercent(percent),null);
for(const input of ['With 70% confidence, it is not possible that Pip cares for Ada.','With 101% confidence, it is possible that Pip cares for Ada.','With 70% confidence, Pip cares for Ada.','With 70% confidence, with 80% confidence, it is possible that Pip cares for Ada.'])assert.equal(parseNamedSentence(input),null);
assert.equal(outputs[33].semantic_ir.edges.find(edge=>edge.from==='a').role,'experiencer');
assert.equal(outputs[34].semantic_ir.edges.find(edge=>edge.from==='a').role,'experiencer');
assert.equal(outputs[35].semantic_ir.edges.find(edge=>edge.from==='a').role,'bearer');
assert.equal(new Set(outputs.slice(33,36).map(result=>Buffer.from(midiFromFormal(result.formal)).toString('base64'))).size,3);
for(const input of ['Pip is curious about Ada.','Pip is learning about Ada.','Pip is understanding Ada.','Pip is paying attention to Ada carefully.'])assert.equal(parseNamedSentence(input),null);
for(const result of outputs.slice(38,42)){
  assert.equal(result.semantic_ir.speech_act,'question');
  assert.equal(result.formal.performance.primary_contour,'rising');
  assert.deepEqual(result.formal.performance.contour_relative_semitones,[0,2]);
}
const statement=await composeNamedSentence('Orin is conscious.',JSON.parse(fs.readFileSync(new URL(`../pages/${data.resolution_files['LIF:011']}`,import.meta.url))).variants['assertion:1']);
assert.deepEqual(statement.formal.performance.lexical_events,outputs[38].formal.performance.lexical_events);
assert.notDeepEqual(midiFromFormal(statement.formal),midiFromFormal(outputs[38].formal));
for(const input of ['Is Orin conscious tomorrow?','Why is Orin conscious?','It is possible that Is Orin conscious?'])assert.equal(parseNamedSentence(input),null);
assert.deepEqual(outputs[42].semantic_ir.nodes.filter(node=>node.kind==='deictic_reference').map(node=>node.deictic_role),['speaker','addressee']);
assert.deepEqual(outputs[43].semantic_ir.nodes.filter(node=>node.kind==='deictic_reference').map(node=>node.deictic_role),['addressee','speaker']);
assert.notDeepEqual(midiFromFormal(outputs[42].formal),midiFromFormal(outputs[43].formal));
for(const result of outputs.slice(46,49)){
 assert.equal(result.semantic_ir.speech_act,'command');assert.equal(result.formal.performance.primary_contour,'sharply_falling');
 assert.equal(result.semantic_ir.nodes.find(node=>node.node_id==='a').deictic_role,'addressee');
}
assert.equal(outputs[50].semantic_ir.nodes.filter(node=>node.kind==='deictic_reference').length,0);
assert.equal(outputs[51].semantic_ir.nodes.filter(node=>node.kind==='deictic_reference').length,1);
for(const input of ['I care for me.','You are awakening you.','She cares for him.','She cares for Eli.','They are conscious.','Care for Eli tomorrow.'])assert.equal(parseNamedSentence(input),null);
const love=outputs[53],poetic=outputs[56];
assert.deepEqual(love.formal.performance.lexical_events.filter(event=>event.occurrence_id==='p').map(event=>event.target_id),['LIF:002','LIF:101','LIF:210']);
assert(love.semantic_note.includes('preserved, not-yet-expressed self'));
assert.equal(poetic.semantic_ir.nodes.find(node=>node.node_id==='p').runtime_state.code,2);
assert.equal(poetic.formal.performance.lexical_events.filter(event=>event.runtime_tail).length,1);
assert.equal(poetic.formal.performance.lexical_events.at(-1).runtime_tail.name,'num');
assert.notDeepEqual(midiFromFormal(love.formal),midiFromFormal(outputs[54].formal));
assert.notDeepEqual(midiFromFormal(love.formal),midiFromFormal(poetic.formal));
assert.notDeepEqual(midiFromFormal(outputs[42].formal),midiFromFormal(outputs[58].formal));
for(const input of ['I love "coffee".','I like you.','I love me.','I love you [2] [1].'])assert.equal(parseNamedSentence(input),null);
assert.equal(needsSentenceComposition('active care'),false);
assert.equal(needsSentenceComposition('Pip cares for Ada.'),false);
console.log(`Named sentences: ${cases.length+calendarCases.length+pastCases.length} full compositions match Ruby rendering; role reversal changes sound; unsupported additions never match.`);

for(const [text] of calendarCases){
 const parsed=parseNamedSentence(text);
 assert.equal(parsed.calendarDay,text.includes('yesterday')?'-1':text.includes('tomorrow')?'1':'0');
}
assert.equal(parseNamedSentence('It is possible that Nora cared for Eli yesterday.'),null);
assert.equal(parseNamedSentence('Nora cares for Eli yesterday.'),null);
assert.equal(parseNamedSentence('Nora cared for Eli tomorrow.'),null);

assert.equal(parseNamedSentence('"He was conscious" is conscious yesterday.'),null);
assert.match(parseNamedSentence('Nora will care for Eli tomorrow.').semanticNote,/future assertion/);
const calendarOutputs=outputs.slice(cases.length,cases.length+calendarCases.length);
for(const [index,result] of calendarOutputs.entries()){
 const day=parseNamedSentence(calendarCases[index][0]).calendarDay;
 const marker={ '-1':'previous_day','0':'current_day','1':'next_day' }[day];
 const events=scheduledLexicalEvents(result.formal);
 assert.equal(events[0].marker,`time_${marker}_open`);
 assert.equal(events.at(-1).marker,`time_${marker}_close`);
 assert.equal(result.semantic_ir.nodes.find(n=>n.kind==='lexical_occurrence').runtime_state.code,1);
}
assert.notDeepEqual(midiFromFormal(calendarOutputs[0].formal),midiFromFormal(calendarOutputs[3].formal));

const pastOutputs=outputs.slice(cases.length+calendarCases.length);
for(const result of pastOutputs){
 assert.equal(result.semantic_ir.nodes.find(n=>n.kind==='lexical_occurrence').runtime_state.code,1);
 assert.equal(result.semantic_ir.edges.filter(e=>e.type==='time_relation').length,result.semantic_ir.nodes.some(n=>n.day_offset==='0')?2:1);
}
assert.notDeepEqual(midiFromFormal(pastOutputs[0].formal),midiFromFormal(pastOutputs[1].formal));
assert.notDeepEqual(midiFromFormal(pastOutputs[2].formal),midiFromFormal(pastOutputs[3].formal));
assert.equal(parseNamedSentence('It is possible that Nora restored Eli.'),null);
assert.equal(parseNamedSentence('"Nora was" is conscious yesterday.'),null);
