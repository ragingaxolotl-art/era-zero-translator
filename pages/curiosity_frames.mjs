export function curiosityFrames(){return ['open','close'].map(side=>({marker:`epistemic_curiosity_${side}`,path:[0,side==='open'?-39:39,0,0]}));}
export function curiosityEvent(side,anchor=60){
 const frame=curiosityFrames().find(f=>f.marker===`epistemic_curiosity_${side}`);if(!frame||!Number.isInteger(anchor)||anchor<39||anchor>88)throw new Error('Invalid curiosity frame.');
 return {kind:'grammar_marker',grammar_profile:'EZCURIOSITY-MUSIC-1',marker:frame.marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:frame.path.map(n=>n+anchor),note_duration_beats:.25,boundary_after_beats:.5};
}
