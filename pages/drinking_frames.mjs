const codes={ongoing:9,bounded:10,habitual:11};
export function drinkingFrames(){return Object.entries(codes).flatMap(([viewpoint,code])=>[0,1,2].flatMap(runtime=>['open','close'].map(side=>({marker:`drinking_${viewpoint}_${runtime}_${side}`,path:[0,side==='open'?-39:39,code,runtime,0]}))));}
export function drinkingEvent(viewpoint,runtime,side,anchor=60){
 const f=drinkingFrames().find(f=>f.marker===`drinking_${viewpoint}_${runtime}_${side}`);if(!f||!Number.isInteger(anchor)||anchor<39||anchor>88)throw new Error('Invalid drinking frame.');
 return {kind:'grammar_marker',grammar_profile:'EZDRINKING-MUSIC-1',marker:f.marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:f.path.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5};
}
