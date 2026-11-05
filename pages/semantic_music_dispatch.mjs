// Shared strict semantic inverses; no expected sentence or predicate hint.
import {decodeCareMidi} from './care_decoder.mjs';
import {decodeSwimmingMidi} from './swimming_decoder.mjs';
import {decodePhysicalEntryMidi} from './physical_entry_decoder.mjs';
import {decodeRunningMidi} from './running_decoder.mjs';
import {decodeSpatialRelationMidi} from './spatial_relation_decoder.mjs';
import {decodePhysicalCustodyMidi,decodeCustodyAcquisitionMidi,decodeCustodyTransferMidi} from './custody_decoder.mjs';
import {decodeCustodyDeliveryMidi} from './delivery_decoder.mjs';
import {decodeDestinationCarryingMidi} from './carrying_decoder.mjs';
import {decodeFeltConditionMidi} from './felt_decoder.mjs';
import {decodeContextualStandardMidi} from './contextual_standard_decoder.mjs';
import {decodeMaterialMeasurementMidi} from './material_measurement_decoder.mjs';
import {decodePropertyComparisonMidi} from './property_comparison_decoder.mjs';
const DECODERS=[decodeCareMidi,decodeSwimmingMidi,decodePhysicalEntryMidi,decodeRunningMidi,decodeSpatialRelationMidi,decodePhysicalCustodyMidi,decodeCustodyAcquisitionMidi,decodeCustodyTransferMidi,decodeCustodyDeliveryMidi,decodeDestinationCarryingMidi,decodeFeltConditionMidi,decodeContextualStandardMidi,decodeMaterialMeasurementMidi,decodePropertyComparisonMidi];
export function decodeSupportedMeaningMidi(bytes,atoms){
 const accepted=[];
 for(const decoder of DECODERS){try{accepted.push(decoder(bytes,atoms));}catch{}}
 if(accepted.length!==1)throw new Error(accepted.length?'Multiple semantic profiles accepted; explicit resolution required.':'No supported full-message semantic profile accepted.');
 return accepted[0];
}

// Draft meanings remain explicitly gated and never silently become canonical.
export async function decodeSupportedMeaningWithDrafts(bytes,atoms,records,{allowDraft=false,allowConjunction=true}={}){
 if(!allowDraft)return decodeSupportedMeaningMidi(bytes,atoms);
 const {decodeFoundationSentenceMidi}=await import('./foundation_semantic_decoder.mjs');
 const {decodeUnderstandingMidi}=await import('./understanding_music.mjs');
 const {decodeUnderstandingAcquisitionMidi}=await import('./understanding_acquisition_music.mjs');
 const {decodeDesiredDrinkingMidi}=await import('./desired_drinking_music.mjs');
 const {decodeDesiredOwnershipMidi}=await import('./desired_ownership_music.mjs');
 const {decodeCustodyOpportunityMidi}=await import('./custody_opportunity_music.mjs');
 const {decodeOwnershipMidi}=await import('./ownership_music.mjs');
 const {decodeDrinkingMidi}=await import('./drinking_music.mjs');
 const {decodePainPreferenceMidi}=await import('./pain_preference_music.mjs');
 const {decodePainComparisonMidi}=await import('./pain_comparison_music.mjs');
 const {decodePainStimulusMidi}=await import('./pain_stimulus_music.mjs');
 const {decodePainMidi}=await import('./pain_music.mjs');
 const {decodeCuriosityMidi}=await import('./curiosity_music.mjs');
 const {decodeRouteLearningMidi}=await import('./route_learning_music.mjs');
 const accepted=[];
 try{accepted.push(decodeSupportedMeaningMidi(bytes,atoms));}catch{}
 try{accepted.push(await decodeFoundationSentenceMidi(bytes,atoms,records,{allowDraft:true,allowDraftQuestionContent:true,allowDraftAcquisition:true}));}catch{}
 try{accepted.push(await decodeUnderstandingMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(await decodeUnderstandingAcquisitionMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(await decodeRouteLearningMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodeDesiredDrinkingMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodeDesiredOwnershipMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodeCustodyOpportunityMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodeOwnershipMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodeDrinkingMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodePainPreferenceMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodePainComparisonMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodePainStimulusMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(decodePainMidi(bytes,atoms,{allowDraft:true}));}catch{}
 try{accepted.push(await decodeCuriosityMidi(bytes,atoms,records,{allowDraft:true}));}catch{}
 if(allowConjunction){const {decodeCognitiveConjunctionMidi}=await import('./cognitive_conjunction_music.mjs');try{accepted.push(await decodeCognitiveConjunctionMidi(bytes,atoms,records,{allowDraft:true}));}catch{}}
 if(accepted.length!==1)throw new Error('No unique supported canonical or draft semantic interpretation.');
 return accepted[0];
}
