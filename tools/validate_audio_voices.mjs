import {VOICE_PROFILES,scheduleVoiceTone} from '../pages/voices.mjs';

class FakeParam{
  constructor(){this.value=0;this.events=[]}
  setValueAtTime(value,time){this.value=value;this.events.push(['set',value,time])}
  exponentialRampToValueAtTime(value,time){this.value=value;this.events.push(['exponential',value,time])}
  setTargetAtTime(value,time,constant){this.value=value;this.events.push(['target',value,time,constant])}
  cancelScheduledValues(time){this.events.push(['cancel',time])}
  cancelAndHoldAtTime(time){this.events.push(['hold',time])}
}
class FakeNode{connect(next){this.next=next;return next}}
class FakeOscillator extends FakeNode{constructor(){super();this.type='sine';this.frequency=new FakeParam();this.detune=new FakeParam();this.started=[];this.stopped=[]}start(time){this.started.push(time)}stop(time){this.stopped.push(time)}}
class FakeGain extends FakeNode{constructor(){super();this.gain=new FakeParam()}}
class FakeFilter extends FakeNode{constructor(){super();this.frequency=new FakeParam();this.type='lowpass'}}
class FakeContext{
  constructor(){this.currentTime=.2;this.oscillators=[]}
  createGain(){return new FakeGain()}
  createBiquadFilter(){return new FakeFilter()}
  createOscillator(){const oscillator=new FakeOscillator();this.oscillators.push(oscillator);return oscillator}
}

const failures=[];
const check=(name,condition)=>{if(!condition)failures.push(name)};
for(const [voice,profile] of Object.entries(VOICE_PROFILES)){
  const context=new FakeContext(),at=.5,duration=.24,note=69,bus=new FakeGain(),handle=scheduleVoiceTone(context,bus,note,at,{voice,duration});
  check(`${voice}: positive bounded release tail`,profile.tail>=.075&&profile.tail<=.35);
  check(`${voice}: handle ends after nominal cue`,Math.abs(handle.end_time-(at+duration+profile.tail))<1e-9);
  check(`${voice}: every partial survives the release`,context.oscillators.length===profile.partials.length&&context.oscillators.every(oscillator=>oscillator.stopped[0]>handle.end_time));
  check(`${voice}: canonical fundamental unchanged`,Math.abs(context.oscillators[0].frequency.events[0][1]-440)<1e-9);
  handle.stop();
  check(`${voice}: manual stop is softened`,context.oscillators.every(oscillator=>oscillator.stopped.at(-1)>context.currentTime));
}

console.log(`Audio voice envelopes: ${failures.length?'FAIL':'PASS'} · ${Object.keys(VOICE_PROFILES).length} voices · release tails and softened stops checked`);
if(failures.length){failures.forEach(failure=>console.error(`FAIL: ${failure}`));process.exit(1)}
