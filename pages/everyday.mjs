// Reader-facing paraphrases are discovery aids. Resolution uses the original sense and target IDs.
const routeNames = {
  atom:'One basic meaning (atom)', compound:'Combined meanings (compound)',
  semantic_ir:'A relationship or action in the sentence (Semantic IR)',
  grammar:'How the sentence fits together (grammar)', gap:'A meaning still missing from the dictionary',
  label:'A name played as sounds'
};
const senses = {
  contextual_thermodynamic_temperature_hot:'The object’s temperature is above the local hot standard',
  contextual_thermodynamic_temperature_cold:'The object’s temperature is below the local cold standard',
  contextual_mass_heavy:'The object’s mass is above the local heavy standard',
  contextual_mass_light:'The object’s mass is below the local light standard',
  contextual_luminance_bright:'The surface’s emitted or reflected light is above the local bright standard',
  contextual_luminance_dim:'The surface’s emitted or reflected light is below the local dim standard',
  contextual_surface_texture_rough:'The surface is more irregular than the local rough standard',
  contextual_surface_texture_smooth:'The surface is less irregular than the local smooth standard',
  contextual_physical_width_wide:'The object’s width is above the local wide standard',
  contextual_physical_width_narrow:'The object’s width is below the local narrow standard',
  coordination_all:'Both parts are true or included', copular_predication:'Says what something is or what it is like',
  generic_transition:'Something comes to be a different way', generate_composite_artifact:'Make one thing from several parts',
  semantic_role:'What brings about the event', generic_state_transition:'Something changes from one state to another',
  persistence_of_occurrence:'The same activity keeps going', boundary_traversal:'Go from one side of a boundary to the other',
  trajectory_tracking:'Move along the path of something else', nutritive_material:'Something that can nourish a living being',
  lose_access_to_representation:'Can no longer bring something to mind', social_friendship:'Someone with whom you share a friendship',
  reference_time_after_now:'Later than the time of speaking', abstract_transition:'Change from one condition to another',
  perfect_auxiliary:'An earlier action matters at the time being described', possession:'Having something as your own',
  affective_social_center:'A place or group you feel you belong to', physical_dwelling:'The place someone lives',
  conditional:'One part depends on whether another part holds', truth_entailing_knowledge:'Knowing that something really is true',
  plural_quantity:'A large number, without giving an exact count', cause_target_displacement:'Make something else change position',
  emotional_effect:'Stir a feeling in someone', negation:'Says the enclosed claim is untrue',
  quantity_one:'Exactly one', coordination_any:'At least one of the alternatives', reference_time_before_now:'Earlier than the time of speaking',
  temporary_suspension:'Stop for a while with a possible continuation', manifest_latent_representation:'Bring something back to mind',
  function_result:'Give back a value from a calculation', movement_to_prior_position:'Go back to a place occupied earlier',
  locomotion:'Run using your own body', machine_operation:'A machine is operating', program_execution:'A program is carrying out its instructions',
  acceptable_risk:'The danger is low enough for this situation', cessation:'An activity comes to a stop',
  generic_cognition:'Use your mind to consider something', caused_target_movement:'Cause something else to travel',
  truth_value:'A claim agrees with how things are', deferred_action:'Wait before acting', chemical_substance:'The substance water',
  desire:'Want something',positive_affect:'Feel happy',negative_affect:'Feel sad',anger_affect:'Feel angry',fear_affect:'Feel afraid',
  affection_or_preference:'Feel affection or liking',recreational_activity:'Do something for play',ingestion:'Take food into the body',
  nutritive_referent:'Food for a living being',game_object_referent:'Something used in play',game_status_measure:'An energy level in the game',
  cleanliness_deficit:'Needs cleaning',satisfied_game_status:'A game meter is full',labeled_person_occupation:'A person who writes programs',
  game_measure_level:'A game value is low',permissive_or_cohortative_clause:'Allow an action or suggest doing it together',
  instrumental_use_relation:'Use something as a tool for an action',requested_information_deletion:'Ask to remove something from storage',
  active_information_deletion:'Something is being removed from storage',completed_information_deletion:'Something has been removed from storage'
};
export const routeName = key => routeNames[key] || String(key||'').replaceAll('_',' ');
export function everydayMeaning(authority, option){
  if(!option)return '';
  const sense=typeof option==='string'?{target_id:option}:option;
  if(sense.target_id==='erase_stored_object')return senses.requested_information_deletion;
  if(sense.sense_key==='temporal_order')return sense.lemma==='after'?'This happens later than the other event':'This happens earlier than the other event';
  return authority?.everyday_choices?.[sense.target_id] || senses[sense.sense_key] || sense.definition || sense.lemma || '';
}
