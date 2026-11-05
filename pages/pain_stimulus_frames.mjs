export const PAIN_RELATION_CODES={actual_causation:2,expected_outcome:3,disposition:4};
export function painStimulusFrames(){return Object.entries(PAIN_RELATION_CODES).flatMap(([relation,code])=>[0,1,2].flatMap(runtime=>['open','close'].map(side=>({marker:`pain_stimulus_${relation}_${runtime}_${side}`,path:[0,side==='open'?-39:39,code,runtime,0]}))));}
export function painStimulusEvent(relation,runtime,side,anchor=60){
 const f=painStimulusFrames().find(f=>f.marker===`pain_stimulus_${relation}_${runtime}_${side}`);
 if(!f||!Number.isInteger(anchor)||anchor<39||anchor>88)throw new Error('Invalid pain relation frame.');
 return {kind:'grammar_marker',grammar_profile:'EZPAIN-STIMULUS-MUSIC-1',marker:f.marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:f.path.map(n=>n+anchor),note_duration_beats:.25,boundary_after_beats:.5};
}
