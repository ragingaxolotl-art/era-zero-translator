import {decodeSupportedMeaningWithDrafts} from './semantic_music_dispatch.mjs?v=physical-closing-1';

// A composed interpretation and an independently readable score are separate
// facts. This check receives no English, expected predicate or original IR.
export async function sentenceReadiness(midi,atoms,{records=[],adjectives}={}){
  try{
    const recovered=await decodeSupportedMeaningWithDrafts(midi,atoms,records,{allowDraft:true,adjectives});
    return {interpretation:'complete',score_inverse:'supported',evidence:'MIDI',
      summary:'Whole sentence ready',
      detail:'Meaning recovered from the score without the original English. Recorded-audio recovery is a separate check.',
      recovered};
  }catch{
    return {interpretation:'complete',score_inverse:'unavailable',evidence:null,
      summary:'Sentence composed · score decoding unverified',
      detail:'You can play this interpretation, but the independent decoder cannot yet recover its complete meaning. This is not a verified round trip.'};
  }
}
