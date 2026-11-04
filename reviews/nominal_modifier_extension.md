# Noun modifiers: dependency audit and implementation sequence

The executable probes in `tools/audit_nominal_modifier_gaps.mjs` write
`reports/nominal_modifier_gaps.json`. These are authored diagnostics, not a
coverage benchmark. Successful composition does not certify meaning or sound.

## Existing work to reuse

`sentences.mjs` already binds one heavy/light restriction to a noun participant,
keeping the noun's phonemic label separate. Its numeric mass restriction has a
strict MIDI inverse in `reference_property_decoder.mjs`. That inverse explicitly
does not recover complete sentence meaning. The existing nominal-mass musical
frame is mass-specific; do not silently reinterpret it as a generic adjective.

`contextual_standards.mjs` provides temperature, mass, luminance and texture
norms. Their unspecified contextual standards are meaningful and must not be
replaced by invented numeric cutoffs. Noun restrictions now accept contextual mass standards for heavy/light;
other dimensions remain unsupported. `foundation_sentences.mjs` accepts plain noun alternatives
but cannot attach these restrictions to preference alternatives.

## Implementation order

1. Define a typed restriction on a reference, with an explicit bearer binding,
   property sense and standard. Reuse existing adjective meanings. Keep the
   restricted reference distinct from a separately asserted property clause.
   Define projection under negation, questions and intensional content before
   implementing generic scope transport.
2. Extend reference validation, renderer and inverse together. Preserve the
   numeric mass encoding. Give generic restrictions an unambiguous encoding;
   compare existing frames before allocating another. Verify every participant
   binding from performed notes, including two independently modified arguments.
3. Admit restricted references into preference alternatives. Test reversed
   alternatives, negation, questions and runtime 0/1/2 independently. Preserve
   distinct reference occurrences when the noun label is the same; identical
   sounds alone must not collapse two treatments into one entity.
4. Audit pain, pain-causing disposition, unpleasant experience and degree
   comparison against approved meanings before composing “painful treatment.”
   A treatment need not itself feel pain, and anticipated pain need not already
   have occurred. “More painful” needs a comparison target and compatible scale;
   it must not mean merely above a contextual threshold. Do not substitute
   heavy/hot support for this original acceptance requirement.
5. Handle object desire separately: “wants the treatment” leaves the desired
   relation underdetermined. A modifier does not justify silently choosing
   possession, undergoing treatment or an occurrence. Request the missing
   reading while preserving the adjective structure.
6. Exercise full message → meaning → audio → recovered meaning with no source
   text or source IR supplied to the decoder. Include same-noun alternatives,
   scope contrasts and compounds of compounds. Synthetic WAV evidence precedes,
   and cannot replace, physical speaker-to-microphone recordings.

No new root family is justified by these structural gaps. No root, approved
compound or runtime meaning was changed. The first implementation reuses existing
mass and contextual-norm frames: 12 heavy/light × negation × runtime cases recover
complete destination-carrying meaning from MIDI and match independent Ruby
rendering. Numeric mass regression remains intact. The new contextual restriction
remains attached to its noun under action negation; negation does not invert the
restriction. Generic modifiers, preference integration and physical-audio
obligations above remain open. Two clean synthetic WAVs now recover complete
destination-carrying meaning through the shared decoder with only the WAV path
as input; see `reports/contextual_nominal_mass_acoustic_probe.json`. This is not
physical recording evidence. The standalone adjective-choice UI now exposes the
contextual noun option, with a handler test and changed-input guard. Combined
viewpoint, per-clause and explicit-pronoun screens now expose the same contextual
option. Handler tests cover independent clause standards, singular they binding,
disabled numeric inputs and invalidation when the standard mode changes while
a template is loading. These are executable handler tests, not live-browser
layout or listening evidence.
