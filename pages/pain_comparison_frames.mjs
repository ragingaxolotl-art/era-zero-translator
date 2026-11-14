const codes={greater_than:5,less_than:6,equal:7};
export function painComparisonFrames(){return Object.entries(codes).flatMap(([relation,code])=>[0,1,2].flatMap(runtime=>['open','close'].map(side=>({marker:`pain_comparison_${relation}_${runtime}_${side}`,path:[0,side==='open'?-39:39,code,runtime,0]}))));}
export function painComparisonEvent(relation,runtime,side,anchor=60){
 const f=painComparisonFrames().find(f=>f.marker===`pain_comparison_${relation}_${runtime}_${side}`);
 if(!f||!Number.isInteger(anchor)||anchor<39||anchor>88)throw new Error('Invalid pain comparison frame.');
 return {kind:'grammar_marker',grammar_profile:'EZPAIN-COMPARISON-MUSIC-1',marker:f.marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:f.path.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5};
}
