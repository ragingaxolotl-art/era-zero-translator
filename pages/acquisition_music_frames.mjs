// Explicit draft result binding; not mere juxtaposition of two predicates.
export function acquisitionMusicFrames({includeUnderstanding=false,includeRoute=false}={}){return ['open','close'].flatMap(side=>[['knowledge_acquisition',32],['acquisition_result',33],...(includeUnderstanding?[['understanding_acquisition',36]]:[]),...(includeRoute?[['route_learning',37]]:[])].map(([name,code])=>({marker:`${name}_${side}`,path:[0,side==='open'?-code:code,0,0]})));}
export function acquisitionMusicEvent(marker,anchor=60){
 const frame=acquisitionMusicFrames({includeUnderstanding:true,includeRoute:true}).find(f=>f.marker===marker);
 if(!frame||!Number.isInteger(anchor)||frame.path.some(n=>anchor+n<0||anchor+n>127))throw new Error('Invalid acquisition frame or anchor.');
 return {kind:'grammar_marker',grammar_profile:marker.startsWith('route_learning_')?'EZROUTE-LEARNING-MUSIC-1':marker.startsWith('understanding_')?'EZUNDERSTANDING-ACQUISITION-MUSIC-1':'EZKNOWLEDGE-ACQUISITION-MUSIC-1',marker,register:'middle',base_midi:anchor,family_opening_absolute_midi:[],address_absolute_midi:frame.path.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5};
}
