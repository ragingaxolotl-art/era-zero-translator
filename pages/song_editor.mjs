import {compactChordMidi} from './compact_chords.mjs';
import {songMidi} from './song_lines.mjs';
import {notesFromMidi} from './performance_codec.mjs';

const key='era-zero-song-lines-v1';
export function mountSongEditor({document,storage,player,download,getAtoms}) {
  const list=document.getElementById('songLines'), status=document.getElementById('songStatus');
  const play=document.getElementById('playSong'), save=document.getElementById('exportSong'),stop=document.getElementById('stopSong');
  const arrangement=document.getElementById('songArrangement');
  const arranged=()=>{
    const melody=songMidi(lines);
    return arrangement.value==='chords'?compactChordMidi(melody,getAtoms()):melody;
  };
  arrangement.addEventListener('change',()=>player.stop());
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
    list.replaceChildren();
    play.disabled=save.disabled=stop.disabled=!lines.length;
    for (const [index,line] of lines.entries()) {
      const row=document.createElement('li'),label=document.createElement('span'),remove=document.createElement('button');
      label.textContent=line.text+' · '+line.label;remove.type='button';remove.textContent='Remove';
      remove.setAttribute('aria-label','Remove line '+(index+1));
      remove.addEventListener('click',()=>{player.stop();lines.splice(index,1);changed('Line removed.');});
      row.append(label,remove);list.append(row);
    }
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
  return (text,midi,label)=>{
    if (!text.trim()||!notesFromMidi(midi).notes.length) throw Error('This line has no music.');
    player.stop();lines.push({text,label,midi:new Uint8Array(midi)});changed('Line '+lines.length+' added.');
    return lines.length;
  };
}
