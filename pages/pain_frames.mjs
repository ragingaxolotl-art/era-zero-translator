// Draft specialization in the existing ±39 extension namespace, discriminant 1.
// Curiosity retains discriminant 0; no prior frame is reassigned.
export function painFrames(){return ['open','close'].map(side=>({marker:`felt_bodily_pain_${side}`,path:[0,side==='open'?-39:39,1,0]}));}
export function painEvent(side,anchor=60){
 const f=painFrames().find(f=>f.marker===`felt_bodily_pain_${side}`);
 if(!f||!Number.isInteger(anchor)||anchor<39||anchor>88)throw new Error('Invalid pain frame.');
 return {kind:'grammar_marker',grammar_profile:'EZPAIN-MUSIC-1',marker:f.marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:f.path.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5};
}
