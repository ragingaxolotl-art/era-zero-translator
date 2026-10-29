import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {encodeName,notesForName} from '../pages/names.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
import {composeNamedSentence,composeSentenceConjunction,composeSentenceConditional,composeSentenceSequence} from '../pages/sentences.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const template=async id=>authority.resolution_files[id]?JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1']:{authority};
const expected=formal=>scheduledLexicalEvents(formal).map(e=>{
 if(e.kind==='grammar_marker')return {kind:'grammar',marker:e.marker};
 if(e.kind==='reference_marker')return {kind:'reference_mode',reference_mode:e.reference_mode,register:e.register};
 if(e.kind==='deictic_reference')return {kind:'deictic',deictic_role:e.deictic_role,register:e.register};
 if(e.kind==='phonemic_label'){
  const name=formal.semantic_ir.nodes.find(n=>n.name?.name_id===e.target_id).name;
  return {kind:'phonemic',register:e.register,phonemes:name.phonemes,instance_code:name.instance_notes.length?name.instance_notes.map(n=>(n-76).toString(16)).join(''):null};
 }
 return {kind:'root',root_id:e.target_id,register:e.register,runtime_state:e.runtime_tail?.code??null};
});
const project=t=>Object.fromEntries(Object.entries(t).filter(([k])=>!['start_tick','end_tick','boundary_after_beats','enclosing_scopes','opening_token','closing_token','sound_code'].includes(k)));
let count=0;
function check(formal){
 const decoded=decodeStrictMusicMidi(midiFromFormal(formal),authority.atoms);
 assert.deepEqual(decoded.tokens.map(project),expected(formal));
 assert.deepEqual(decoded.tokens.map(t=>t.boundary_after_beats),scheduledLexicalEvents(formal).map(e=>e.boundary_after_beats??.5));
 assert.equal(decoded.speech_act,formal.semantic_ir.speech_act);
 count++;return decoded;
}
for(const relative of Object.values(authority.resolution_files)){
 const document=JSON.parse(fs.readFileSync(new URL('pages/'+relative,root)));
 for(const resolution of Object.values(document.variants))check(resolution.formal);
}
// All published unit codes, including the last code, must independently decode.
// These are structural measurement probes, not approvals of every predicate/unit pairing.
const unitSamples=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-e',`
base=YAML.load_file('tests/semantic_ir_cases.yaml')['valid_cases'].find{|c|c['case_id']=='measurement'}['ir']
units=EraZeroValidation.load_yaml('spec/semantic_ir_1.0.yaml').fetch('quantity_and_measurement').fetch('units').values.flatten
puts JSON.generate(units.product([0,1,2]).map do |unit,state|
 ir=Marshal.load(Marshal.dump(base));ir['nodes'].find{|n|n['kind']=='measurement'}.merge!('unit'=>unit,'magnitude'=>'0.5')
 ir['nodes'].select{|n|n['kind']=='lexical_occurrence'}.each{|n|n['runtime_state']['code']=state}
 digest=EraZeroRenderer.semantic_digest(ir);ir['utterance_id']='UTT:'+digest[0,24];ir['serialization']['content_digest']=digest
 {unit:unit,state:state,formal:EraZeroRenderer.render(ir)}
end)
`],{cwd:root,encoding:'utf8',maxBuffer:8_000_000}));
const unitOrder=['1','second','minute','hour','day','meter','kilometer','gram','kilogram','degree','radian','bit','byte'];
assert.deepEqual([...new Set(unitSamples.map(s=>s.unit))],unitOrder);
for(const sample of unitSamples){
 let decoded;assert.doesNotThrow(()=>{decoded=check(sample.formal)},`${sample.unit} runtime ${sample.state}`);
 assert(decoded.tokens.some(t=>t.marker===`measurement_unit_${unitOrder.indexOf(sample.unit)+1}`));
 assert(decoded.tokens.filter(t=>t.kind==='root'&&t.runtime_state!==null).every(t=>t.runtime_state===sample.state));
}
const unitMidi=midiFromFormal(unitSamples[0].formal),unitNotes=notesFromMidi(unitMidi);
const unitToken=decodeStrictMusicMidi(unitMidi,authority.atoms).tokens.find(t=>t.marker==='measurement_unit_1');
for(const invalidCode of [0,14]){
 const notes=structuredClone(unitNotes.notes);
 const codeNote=notes.find(n=>n.start_tick===unitToken.start_tick+unitNotes.division/2);
 assert(codeNote);codeNote.midi=60+invalidCode;
 assert.throws(()=>decodeStrictMusicMidi(notesMidi(notes,unitNotes.division),authority.atoms));
}
const examples=[
 'Ada has a directed data link to Ben [2].',
 'I have a directed data link to you [0].',
 'The sensor is registering optical input from the bell.',
 'The sensor is registering acoustic input from the bell [2].',
 'It is not necessary that Ada is repairing the radio.',
 'The box has more mass than the radio.',
 'The box has a mass of at least 2.5 kilograms.',
 'Exactly two robots are repairing the radio.',
 'Ada was repairing the radio yesterday.'
];
const {parseNamedSentence}=await import('../pages/sentences.mjs');
for(const text of examples){const parsed=parseNamedSentence(text);assert(parsed,text);check((await composeNamedSentence(text,await template(parsed.predicate))).formal);}
for(const [compose,text] of [[composeSentenceConjunction,'Ada is repairing the radio and Ben is damaging the box.'],[composeSentenceSequence,'Ada is repairing the radio, then Ben is damaging the box.'],[composeSentenceConditional,'If the radio is damaged, repair it.']])check((await compose(text,template)).formal);
// Exercise exact decimal token payloads and transpose the same audible structure.
const modal=await composeNamedSentence('It is possible that Ada is repairing the radio.',await template('REP:111'));
modal.formal.semantic_ir.nodes.find(n=>n.operator==='modality').strength='0.9999999999999999999999999999999999999';
check(modal.formal);
const original=decodeStrictMusicMidi(midiFromFormal(modal.formal),authority.atoms);
for(const offset of [-12,12]){
 const shifted=structuredClone(modal.formal);shifted.performance.anchor_midi+=offset;
 for(const event of shifted.performance.lexical_events){event.base_midi+=offset;for(const key of ['family_opening_absolute_midi','address_absolute_midi'])event[key]=event[key].map(n=>n+offset);if(event.runtime_tail)event.runtime_tail.absolute_note+=offset;}
 const decoded=decodeStrictMusicMidi(midiFromFormal(shifted),authority.atoms);
 assert.deepEqual({...decoded,anchor_midi:60},original);
}
const bytes=midiFromFormal(modal.formal),corrupt=bytes.slice();corrupt[corrupt.indexOf(0x90)+1]++;
assert.throws(()=>decodeStrictMusicMidi(corrupt,authority.atoms));
assert.throws(()=>decodeStrictMusicMidi(bytes.slice(0,-1),authority.atoms));
assert.throws(()=>decodeStrictMusicMidi(bytes,authority.atoms,{maxTokens:1}),/limit/);
assert.throws(()=>decodeStrictMusicMidi(bytes,authority.atoms,{maxNotes:1}),/note count/);
// Instance tags are audible fingerprint fragments, not recovered object IDs.
const tagged=structuredClone((await composeNamedSentence('Ada is repairing the radio.',await template('REP:111'))).formal);
const name=await encodeName('Ada','instrumented-reference-7');
const reference=tagged.semantic_ir.nodes.find(n=>n.node_id==='a');reference.name=name;
const label=tagged.performance.lexical_events.find(e=>e.occurrence_id==='a');
label.target_id=name.name_id;label.address_relative_semitones=notesForName(name).map(n=>n-60);label.address_absolute_midi=label.address_relative_semitones.map(n=>label.base_midi+n);
check(tagged);
// Insert a gap inside an instance fingerprint. It cannot become two tokens.
function notesMidi(notes,division){
 const vlq=n=>{const bytes=[n&127];while((n>>=7)>0)bytes.unshift((n&127)|128);return bytes};
 const u16=n=>[n>>8,n&255],u32=n=>[n>>>24,(n>>>16)&255,(n>>>8)&255,n&255];
 const events=notes.flatMap(n=>[[n.start_tick,1,n.midi],[n.end_tick,0,n.midi]]).sort((a,b)=>a[0]-b[0]||a[1]-b[1]);
 const track=[];let last=0;
 for(const [at,on,pitch] of events){track.push(...vlq(at-last),on?0x90:0x80,pitch,on?88:0);last=at;}
 track.push(0,255,47,0);
 return Uint8Array.from([...Buffer.from('MThd'),...u32(6),...u16(0),...u16(1),...u16(division),...Buffer.from('MTrk'),...u32(track.length),...track]);
}
const taggedNotes=notesFromMidi(midiFromFormal(tagged));
const decodedTag=decodeStrictMusicMidi(midiFromFormal(tagged),authority.atoms).tokens.find(t=>t.kind==='phonemic');
const index=taggedNotes.notes.findIndex(n=>n.start_tick===decodedTag.start_tick)+3+name.phonemes.length*2+3;
for(const note of taggedNotes.notes.slice(index)){note.start_tick+=taggedNotes.division/2;note.end_tick+=taggedNotes.division/2;}
assert.throws(()=>decodeStrictMusicMidi(notesMidi(taggedNotes.notes,taggedNotes.division),authority.atoms),/malformed/);
// Duplicate dictionary codewords must produce ambiguity, never a chosen identity.
const simple=(await template('REP:111')).formal;
assert.throws(()=>decodeStrictMusicMidi(midiFromFormal(simple),[...authority.atoms,{...authority.atoms.find(a=>a.canonical_id==='REP:111'),canonical_id:'fixture:ambiguous'}]),/ambiguous/);
// A syntactically valid but mismatched closing convention must fail balancing.
const nested=structuredClone((await template('CMP:bcfd189eb305cf364ada975a')).formal);
const closing=nested.performance.lexical_events.find(e=>e.marker==='convention_1_close');
closing.address_absolute_midi[9]=closing.base_midi-1;
assert.throws(()=>decodeStrictMusicMidi(midiFromFormal(nested),authority.atoms),/scope/);
const kay=await composeNamedSentence('Kay is repairing the radio.',await template('REP:111'));
const cay=await composeNamedSentence('Cay is repairing the radio.',await template('REP:111'));
assert.deepEqual(decodeStrictMusicMidi(midiFromFormal(kay.formal),authority.atoms),decodeStrictMusicMidi(midiFromFormal(cay.formal),authority.atoms));
console.log(`Independent strict music inverse: ${count} dictionary and sentence performances recover audible lexical/reference/grammar tokens and exact boundaries, without source IR or a formal plan.`);
