import assert from 'node:assert/strict';
import fs from 'node:fs';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,composeSentenceConjunction,composeSentenceSequence,composeSentenceConditional,composeSentenceDisjunction,needsSentenceComposition} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodePropertyComparisonMidi} from '../pages/property_comparison_decoder.mjs';
import {decodeSupportedMeaningMidi} from '../pages/semantic_music_dispatch.mjs';
import {decodePropertyComparisonGroupMidi} from '../pages/property_comparison_group_decoder.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {notesFromMidi,midiFromNoteTimeline} from '../pages/performance_codec.mjs';
import {readSongLine} from '../pages/song_readback.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const load=async id=>({...JSON.parse(fs.readFileSync(new URL('../pages/'+authority.resolution_files[id],import.meta.url))).variants['assertion:1'],authority});
const hash=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const legacy=JSON.parse(fs.readFileSync(new URL('./ordinary_comparative_legacy_2026_11_23.json',import.meta.url)));
assert.equal(legacy.cases.length,24);
for(const row of legacy.cases){
 const result=await composeNamedSentence(row.input,await load(parseNamedSentence(row.input).predicate),row.options),bytes=midiFromFormal(result.formal),chords=compactChordMidi(bytes,authority.atoms);
 assert.equal(hash(bytes),row.melody_sha256);assert.equal(hash(chords),row.chords_sha256);
 assert.deepEqual(decodePropertyComparisonMidi(bytes),row.meaning);
 assert.deepEqual(decodeSupportedMeaningMidi(expandChordMidi(chords,authority.atoms),authority.atoms),row.meaning);
}
const forms=[['hotter','thermodynamic_temperature','greater_than','temperature_comparison'],['colder','thermodynamic_temperature','less_than','temperature_comparison'],['heavier','mass','greater_than','mass_comparison'],['lighter','mass','less_than','mass_comparison']];
const neg={operator:'negation'},past={operator:'time',relation:'before_speech'},future={operator:'time',relation:'after_speech'},possible={operator:'modality',mode:'possible'};
let singles=0,groups=0;const examples={};
for(const [word,dimension,relation,interpretation] of forms)for(const state of [0,1,2]){
 for(const [input,scopes,act='assertion',reversed=false] of [
  [`The cup is ${word} than the plate.`,[]],
  [`The plate is ${word} than the cup.`,[],'assertion',true],
  [`The cup is not ${word} than the plate.`,[neg]],
  [`The cup isn't ${word} than the plate.`,[neg]],
  [`The cup was ${word} than the plate.`,[past]],
  [`The cup was not ${word} than the plate.`,[past,neg]],
  [`The cup will be ${word} than the plate.`,[future]],
  [`The cup will not be ${word} than the plate.`,[future,neg]],
  [`Is the cup ${word} than the plate?`,[],'question'],
  [`Was the cup not ${word} than the plate?`,[past,neg],'question'],
  [`It is possible that the cup is ${word} than the plate.`,[possible]],
  [`It is not possible that the cup is ${word} than the plate.`,[neg,possible]],
  [`It is possible that the cup is not ${word} than the plate.`,[possible,neg]],
  [`It is not the case that the cup was ${word} than the plate.`,[neg,past]],
  [`With 37.5% confidence, it is possible that the cup is ${word} than the plate.`,[{...possible,strength:'0.375'}]]
 ]){
  const text=input+` [${state}]`,parsed=parseNamedSentence(text);assert(parsed,text);
  const template=await load(parsed.predicate);
  await assert.rejects(()=>composeNamedSentence(text,template),e=>e.code===interpretation+'_required');
  const result=await composeNamedSentence(text,template,{interpretation}),midi=midiFromFormal(result.formal);
  const heard=decodeSupportedMeaningMidi(midi,authority.atoms),chords=compactChordMidi(midi,authority.atoms);
  assert.equal(heard.profile,'EZPROPERTYCOMPARE-1');assert.equal(heard.dimension,dimension);assert.equal(heard.relation,relation);
  assert.equal(heard.runtime_state,state);assert.equal(heard.speech_act,act);assert.deepEqual(heard.scopes,scopes,text);
  assert.deepEqual(heard.participants.bearer.phonemes,reversed?['P','L','AE','T']:['K','UH','P']);
  assert.deepEqual(heard.participants.comparison_standard.phonemes,reversed?['K','UH','P']:['P','L','AE','T']);
  assert.equal(heard.participants.bearer.reference_mode,'definite_nominal');
  assert.deepEqual(decodeSupportedMeaningMidi(expandChordMidi(chords,authority.atoms),authority.atoms),heard);
  assert(!result.semantic_ir.nodes.some(n=>n.kind==='measurement'));
  if(state===1)examples[input]={heard,midi,result};singles++;
 }
 for(const [text,roles] of [[`I am ${word} than you.`,['speaker','addressee']],[`You are ${word} than me.`,['addressee','speaker']]]){
  const input=text+` [${state}]`,p=parseNamedSentence(input);assert(p,input);
  const result=await composeNamedSentence(input,await load(p.predicate),{interpretation}),bytes=midiFromFormal(result.formal),heard=decodePropertyComparisonMidi(bytes);
  assert.deepEqual(Object.values(heard.participants).map(p=>p.role),roles);assert.equal(heard.runtime_state,state);
  assert.deepEqual(decodePropertyComparisonMidi(expandChordMidi(compactChordMidi(bytes,authority.atoms),authority.atoms)),heard);singles++;
 }
}
// Logical counterexamples: the negative strict relation includes equality.
const evaluate=(m,a,b)=>m.scopes.some(s=>s.operator==='negation')?!(m.relation==='greater_than'?a>b:a<b):(m.relation==='greater_than'?a>b:a<b);
assert.equal(evaluate(examples['The cup is not heavier than the plate.'].heard,10,10),true);
assert.equal(evaluate(examples['The cup is lighter than the plate.'].heard,10,10),false);
assert.notDeepEqual(examples['It is not possible that the cup is heavier than the plate.'].heard.scopes,examples['It is possible that the cup is not heavier than the plate.'].heard.scopes);
for(const text of ['The cup is much hotter than the plate.','The cup is hotter.','The cup is heavier than the plate by two kilograms.','The cup was colder than the plate yesterday.']){
 assert.equal(parseNamedSentence(text),null,text);assert(needsSentenceComposition(text),text);
}
for(const state of [0,1,2])for(const [operator,compose,join] of [
 ['all_of',composeSentenceConjunction,(a,b)=>a+' and '+b+'.'],
 ['sequence',composeSentenceSequence,(a,b)=>a+', then '+b+'.'],
 ['conditional',composeSentenceConditional,(a,b)=>'If '+a+', then '+b+'.'],
 ['any_of',(t,l,c)=>composeSentenceDisjunction(t,l,c,{disjunction:'any_of'}),(a,b)=>a+' or '+b+'.'],
 ['exactly_one',(t,l,c)=>composeSentenceDisjunction(t,l,c,{disjunction:'exactly_one'}),(a,b)=>a+' or '+b+'.']
]){
 const text=join(`The cup was not hotter than the plate [${state}]`,`Nora is conscious [${(state+1)%3}]`);
 const result=await compose(text,load,[{interpretation:'temperature_comparison'},{}]),midi=midiFromFormal(result.formal);
 const m=decodeSupportedMeaningMidi(midi,authority.atoms);
 assert.equal(m.profile,'EZPROPERTYCOMPARE-GROUP-1');assert.equal(m.operator,operator);assert.equal(m.members.length,2);
 assert.equal(m.members[0].dimension,'thermodynamic_temperature');assert.equal(m.members[0].relation,'greater_than');assert.deepEqual(m.members[0].scopes,[past,neg]);
 assert.equal(m.members[1].predicate,'LIF:011');assert.deepEqual(m.members[1].bearer.phonemes,['N','AO','R','AE']);
 assert.deepEqual(m.members.map(p=>p.runtime_state),[state,(state+1)%3]);assert(!m.members.some(p=>'speech_act' in p));
 assert.deepEqual(decodeSupportedMeaningMidi(expandChordMidi(compactChordMidi(midi,authority.atoms),authority.atoms),authority.atoms),m);groups++;
 if(state===1&&operator==='sequence')examples.sequence={result,midi,heard:m};
 if(state===1&&operator==='all_of')examples.union={result,midi,heard:m};
}
const mixed=await composeSentenceConjunction('The cup is heavier than the plate and the gate is wide.',load,[{interpretation:'mass_comparison'},{interpretation:'width_standard',standard:{kind:'contextual',dimension:'physical_width'}}]);
const mixedMeaning=decodeSupportedMeaningMidi(midiFromFormal(mixed.formal),authority.atoms);
assert.equal(mixedMeaning.members[0].dimension,'mass');assert.equal(mixedMeaning.members[1].standard.norm,'wide');groups++;
const two=await composeSentenceConjunction('The cup is hotter than the plate and the plate is lighter than the cup.',load,[{interpretation:'temperature_comparison'},{interpretation:'mass_comparison'}]);
assert.deepEqual(decodeSupportedMeaningMidi(midiFromFormal(two.formal),authority.atoms).members.map(m=>m.dimension),['thermodynamic_temperature','mass']);groups++;
const outer=structuredClone(two.formal),center=outer.semantic_ir.edges.find(e=>e.type==='centers'&&e.to===outer.semantic_ir.root_clause),inside=center.from;
outer.semantic_ir.nodes.push({node_id:'outer_negation',kind:'scope_operator',operator:'negation'});center.from='outer_negation';outer.semantic_ir.edges.push({edge_id:'outer_scope',type:'scopes',from:inside,to:'outer_negation'});
const outerMeaning=decodePropertyComparisonGroupMidi(midiFromFormal(outer),authority.atoms);
assert.deepEqual(outerMeaning.scopes,[neg]);assert(outerMeaning.members.every(m=>m.scopes.length===0));
const timeline=notesFromMidi(examples.sequence.midi),observed=decodeStrictMusicMidi(examples.sequence.midi,authority.atoms),boundary=observed.tokens.find(t=>t.boundary_after_beats===1);
const withoutBoundary=timeline.notes.map(n=>n.start_tick>boundary.end_tick?{...n,start_tick:n.start_tick-timeline.division/2,end_tick:n.end_tick-timeline.division/2}:n);
assert.throws(()=>decodeSupportedMeaningMidi(midiFromNoteTimeline(withoutBoundary,timeline.division,timeline.tempos[0].value),authority.atoms));
const union=notesFromMidi(examples.union.midi),separator=decodeStrictMusicMidi(examples.union.midi,authority.atoms).tokens.find(t=>t.marker==='coord_member');
const delta=separator.end_tick-separator.start_tick+union.division/2;
const withoutSeparator=union.notes.filter(n=>n.start_tick<separator.start_tick||n.end_tick>separator.end_tick).map(n=>n.start_tick>separator.end_tick?{...n,start_tick:n.start_tick-delta,end_tick:n.end_tick-delta}:n);
assert.throws(()=>decodeSupportedMeaningMidi(midiFromNoteTimeline(withoutSeparator,union.division,union.tempos[0].value),authority.atoms));
const question=notesFromMidi(examples.union.midi);question.notes.at(-1).midi+=2;
const asked=decodeSupportedMeaningMidi(midiFromNoteTimeline(question.notes,question.division,question.tempos[0].value),authority.atoms);
assert.equal(asked.speech_act,'question');assert(!asked.members.some(m=>'speech_act' in m));
const readback=await readSongLine(compactChordMidi(examples.sequence.midi,authority.atoms),authority.atoms,[],true);
assert.match(readback.summary,/temporal order/);assert.match(readback.summary,/Clause 1 content/);assert.match(readback.summary,/thermodynamic temperature/);assert.match(readback.summary,/does not hold/);
const singleReadback=await readSongLine(examples['The cup is not heavier than the plate.'].midi,authority.atoms,[],false);
assert.match(singleReadback.summary,/physical mass/);assert.match(singleReadback.summary,/comparison participant/);assert.match(singleReadback.summary,/does not hold/);
// A different well-formed root is still not a material comparison head.
const sample=examples['The cup is hotter than the plate.'],source=notesFromMidi(sample.midi);
const head=decodeStrictMusicMidi(sample.midi,authority.atoms).tokens.find(t=>t.kind==='root');
const otherMidi=midiFromFormal((await load('DAT:000')).formal),other=notesFromMidi(otherMidi),otherRoot=decodeStrictMusicMidi(otherMidi,authority.atoms).tokens.find(t=>t.kind==='root');
const replacement=other.notes.filter(n=>n.start_tick>=otherRoot.start_tick&&n.end_tick<=otherRoot.end_tick).map(n=>({...n,start_tick:n.start_tick-otherRoot.start_tick+head.start_tick,end_tick:n.end_tick-otherRoot.start_tick+head.start_tick}));
const lengthDelta=replacement.at(-1).end_tick-head.end_tick;
const wrongHead=source.notes.filter(n=>n.start_tick<head.start_tick||n.end_tick>head.end_tick).map(n=>n.start_tick>head.end_tick?{...n,start_tick:n.start_tick+lengthDelta,end_tick:n.end_tick+lengthDelta}:n).concat(replacement).sort((a,b)=>a.start_tick-b.start_tick);
const wrongBytes=midiFromNoteTimeline(wrongHead,source.division,source.tempos[0].value);
assert(decodeStrictMusicMidi(wrongBytes,authority.atoms).tokens.some(t=>t.root_id==='DAT:000'));
assert.throws(()=>decodeSupportedMeaningMidi(wrongBytes,authority.atoms));
const parity=[examples['The cup was not hotter than the plate.'],examples['The cup will not be heavier than the plate.'],examples['It is not the case that the cup was colder than the plate.'],examples['With 37.5% confidence, it is possible that the cup is lighter than the plate.'],examples.sequence,examples.union];
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:new URL('..',import.meta.url),input:JSON.stringify(parity.map(e=>e.result.semantic_ir)),encoding:'utf8',maxBuffer:20_000_000}));
for(const [i,value] of parity.entries()){assert.deepEqual(value.result.formal,ruby[i].formal);assert.equal(Buffer.from(value.midi).toString('base64'),ruby[i].midi);}
console.log(`PASS ${singles} ordinary comparison pairs, ${groups} grouped pairs, 24 frozen earlier performances, independent directions/roles/scopes/runtime recovery, equality counterexample, framed group corruption and song readback.`);
