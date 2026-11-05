import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {createKnowledgeAcquisition} from '../pages/knowledge_acquisition.mjs';
import {midiFromKnowledgeAcquisition,knowledgeAcquisitionEvents} from '../pages/knowledge_acquisition_music.mjs';
import {decodeFoundationSentenceMidi as decode} from '../pages/foundation_semantic_decoder.mjs';
import {acquisitionMusicFrames} from '../pages/acquisition_music_frames.mjs';
import {questionContentMusicFrames} from '../pages/question_music_frames.mjs';
import {quantifiedMusicFrames} from '../pages/quantified_music.mjs';
import {strictGrammarFrameInventory} from '../pages/strict_music_decoder.mjs';
import {midiFromFormal,midiFromScheduledEvents} from '../pages/engine.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url))),authority=read('pages/data/index.json'),records=read('pages/data/foundation_preview_candidates.json').records;
const load=id=>({...read('pages/'+authority.resolution_files[id]).variants['assertion:1'],authority}),options={allowDraft:true,allowDraftQuestionContent:true,allowDraftAcquisition:true};
const paths=acquisitionMusicFrames().map(f=>f.path.join(','));assert.equal(new Set(paths).size,4);assert(![...strictGrammarFrameInventory(),...questionContentMusicFrames(),...quantifiedMusicFrames()].some(f=>paths.includes(f.path.join(','))));
let count=0;const parity=[];
for(const eventState of [0,1,2])for(const resultState of [0,1,2])for(const negative of [false,true]){
 const result=await composeFoundationSentence(`Nora knows whether Eli is ${negative?'not ':''}conscious [${resultState}].`,authority,records,load,{allowDraft:true,allowCognitive:true});
 const doc=await createKnowledgeAcquisition(result,{allowDraft:true,runtimeState:eventState}),bytes=await midiFromKnowledgeAcquisition(doc,result.formal,authority,{allowDraft:true}),d=await decode(bytes,authority.atoms,records,options);
 assert.equal(d.meaning.predicate.root_id,'ORI:110');assert.equal(d.meaning.runtime_state,eventState);assert.equal(d.meaning.result.runtime_state,resultState);assert.equal(d.meaning.result_assertion,'at_culmination_only');assert.deepEqual(d.meaning.phase_contract,doc.phase_contract);
 const original=await decode(midiFromFormal(result.formal),authority.atoms,records,options);assert.deepEqual(d.meaning.result,original.meaning);assert.deepEqual(d.meaning.result.arguments.content.proposition.scopes,negative?[{operator:'negation'}]:[]);
 await assert.rejects(()=>decode(bytes,authority.atoms,records,{allowDraft:true,allowDraftQuestionContent:true}));
 const events=await knowledgeAcquisitionEvents(doc,result.formal,authority,{allowDraft:true});events.splice(events.findIndex(e=>e.target_id==='ORI:110'),1);await assert.rejects(()=>decode(midiFromScheduledEvents(events,60,[0,0]),authority.atoms,records,options));parity.push({document:doc,midi:Buffer.from(bytes).toString('base64')});count++;
}
console.log(`PASS ${count} acquisition performances: independent transition/result runtimes, complete result meaning recovery, phase linkage, content negation, explicit admission, missing-root rejection and frame collision checks. English integration pending.`);

const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_knowledge_acquisition','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|Base64.strict_encode64(EraZeroKnowledgeAcquisition.midi(d,allow_draft:true))})"],{cwd:new URL('..',import.meta.url),input:JSON.stringify(parity.map(p=>p.document)),encoding:'utf8',maxBuffer:15_000_000}));
assert.deepEqual(ruby,parity.map(p=>p.midi));
const invalid=structuredClone(parity[0].document);invalid.phase_contract.after='holds';
const bad=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_knowledge_acquisition','-e',"d=JSON.parse(STDIN.read);puts JSON.generate(d.each_with_index.map{|v,i|begin;EraZeroKnowledgeAcquisition.midi(v,allow_draft:i!=0);false;rescue StandardError;true;end})"],{cwd:new URL('..',import.meta.url),input:JSON.stringify([parity[0].document,invalid]),encoding:'utf8'}));assert.deepEqual(bad,[true,true]);
console.log('PASS all 18 acquisition MIDI streams equal Ruby regeneration; default admission and changed persistence contract reject.');
