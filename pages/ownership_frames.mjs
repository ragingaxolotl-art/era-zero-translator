// Draft extension within the existing +/-39 namespace; no root sound changes.
export function ownershipFrames(){return [0,1,2].flatMap(runtime=>['open','close'].map(side=>({marker:`ownership_${runtime}_${side}`,path:[0,side==='open'?-39:39,14,runtime,0]})));}
export function ownershipEvent(runtime,side,anchor=60){
 const frame=ownershipFrames().find(f=>f.marker===`ownership_${runtime}_${side}`);
 if(!frame||!Number.isInteger(anchor)||anchor<39||anchor>88)throw new Error('Invalid ownership frame.');
 return {kind:'grammar_marker',grammar_profile:'EZOWNERSHIP-MUSIC-1',marker:frame.marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:frame.path.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5};
}
