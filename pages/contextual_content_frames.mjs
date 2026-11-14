// Draft selectors occupy a separate opt-in musical namespace.
export const CONTEXTUAL_CONTENT_KINDS=Object.freeze(['topic','communicated_content','reasons','perspective']);
export function contextualContentMusicFrames(){return CONTEXTUAL_CONTENT_KINDS.flatMap((kind,code)=>['open','close'].map(side=>({marker:`content_${kind}_${side}`,path:[0,side==='open'?-34:34,code,0]})));}
export function contextualContentMusicEvent(kind,side,anchor=60){
 const frame=contextualContentMusicFrames().find(f=>f.marker===`content_${kind}_${side}`);
 if(!frame||!Number.isInteger(anchor)||anchor<34||anchor>93)throw new Error('Invalid contextual content frame or anchor.');
 return {kind:'grammar_marker',grammar_profile:'EZCONTEXTUAL-CONTENT-MUSIC-1',marker:frame.marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:frame.path.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5};
}
