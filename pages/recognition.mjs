export const RECOGNITION_FORMAT='EZRP-1';
export const RECOGNITION_MODES=Object.freeze(['strict','recognition','learning']);

function recordsById(registry){
  if(!registry||registry.metadata?.format!==RECOGNITION_FORMAT)throw new Error('Recognition registry is unavailable or unsupported.');
  return new Map(registry.records.map(record=>[record.target_id,record]));
}

export function recognitionForTarget(targetId,registry,baseMidi=60,mode='recognition'){
  if(mode==='strict')return null;
  if(!RECOGNITION_MODES.includes(mode))throw new Error(`Unknown recognition mode: ${mode}`);
  const record=recordsById(registry).get(targetId);
  if(!record)throw new Error(`No recognition phrase for ${targetId}.`);
  const factor=mode==='learning'?1.35:1;
  const secondsPerBeat=registry.timing.seconds_per_beat*factor;
  return{
    ...record,
    mode,
    absolute_midi:record.relative_semitones.map(offset=>baseMidi+offset),
    duration_seconds:record.duration_beats.map(beats=>Number((beats*secondsPerBeat).toFixed(4))),
    inter_note_seconds:registry.timing.inter_note_seconds*factor,
    separation_before_seconds:registry.timing.separation_before_seconds*factor,
    separation_after_seconds:registry.timing.separation_after_seconds*factor
  };
}

export function verifyRecognition(targetId,observed,registry){
  if(observed===null||observed===undefined)return{status:'valid_strict_absence',semantic_content:false};
  const expected=recordsById(registry).get(targetId);
  if(!expected)return{status:'unknown_target',semantic_content:false};
  const fields=['note_count','degree_indices','relative_semitones','duration_beats','checksum'];
  const valid=fields.every(field=>JSON.stringify(observed[field])===JSON.stringify(expected[field]));
  return{status:valid?'valid_checksum':'checksum_mismatch',target_id:targetId,semantic_content:false,expected_checksum:expected.checksum,observed_checksum:observed.checksum||null};
}
