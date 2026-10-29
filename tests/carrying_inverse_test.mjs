import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,composeSentenceSequence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {decodeDestinationCarryingMidi} from '../pages/carrying_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),template={authority};
const standard={dimension:'mass',threshold:'20.5',scale:'kilogram'},outputs=[];
const named=(phonemes,mode='name')=>({kind:'phonemic',reference_mode:mode,phonemes,instance_code:null});
const pip=named(['P','IH','P']),ada=named(['AE','D','AE']),box=named(['B','AA','K','S'],'definite_nominal');
const cases=[
 ['Pip is carrying the box to Ada.',false,[{operator:'aspect',aspect:'ongoing'}]],
 ['Pip carried the box to Ada.',true,[{operator:'time',relation:'before_speech'},{operator:'aspect',aspect:'bounded'}]],
 ['Pip habitually carries the box to Ada.',true,[{operator:'aspect',aspect:'habitual'}]],
 ['Pip did not carry the box to Ada.',true,[{operator:'time',relation:'before_speech'},{operator:'negation'},{operator:'aspect',aspect:'bounded'}]],
 ['Did Pip carry the box to Ada?',true,[{operator:'time',relation:'before_speech'},{operator:'aspect',aspect:'bounded'}]],
 ['Pip carried the box to Ada yesterday.',true,[{operator:'time',relation:'previous_day'},{operator:'aspect',aspect:'bounded'}]],
 ['Pip is carrying the heavy box to Ada.',false,[{operator:'aspect',aspect:'ongoing'}]],
 ['Pip habitually carries the light box to Ada.',true,[{operator:'aspect',aspect:'habitual'}]],
 ['It is not possible that Pip is carrying the box to Ada.',false,[{operator:'negation'},{operator:'modality',mode:'possible'},{operator:'aspect',aspect:'ongoing'}]],
 ['It is possible that Pip is not carrying the box to Ada.',false,[{operator:'modality',mode:'possible'},{operator:'negation'},{operator:'aspect',aspect:'ongoing'}]],
 ['With 70% confidence, it is possible that Pip is carrying the box to Ada.',false,[{operator:'modality',mode:'possible',strength:'0.7'},{operator:'aspect',aspect:'ongoing'}]],
 ['I am carrying the box to you.',false,[{operator:'aspect',aspect:'ongoing'}]]
];
for(const state of [0,1,2])for(const [text,completed,scopes] of cases){
 const parsed=parseNamedSentence(text),r=await composeNamedSentence(text+` [${state}]`,template,{destination:'spatial',...(parsed.requiredInterpretation?{interpretation:'mass_standard',standard}:{})});
 const bytes=midiFromFormal(r.formal),decoded=decodeDestinationCarryingMidi(bytes,authority.atoms);outputs.push({r,decoded,bytes});
 assert.equal(decoded.predicate,completed?'completed_destination_carrying':'ongoing_destination_carrying');assert.equal(decoded.runtime_state,state);assert.deepEqual(decoded.scopes,scopes,text);
 assert.equal(decoded.speech_act,text.startsWith('Did ')?'question':'assertion');assert.equal(decoded.meaning.receipt_asserted,false);
 assert.deepEqual(decoded.participants.carrier,text.startsWith('I ')?{kind:'deictic',role:'speaker'}:pip);
 assert.deepEqual(decoded.participants.destination,text.startsWith('I ')?{kind:'deictic',role:'addressee'}:ada);
 assert.deepEqual(decoded.participants.load,{...box,...(parsed.requiredInterpretation?{property:{dimension:'mass',comparison:parsed.adjective==='heavy'?'greater_than':'less_than',magnitude:'20.5',unit:'kilogram'}}:{})});
 const transposed=structuredClone(r.formal);transposed.performance.anchor_midi+=12;
 for(const event of transposed.performance.lexical_events){event.base_midi+=12;for(const key of ['family_opening_absolute_midi','address_absolute_midi'])event[key]=event[key].map(n=>n+12);if(event.runtime_tail)event.runtime_tail.absolute_note+=12;}
 assert.deepEqual(decodeDestinationCarryingMidi(midiFromFormal(transposed),authority.atoms),decoded);
 assert.throws(()=>decodeDestinationCarryingMidi(bytes.slice(0,-1),authority.atoms));
}
// Reference-renderer MIDI exercises lexical argument states without passing any
// source IR or rendering metadata into the inverse.
const controlled=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_controlled_english','-rera_zero_presentation','-rbase64','-e',String.raw`
 c=EraZeroControlledEnglish::Compiler.new
 labels=['ongoing destination-directed physical carrying','completed physical carrying to a destination']
 puts JSON.generate(labels.product([0,1,2]).map{|label,state|
  ir=c.compile!(%Q{ASSERT "#{label}" [#{state}] ROLE source "distinct material object" [0] ROLE target "distinct material object" [1] ROLE actor REF target ROLE destination "distinct material object" [2].})
  {state:state,completed:label.start_with?('completed'),midi:Base64.strict_encode64(EraZeroPresentation.midi(EraZeroRenderer.render(ir)))}
 })
`],{cwd:new URL('..',import.meta.url),encoding:'utf8',maxBuffer:3_000_000}));
for(const row of controlled){
 const d=decodeDestinationCarryingMidi(Buffer.from(row.midi,'base64'),authority.atoms);
 assert.equal(d.runtime_state,row.state);assert.equal(d.predicate,row.completed?'completed_destination_carrying':'ongoing_destination_carrying');assert.deepEqual(d.scopes,[]);
 for(const [role,state] of [['carrier',0],['load',1],['destination',2]])assert.deepEqual(d.participants[role],{kind:'lexical',root_id:'MAT:010',runtime_state:state});
}
// Independent raw MIDI writer for semantic corruptions. No renderer is used to
// repair or revalidate these altered performances before decoding them.
function midi(notes,division){
 const vlq=n=>{let a=[n&127];while((n>>=7)>0)a.unshift((n&127)|128);return a;},u32=n=>[n>>>24&255,n>>>16&255,n>>>8&255,n&255];
 const events=notes.flatMap(n=>[[n.start_tick,1,[0x90,n.midi,90]],[n.end_tick,0,[0x80,n.midi,0]]]).sort((a,b)=>a[0]-b[0]||a[1]-b[1]);
 let previous=0,track=[];for(const [tick,,event] of events){track.push(...vlq(tick-previous),...event);previous=tick;}track.push(0,255,47,0);
 return new Uint8Array([77,84,104,100,0,0,0,6,0,0,0,1,division>>8,division&255,77,84,114,107,...u32(track.length),...track]);
}
const fixture=outputs.find(o=>o.r.source_input==='Pip carried the box to Ada. [1]'),observed=decodeStrictMusicMidi(fixture.bytes,authority.atoms),raw=notesFromMidi(fixture.bytes);
const changed=(transform)=>{const notes=structuredClone(raw.notes);transform(notes);const bytes=midi(notes,raw.division);decodeStrictMusicMidi(bytes,authority.atoms);assert.throws(()=>decodeDestinationCarryingMidi(bytes,authority.atoms),/destination-carrying/);};
const notesFor=(notes,t)=>notes.filter(n=>n.start_tick>=t.start_tick&&n.end_tick<=t.end_tick);
// Balanced but wrong convention identity: the outer completion becomes unknown.
changed(notes=>{for(const t of observed.tokens.filter(t=>t.marker==='convention_6_open'||t.marker==='convention_6_close')){const ns=notesFor(notes,t);ns[9].midi=61;}});
// Keep a grammatical role frame but change the outer destination to recipient.
changed(notes=>{const start=observed.tokens.find(t=>t.marker==='role_destination_open'),end=observed.tokens[start.closing_token];for(const t of [start,end]){const ns=notesFor(notes,t);[1,1,0].forEach((p,i)=>ns[i+2].midi=60+p);}});
// Both destinations are valid sound labels, but they no longer agree.
changed(notes=>{const goal=observed.tokens.find(t=>t.kind==='phonemic'&&t.phonemes.join(' ')==='AE D AE'),carrier=observed.tokens.find(t=>t.kind==='phonemic'&&t.phonemes.join(' ')==='P IH P');const a=notesFor(notes,goal),b=notesFor(notes,carrier);assert.equal(a.length,b.length);a.forEach((n,i)=>n.midi=b[i].midi+24);});
// A structurally valid approach root cannot replace the completed-arrival head.
changed(notes=>{const head=observed.tokens.find(t=>t.root_id==='MOV:110'),inner=observed.tokens.find(t=>t.root_id==='MOV:111');const a=notesFor(notes,head),b=notesFor(notes,inner);assert.equal(a.length,b.length+1);b.forEach((n,i)=>a[i].midi=n.midi);});
// Repeating the right noun with a different mass restriction is also inconsistent.
const propertyFixture=outputs.find(o=>o.r.source_input==='Pip habitually carries the light box to Ada. [1]');
const propertyObserved=decodeStrictMusicMidi(propertyFixture.bytes,authority.atoms),propertyRaw=notesFromMidi(propertyFixture.bytes);
const digit=propertyObserved.tokens.find(t=>t.marker==='digit_2');notesFor(propertyRaw.notes,digit)[3].midi++;
const propertyChanged=midi(propertyRaw.notes,propertyRaw.division);decodeStrictMusicMidi(propertyChanged,authority.atoms);
assert.throws(()=>decodeDestinationCarryingMidi(propertyChanged,authority.atoms),/destination-carrying/);
// Both performances use homophonic labels; the inverse must not invent spelling.
const homophones=[];
for(const name of ['Kay','Cay']){const r=await composeNamedSentence(`${name} carried the box to Ada.`,template,{destination:'spatial'});homophones.push(decodeDestinationCarryingMidi(midiFromFormal(r.formal),authority.atoms));}
assert.deepEqual(homophones[0],homophones[1]);
// Different source/load assignments must survive even with identical vocabulary.
const a=await composeNamedSentence('Pip carried Ada to the box.',template,{destination:'spatial'});
const b=await composeNamedSentence('Ada carried Pip to the box.',template,{destination:'spatial'});
const da=decodeDestinationCarryingMidi(midiFromFormal(a.formal),authority.atoms),db=decodeDestinationCarryingMidi(midiFromFormal(b.formal),authority.atoms);
assert.deepEqual(da.participants.carrier,db.participants.load);assert.deepEqual(da.participants.load,db.participants.carrier);assert.notDeepEqual(da,db);
// Unknown constructions and extra clauses cannot produce a partial inverse.
const toward=await composeNamedSentence('Pip carried the box toward Ada.',template);
assert.throws(()=>decodeDestinationCarryingMidi(midiFromFormal(toward.formal),authority.atoms));
const sequence=await composeSentenceSequence('Pip is carrying the box, then Ada is carrying the shelf.',async()=>template);
assert.throws(()=>decodeDestinationCarryingMidi(midiFromFormal(sequence.formal),authority.atoms));
console.log(`Carrying MIDI inverse: ${outputs.length} full supported performances recover predicate, ordered scope, participants, property and runtime from MIDI alone. Transposition, role reversal, malformed-but-balanced conventions/roles/bindings/roots, truncation and unsupported extra content are checked.`);
