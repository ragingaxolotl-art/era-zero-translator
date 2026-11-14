export function painPreferenceFrames(){return [0,1,2].flatMap(runtime=>['open','close'].map(side=>({marker:`pain_preference_${runtime}_${side}`,path:[0,side==='open'?-39:39,8,runtime,0]})));}
export function painPreferenceEvent(runtime,side,anchor=60){
 const f=painPreferenceFrames().find(f=>f.marker===`pain_preference_${runtime}_${side}`);
 if(!f||!Number.isInteger(anchor)||anchor<39||anchor>88)throw new Error('Invalid pain preference frame.');
 return {kind:'grammar_marker',grammar_profile:'EZPAIN-PREFERENCE-MUSIC-1',marker:f.marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:f.path.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5};
}
