export const VOICE_PROFILES=Object.freeze({
  era_zero:Object.freeze({label:'Era Zero tones',description:'The original clear reference-tone voice.',attack:.018,release:.065,filter:9200,sectionWaveform:true,partials:[[1,1,'triangle']]}),
  ocarina:Object.freeze({label:'Ocarina',description:'A soft breath-flute voice with a strong pure fundamental.',attack:.055,release:.12,filter:4300,partials:[[1,1,'sine'],[2,.16,'sine'],[3,.045,'sine']]}),
  electric_piano:Object.freeze({label:'Electric piano',description:'A rounded keyboard voice with a bright struck overtone.',attack:.008,release:.18,filter:6800,partials:[[1,1,'sine'],[2,.32,'sine'],[3,.10,'triangle']]}),
  synth_bell:Object.freeze({label:'Synth bell',description:'A bright electronic keyboard bell.',attack:.004,release:.24,filter:9800,partials:[[1,1,'sine'],[2,.38,'sine'],[2.72,.18,'sine'],[4.1,.08,'sine']]}),
  warm_organ:Object.freeze({label:'Warm organ',description:'A sustained electric-organ voice.',attack:.035,release:.10,filter:5600,partials:[[1,1,'sine'],[2,.42,'sine'],[3,.19,'sine'],[4,.08,'sine']]})
});

export const voiceProfile=id=>VOICE_PROFILES[id]||VOICE_PROFILES.era_zero;

export function scheduleVoiceTone(context,bus,note,at,{voice='era_zero',frame=false,duration=.28,waveform=null,gainLevel=null}={}){
  const profile=voiceProfile(voice),level=gainLevel??(frame?.18:.14),tone=context.createGain(),filter=context.createBiquadFilter(),envelope=context.createGain(),oscillators=[];
  filter.type='lowpass';filter.frequency.setValueAtTime(profile.filter,at);
  tone.connect(filter).connect(envelope).connect(bus);
  envelope.gain.setValueAtTime(.0001,at);
  envelope.gain.exponentialRampToValueAtTime(Math.max(.0002,level),at+Math.min(profile.attack,duration*.35));
  envelope.gain.setValueAtTime(Math.max(.0002,level*.88),Math.max(at+profile.attack,at+duration-profile.release));
  envelope.gain.exponentialRampToValueAtTime(.0001,at+duration);
  const base=440*Math.pow(2,(note-69)/12),partials=profile.sectionWaveform?[[1,1,waveform||(frame?'sine':'triangle')]]:profile.partials;
  partials.forEach(([ratio,weight,type],index)=>{const oscillator=context.createOscillator(),partialGain=context.createGain();oscillator.type=type;oscillator.frequency.setValueAtTime(base*ratio,at);if(index&&voice==='ocarina')oscillator.detune.setValueAtTime(index===1?2:-2,at);partialGain.gain.setValueAtTime(weight,at);oscillator.connect(partialGain).connect(tone);oscillator.start(at);oscillator.stop(at+duration+.04);oscillators.push(oscillator)});
  return{stop(){oscillators.forEach(oscillator=>{try{oscillator.stop()}catch{}})}};
}
