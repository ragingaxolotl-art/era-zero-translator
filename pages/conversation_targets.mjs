import {analyzeEnglish} from './english.mjs?v=physical-closing-1';

// A curated performance scores only the exact line and speaker in its source.
export function conversationTargets(english, authority, {turn, speaker} = {}) {
 if (turn?.motif && turn.english === english && turn.speaker === speaker) {
  const {target_id, term, limitation} = turn.motif;
  if (!authority.resolution_files[target_id] || !term || !limitation) {
   throw new Error('A story motif is missing its dictionary entry or performance note.');
  }
  return {targets: [{target_id, term}], warnings: [limitation], curated: true};
 }
 const targets = [], warnings = [];
 for (const sentence of english.split(/(?<=[.!?])\s+/).filter(Boolean)) {
  for (const item of analyzeEnglish(sentence, authority).term_coverage) {
   if (item.status === 'canonical') {
    const match = item.matches.find(candidate =>
     ['atom', 'compound'].includes(candidate.route) && authority.resolution_files[candidate.target_id]
    );
    if (match) targets.push({target_id: match.target_id, term: item.term, sense_key: match.sense_key});
   } else if (['unresolved_semantic', 'documented_gap', 'structural'].includes(item.status)) {
    warnings.push(item.term + ' · ' + item.status.replaceAll('_', ' '));
   }
  }
 }
 return {targets, warnings, curated: false};
}
