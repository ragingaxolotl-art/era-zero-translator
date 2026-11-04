import {curiosityFrames} from '../pages/curiosity_frames.mjs';
import {strictGrammarFrameInventory} from '../pages/strict_music_decoder.mjs';
import {acquisitionMusicFrames} from '../pages/acquisition_music_frames.mjs';
import {contextualInquiryFrames} from '../pages/contextual_inquiry_frames.mjs';
import {contextualContentMusicFrames} from '../pages/contextual_content_frames.mjs';
import {contentSelectionFrames} from '../pages/content_selection.mjs';
import {questionContentMusicFrames} from '../pages/question_music_frames.mjs';
import {quantifiedMusicFrames} from '../pages/quantified_music.mjs';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeCuriosity,validateCuriosity,curiosityInterpretationPlan} from '../pages/curiosity.mjs';
import {midiFromCuriosity,decodeCuriosityMidi} from '../pages/curiosity_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_preview_candidates.json',import.meta.url))).records;
const phrases=['Orin is curious about the map.','Orin is not curious about the map.','Orin was curious about the map.',"Orin wasn't curious about the map.",'Is Orin curious about the map?',"Wasn't Orin curious about the map?",'I am curious about Nora.','Are you curious about this map?','"River Stone" was curious about that map.'];
const sounds=new Set();let count=0;
for(const phrase of phrases)for(const runtime of [0,1,2]){
 const d=await composeCuriosity(phrase+` [${runtime}]`,{allowDraft:true}),bytes=await midiFromCuriosity(d,authority,records,{allowDraft:true}),r=await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,records,{allowDraft:true});
 assert.equal(r.profile,'EZCURIOSITY-INVERSE-1');assert.equal(r.runtime_state,runtime);assert.deepEqual(r.scopes,d.scopes);assert.equal(r.speech_act,d.speech_act);assert.equal(r.criterion,d.criterion);assert.equal(r.desired_outcome,d.desired_outcome);assert.equal(r.outcome_commitment,'desired_not_asserted');assert.equal(r.inquiry.specific_question_supplied,false);assert.equal(r.inquiry.answer_commitment,'none');
 if(d.experiencer.name)assert.deepEqual(r.experiencer.phonemes,d.experiencer.name.phonemes);else assert.equal(r.experiencer.role,d.experiencer.deictic_role);
 assert.deepEqual(r.inquiry.topic.anchor.phonemes,d.inquiry.topic.anchor.name.phonemes);sounds.add(Buffer.from(bytes).toString('base64'));count++;
 await assert.rejects(()=>decodeCuriosityMidi(bytes,authority.atoms,records));
}
assert.equal(sounds.size,27);
const neutral=await composeCuriosity('They are curious about the map.',{allowDraft:true,bindings:{ref0:{referent:'Orin',number:'singular'}}}),named=await composeCuriosity(phrases[0],{allowDraft:true});assert.deepEqual(neutral,named);
for(const mutate of [d=>d.outcome_commitment='asserted',d=>d.criterion='Attention is enough',d=>d.desired_outcome='someone_else_gains_information',d=>d.inquiry.specific_question_supplied=true]){
 const d=structuredClone(named);mutate(d);const {content_digest,content_id,...body}=d,digest=await canonicalDigest(body);d.content_digest=digest;d.content_id=`EZCUR:${digest.slice(0,24)}`;await assert.rejects(()=>validateCuriosity(d,{allowDraft:true}));
}
for(const text of ['Orin is curious.','Orin is very curious about the map.','Orin is curious whether Nora swims.','Orin are curious about the map.'])assert.equal(curiosityInterpretationPlan(text),null);
console.log(`PASS ${count} curiosity sentence/music inverses with unchanged desire identity, unasserted epistemic outcome, unresolved inquiry, scope, runtime and explicit singular they.`);

const paths=curiosityFrames().map(f=>f.path.join(','));
for(const f of [...strictGrammarFrameInventory(),...acquisitionMusicFrames({includeUnderstanding:true,includeRoute:true}),...contextualInquiryFrames(),...contextualContentMusicFrames(),...contentSelectionFrames(),...questionContentMusicFrames(),...quantifiedMusicFrames()])assert(!paths.includes(f.path.join(',')));
