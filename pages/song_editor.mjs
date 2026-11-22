import {compactChordPerformance} from './compact_chords.mjs?v=state-adjectives-1';
import {readSongLine} from './song_readback.mjs?v=information-operations-1';
import {compactChordMidi} from './compact_chords.mjs?v=state-adjectives-1';
import {songMidi} from './song_lines.mjs?v=information-operations-1';
import {notesFromMidi} from './performance_codec.mjs';

import {isSongStorageKey,readSongLines,newSongLine,saveSongLine,removeSongLine} from './song_storage.mjs?v=field-repairs-1';
export function mountSongEditor({document,storage,player,download,getAtoms,getRecords,getAdjectives}) {
  const list=document.getElementById('songLines'), status=document.getElementById('songStatus');
  const play=document.getElementById('playSong'), save=document.getElementById('exportSong'),stop=document.getElementById('stopSong');
  const arrangement=document.getElementById('songArrangement');
  const preview=document.getElementById('previewSongRoot'),timing=document.getElementById('songTiming');
  const next=document.getElementById('nextSongRoot');
  let prepared=null,original=null,rootIndex=0;
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
    if(next)next.disabled=true;
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
      if(next)next.disabled=result.rootCount<2;
      if(rootIndex>0)preview.textContent='Hear root '+(rootIndex+1)+(inChords()?' in chords':' as a melody');
      timing.textContent='Melody '+showSeconds(result.melodySeconds)+' · Compact chords '+showSeconds(result.chordSeconds)+
        '. The first chord starts at '+showSeconds(result.firstRoot.atSeconds)+'. Root '+(rootIndex+1)+' of '+result.rootCount+' · '+result.previews[rootIndex].id+'.';
    }catch(error){timing.textContent=error.message;}
  }
  arrangement.addEventListener('change',()=>{player.stop();showArrangement();});
  async function hearRoot(){
    try{
      const first=performance().previews[rootIndex];
      if(first)await player.play(inChords()?first.chords:first.melody,{chords:inChords()});
    }catch(error){status.textContent=error.message;}
  }
  preview?.addEventListener('click',hearRoot);
  next?.addEventListener('click',()=>{rootIndex=(rootIndex+1)%performance().rootCount;showArrangement();return hearRoot();});
  let lines=[],canSave=true;
  function reload(){
    if(!canSave)return;
    try{
      const stored=readSongLines(storage);
      for(const line of stored)notesFromMidi(line.midi);
      lines=stored;
    }catch{
      canSave=false;status.textContent='The saved song could not be opened. New lines are available in this tab.';
    }
  }
  reload();
  document.defaultView?.addEventListener('storage',event=>{
    if(!canSave||!isSongStorageKey(event.key))return;
    reload();render();
  });
  function render() {
    prepared=null;original=null;rootIndex=0;
    list.replaceChildren();
    play.disabled=save.disabled=stop.disabled=!lines.length;
    for (const [index,line] of lines.entries()) {
      const row=document.createElement('li'),label=document.createElement('span'),remove=document.createElement('button');
      label.textContent=line.text+' · '+line.label;remove.type='button';remove.textContent='Remove';
      remove.setAttribute('aria-label','Remove line '+(index+1));
      remove.addEventListener('click',()=>{player.stop();lines=lines.filter(item=>item.id!==line.id);changed('Line removed.',()=>removeSongLine(storage,line.id));});
      row.append(label,remove);
      if(getRecords){
        const check=document.createElement('button'),result=document.createElement('div');
        check.type='button';check.textContent='Check musical meaning';check.setAttribute('aria-label','Check musical meaning of line '+(index+1));
        result.setAttribute('role','status');
        check.addEventListener('click',async()=>{
          check.disabled=true;result.textContent='Reading the notes…';
          try{
            const chords=inChords(),atoms=getAtoms(),bytes=chords?compactChordMidi(line.midi,atoms):line.midi;
            const heard=await readSongLine(bytes,atoms,await getRecords(),chords,await getAdjectives?.());
            const details=document.createElement('details'),summary=document.createElement('summary'),decoded=document.createElement('pre');
            summary.textContent='Recovered roles and scope';decoded.textContent=JSON.stringify(heard.meaning,null,2);
            details.append(summary,decoded);result.textContent='Meaning recovered from the '+(chords?'chords':'melody')+'. '+heard.summary;result.append(details);
          }catch(error){result.textContent='This line plays. The listener could not recover a unique reading. '+error.message;}
          finally{check.disabled=false;}
        });
        row.append(check,result);
      }
      list.append(row);
    }
    showArrangement();
  }
  function changed(message,persist) {
    try {
      if(!canSave)throw Error();
      persist();reload();
      if(!canSave)throw Error();
      status.textContent=message+' Saved in this browser.';
    } catch {
      canSave=false;
      status.textContent=message+' Available in this tab. Download the song MIDI to keep a copy.';
    }
    render();
  }
  play.addEventListener('click',async()=>{try {await player.play(arranged(),{chords:arrangement.value==='chords'});} catch(e){status.textContent=e.message;}});
  stop.addEventListener('click',()=>player.stop());
  save.addEventListener('click',()=>{try{download(new Blob([arranged()],{type:'audio/midi'}),'era-zero-song-'+arrangement.value+'.mid');}catch(error){status.textContent=error.message;}});
  render();
  function addLine(text,midi,label){
    if (!text.trim()||!notesFromMidi(midi).notes.length) throw Error('This line has no music.');
    player.stop();reload();
    const line=newSongLine(text,label,midi,lines);
    lines.push(line);changed('Line '+lines.length+' added.',()=>saveSongLine(storage,line));
    return lines.findIndex(item=>item.id===line.id)+1;
  }
  addLine.refreshArrangement=showArrangement;
  return addLine;
}
