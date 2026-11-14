// Draft content delimiter, distinct from the final direct-question contour.
export function questionContentMusicFrames(){return ['open','close'].map(side=>({marker:`polar_content_${side}`,path:[0,side==='open'?-31:31,0,0]}));}
export function questionContentMusicEvent(side,anchor=60){
 const frame=questionContentMusicFrames().find(f=>f.marker===`polar_content_${side}`);
 if(!frame||!Number.isInteger(anchor)||frame.path.some(n=>anchor+n<0||anchor+n>127))throw new Error('Invalid question-content frame or anchor.');
 return {kind:'grammar_marker',grammar_profile:'EZQUESTION-MUSIC-1',marker:frame.marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:frame.path.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5};
}
