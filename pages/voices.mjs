export const VOICE_PROFILES=Object.freeze({
  era_zero:Object.freeze({label:'Era Zero tones',description:'The original clear reference-tone voice.',attack:.018,sustain:.82,tail:.075,filter:9200,sectionWaveform:true,partials:[[1,1,'triangle']]}),
  ocarina:Object.freeze({label:'Ocarina',description:'A soft breath-flute voice with a strong pure fundamental.',attack:.055,sustain:.94,tail:.14,filter:4300,partials:[[1,1,'sine'],[2,.16,'sine'],[3,.045,'sine']]}),
  electric_piano:Object.freeze({label:'Electric piano',description:'A rounded keyboard voice with a bright struck overtone.',attack:.008,sustain:.48,tail:.22,filter:6800,partials:[[1,1,'sine'],[2,.32,'sine'],[3,.10,'triangle']]}),
  synth_bell:Object.freeze({label:'Synth bell',description:'A bright electronic keyboard bell.',attack:.004,sustain:.28,tail:.34,filter:9800,partials:[[1,1,'sine'],[2,.38,'sine'],[2.72,.18,'sine'],[4.1,.08,'sine']]}),
  warm_organ:Object.freeze({label:'Warm organ',description:'A sustained electric-organ voice.',attack:.035,sustain:.88,tail:.15,filter:5600,partials:[[1,1,'sine'],[2,.42,'sine'],[3,.19,'sine'],[4,.08,'sine']]})
});

export const voiceProfile=id=>VOICE_PROFILES[id]||VOICE_PROFILES.era_zero;

export function scheduleVoiceTone(context,bus,note,at,{voice='era_zero',frame=false,duration=.28,waveform=null,gainLevel=null}={}){
  const profile=voiceProfile(voice),level=gainLevel??(frame?.18:.14),tone=context.createGain(),filter=context.createBiquadFilter(),envelope=context.createGain(),oscillators=[];
  filter.type='lowpass';filter.frequency.setValueAtTime(profile.filter,at);
  tone.connect(filter).connect(envelope).connect(bus);
  envelope.gain.setValueAtTime(.0001,at);
  const attackEnd=at+Math.min(profile.attack,duration*.35),nominalEnd=at+duration,releaseEnd=nominalEnd+profile.tail,sustainLevel=Math.max(.0002,level*profile.sustain);
  envelope.gain.exponentialRampToValueAtTime(Math.max(.0002,level),attackEnd);
  envelope.gain.exponentialRampToValueAtTime(sustainLevel,Math.max(attackEnd+.002,nominalEnd));
  envelope.gain.exponentialRampToValueAtTime(.0001,releaseEnd);
  const base=440*Math.pow(2,(note-69)/12),partials=profile.sectionWaveform?[[1,1,waveform||(frame?'sine':'triangle')]]:profile.partials;
  partials.forEach(([ratio,weight,type],index)=>{const oscillator=context.createOscillator(),partialGain=context.createGain();oscillator.type=type;oscillator.frequency.setValueAtTime(base*ratio,at);if(index&&voice==='ocarina')oscillator.detune.setValueAtTime(index===1?2:-2,at);partialGain.gain.setValueAtTime(weight,at);oscillator.connect(partialGain).connect(tone);oscillator.start(at);oscillator.stop(releaseEnd+.035);oscillators.push(oscillator)});
  return{end_time:releaseEnd,stop(){const now=context.currentTime;if(typeof envelope.gain.cancelAndHoldAtTime==='function')envelope.gain.cancelAndHoldAtTime(now);else envelope.gain.cancelScheduledValues(now);envelope.gain.setTargetAtTime(.0001,now,.012);oscillators.forEach(oscillator=>{try{oscillator.stop(now+.055)}catch{}})}};
}
