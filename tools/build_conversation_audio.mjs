import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {visemePlanFromFormal} from '../pages/visemes.mjs';
import {voiceProfile} from '../pages/voices.mjs';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const script=JSON.parse(fs.readFileSync(path.join(root,'examples/two_beings_conversation.json'),'utf8'));
const index=JSON.parse(fs.readFileSync(path.join(root,'pages/data/index.json'),'utf8'));
const rate=44100,events=[];
let cursor=.35;

for(const turn of script.turns){
  const speaker=script.speakers[turn.speaker];
  for(const target of turn.targets){
    const relative=index.resolution_files[target];
    if(!relative)throw new Error(`No hosted resolution for ${target}`);
    const document=JSON.parse(fs.readFileSync(path.join(root,'pages',relative.replace(/^\.\//,'')),'utf8'));
    const formal=document.variants['assertion:1'].formal;
    const plan=visemePlanFromFormal(formal);
    for(const cue of plan.cues)events.push({...cue,start:cursor+cue.start,voice:speaker.voice,pan:speaker.pan});
    cursor+=plan.duration_seconds+.16;
  }
  cursor+=.62;
}

const totalSeconds=cursor+.4,totalFrames=Math.ceil(totalSeconds*rate),left=new Float64Array(totalFrames),right=new Float64Array(totalFrames);
const wave=(type,phase)=>type==='triangle'?2/Math.PI*Math.asin(Math.sin(phase)):type==='square'?(Math.sin(phase)>=0?1:-1):Math.sin(phase);
for(const event of events){
  const profile=voiceProfile(event.voice),partials=profile.sectionWaveform?[[1,1,event.section==='runtime_ending'?'square':event.section==='family_opening'?'sine':'triangle']]:profile.partials;
  const start=Math.floor(event.start*rate),end=Math.min(totalFrames,Math.ceil((event.start+event.duration+profile.tail)*rate)),base=440*Math.pow(2,(event.note-69)/12);
  const panLeft=Math.sqrt((1-event.pan)/2),panRight=Math.sqrt((1+event.pan)/2),level=event.section==='family_opening'?.085:event.section==='runtime_ending'?.052:event.section==='sentence_contour'?.072:.064;
  for(let frame=start;frame<end;frame++){
    const t=frame/rate-event.start,attack=Math.min(profile.attack,event.duration*.35),sustain=level*profile.sustain;
    let envelope;
    if(t<attack)envelope=level*Math.max(0,t/Math.max(attack,.001));
    else if(t<event.duration)envelope=level+(sustain-level)*((t-attack)/Math.max(event.duration-attack,.001));
    else envelope=sustain*Math.max(0,1-(t-event.duration)/profile.tail);
    let sample=0;
    partials.forEach(([ratio,weight,type])=>{sample+=weight*wave(type,2*Math.PI*base*ratio*t)});
    sample*=envelope;
    left[frame]+=sample*panLeft;right[frame]+=sample*panRight;
  }
}

let peak=0;
for(let i=0;i<totalFrames;i++){left[i]=Math.tanh(left[i]*1.8);right[i]=Math.tanh(right[i]*1.8);peak=Math.max(peak,Math.abs(left[i]),Math.abs(right[i]))}
const scale=peak>.92?.92/peak:1,dataBytes=totalFrames*4,buffer=Buffer.alloc(44+dataBytes);
buffer.write('RIFF',0);buffer.writeUInt32LE(36+dataBytes,4);buffer.write('WAVE',8);buffer.write('fmt ',12);buffer.writeUInt32LE(16,16);buffer.writeUInt16LE(1,20);buffer.writeUInt16LE(2,22);buffer.writeUInt32LE(rate,24);buffer.writeUInt32LE(rate*4,28);buffer.writeUInt16LE(4,32);buffer.writeUInt16LE(16,34);buffer.write('data',36);buffer.writeUInt32LE(dataBytes,40);
for(let i=0;i<totalFrames;i++){buffer.writeInt16LE(Math.round(Math.max(-1,Math.min(1,left[i]*scale))*32767),44+i*4);buffer.writeInt16LE(Math.round(Math.max(-1,Math.min(1,right[i]*scale))*32767),46+i*4)}
const media=path.join(root,'pages/media');fs.mkdirSync(media,{recursive:true});
const wav=path.join(media,'two-beings-file-migration.wav'),mp3=path.join(media,'two-beings-file-migration.mp3');fs.writeFileSync(wav,buffer);
let encoded=false;
for(const [command,args] of [
  ['ffmpeg',['-y','-loglevel','error','-i',wav,'-codec:a','libmp3lame','-b:a','192k',mp3]],
  ['/Applications/Storyboarder.app/Contents/Resources/app.asar.unpacked/node_modules/@ffmpeg-installer/darwin-x64/ffmpeg',['-y','-loglevel','error','-i',wav,'-codec:a','libmp3lame','-b:a','192k',mp3]],
  ['/Applications/Promethean/Activsoftware Inspire/ffmpeg',['-y','-loglevel','error','-i',wav,'-codec:a','libmp3lame','-b:a','192k',mp3]],
  ['afconvert',['-f','MPG3','-d','.mp3','-b','192000',wav,mp3]]
]){
  const result=spawnSync(command,args,{stdio:'inherit'});if(result.status===0){encoded=true;break}
}
if(!encoded)throw new Error(`WAV created at ${wav}, but no MP3 encoder succeeded.`);
fs.unlinkSync(wav);
console.log(`Built ${path.relative(root,mp3)} · ${script.turns.length} turns · ${events.length} tone events · ${totalSeconds.toFixed(2)} seconds`);
