const codes={explicit_content_subject:18};
export function desiredAvailabilityFrames(){return Object.entries(codes).flatMap(([binding,code])=>[0,1,2].flatMap(runtime=>['open','close'].map(side=>({marker:`desired_availability_${binding}_${runtime}_${side}`,path:[0,side==='open'?-39:39,code,runtime,0]}))));}
export function desiredAvailabilityEvent(binding,runtime,side,anchor=60){
 const f=desiredAvailabilityFrames().find(f=>f.marker===`desired_availability_${binding}_${runtime}_${side}`);if(!f||!Number.isInteger(anchor)||anchor<39||anchor>88)throw new Error('Invalid desired availability frame.');
 return {kind:'grammar_marker',grammar_profile:'EZDESIRED-AVAILABILITY-MUSIC-1',marker:f.marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:f.path.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5};
}
