import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,composeSentenceSequence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {decodePhysicalCustodyMidi} from '../pages/custody_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),template={authority},outputs=[];
const phonemic=(phonemes,reference_mode='name')=>({kind:'phonemic',reference_mode,phonemes,instance_code:null});
const ada=phonemic(['AE','D','AE']),box=phonemic(['B','AA','K','S'],'definite_nominal');
const cases=[
 ['Ada has physical custody of the box.',[]],
 ['Ada does not have physical custody of the box.',[{operator:'negation'}]],
 ['Does Ada have physical custody of the box?',[]],
 ['Does Ada not have physical custody of the box?',[{operator:'negation'}]],
 ['It is possible that Ada has physical custody of the box.',[{operator:'modality',mode:'possible'}]],
 ['It is not possible that Ada has physical custody of the box.',[{operator:'negation'},{operator:'modality',mode:'possible'}]],
 ['It is possible that Ada does not have physical custody of the box.',[{operator:'modality',mode:'possible'},{operator:'negation'}]],
 ['With 70% confidence, it is possible that Ada has physical custody of the box.',[{operator:'modality',mode:'possible',strength:'0.7'}]],
 ['I have physical custody of the box.',[]],
 ['You have physical custody of the box.',[]],
 ['Ada has physical custody of the heavy box.',[]],
 ['Ada has physical custody of the light box.',[]]
];
// Independent MIDI writer permits transposition and balanced semantic corruptions.
function midi(notes,division){
 const vlq=n=>{let a=[n&127];while((n>>=7)>0)a.unshift((n&127)|128);return a;},u32=n=>[n>>>24&255,n>>>16&255,n>>>8&255,n&255];
 const events=notes.flatMap(n=>[[n.start_tick,1,[0x90,n.midi,90]],[n.end_tick,0,[0x80,n.midi,0]]]).sort((a,b)=>a[0]-b[0]||a[1]-b[1]);
 let previous=0,track=[];for(const [tick,,event] of events){track.push(...vlq(tick-previous),...event);previous=tick;}track.push(0,255,47,0);
 return new Uint8Array([77,84,104,100,0,0,0,6,0,0,0,1,division>>8,division&255,77,84,114,107,...u32(track.length),...track]);
}
for(const state of [0,1,2])for(const [text,scopes] of cases){
 const parsed=parseNamedSentence(text);assert(parsed,text);
 const r=await composeNamedSentence(text+` [${state}]`,template,parsed.requiredInterpretation?{interpretation:'mass_standard',standard:{dimension:'mass',threshold:'12.5',scale:'kilogram'}}:{});
 const bytes=midiFromFormal(r.formal),d=decodePhysicalCustodyMidi(bytes,authority.atoms);outputs.push({text,state,bytes,d});
 assert.equal(d.profile,'EZCUSTODY-INVERSE-1');assert.equal(d.predicate,'practical_physical_custody');assert.equal(d.runtime_state,state);assert.deepEqual(d.scopes,scopes,text);
 assert.equal(d.speech_act,text.startsWith('Does ')?'question':'assertion');assert.deepEqual(d.convention_codes,[7]);
 assert.deepEqual(d.participants.holder,text.startsWith('I ')?{kind:'deictic',role:'speaker'}:text.startsWith('You ')?{kind:'deictic',role:'addressee'}:ada);
 assert.deepEqual(d.participants.object,{...box,...(parsed.requiredInterpretation?{property:{dimension:'mass',comparison:parsed.adjective==='heavy'?'greater_than':'less_than',magnitude:'12.5',unit:'kilogram'}}:{})});
 assert.deepEqual(d.meaning,{established_practical_control:true,holder_distinct_from_object:true,exclusive_control_required:false,ownership_asserted:false,receipt_asserted:false,transfer_asserted:false,continuous_physical_influence_required:false});
 const raw=notesFromMidi(bytes);assert.deepEqual(decodePhysicalCustodyMidi(midi(raw.notes.map(n=>({...n,midi:n.midi+12})),raw.division),authority.atoms),d);
 assert.throws(()=>decodePhysicalCustodyMidi(bytes.slice(0,-1),authority.atoms));
}
const controlled=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_controlled_english','-rera_zero_presentation','-rbase64','-e',String.raw`
 c=EraZeroControlledEnglish::Compiler.new
 puts JSON.generate(%w[ASSERT QUESTION COMMAND].product([0,1,2]).map{|act,state|
 ir=c.compile!(%Q{#{act} "practical physical custody" [#{state}] ROLE source "identified other" [0] ROLE target "distinct material object" [2].})
 {act:act,state:state,midi:Base64.strict_encode64(EraZeroPresentation.midi(EraZeroRenderer.render(ir)))}
 })
`],{cwd:new URL('..',import.meta.url),encoding:'utf8',maxBuffer:3_000_000}));
for(const row of controlled){const d=decodePhysicalCustodyMidi(Buffer.from(row.midi,'base64'),authority.atoms);assert.equal(d.runtime_state,row.state);assert.equal(d.speech_act,{ASSERT:'assertion',QUESTION:'question',COMMAND:'command'}[row.act]);assert.deepEqual(d.scopes,[]);assert.deepEqual(d.participants,{holder:{kind:'lexical',root_id:'LIF:010',runtime_state:0},object:{kind:'lexical',root_id:'MAT:010',runtime_state:2}});}
const fixture=outputs.find(o=>o.text===cases[0][0]&&o.state===1),observed=decodeStrictMusicMidi(fixture.bytes,authority.atoms),raw=notesFromMidi(fixture.bytes);
const notesFor=(notes,t)=>notes.filter(n=>n.start_tick>=t.start_tick&&n.end_tick<=t.end_tick);
const changed=transform=>{const notes=structuredClone(raw.notes);transform(notes);const bytes=midi(notes,raw.division);decodeStrictMusicMidi(bytes,authority.atoms);assert.throws(()=>decodePhysicalCustodyMidi(bytes,authority.atoms),/physical-custody/);};
// A different known convention remains balanced, but is not custody.
changed(notes=>{for(const t of observed.tokens.filter(t=>['convention_7_open','convention_7_close'].includes(t.marker)))notesFor(notes,t)[9].midi=60;});
// Source and actor have the same register but distinct roles.
changed(notes=>{const start=observed.tokens.find(t=>t.marker==='role_source_open');for(const t of [start,observed.tokens[start.closing_token]])notesFor(notes,t)[4].midi=60;});
// Active physical influence is not the established coupling head.
changed(notes=>{const ns=notesFor(notes,observed.tokens.find(t=>t.root_id==='MAT:210'));ns[6].midi+=2;});
// An active-object root cannot silently replace the exact material qualifier.
changed(notes=>{const ns=notesFor(notes,observed.tokens.find(t=>t.root_id==='MAT:010'));ns[6].midi+=2;});
const inverses=[];
for(const text of ['Ada has physical custody of Ben.','Ben has physical custody of Ada.']){const r=await composeNamedSentence(text,template);inverses.push(decodePhysicalCustodyMidi(midiFromFormal(r.formal),authority.atoms));}
assert.deepEqual(inverses[0].participants.holder,inverses[1].participants.object);assert.deepEqual(inverses[0].participants.object,inverses[1].participants.holder);assert.notDeepEqual(inverses[0],inverses[1]);
const homophones=[];for(const name of ['Kay','Cay']){const r=await composeNamedSentence(`${name} has physical custody of the box.`,template);homophones.push(decodePhysicalCustodyMidi(midiFromFormal(r.formal),authority.atoms));}assert.deepEqual(...homophones);
for(const text of ['Ada is physically supporting the box.','Ada is carrying the box.']){const r=await composeNamedSentence(text,template);assert.throws(()=>decodePhysicalCustodyMidi(midiFromFormal(r.formal),authority.atoms));}
const group=await composeSentenceSequence('Ada has physical custody of the box, then Ben has physical custody of the shelf.',async()=>template);assert.throws(()=>decodePhysicalCustodyMidi(midiFromFormal(group.formal),authority.atoms));
console.log(`Custody MIDI inverse: ${outputs.length} sentence/state/scope/property cases and nine reference-rendered speech-act/state cases recover custody, participants and independent runtime states from MIDI alone. Transposition, role reversal, homophone limits, balanced semantic corruptions, truncation and unsupported extra clauses are checked.`);
