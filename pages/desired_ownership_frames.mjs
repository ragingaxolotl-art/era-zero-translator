const codes={same_as_desire_holder:15,explicit_content_subject:16};
export function desiredOwnershipFrames(){return Object.entries(codes).flatMap(([binding,code])=>[0,1,2].flatMap(runtime=>['open','close'].map(side=>({marker:`desired_ownership_${binding}_${runtime}_${side}`,path:[0,side==='open'?-39:39,code,runtime,0]}))));}
export function desiredOwnershipEvent(binding,runtime,side,anchor=60){
 const f=desiredOwnershipFrames().find(f=>f.marker===`desired_ownership_${binding}_${runtime}_${side}`);if(!f||!Number.isInteger(anchor)||anchor<39||anchor>88)throw new Error('Invalid desired ownership frame.');
 return {kind:'grammar_marker',grammar_profile:'EZDESIRED-OWNERSHIP-MUSIC-1',marker:f.marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:f.path.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5};
}
