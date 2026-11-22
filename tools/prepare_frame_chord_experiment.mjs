// Build a versioned research alphabet from the public grammar, never from a sentence.
import fs from 'node:fs';
import {strictGrammarFrameInventory} from '../pages/strict_music_decoder.mjs';
const modules=[['information_passage_frames','informationPassageFrames'],['desired_availability_frames','desiredAvailabilityFrames'],
 ['custody_opportunity_frames','custodyOpportunityFrames'],['desired_ownership_frames','desiredOwnershipFrames'],
 ['ownership_frames','ownershipFrames'],['desired_drinking_frames','desiredDrinkingFrames'],['drinking_frames','drinkingFrames'],
 ['pain_preference_frames','painPreferenceFrames'],['pain_comparison_frames','painComparisonFrames'],
 ['pain_stimulus_frames','painStimulusFrames'],['pain_frames','painFrames'],['curiosity_frames','curiosityFrames'],
 ['contextual_inquiry_frames','contextualInquiryFrames'],['content_selection','contentSelectionFrames'],
 ['contextual_content_frames','contextualContentMusicFrames'],['acquisition_music_frames','acquisitionMusicFrames'],
 ['question_music_frames','questionContentMusicFrames'],['quantified_music','quantifiedMusicFrames']];
const frames=strictGrammarFrameInventory();
for(const [file,name] of modules){const module=await import('../pages/'+file+'.mjs');frames.push(...module[name]({includeUnderstanding:true,includeRoute:true}));}
const unique=new Map();for(const f of frames){
 if(unique.has(f.marker)&&JSON.stringify(unique.get(f.marker))!==JSON.stringify(f.path))throw Error('Conflicting frame: '+f.marker);
 unique.set(f.marker,f.path);
}
const entries=[...unique.entries()].sort(([a],[b])=>a<b?-1:a>b?1:0).map(([marker,path],code)=>({code,marker,path}));
if(entries.length>24**2)throw Error('Alphabet exceeds two chord digits.');
fs.mkdirSync(new URL('../experiments/',import.meta.url),{recursive:true});
const out=new URL('../experiments/frame_chords_v1.json',import.meta.url);
if(fs.existsSync(out))throw Error('The experimental version is frozen; make a new version to change it.');
fs.writeFileSync(out,JSON.stringify({profile:'DBA-FRAME-CHORD-EXPERIMENT-1',status:'research only; not a released language change',entries},null,2)+'\n');
console.log(entries.length+' public grammar frames; 2 consonant four-voice chords per frame.');
