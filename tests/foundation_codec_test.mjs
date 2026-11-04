import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {foundationEvent,foundationPath,foundationPayload,validateFoundations} from '../pages/foundations.mjs';
import {decodeFoundationMusicMidi} from '../pages/foundation_decoder.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {canonicalDigest,midiFromFormal} from '../pages/engine.mjs';
const root=new URL('..',import.meta.url),registry=JSON.parse(fs.readFileSync(new URL('reviews/foundation_extension_candidates.json',root))),atoms=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))).atoms;
await assert.rejects(()=>validateFoundations(registry.records),/unapproved/);
await validateFoundations(registry.records,{allowDraft:true});
// Exhaust all addresses in the proposed eight-trit space; this is address evidence,
// not an approval of 6,561 meanings or a perceptual-listening score.
assert.equal(new Set(Array.from({length:6561},(_,i)=>foundationPath(i).join(','))).size,6561);
for(const a of atoms)assert(!a.note_path_semitones.includes(-23));
const samples=[];
for(const r of registry.records)for(const register of ['low','middle','high','sustained_background'])for(const runtimeState of [0,1,2])for(const anchor of [48,60,72])samples.push({r,options:{register,runtimeState,anchor,allowDraft:true}});
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_foundations','-rjson','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|s|o=s["options"];EraZeroFoundations.event(s["r"],register:o["register"],runtime_state:o["runtimeState"],anchor:o["anchor"],allow_draft:true)})'],{cwd:root,input:JSON.stringify(samples),encoding:'utf8',maxBuffer:8_000_000}));
const sounds=[];
for(const [i,s] of samples.entries()){
 const event=await foundationEvent(s.r,s.options);assert.deepEqual(event,ruby[i]);
 // Transport probe only. This empty-IR harness is deliberately NOT an EZF semantic utterance.
 const harness={semantic_ir:{nodes:[],edges:[]},performance:{lexical_events:[event],anchor_midi:s.options.anchor,contour_relative_semitones:[0,0]}};
 const midi=midiFromFormal(harness);sounds.push(Buffer.from(midi).toString('base64'));
 assert.throws(()=>decodeStrictMusicMidi(midi,atoms),/unrecognized/);
 const d=await decodeFoundationMusicMidi(midi,atoms,registry.records,{allowDraft:true});
 assert.equal(d.tokens.length,1);assert.equal(d.tokens[0].kind,'foundation');assert.equal(d.tokens[0].foundation_id,s.r.foundation_id);assert.equal(d.tokens[0].runtime_state,s.options.runtimeState);assert.equal(d.tokens[0].register,s.options.register);assert.equal(d.anchor_midi,s.options.anchor);
 await assert.rejects(()=>decodeFoundationMusicMidi(midi,atoms,registry.records),/unapproved/);
 // A duration-valid wrong frame must fail, even when the runtime ending is intact.
 const broken=structuredClone(harness);broken.performance.lexical_events[0].address_absolute_midi[1]++;
 await assert.rejects(()=>decodeFoundationMusicMidi(midiFromFormal(broken),atoms,registry.records,{allowDraft:true}),/unrecognized/);
}
assert.equal(new Set(sounds).size,sounds.length);
// The candidate-aware observer must leave every current atomic performance intact.
const index=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));let legacy=0;
for(const atom of atoms){
 const document=JSON.parse(fs.readFileSync(new URL('pages/'+index.resolution_files[atom.canonical_id],root)));
 for(const state of [0,1,2]){
  const bytes=midiFromFormal(document.variants[`assertion:${state}`].formal);
  const before=decodeStrictMusicMidi(bytes,atoms),after=await decodeFoundationMusicMidi(bytes,atoms,registry.records,{allowDraft:true});
  assert.deepEqual(after.tokens,before.tokens);assert.equal(after.speech_act,before.speech_act);legacy++;
 }
}
const mutable=structuredClone(registry.records[0]),pending=foundationEvent(mutable,{allowDraft:true});mutable.sound_code=6560;const snapshotted=await pending;assert.equal(snapshotted.target_id,registry.records[0].foundation_id);assert.deepEqual(snapshotted.address_relative_semitones,foundationPath(0));
const invalid=[...registry.records,structuredClone(registry.records[0])];await assert.rejects(()=>validateFoundations(invalid,{allowDraft:true}),/collision/);
const altered=structuredClone(registry.records);altered[0].definition+=' Changed meaning.';await assert.rejects(()=>validateFoundations(altered,{allowDraft:true}),/mismatch/);
const rejectedByRuby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_foundations','-rjson','-e',String.raw`
 r=JSON.parse(STDIN.read)
 trials=[-> {EraZeroFoundations.validate!(r)},-> {EraZeroFoundations.validate!(r+[r[0]],allow_draft:true)},-> {EraZeroFoundations.path(-1)},-> {EraZeroFoundations.path(6561)},-> {EraZeroFoundations.event(r[0],anchor:0,allow_draft:true)}]
 puts JSON.generate(trials.map{|t|begin;t.call;false;rescue ArgumentError;true;end})
`],{cwd:root,input:JSON.stringify(registry.records),encoding:'utf8'}));assert.deepEqual(rejectedByRuby,[true,true,true,true,true]);
for(const code of [-1,6561,1.5])assert.throws(()=>foundationPath(code),/address/);
for(const anchor of [0,127,60.5])await assert.rejects(()=>foundationEvent(registry.records[0],{anchor,allowDraft:true}),/range|context/);
// A different meaning cannot reuse an occupied address, even with a valid new hash.
const conflict=structuredClone(registry.records[1]);conflict.sound_code=0;conflict.content_digest=await canonicalDigest(foundationPayload(conflict));conflict.foundation_id='FND:'+conflict.content_digest.slice(0,24);await assert.rejects(()=>validateFoundations([registry.records[0],conflict],{allowDraft:true}),/collision/);
console.log(`Candidate foundation codec: ${samples.length} register/anchor/runtime cases match independent Ruby events and decode from MIDI; 6,561 addresses are unique and ${legacy} existing atomic performances decode unchanged. Unapproved defaults, malformed frames, altered identities and occupied addresses reject. No sentence translation or canonical vocabulary is certified.`);
