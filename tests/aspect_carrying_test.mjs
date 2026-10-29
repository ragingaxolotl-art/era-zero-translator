import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal,svgFromFormal,canonicalDigest} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {decodeNominalMassRestrictions} from '../pages/reference_property_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),results=[];
const standard={dimension:'mass',threshold:'20',scale:'kilogram'};
const sentences=[
 ['Pip is carrying the box.','ongoing',false],['Pip was carrying the box.','ongoing',false],
 ['Pip carried the box.','bounded',false],['Pip did not carry the box.','bounded',true],
 ['Pip carried the box toward Ada yesterday.','bounded',false],['Did Pip carry the box toward Ada?','bounded',false],
 ['Pip habitually carries the box toward Ada.','habitual',false],['Pip does not habitually carry the box.','habitual',true],
 ['Pip habitually carried the box.','habitual',false],['Pip did not habitually carry the box.','habitual',true],
 ['Does Pip habitually carry the box?','habitual',false],['Did Pip not habitually carry the box?','habitual',true],
 ['Pip carried the heavy box toward Ada.','bounded',false],['Does the heavy robot habitually carry the box?','habitual',false],
 ['It is possible that Pip habitually carries the box.','habitual',false]
];
for(const state of [0,1,2])for(const [text,aspect,negated] of sentences){
 const input=text+` [${state}]`,parsed=parseNamedSentence(input);assert(parsed,input);assert.equal(parsed.aspect,aspect,input);
 const r=await composeNamedSentence(input,{authority},parsed.requiredInterpretation?{interpretation:'mass_standard',standard}:{});results.push(r);
 const ir=r.semantic_ir,operator=ir.nodes.find(n=>n.operator==='aspect');assert.equal(operator.aspect,aspect);
 assert.equal(ir.nodes.find(n=>n.node_id==='p').runtime_state.code,state);
 assert.equal(ir.nodes.some(n=>n.operator==='negation'),negated);
 if(negated)assert(ir.edges.some(e=>e.type==='scopes'&&e.from==='aspect'&&e.to==='neg'));
 const d=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);
 assert.equal(d.tokens.find(t=>t.root_id==='MOV:121').runtime_state,state);
 const opening=d.tokens.find(t=>t.marker===`aspect_${aspect}_open`);assert(opening);
 assert.equal(opening.enclosing_scopes.some(i=>d.tokens[i].marker==='negation_open'),negated);
 assert(!d.tokens.some(t=>t.root_id==='MOV:110'||t.marker==='role_recipient_open'));
 if(text.includes('yesterday'))assert(d.tokens.some(t=>t.marker==='time_previous_day_open'));
 else if(/was |carried|did |Did /.test(text))assert(d.tokens.some(t=>t.marker==='time_before_speech_open'));
 else assert(!d.tokens.some(t=>/^time_/.test(t.marker||'')));
 if(text.includes('heavy'))assert(decodeNominalMassRestrictions(midiFromFormal(r.formal),authority.atoms).restrictions.every(p=>p.magnitude==='20'));
 assert(svgFromFormal(r.formal).includes('<svg'));
}
const expected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:24_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,expected[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(expected[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
// Controlled grammar exercises aspect even with no roles to trigger scheduling.
const controlled=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_controlled_english','-rera_zero_presentation','-rbase64','-e',`puts JSON.generate(%w[bounded ongoing habitual].product([0,1,2]).map{|aspect,state|ir=EraZeroControlledEnglish::Compiler.new.compile(%Q{ASSERT ASPECT #{aspect} "active shared-frame movement" [#{state}].}).fetch('semantic_ir');f=EraZeroRenderer.render(ir);{aspect:aspect,state:state,formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})`],{cwd:root,encoding:'utf8',maxBuffer:5_000_000}));
for(const r of controlled){const midi=midiFromFormal(r.formal);assert.deepEqual(Buffer.from(midi),Buffer.from(r.midi,'base64'));const d=decodeStrictMusicMidi(midi,authority.atoms);assert(d.tokens.some(t=>t.marker===`aspect_${r.aspect}_open`));assert.equal(d.tokens.find(t=>t.root_id==='MOV:121').runtime_state,r.state);}
for(const value of [undefined,'perfect','future','inactive']){const f=structuredClone(controlled[0].formal);f.semantic_ir.nodes.find(n=>n.operator==='aspect').aspect=value;assert.throws(()=>midiFromFormal(f),/Unsupported musical aspect/);}
const wrong=structuredClone(controlled[0].formal);wrong.semantic_ir.nodes.find(n=>n.operator==='aspect').runtime_state={code:2};assert.throws(()=>midiFromFormal(wrong),/Unsupported musical aspect/);
const nominalScope=structuredClone(controlled[0].formal);nominalScope.semantic_ir.nodes.find(n=>n.kind==='lexical_occurrence').kind='phonemic_reference';assert.throws(()=>midiFromFormal(nominalScope),/Unsupported musical aspect/);
// Not having a habit and habitually refraining must not share a performance.
const noHabit=results.find(r=>r.source_input==='Pip does not habitually carry the box. [1]');
const refraining=structuredClone(noHabit.semantic_ir);
refraining.edges.find(e=>e.type==='centers').from='aspect';
refraining.edges.find(e=>e.type==='scopes'&&e.to==='aspect').from='neg';
refraining.edges.find(e=>e.type==='scopes'&&e.to==='neg').from='p';
delete refraining.utterance_id;delete refraining.serialization;
const digest=await canonicalDigest(refraining);refraining.utterance_id=`UTT:${digest.slice(0,24)}`;refraining.serialization={canonical_format:'EZIR-JSON-1',content_digest:digest};
const contrast=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-e','puts JSON.generate(EraZeroRenderer.render(JSON.parse(STDIN.read)))'],{cwd:root,input:JSON.stringify(refraining),encoding:'utf8'}));
assert.notDeepEqual(midiFromFormal(noHabit.formal),midiFromFormal(contrast));
const openings=f=>decodeStrictMusicMidi(midiFromFormal(f),authority.atoms).tokens.filter(t=>['negation_open','aspect_habitual_open'].includes(t.marker)).map(t=>t.marker);
assert.deepEqual(openings(noHabit.formal),['negation_open','aspect_habitual_open']);assert.deepEqual(openings(contrast),['aspect_habitual_open','negation_open']);
const command=await composeNamedSentence('Carry the box.',{authority});assert(!command.semantic_ir.nodes.some(n=>n.operator==='aspect'));
for(const input of ['Pip carried the box to Ada.','Pip has carried the box.','Pip will carry the box tomorrow.','Pip habitually carries the box every day.'])assert.equal(parseNamedSentence(input),null,input);
assert.equal(parseNamedSentence('Pip carries the box.').requiredViewpoint,true);
await assert.rejects(()=>composeNamedSentence('Pip carries the box.',{authority}),e=>e.code==='carrying_viewpoint_required');
console.log(`Aspect: ${results.length} carrying/negation/past/question/nominal-property/runtime cases have Ruby/browser formal and MIDI parity; 9 controlled aspect/state cases preserve distinct audible frames without participant roles. Bounded, ongoing and habitual stay separate from tense, arrival and runtime.`);
