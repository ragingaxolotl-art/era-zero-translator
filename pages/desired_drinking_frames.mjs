const codes={same_as_desire_holder:12,explicit_content_subject:13};
export function desiredDrinkingFrames(){return Object.entries(codes).flatMap(([binding,code])=>[0,1,2].flatMap(runtime=>['open','close'].map(side=>({marker:`desired_drinking_${binding}_${runtime}_${side}`,path:[0,side==='open'?-39:39,code,runtime,0]}))));}
export function desiredDrinkingEvent(binding,runtime,side,anchor=60){
 const f=desiredDrinkingFrames().find(f=>f.marker===`desired_drinking_${binding}_${runtime}_${side}`);if(!f||!Number.isInteger(anchor)||anchor<39||anchor>88)throw new Error('Invalid desired drinking frame.');
 return {kind:'grammar_marker',grammar_profile:'EZDESIRED-DRINKING-MUSIC-1',marker:f.marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:f.path.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5};
}
