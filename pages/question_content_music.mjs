import {canonicalDigest,midiFromScheduledEvents} from './engine.mjs';
import {scheduledLexicalEvents} from './scheduler.mjs';
import {validatePolarQuestionContent} from './question_content.mjs';
import {questionContentMusicEvent} from './question_music_frames.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
export async function midiFromPolarQuestionContent(document,formal,{allowDraft=false}={}){
 formal=structuredClone(formal);
 document=await validatePolarQuestionContent(document,{allowDraft});
 if(await canonicalDigest(document.proposition)!==await canonicalDigest(formal.semantic_ir)||formal.semantic_digest!==document.proposition.serialization.content_digest)throw new Error('Question content and formal proposition differ.');
 const anchor=formal.performance.anchor_midi;
 const events=[questionContentMusicEvent('open',anchor),...scheduledLexicalEvents(formal),questionContentMusicEvent('close',anchor)];
 // This is a standalone content audition, not a matrix utterance. The neutral
 // closing contour terminates the stream; the wrapper carries nonassertion.
 return midiFromScheduledEvents(events,anchor,[0,0]);
}
export function readPolarQuestionContentMusic(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Question-content music requires draft opt-in.');
 const reader=strictSemanticReader(bytes,atoms,'Malformed polar-content music.',{allowDraftQuestionContent:true}),tree=reader.readTree();
 if(reader.observed.speech_act!=='assertion'||tree.length!==1||tree[0].marker!=='polar_content_open'||!tree[0].children.length)throw new Error('Expected one nonempty polar-content frame with neutral termination.');
 return {profile:'EZQUESTION-MUSIC-1',question_kind:'polar',assertion_commitment:'neither_answer',predicate_tree:tree[0].children,limitations:['Structural token recovery; predicate-specific semantic validation is still required.','Standalone content audition; no matrix cognitive predicate is asserted.']};
}
