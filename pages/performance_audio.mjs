import{visemePlanFromFormal}from'./visemes.mjs';
import{verifyPerformanceNotes}from'./performance_codec.mjs';

export const AUDIO_CHECK_FORMAT='EZREC-AUDIO-1';
export const REFERENCE_SAMPLE_RATE=22050;

export function pcmFromPerformance(formal,registry,mode='recognition',sampleRate=REFERENCE_SAMPLE_RATE){
  if(!Number.isInteger(sampleRate)||sampleRate<16000||sampleRate>96000)throw new Error('Unsupported audio sample rate.');
  const plan=visemePlanFromFormal(formal,{mode,recognitionRegistry:registry});
  const samples=new Float32Array(Math.ceil((plan.duration_seconds+.05)*sampleRate));
  for(const cue of plan.cues){
    const start=Math.round(cue.start*sampleRate),length=Math.round(cue.duration*sampleRate),frequency=440*2**((cue.note-69)/12),fade=Math.min(Math.round(.012*sampleRate),Math.floor(length/5));
    for(let i=0;i<length;i++){
      const envelope=Math.min(1,(i+1)/fade,(length-i)/fade);
      samples[start+i]+=.42*envelope*Math.sin(2*Math.PI*frequency*i/sampleRate);
    }
  }
  return{format:AUDIO_CHECK_FORMAT,sample_rate:sampleRate,samples,formal_id:formal.formal_id,mode,semantic_content:false};
}

export function wavFromPerformance(formal,registry,mode='recognition'){
  const pcm=pcmFromPerformance(formal,registry,mode),bytes=new Uint8Array(44+pcm.samples.length*2),view=new DataView(bytes.buffer);
  const word=(at,value)=>view.setUint16(at,value,true),dword=(at,value)=>view.setUint32(at,value,true),tag=(at,value)=>{for(let i=0;i<value.length;i++)bytes[at+i]=value.charCodeAt(i)};
  tag(0,'RIFF');dword(4,bytes.length-8);tag(8,'WAVE');tag(12,'fmt ');dword(16,16);word(20,1);word(22,1);dword(24,pcm.sample_rate);dword(28,pcm.sample_rate*2);word(32,2);word(34,16);tag(36,'data');dword(40,pcm.samples.length*2);
  for(let i=0;i<pcm.samples.length;i++)view.setInt16(44+i*2,Math.round(Math.max(-1,Math.min(1,pcm.samples[i]))*32767),true);
  return bytes;
}

function pitchOfSegment(samples,sampleRate,start,end){
  const length=Math.min(4096,end-start),from=Math.floor((start+end-length)/2),minimum=Math.max(2,Math.floor(sampleRate/2200)),maximum=Math.min(Math.floor(sampleRate/110),Math.floor(length/3));
  if(length<1024||maximum<=minimum)return null;
  const correlations=[];
  for(let lag=minimum;lag<=maximum;lag++){
    let cross=0,left=0,right=0;
    for(let i=0;i<length-lag;i++){const a=samples[from+i],b=samples[from+i+lag];cross+=a*b;left+=a*a;right+=b*b}
    correlations.push({lag,score:cross/Math.sqrt(left*right||1)});
  }
  const best=Math.max(...correlations.map(x=>x.score));
  if(best<.79)return null;
  const candidate=correlations.find(x=>x.score>=Math.max(.79,best-.003));
  const hz=sampleRate/candidate.lag,midi=Math.round(69+12*Math.log2(hz/440));
  return midi>=0&&midi<=127?{midi,confidence:Number(candidate.score.toFixed(3))}:null;
}

export function notesFromPcm(input,sampleRate){
  if(!input||!Number.isInteger(sampleRate)||sampleRate<8000||sampleRate>192000)throw new Error('Invalid decoded audio.');
  const samples=input instanceof Float32Array?input:Float32Array.from(input);
  if(samples.length>sampleRate*120)throw new Error('Audio check is limited to two minutes.');
  const block=Math.max(64,Math.round(sampleRate*.006)),energy=[];
  for(let at=0;at<samples.length;at+=block){let squared=0;for(let i=at;i<Math.min(samples.length,at+block);i++)squared+=samples[i]**2;energy.push(Math.sqrt(squared/Math.min(block,samples.length-at)))}
  const peak=Math.max(0,...energy);
  if(peak<.008)throw new Error('Audio is silent or too quiet.');
  const threshold=Math.max(.008,peak*.16),regions=[];let begin=null;
  energy.forEach((rms,index)=>{const active=rms>=threshold;if(active&&begin===null)begin=index;if(!active&&begin!==null){if((index-begin)*block/sampleRate>=.045)regions.push([begin*block,index*block]);begin=null}});
  if(begin!==null)regions.push([begin*block,samples.length]);
  const notes=[];
  for(const[start,end]of regions){const pitch=pitchOfSegment(samples,sampleRate,start,end);if(!pitch)throw new Error('A tone could not be identified reliably; use clean, single-voice audio.');notes.push({...pitch,start_seconds:Number((start/sampleRate).toFixed(3)),duration_seconds:Number(((end-start)/sampleRate).toFixed(3))})}
  if(!notes.length)throw new Error('No distinct notes detected.');
  return notes;
}

export function verifyPerformancePcm(formal,registry,samples,sampleRate){
  const notes=notesFromPcm(samples,sampleRate),result=verifyPerformanceNotes(formal,registry,notes);
  return{...result,audio_format:AUDIO_CHECK_FORMAT,observed_notes:notes};
}
