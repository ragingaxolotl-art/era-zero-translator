import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {parseNominal} from '../pages/nominals.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {decodeCareMidi} from '../pages/care_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const load=id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:{...JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'],authority};
const inputs=['Nora cares for Eli and Orin.','Nora cares for both Eli and Orin.','I care for the lantern and the sprocket.','Nora cared for Eli and Orin yesterday.','Does Nora care for Eli and Orin?','Care for Eli and Orin.'];
const results=[];
for(const state of [0,1,2])for(const text of inputs){
 const input=text+` [${state}]`,p=parseNamedSentence(input);assert(p,input);assert.equal(p.participantGroups.length,1);
 const r=await composeNamedSentence(input,load(p.predicate));results.push(r);
 const ir=r.semantic_ir,group=ir.nodes.find(n=>n.kind==='coordination');assert.equal(group.operator,'all_of');
 assert.equal(ir.nodes.filter(n=>n.kind==='lexical_occurrence').length,1);
 assert.equal(ir.edges.filter(e=>e.type==='fills_role'&&e.role==='target').length,1);
 assert.equal(ir.edges.filter(e=>e.type==='member_of'&&e.to===group.node_id).length,2);
 const d=decodeCareMidi(midiFromFormal(r.formal),authority.atoms);assert.equal(d.runtime_state,state);assert.equal(d.target_coordination,'all_of');assert.equal(d.participants.targets.length,2);
 assert.equal(d.speech_act,text.startsWith('Does')?'question':text.startsWith('Care')?'command':'assertion');
 assert.deepEqual(d.scopes,text.includes('yesterday')?[{operator:'time',relation:'previous_day'}]:[]);
 const refs=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms).tokens.filter(t=>t.kind==='phonemic');assert(refs.slice(-2).every(t=>t.register==='high'));
 if(text.includes('Eli'))assert.deepEqual(d.participants.targets.map(t=>t.phonemes),[['EH','L','IH'],['AO','R','IH','N']]);
 else assert(d.participants.targets.every(t=>t.reference_mode==='definite_nominal'));
}
for(const text of ['Nora is repairing the lantern.','The sprocket is damaged.','Nora is physically repairing the gyroscope.','Pip carried the heavy crate to Ada.','Nora acquired physical custody of the microscope.']){
 const p=parseNamedSentence(text);assert(p,text);const options={...(p.requiredDestination?{destination:'spatial'}:{}),...(p.requiredInterpretation?{interpretation:'mass_standard',standard:{dimension:'mass',threshold:'20',scale:'kilogram'}}:{})};
 results.push(await composeNamedSentence(text,load(p.predicate),options));
}
const refs=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:25_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,refs[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(refs[i].midi,'base64'));}
for(const x of ['the hungry','the bright','the and','the heavy crate','the broken gyroscope'])assert.equal(parseNominal(x),null,x);
for(const text of ['Nora cares for Eli and Nora.','Nora cares for Eli and Eli.','Nora does not care for Eli and Orin.','Nora cares for Eli or Orin.'])assert.equal(parseNamedSentence(text),null,text);
assert.equal(parseNominal('the gyroscope').head,'gyroscope');
const simple=await composeNamedSentence('Nora cares for Eli.',load('LIF:211'));assert.equal(decodeCareMidi(midiFromFormal(simple.formal),authority.atoms).target_coordination,null);
const swapped=await composeNamedSentence('Eli cares for Nora and Orin.',load('LIF:211'));assert.notDeepEqual(decodeCareMidi(midiFromFormal(swapped.formal),authority.atoms).participants,decodeCareMidi(midiFromFormal(results[0].formal),authority.atoms).participants);
console.log(`${results.length} ordinary-reference compositions match Ruby formal/MIDI; MIDI-only care inverse preserves coordinated targets, role changes and 0/1/2. Unlisted noun heads remain sound labels and adjective phrases are not swallowed.`);
