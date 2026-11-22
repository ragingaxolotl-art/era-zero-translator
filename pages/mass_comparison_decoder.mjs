import {decodePropertyComparisonMidi} from './property_comparison_decoder.mjs?v=partial-word-flow-1';

// Preserve the existing mass-only API and its rejection of other dimensions.
export function decodeMassComparisonMidi(bytes){
 const result=decodePropertyComparisonMidi(bytes);
 if(result.dimension!=='mass')throw new Error('Unsupported or malformed strict mass-comparison music.');
 return result;
}
