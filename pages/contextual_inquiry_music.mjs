import {validateContextualInquiry} from './contextual_inquiry.mjs';
import {contextualInquiryEvent} from './contextual_inquiry_frames.mjs';
import {contextualContentMusicEvent} from './contextual_content_frames.mjs';
import {renderLexicalOccurrences} from './bound_compounds.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
import {readSelectedContent} from './content_selection.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
export function decodeContextualInquiryMidi(bytes,atoms,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Contextual inquiry requires draft opt-in.');
 const reader=strictSemanticReader(bytes,atoms,'Malformed contextual inquiry.',{allowDraftContextualContent:true,allowDraftContextualInquiry:true}),tree=reader.readTree();
 if(reader.observed.speech_act!=='assertion'||tree.length!==1||tree[0].marker!=='contextual_inquiry_open'||tree[0].children?.length!==1||tree[0].children[0].marker!=='content_topic_open')throw new Error('Expected one contextual inquiry with a topic and neutral termination.');
 const topic=readSelectedContent(tree[0].children[0].children,'topic',reader);
 return {profile:'EZCONTEXTUAL-INQUIRY-INVERSE-1',status:'draft',content_kind:'contextual_question_set',topic,resolution_scope:'local_context',question_selection:'contextually_relevant_unresolved',answer_commitment:'none',specific_question_supplied:false,limitations:['Context must resolve the relevant questions; a topic label does not specify them.','No answer, knowledge, desire, curiosity, attention or information-seeking action is asserted.']};
}
export async function midiFromContextualInquiry(document,authority,{allowDraft=false,anchor=60}={}){
 const d=await validateContextualInquiry(document,{allowDraft});
 const refs=await renderLexicalOccurrences({nodes:[d.topic.anchor],edges:[]},authority,{anchor});
 const events=[contextualInquiryEvent('open',anchor),contextualContentMusicEvent('topic','open',anchor),...refs,contextualContentMusicEvent('topic','close',anchor),contextualInquiryEvent('close',anchor)];
 const bytes=midiFromScheduledEvents(events,anchor,[0,0]);decodeContextualInquiryMidi(bytes,authority.atoms,{allowDraft:true});return bytes;
}
