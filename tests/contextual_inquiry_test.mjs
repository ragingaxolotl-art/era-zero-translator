import assert from 'node:assert/strict';
import fs from 'node:fs';
import {canonicalDigest} from '../pages/engine.mjs';
import {contextualContentReference,createContextualContent} from '../pages/contextual_content.mjs';
import {createContextualInquiry,validateContextualInquiry} from '../pages/contextual_inquiry.mjs';
import {midiFromContextualInquiry,decodeContextualInquiryMidi} from '../pages/contextual_inquiry_music.mjs';
import {midiFromContextualContentDocument,readContextualContentMusic} from '../pages/contextual_content_music.mjs';
import {contextualInquiryFrames} from '../pages/contextual_inquiry_frames.mjs';
import {strictGrammarFrameInventory} from '../pages/strict_music_decoder.mjs';
import {acquisitionMusicFrames} from '../pages/acquisition_music_frames.mjs';
import {contextualContentMusicFrames} from '../pages/contextual_content_frames.mjs';
import {contentSelectionFrames} from '../pages/content_selection.mjs';
import {questionContentMusicFrames} from '../pages/question_music_frames.mjs';
import {quantifiedMusicFrames} from '../pages/quantified_music.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),paths=contextualInquiryFrames().map(f=>f.path.join(','));
for(const f of [...strictGrammarFrameInventory(),...acquisitionMusicFrames({includeUnderstanding:true,includeRoute:true}),...contextualContentMusicFrames(),...contentSelectionFrames(),...questionContentMusicFrames(),...quantifiedMusicFrames()])assert(!paths.includes(f.path.join(',')));
let count=0;
for(const label of ['the map','this map','that map','Nora','"River Stone"','I','you'])for(const anchor of [48,60,72]){
 const reference=await contextualContentReference(label),document=await createContextualInquiry(reference,{allowDraft:true}),midi=await midiFromContextualInquiry(document,authority,{allowDraft:true,anchor});
 const recovered=decodeContextualInquiryMidi(midi,authority.atoms,{allowDraft:true});
 assert.equal(recovered.answer_commitment,'none');assert.equal(recovered.specific_question_supplied,false);assert.equal(recovered.question_selection,'contextually_relevant_unresolved');
 const topic=await midiFromContextualContentDocument(document.topic,authority,{allowDraft:true,anchor});
 assert.notDeepEqual(midi,topic);assert.deepEqual(recovered.topic,((({anchor,selection})=>({anchor,...(selection?{selection}:{})}))(readContextualContentMusic(topic,authority.atoms,{allowDraft:true}))));
 assert.throws(()=>readContextualContentMusic(midi,authority.atoms,{allowDraft:true}));assert.throws(()=>decodeContextualInquiryMidi(topic,authority.atoms,{allowDraft:true}));assert.throws(()=>decodeContextualInquiryMidi(midi,authority.atoms));count++;
}
const valid=await createContextualInquiry(await contextualContentReference('the map'),{allowDraft:true});
for(const mutate of [d=>d.specific_question_supplied=true,d=>d.answer_commitment='positive',d=>d.question_selection='who made the map',d=>d.curiosity_asserted=true,async d=>d.topic=await createContextualContent('reasons',d.topic.anchor,{allowDraft:true})]){
 const d=structuredClone(valid);await mutate(d);const {content_digest,content_id,...body}=d,digest=await canonicalDigest(body);d.content_digest=digest;d.content_id=`EZINQUIRY:${digest.slice(0,24)}`;await assert.rejects(()=>validateContextualInquiry(d,{allowDraft:true}));
}
await assert.rejects(()=>createContextualInquiry(valid.topic.anchor));
console.log(`PASS ${count} contextual inquiry meanings/MIDI inverses: topic preserved, questions unresolved, no answer or curiosity asserted, topic-only distinction and rehashed corruption rejection.`);
