import {decodeContextualGroupMidi} from './contextual_group_decoder.mjs?v=ordinary-comparatives-1';
import {decodePropertyComparisonGroupMidi} from './property_comparison_group_decoder.mjs?v=ordinary-comparatives-1';
// Shared strict semantic inverses; no expected sentence or predicate hint.
import {decodeCareMidi} from './care_decoder.mjs?v=ordinary-comparatives-1';
import {decodeLoveMidi} from './love_decoder.mjs?v=ordinary-comparatives-1';
import {decodeSwimmingMidi} from './swimming_decoder.mjs?v=ordinary-comparatives-1';
import {decodePhysicalEntryMidi} from './physical_entry_decoder.mjs?v=ordinary-comparatives-1';
import {decodeRunningMidi} from './running_decoder.mjs?v=ordinary-comparatives-1';
import {decodeSpatialRelationMidi} from './spatial_relation_decoder.mjs?v=ordinary-comparatives-1';
import {decodePhysicalCustodyMidi,decodeCustodyAcquisitionMidi,decodeCustodyTransferMidi} from './custody_decoder.mjs?v=ordinary-comparatives-1';
import {decodeCustodyDeliveryMidi} from './delivery_decoder.mjs?v=ordinary-comparatives-1';
import {decodeNamedProcessMidi} from './named_process_decoder.mjs?v=ordinary-comparatives-1';
import {decodePhysicalCarryingMidi,decodeDestinationCarryingMidi} from './carrying_decoder.mjs?v=ordinary-comparatives-1';
import {decodeFeltConditionMidi} from './felt_decoder.mjs?v=ordinary-comparatives-1';
import {decodeContextualStandardMidi} from './contextual_standard_decoder.mjs?v=ordinary-comparatives-1';
import {decodeMaterialMeasurementMidi} from './material_measurement_decoder.mjs?v=ordinary-comparatives-1';
import {decodePropertyComparisonMidi} from './property_comparison_decoder.mjs?v=ordinary-comparatives-1';
const DECODERS=[decodePropertyComparisonGroupMidi,decodeContextualGroupMidi,decodeNamedProcessMidi,decodePhysicalCarryingMidi,decodeCareMidi,decodeLoveMidi,decodeSwimmingMidi,decodePhysicalEntryMidi,decodeRunningMidi,decodeSpatialRelationMidi,decodePhysicalCustodyMidi,decodeCustodyAcquisitionMidi,decodeCustodyTransferMidi,decodeCustodyDeliveryMidi,decodeDestinationCarryingMidi,decodeFeltConditionMidi,decodeContextualStandardMidi,decodeMaterialMeasurementMidi,decodePropertyComparisonMidi];
export function decodeSupportedMeaningMidi(bytes,atoms){
 const accepted=[];
 for(const decoder of DECODERS){try{accepted.push(decoder(bytes,atoms));}catch{}}
 if(accepted.length!==1)throw new Error(accepted.length?'Multiple semantic profiles accepted; explicit resolution required.':'No supported full-message semantic profile accepted.');
 return accepted[0];
}

// Draft meanings remain explicitly gated and never silently become canonical.
export async function decodeSupportedMeaningWithDrafts(bytes,atoms,records,{allowDraft=false,allowConjunction=true,adjectives}={}){
 if(!allowDraft)return decodeSupportedMeaningMidi(bytes,atoms);
 const {decodeFoundationSentenceMidi}=await import('./foundation_semantic_decoder.mjs?v=ordinary-comparatives-1');
 const {decodeUnderstandingMidi}=await import('./understanding_music.mjs?v=ordinary-comparatives-1');
 const {decodeUnderstandingAcquisitionMidi}=await import('./understanding_acquisition_music.mjs?v=ordinary-comparatives-1');
 const {decodeDesiredDrinkingMidi}=await import('./desired_drinking_music.mjs?v=ordinary-comparatives-1');
 const {decodeDesiredAvailabilityMidi}=await import('./desired_availability_music.mjs?v=ordinary-comparatives-1');
 const {decodeDesiredOwnershipMidi}=await import('./desired_ownership_music.mjs?v=ordinary-comparatives-1');
 const {decodeCustodyOpportunityMidi}=await import('./custody_opportunity_music.mjs?v=ordinary-comparatives-1');
 const {decodeOwnershipMidi}=await import('./ownership_music.mjs?v=ordinary-comparatives-1');
 const {decodeDrinkingMidi}=await import('./drinking_music.mjs?v=ordinary-comparatives-1');
 const {decodePainPreferenceMidi}=await import('./pain_preference_music.mjs?v=ordinary-comparatives-1');
 const {decodePainComparisonMidi}=await import('./pain_comparison_music.mjs?v=ordinary-comparatives-1');
 const {decodePainStimulusMidi}=await import('./pain_stimulus_music.mjs?v=ordinary-comparatives-1');
 const {decodePainMidi}=await import('./pain_music.mjs?v=ordinary-comparatives-1');
 const {decodeCuriosityMidi}=await import('./curiosity_music.mjs?v=ordinary-comparatives-1');
 const {decodeRouteLearningMidi}=await import('./route_learning_music.mjs?v=ordinary-comparatives-1');
 const {decodeDictionaryClauseMidi}=await import('./dictionary_clause_music.mjs?v=ordinary-comparatives-1');
 const {decodeFaultCorrectionMidi}=await import('./fault_correction.mjs?v=ordinary-comparatives-1');
 const {decodeInformationPassageMidi}=await import('./information_passage.mjs?v=ordinary-comparatives-1');
 const {decodeKnownValueMidi}=await import('./known_value.mjs?v=ordinary-comparatives-1');
 const {decodeStoryMidi}=await import('./story_music.mjs?v=ordinary-quantifiers-1');
 const accepted=[];
 try{accepted.push(decodeKnownValueMidi(bytes,atoms));}catch{}
 try{accepted.push(decodeStoryMidi(bytes,atoms,adjectives));}catch{}
 try{accepted.push(decodeDictionaryClauseMidi(bytes,atoms));}catch{}
 try{accepted.push(await decodeFaultCorrectionMidi(bytes,atoms));}catch{}
 try{accepted.push(decodeInformationPassageMidi(bytes,atoms));}catch{}
 try{accepted.push(decodeSupportedMeaningMidi(bytes,atoms));}catch{}
 try{accepted.push(await decodeFoundationSentenceMidi(bytes,atoms,records,{allowDraft:true,allowDraftQuestionContent:true,allowDraftAcquisition:true}));}catch{}
 try{accepted.push(await decodeUnderstandingMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(await decodeUnderstandingAcquisitionMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(await decodeRouteLearningMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodeDesiredDrinkingMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodeDesiredAvailabilityMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodeDesiredOwnershipMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodeCustodyOpportunityMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodeOwnershipMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodeDrinkingMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodePainPreferenceMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodePainComparisonMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodePainStimulusMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodePainMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(await decodeCuriosityMidi(bytes,atoms,records,{allowDraft:true}));}catch{}
 if(allowConjunction){const {decodeCognitiveConjunctionMidi}=await import('./cognitive_conjunction_music.mjs?v=ordinary-quantifiers-1');try{accepted.push(await decodeCognitiveConjunctionMidi(bytes,atoms,records,{allowDraft:true}));}catch{}}
 if(accepted.length!==1)throw new Error('No unique supported canonical or draft semantic interpretation.');
 return accepted[0];
}
