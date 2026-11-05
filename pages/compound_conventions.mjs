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

// Scan strict note events for fixed-width frames. A closing frame may attach
// directly to the next qualified payload, so a gap is not a frame delimiter.
export function conventionFramesFromNotes(notes,division,anchor){
 if(!Array.isArray(notes)||!Number.isInteger(division)||division<=0||!Number.isInteger(anchor))throw new Error('Invalid compound convention note input.');
 const frames=[],stack=[];
 for(let i=0;i<notes.length;i++){
  if(notes[i].midi!==anchor||!notes[i+1]||![-19,19].includes(notes[i+1].midi-anchor))continue;
  const group=notes.slice(i,i+11);
  if(group.length!==11||group.some((n,j)=>n.end_tick-n.start_tick!==division/4||(j&&n.start_tick!==group[j-1].end_tick)))throw new Error('Malformed compound convention timing.');
  const frame=decodeConventionFrame(group.map(n=>n.midi-anchor));
  if(frame.side==='open')stack.push(frame.sound_code);
  else if(stack.pop()!==frame.sound_code)throw new Error('Mismatched compound convention scope.');
  frames.push({...frame,start_tick:group[0].start_tick,end_tick:group.at(-1).end_tick});
  i+=10;
 }
 if(stack.length)throw new Error('Unclosed compound convention scope.');
 return frames;
}
