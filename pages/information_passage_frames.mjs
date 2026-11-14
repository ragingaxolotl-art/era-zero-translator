// Draft constructions for a speaker group, a present-perfect report and an erasure outcome.
const codes = {speaker_group: 8, present_perfect: 9, erase_stored_object: 10, dictionary_clause: 11, indefinite_singular: 12};
export function informationPassageFrames() {
  return Object.entries(codes).flatMap(([name, code]) => ['open', 'close'].map(side => {
    const sign = side === 'open' ? -1 : 1;
    return {marker:name+'_'+side, path:[0, sign*23, code, sign*23, 0]};
  }));
}
export function informationFrame(marker, anchor) {
  const frame = informationPassageFrames().find(entry => entry.marker === marker);
  if (!frame) throw Error('Unknown information-passage frame.');
  return {kind:'grammar_marker', marker, family_opening_absolute_midi:[],
    address_absolute_midi:frame.path.map(offset => anchor+offset), note_duration_beats:.25, boundary_after_beats:.5};
}
