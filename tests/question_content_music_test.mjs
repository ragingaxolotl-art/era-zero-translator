import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {createPolarQuestionContent} from '../pages/question_content.mjs';
import {midiFromPolarQuestionContent,readPolarQuestionContentMusic} from '../pages/question_content_music.mjs';
import {questionContentMusicFrames,questionContentMusicEvent} from '../pages/question_music_frames.mjs';
import {quantifiedMusicFrames} from '../pages/quantified_music.mjs';
import {strictGrammarFrameInventory,decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
import {strictSemanticReader} from '../pages/strict_semantic_reader.mjs';
import {midiFromFormal,midiFromScheduledEvents} from '../pages/engine.mjs';
const data=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const load=id=>data.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority:data}:{...JSON.parse(fs.readFileSync(new URL('../pages/'+data.resolution_files[id],import.meta.url))).variants['assertion:1'],authority:data};
const paths=questionContentMusicFrames().map(f=>f.path.join(','));assert.equal(new Set(paths).size,2);assert(![...strictGrammarFrameInventory(),...quantifiedMusicFrames()].some(f=>paths.includes(f.path.join(','))));
// Strip only token positions/timing; retain every musical root, name, role,
// register, runtime value and frame nesting for comparison of the payload.
function meaning(value){if(Array.isArray(value))return value.map(meaning);if(value&&typeof value==='object')return Object.fromEntries(Object.entries(value).filter(([k])=>!['opening_token','closing_token','enclosing_scopes','start_tick','end_tick'].includes(k)).map(([k,v])=>[k,meaning(v)]));return value;}
let count=0;
for(const state of [0,1,2])for(const phrase of ['Nora is conscious.','Nora is not conscious.','Eli is repairing the radio.','Eli is swimming.']){
 const input=phrase+` [${state}]`,parsed=parseNamedSentence(input),r=await composeNamedSentence(input,await load(parsed.predicate));
 const doc=await createPolarQuestionContent(r.semantic_ir,{allowDraft:true}),bytes=await midiFromPolarQuestionContent(doc,r.formal,{allowDraft:true});
 assert.throws(()=>decodeStrictMusicMidi(bytes,data.atoms));assert.throws(()=>readPolarQuestionContentMusic(bytes,data.atoms));
 const decoded=readPolarQuestionContentMusic(bytes,data.atoms,{allowDraft:true});assert.equal(decoded.assertion_commitment,'neither_answer');
 const original=strictSemanticReader(midiFromFormal(r.formal),data.atoms,'invalid').readTree();
 assert.deepEqual(meaning(decoded.predicate_tree),meaning(original));assert.notDeepEqual(bytes,midiFromFormal(r.formal));
 const direct=structuredClone(r.formal);direct.performance.contour_relative_semitones=[0,2];assert.notDeepEqual(bytes,midiFromFormal(direct));
 assert.throws(()=>readPolarQuestionContentMusic(midiFromFormal(direct),data.atoms,{allowDraft:true}));
 await assert.rejects(()=>midiFromPolarQuestionContent(doc,r.formal));
 count++;
}
for(const anchor of [48,60,72]){
 const empty=midiFromScheduledEvents(['open','close'].map(s=>questionContentMusicEvent(s,anchor)),anchor,[0,0]);
 assert.throws(()=>readPolarQuestionContentMusic(empty,data.atoms,{allowDraft:true}));
}
console.log(`PASS ${count} content auditions: independent MIDI token recovery preserves entire predicate structure; distinct from assertions/direct questions, explicit opt-in and no grammar-path collisions. Full cognitive inverse remains unfinished.`);
