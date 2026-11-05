// Restriction on the source of referenced content, not a matrix speech event.
import {grammarMarker} from './scheduler.mjs';
export function contentSelectionFrames(){return ['open','close'].map(side=>({marker:`spoken_source_${side}`,path:[0,side==='open'?-35:35,0,0]}));}
export function spokenSourceEvent(side,anchor){
 const frame=contentSelectionFrames().find(f=>f.marker===`spoken_source_${side}`);
 if(!frame||!Number.isInteger(anchor)||anchor<35||anchor>92)throw new Error('Invalid spoken-source frame.');
 return {kind:'grammar_marker',grammar_profile:'EZCONTENT-SELECTION-1',marker:frame.marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:frame.path.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5};
}
export function validContentSelection(kind,selection){return kind==='communicated_content'&&selection&&typeof selection==='object'&&!Array.isArray(selection)&&Object.keys(selection).length===2&&selection.channel==='speech'&&selection.time==='before_speech';}
export function selectedContentEvents(content,events,anchor){
 if(!Object.hasOwn(content,'selection'))return events;
 if(!validContentSelection(content.content_kind,content.selection))throw new Error('Unsupported content selection.');
 const formal={performance:{anchor_midi:anchor}};
 return [spokenSourceEvent('open',anchor),grammarMarker(formal,'content-source','time_before_speech_open'),...events,grammarMarker(formal,'content-source','time_before_speech_close'),spokenSourceEvent('close',anchor)];
}
export function readSelectedContent(nodes,kind,reader){
 let selection;
 if(nodes.length===1&&nodes[0].marker==='spoken_source_open'){
  const source=nodes[0];if(kind!=='communicated_content'||source.children?.length!==1||source.children[0].marker!=='time_before_speech_open')throw new Error('Invalid spoken content source.');
  selection={channel:'speech',time:'before_speech'};nodes=source.children[0].children;
 }
 const anchor=reader.reference(nodes,'middle');
 if(!['phonemic','deictic'].includes(anchor.kind)||anchor.property||anchor.reference_mode==='nominal_class')throw new Error('Invalid contextual content reference.');
 return {anchor,...(selection?{selection}:{})};
}
