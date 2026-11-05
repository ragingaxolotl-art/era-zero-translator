export function contextualInquiryFrames(){return ['open','close'].map(side=>({marker:`contextual_inquiry_${side}`,path:[0,side==='open'?-38:38,0,0]}));}
export function contextualInquiryEvent(side,anchor=60){
 const frame=contextualInquiryFrames().find(f=>f.marker===`contextual_inquiry_${side}`);
 if(!frame||!Number.isInteger(anchor)||anchor<38||anchor>89)throw new Error('Invalid contextual inquiry frame.');
 return {kind:'grammar_marker',grammar_profile:'EZCONTEXTUAL-INQUIRY-MUSIC-1',marker:frame.marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:frame.path.map(n=>n+anchor),note_duration_beats:.25,boundary_after_beats:.5};
}
