// Draft EZCOUNT-MUSIC-1; requires explicit opt-in in the strict MIDI inverse.
export function quantifiedMusicFrames(){
 const frames=[];
 for(const side of ['open','close']){
  const sign=side==='open'?-1:1;
  ['exact','at_least','at_most'].forEach((q,i)=>frames.push({marker:`counted_${q}_${side}`,path:[0,sign*27,i,0]}));
  frames.push({marker:`counted_restriction_${side}`,path:[0,sign*28,0,0]});
  frames.push({marker:`counted_predicate_${side}`,path:[0,sign*29,0,0]});
 }
 for(let depth=0;depth<128;depth++)frames.push({marker:`counted_reference_${depth}`,path:[0,-30,...depth.toString(3).padStart(5,'0').split('').map(d=>[0,1,-1][Number(d)]),0]});
 return frames;
}
export function quantifiedMusicEvent(marker,anchor=60){
 const frame=quantifiedMusicFrames().find(f=>f.marker===marker);
 if(!frame||!Number.isInteger(anchor)||frame.path.some(n=>anchor+n<0||anchor+n>127))throw new Error('Invalid draft counted-music marker or anchor.');
 return {kind:'grammar_marker',grammar_profile:'EZCOUNT-MUSIC-1',marker,occurrence_id:'draft-count',target_id:`EZCOUNT:${marker}`,register:'middle',base_midi:anchor,family_qualified_transliteration:marker,formal_carrier:'',family_opening_relative_semitones:[],family_opening_absolute_midi:[],address_relative_semitones:frame.path,address_absolute_midi:frame.path.map(n=>anchor+n),note_duration_beats:.25,boundary_after_beats:.5};
}
