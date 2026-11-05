# Painful treatment: semantic dependency decision

This is an author design review of the translator's vocabulary, not a clinical
account of pain. `tools/audit_pain_dependencies.mjs` extracts the exact current
compound definitions and root exclusions into `reports/pain_dependency_audit.json`.
Its literal search is evidence to inspect, not proof that every possible
composition has been ruled out.

## Reuse before extension

The approved felt-self-condition compound (convention 11) provides conscious
experience and a bound experiencer. Unpleasant felt condition (18) adds valence
but explicitly excludes inference of pain. Felt bodily need (14) adds a demand
for replenishment or maintenance, which is not interchangeable with pain.
Sadness (19) specializes a different experiential quality. WRN internal faults
require adverse classification; they do not supply pain merely by describing a
fault. Keep all these definitions, identities and sounds unchanged.

A pain-specific convention can specialize the existing experiential structure.
The first candidate should explicitly select the felt bodily-pain reading, with
an experiencer; emotional hurt and figurative “a painful task” require their own
reading decisions. Do not add injury, visible damage, a known cause, a wish,
conscious verbal report or a treatment event merely from this selected meaning.
No extra LIF/STR family is justified by the evidence so far.

## Dependency order and scope

1. Define and validate felt bodily pain, reusing the felt-condition dependency.
   Check pain versus generic unpleasantness, sadness and damage. Preserve the
   same experiencer through every nested compound and runtime 0/1/2.
2. Define a reusable relation between a stimulus/event and the experience it
   produces or is expected/disposed to produce. Bind the pain experiencer
   separately from the stimulus. Actual causation, expected outcome and general
   disposition are distinct; bare “painful treatment” may require a choice.
   An expected painful treatment must not assert that treatment or pain occurred.
3. Define intensity comparison over compatible pain experiences or outcomes.
   Specify the comparison target, experiencer/context and comparison basis.
   “More painful” must not be encoded as an extra runtime level, a louder note,
   or merely a second contextual threshold. Ordinal comparison does not require
   inventing a numerical pain score or equating different people's scales.
4. Attach the resulting restriction to each treatment reference and then bind
   those references into the existing preference meaning. Keep reference
   identity explicit: matching noun sounds do not settle whether these are two
   treatments or two descriptions of the same treatment.
5. Keep preference polarity and speech act outside the alternatives. Preferring
   A to B does not assert absolute liking, choosing A, undergoing A, or absence
   of pain. Negated preference is not reversed preference or absence of pain.

## Acceptance obligations before claiming support

- “Nora is in pain” versus “Nora feels unpleasant” versus “Nora is injured”:
  preserve the selected meaning without substituting another one.
- “The treatment is painful for Nora”: the treatment is the stimulus, Nora the
  experiencer; the treatment is not conscious by virtue of this sentence.
- “The treatment would be painful for Nora”: preserve the selected nonactual
  scope; do not assert present pain or that the treatment happened.
- “Treatment A is more painful for Nora than treatment B”: recover both
  alternatives, their order and the selected shared comparison context.
- Original acceptance: “Nora prefers the painful treatment to the more painful
  treatment.” Preserve relative preference even when both alternatives have
  negative valence. Resolve the missing comparison referent/context explicitly
  if it cannot be established; do not silently invent an experiencer.
- Reverse alternatives, negate preference and ask the corresponding question;
  verify distinct recovered meanings at each runtime 0/1/2.
- For each implemented reading, decode full generated audio without source
  English, source IR or expected-note input. Add physical recordings before
  claiming robust recorded-audio recovery.

This review allocates no convention number and admits no new canonical meaning.
Pain construction, cause/disposition structure, intensity comparison and the
original painful-treatment acceptance remain unimplemented. Heavy/light
preference support is infrastructure evidence, not satisfaction of these cases.


## Draft meaning implementation checkpoint

`pages/pain_meaning.mjs` now provides an opt-in semantic document for explicit
“in bodily pain” sentences. It pins the existing felt-self-condition identity
and version, preserves a validated reference, speech act, past/negation scopes
and independent runtime. It does not infer injury, cause, stimulus or intensity.
The bodily-pain quality is an explicit draft specialization, not a consequence
of root adjacency. Generic “in pain” remains pending reading selection.

Twenty-four meaning contrasts and rehashed contract-corruption checks pass,
including singular they resolved to an explicit experiencer. No convention
number, canonical admission, renderer, MIDI inverse, UI route or audio recovery
is implemented for this profile yet. Complete pain translation remains open.
