import {compactChordPerformance} from './compact_chords.mjs?v=joined-roots-1';
import {songMidi} from './song_lines.mjs';
import {notesFromMidi} from './performance_codec.mjs';

const key='era-zero-song-lines-v1';
export function mountSongEditor({document,storage,player,download,getAtoms}) {
  const list=document.getElementById('songLines'), status=document.getElementById('songStatus');
  const play=document.getElementById('playSong'), save=document.getElementById('exportSong'),stop=document.getElementById('stopSong');
  const arrangement=document.getElementById('songArrangement');
  const preview=document.getElementById('previewSongRoot'),timing=document.getElementById('songTiming');
  let prepared=null,original=null;
  const originalMelody=()=>original??=songMidi(lines);
  function performance(){
    if(!prepared){
      const melody=originalMelody();
      prepared={melody,...compactChordPerformance(melody,getAtoms(),{preview:true})};
    }
    return prepared;
  }
  const inChords=()=>arrangement.value==='chords';
  const arranged=()=>inChords()?performance().midi:originalMelody();
  const showSeconds=n=>Number(n.toFixed(2))+' s';
  function showArrangement(){
    if(!preview||!timing)return;
    preview.disabled=true;
    preview.textContent=inChords()?'Hear first root in chords':'Hear first root as a melody';
    timing.textContent='';
    if(!lines.length||!getAtoms()?.length)return;
    try{
      const result=performance();
      if(!result.firstRoot){
        timing.textContent='This song contains no recognizable dictionary root. Both arrangements use the same notes.';
        return;
      }
      preview.disabled=false;
      timing.textContent='Melody '+showSeconds(result.melodySeconds)+' · Compact chords '+showSeconds(result.chordSeconds)+
        '. The first chord starts at '+showSeconds(result.firstRoot.atSeconds)+'.';
    }catch(error){timing.textContent=error.message;}
  }
  arrangement.addEventListener('change',()=>{player.stop();showArrangement();});
  preview?.addEventListener('click',async()=>{
    try{
      const first=performance().firstRoot;
      if(first)await player.play(inChords()?first.chords:first.melody,{chords:inChords()});
    }catch(error){status.textContent=error.message;}
  });
  let lines=[],canSave=true;
  try {
    const stored=storage.getItem(key);
    if (stored) lines=JSON.parse(stored).map(({text,bytes,label})=>{
      if (typeof text!=='string'||typeof label!=='string'||typeof bytes!=='string') throw Error();
      const midi=Uint8Array.from(atob(bytes),c=>c.charCodeAt(0));
      notesFromMidi(midi);return {text,midi,label};
    });
  } catch { canSave=false;status.textContent='The saved song could not be opened. New lines are available in this tab.'; }
  function render() {
    prepared=null;original=null;
    list.replaceChildren();
    play.disabled=save.disabled=stop.disabled=!lines.length;
    for (const [index,line] of lines.entries()) {
      const row=document.createElement('li'),label=document.createElement('span'),remove=document.createElement('button');
      label.textContent=line.text+' · '+line.label;remove.type='button';remove.textContent='Remove';
      remove.setAttribute('aria-label','Remove line '+(index+1));
      remove.addEventListener('click',()=>{player.stop();lines.splice(index,1);changed('Line removed.');});
      row.append(label,remove);list.append(row);
    }
    showArrangement();
  }
  function changed(message) {
    render();
    try {
      if (!canSave) throw Error();
      storage.setItem(key,JSON.stringify(lines.map(({text,label,midi})=>({text,label,bytes:btoa(Array.from(midi,b=>String.fromCharCode(b)).join(''))}))));
      status.textContent=message+' Saved in this browser.';
    } catch { status.textContent=message+' Available in this tab. Download the song MIDI to keep a copy.'; }
  }
  play.addEventListener('click',async()=>{try {await player.play(arranged(),{chords:arrangement.value==='chords'});} catch(e){status.textContent=e.message;}});
  stop.addEventListener('click',()=>player.stop());
  save.addEventListener('click',()=>{try{download(new Blob([arranged()],{type:'audio/midi'}),'era-zero-song-'+arrangement.value+'.mid');}catch(error){status.textContent=error.message;}});
  render();
  function addLine(text,midi,label){
    if (!text.trim()||!notesFromMidi(midi).notes.length) throw Error('This line has no music.');
    player.stop();lines.push({text,label,midi:new Uint8Array(midi)});changed('Line '+lines.length+' added.');
    return lines.length;
  }
  addLine.refreshArrangement=showArrangement;
  return addLine;
}
