// Draft extension within the existing +/-39 namespace; no root sound changes.
export function custodyOpportunityFrames(){return [0,1,2].flatMap(runtime=>['open','close'].map(side=>({marker:`custody_opportunity_${runtime}_${side}`,path:[0,side==='open'?-39:39,17,runtime,0]})));}
export function custodyOpportunityEvent(runtime,side,anchor=60){
 const frame=custodyOpportunityFrames().find(f=>f.marker===`custody_opportunity_${runtime}_${side}`);
 if(!frame||!Number.isInteger(anchor)||anchor<39||anchor>88)throw new Error('Invalid custody_opportunity frame.');
 return {kind:'grammar_marker',grammar_profile:'EZCUSTODY-OPPORTUNITY-MUSIC-1',marker:frame.marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:frame.path.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5};
}
