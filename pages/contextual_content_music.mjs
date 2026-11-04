// Draft contextual selectors. These select content; they do not assert a
// communication, a true answer, understanding, empathy, or successful learning.
import {midiFromScheduledEvents} from './engine.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
import {CONTEXTUAL_CONTENT_KINDS,contextualContentMusicEvent} from './contextual_content_frames.mjs';
export {CONTEXTUAL_CONTENT_KINDS,contextualContentMusicFrames,contextualContentMusicEvent} from './contextual_content_frames.mjs';
export function readContextualContentMusic(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Contextual content requires explicit draft opt-in.');
 const reader=strictSemanticReader(bytes,atoms,'Malformed contextual content music.',{allowDraftContextualContent:true}),tree=reader.readTree();
 const kind=CONTEXTUAL_CONTENT_KINDS.find(k=>tree[0]?.marker===`content_${k}_open`);
 if(reader.observed.speech_act!=='assertion'||tree.length!==1||!kind)throw new Error('Expected one contextual selector and neutral termination.');
 const reference=reader.reference(tree[0].children,'middle');
 if(reference.kind==='lexical'||reference.property||reference.reference_mode==='nominal_class')throw new Error('Contextual selector requires a singular entity reference.');
 return {profile:'EZCONTEXTUAL-CONTENT-MUSIC-1',status:'draft',content_kind:kind,anchor:reference,resolution_scope:'local_context',assertion_commitment:'none',limitations:['Context selects the content; no particular proposition, answer, explanation or experience is supplied.','Phonemes do not prove external identity. Multiple contents associated with the same anchor require further contextual resolution.','No matrix cognitive predicate or successful acquisition is asserted.']};
}
export function midiFromContextualContent(kind,referenceEvents,atoms,{allowDraft=false,anchor=60}={}){
 if(!allowDraft)throw new Error('Contextual content requires explicit draft opt-in.');
 const events=[contextualContentMusicEvent(kind,'open',anchor),...structuredClone(referenceEvents),contextualContentMusicEvent(kind,'close',anchor)];
 const bytes=midiFromScheduledEvents(events,anchor,[0,0]);
 // Validate what was actually sounded, including exact reference cardinality.
 readContextualContentMusic(bytes,atoms,{allowDraft:true});
 return bytes;
}
