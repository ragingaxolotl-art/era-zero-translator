// Decode one complete EZLEX-1 frame, relative to the utterance anchor.
// This recovers a convention code, not the meaning of the enclosed payload.
export function decodeConventionFrame(pitches){
 if(!Array.isArray(pitches)||pitches[0]!==0||![-19,19].includes(pitches[1]))return null;
 if(pitches.length!==11||pitches.at(-1)!==0)throw new Error('Malformed compound convention frame.');
 let code=0;
 for(const pitch of pitches.slice(2,-1)){
  const trit=[0,1,-1].indexOf(pitch);
  if(trit<0)throw new Error('Malformed compound convention trit.');
  code=code*3+trit;
 }
 return {profile:'EZLEX-1',side:pitches[1]===-19?'open':'close',sound_code:code};
}
