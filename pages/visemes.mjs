import{soundPlanFromFormal}from'./engine.mjs?v=1.14.0';
import{recognitionForTarget}from'./recognition.mjs?v=1.14.0';

export const VISEME_VERSION='EZVISEME-1';
export const EYE_EXPRESSIONS=Object.freeze(['happy','sad','angry']);
export const VISEMES=Object.freeze({
  REST:{label:'rest',description:'Neutral closed rest between voiced events.'},
  MBP:{label:'bilabial closure',description:'Both lips close for m, b, or p.'},
  TDS:{label:'front tongue',description:'Tongue-front articulation for t, d, or s.'},
  KG:{label:'back tongue',description:'Back-of-mouth articulation for k or g.'},
  LN:{label:'tongue lift',description:'Tongue lifts behind the teeth for l or n.'},
  W:{label:'rounded glide',description:'Rounded forward glide for w.'},
  Y:{label:'palatal glide',description:'Narrow spread glide for y.'},
  A:{label:'wide open',description:'Open jaw for a.'},
  E:{label:'mid spread',description:'Moderately spread mouth for e.'},
  I:{label:'narrow spread',description:'Spread narrow mouth for i.'},
  O:{label:'round open',description:'Rounded open mouth for o.'},
  U:{label:'round narrow',description:'Tightly rounded mouth for u.'}
});

const ONSETS=Object.freeze({m:'MBP',b:'MBP',p:'MBP',t:'TDS',d:'TDS',s:'TDS',k:'KG',g:'KG',l:'LN',n:'LN',w:'W',y:'Y'});
const NUCLEI=Object.freeze({a:'A',e:'E',i:'I',o:'O',u:'U'});
export const SYLLABLE_VISEMES=Object.freeze(Object.fromEntries(
  ['ba','da','do','ga','gi','ki','li','ma','ni','nu','si','te','wu','ya'].map(syllable=>[syllable,Object.freeze({onset:ONSETS[syllable[0]],nucleus:NUCLEI[syllable.at(-1)]})])
));

export function visemesForSyllable(syllable){
  const normalized=String(syllable||'').toLowerCase();
  const mapped=SYLLABLE_VISEMES[normalized];
  if(!mapped)throw new Error(`No Era Zero viseme mapping for syllable: ${syllable}`);
  return mapped;
}

function cue({section,note,start,duration,syllable,targetId,eventIndex,noteIndex,sustainOnly=false}){
  const map=visemesForSyllable(syllable);
  const onsetDuration=sustainOnly?0:Math.min(.075,duration*.28);
  return{section,note,start:Number(start.toFixed(4)),duration,syllable,target_id:targetId,event_index:eventIndex,note_index:noteIndex,onset_viseme:sustainOnly?map.nucleus:map.onset,nucleus_viseme:map.nucleus,onset_duration:Number(onsetDuration.toFixed(4)),sustain_only:sustainOnly};
}

export function visemePlanFromFormal(formal,options={}){
  const mode=options.mode||'strict',registry=options.recognitionRegistry||null;
  const sound=soundPlanFromFormal(formal),cues=[];
  let at=.08,lastSyllable='ma';
  sound.lexical_events.forEach((event,eventIndex)=>{
    const carrier=event.formal_carrier.split('-');
    const lexicalDuration=(event.note_duration_beats||1)*.24;
    if(carrier.length!==4)throw new Error(`Expected four carrier syllables for ${event.target_id}.`);
    carrier.forEach(visemesForSyllable);
    event.family_opening.forEach((note,noteIndex)=>{
      cues.push(cue({section:'family_opening',note,start:at,duration:lexicalDuration,syllable:carrier[0],targetId:event.target_id,eventIndex,noteIndex}));
      at+=lexicalDuration+.04;
    });
    at+=.10;
    event.address_path.forEach((note,noteIndex)=>{
      const syllable=carrier[noteIndex];
      cues.push(cue({section:'address_path',note,start:at,duration:lexicalDuration,syllable,targetId:event.target_id,eventIndex,noteIndex}));
      lastSyllable=syllable;
      at+=lexicalDuration+.04;
    });
    if(mode!=='strict'){
      const recognition=recognitionForTarget(event.target_id,registry,formal.performance.lexical_events[eventIndex].base_midi,mode);
      at+=recognition.separation_before_seconds;
      recognition.absolute_midi.forEach((note,noteIndex)=>{
        const duration=recognition.duration_seconds[noteIndex];
        cues.push(cue({section:'recognition_phrase',note,start:at,duration,syllable:lastSyllable,targetId:event.target_id,eventIndex,noteIndex,sustainOnly:true}));
        at+=duration+recognition.inter_note_seconds;
      });
      at+=recognition.separation_after_seconds;
    }else at+=.08;
    event.runtime_ending.forEach((note,noteIndex)=>{
      const duration=(event.runtime?.duration_beats||.5)*.24;
      cues.push(cue({section:'runtime_ending',note,start:at,duration,syllable:lastSyllable,targetId:event.target_id,eventIndex,noteIndex,sustainOnly:true}));
      at+=duration+.04;
    });
    at+=.16;
  });
  sound.sentence_contour.forEach((note,noteIndex)=>{
    cues.push(cue({section:'sentence_contour',note,start:at,duration:.30,syllable:lastSyllable,targetId:null,eventIndex:null,noteIndex,sustainOnly:true}));
    at+=.34;
  });
  const plan={format:VISEME_VERSION,version:'1.0.0',formal_id:formal.formal_id,semantic_digest:formal.semantic_digest,semantic_identity_changed:false,pitch_drives_viseme:false,carrier_drives_viseme:true,primary_contour:sound.primary_contour,cues,duration_seconds:Number((at+.08).toFixed(4))};
  return mode==='strict'?plan:{...plan,recognition_mode:mode,recognition_semantic_content:false};
}

export function visemeFrameAt(plan,elapsedSeconds){
  const cue=plan.cues.find(item=>elapsedSeconds>=item.start&&elapsedSeconds<item.start+item.duration);
  if(!cue)return{viseme:'REST',cue:null,progress:0};
  const local=elapsedSeconds-cue.start;
  return{viseme:local<cue.onset_duration?cue.onset_viseme:cue.nucleus_viseme,cue,progress:Math.max(0,Math.min(1,local/cue.duration))};
}

export function visemeFileFromFormal(formal,eyeExpression='happy',options={}){
  if(!EYE_EXPRESSIONS.includes(eyeExpression))throw new Error(`Unknown eye-expression layer: ${eyeExpression}`);
  const plan=visemePlanFromFormal(formal,options);
  const file={format:plan.format,version:plan.version,formal_id:plan.formal_id,semantic_digest:plan.semantic_digest,semantic_identity_changed:false,duration_seconds:plan.duration_seconds,layers:{head:{id:'head/base'},eyes:{id:`eyes/${eyeExpression}`,expression:eyeExpression},mouth:{id:'mouth/sounds',cues:plan.cues.map(cue=>({at_seconds:cue.start,duration_seconds:cue.duration,midi_note:cue.note,viseme_sound:cue.syllable,poses:cue.sustain_only?[{at_seconds:0,pose:cue.nucleus_viseme}]:[{at_seconds:0,pose:cue.onset_viseme},{at_seconds:cue.onset_duration,pose:cue.nucleus_viseme}]}))}}};
  return plan.recognition_mode?{...file,recognition_mode:plan.recognition_mode,recognition_semantic_content:false}:file;
}
