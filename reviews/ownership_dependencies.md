# Ownership dependency review

Status: proposed semantic contract, not implemented or canonical. This review
follows the object-desire outcome probe that cannot compose “Nora owns the tea.”
It does not change roots, dictionary entries, musical codes or authority status.

## Existing meanings do not supply ownership

The current index contains 324 roots. MAT:210 is established material coupling:
a bearer can transmit physical influence to a distinct target. The custody
compound adds effective control of physical access/handling, explicitly without
ownership. Receiving borrowed tea and holding someone else's tea therefore cannot
be translated as becoming its owner. Conversely, an owner need not hold the tea.

The earlier receipt/possession review already excludes ownership from arrival,
support, carrying, custody and custody transfer. Current delivery is built from
those meanings and does not fill this gap. LOG:210 relates a specified constraint
to a target; it does not specify ownership rules or identify an owner. STR:110
incorporates a target into a structure, which is not entitlement. ORI:210 supplies
dependence on a specified ground, not the content of a rights relation. CON:110
is communicative uptake; it cannot be used as material or normative receipt.

Evidence: pages/data/index.json; reviews/receipt_possession_foundation.md;
reviews/physical_custody_foundation.md; pages/delivery_decoder.mjs;
reports/object_desire_outcome_coverage.json. These are semantic distinctions,
not advice about real-world legal ownership.

## Candidate dependency order

1. Represent a contextual normative framework as a referenced entity. A name
   identifies the framework but cannot encode its entire rules as a sound label.
2. Define a conventional ownership-status relation with explicit owner, object,
   and framework participants. Its additional invariant is recognition of the
   participant as owner of the object under that framework. Recognition here is
   institutional status, not a claim that every person believes or accepts it.
3. Keep individual incidents (permission to use, authority to transfer, exclusion,
   duties, limits and fractional share) separate. Ownership must not silently
   assert an unlimited universal bundle of rights. Specify these separately when
   the input expresses them. Co-ownership and shares need plural/quantity work.
4. Define acquisition or transfer of ownership only after that status relation
   works. Reuse before/culmination event structure where its commitments match;
   never rename the physical custody-transfer compound.
5. Compose ownership under desire/knowledge/negation with the existing scoped
   grammar. “Nora wants tea” still needs explicit outcome selection. Selecting
   ownership must not select a normative framework or assert current ownership.

An unresolved contextual framework is not equivalent to a named framework. Before
implementation, choose an audible representation for the unresolved context or
require an explicit framework. Do not insert a silent default. The current sound
label mechanism can represent explicit framework references, but does not alone
implement the new three-place ownership relation. No extra root family is
justified by the evidence above; first evaluate a reviewed conventional compound.

## Acceptance contrasts before promotion

- Nora has custody of Eli's object: custody does not entail Nora's ownership.
- Nora owns an object held by Eli: ownership does not entail Nora's custody.
- A framework permits Nora to use an object: permission does not entail ownership.
- Ownership differs between two explicitly named frameworks: retain both bindings
  and do not collapse the statements into a contradiction without framework scope.
- Nora does not own the object: this does not assert that another participant owns
  it, nor that the object is unowned under every framework.
- Does Nora own it?: preserve question scope without asserting ownership.
- Nora wants Eli to own it: preserve distinct desire holder and proposed owner;
  the ownership remains intensional, including independent runtime 0/1/2.
- Ownership transfer without physical delivery and custody delivery without
  ownership transfer must remain musically distinguishable.

Tests must recover relation, framework, owner, object and scope from performed
sound; matching English aliases or differing MIDI hashes are insufficient. A
complete implementation also needs independent rendering, strict inverse checks,
forged participant-binding rejection, blind WAV tests and physical recordings.
No ownership translation is claimed complete by this review.


## Draft semantic implementation checkpoint

`pages/ownership_meaning.mjs` implements a draft-only three-participant status
contract using validated existing entity/name references. The framework must be
explicit and phonemic; speaker/listener references cannot silently serve as its
identity. The contract retains framework inside proposition scope and makes no
custody, control, acquisition, unrestricted rights, exclusivity, share or universal
agreement assertion. Its reference label does not supply the framework's rules.

Forty-eight authored documents distinguish two owners, two frameworks, assertion
versus question, negation and runtime 0/1/2 under past scope. Validation rejects
missing frameworks, altered participant identities, extra hidden rights and
rehashed attempts to change the contract. The test is registered in the runner.
This is semantic-model evidence only: no musical identity has been allocated,
English parser or preview added, compound promoted, or audio recovery demonstrated.
The prior 235-check regression predates this module. Next: specify the audible
three-role convention, then independently encode/decode it and connect explicit
English interpretation. Unspecified-context and co-ownership remain unresolved.


## English composition checkpoint

`pages/ownership_sentences.mjs` now composes own/owns/owned, negative auxiliaries,
straight/curly negative contractions and yes/no questions into the draft model.
Framework is an explicit API selection; no contextual framework is invented.
Entity references reuse existing definite/proximal/distal nouns, names and
speaker/listener references. Bare mass nouns and unqualified “has” do not silently
become ownership. Explicit singular-they and object-pronoun bindings reuse the
shared resolver; plural groups are not coerced to one owner.

Eighteen full-document comparisons check tense, negation, question and all runtime
states. Three neutral-reference contrasts match their explicit named meanings;
invalid agreement, absent frameworks and conflicting punctuation reject. Changing
the named framework changes the semantic document. This remains an API semantic
extension, not a complete translation: no ownership music, independent inverse,
WAV recovery, UI route or canonical promotion is available yet.


## Draft musical and waveform checkpoint

Ownership uses draft frame subcode 14 in the existing +/-39 namespace with
runtime-bearing open/close paths `[0, +/-39, 14, runtime, 0]`. Existing subcodes
0–13 retain their meanings. Inside the new frame, the existing experiencer,
content and comparison-standard role frames identify owner, object and normative
framework respectively; this local convention does not redefine those roles in
other predicates. Existing phonemic/deictic reference rendering and time/negation
wrappers are reused. No root or approved compound sound changes.

Eighteen meaning-to-MIDI/inverse checks cover two named frameworks, all runtime
states, question and past-negated forms, with transposition and unique shared
dispatch. Default strict decoding rejects the draft frame. A clean synthetic WAV
for “Didn't Nora own this tea? [2]” under an explicitly selected Harbor charter
recovers the complete inverse without original English, selected framework or
semantic document supplied to the decoder. See ownership_acoustic_probe.json.
This is one authored clean sample, not physical microphone evidence or robustness
coverage. Independent Ruby rendering, adversarial role/framing corruption,
interface integration, nested ownership/desire and physical recordings remain
open. Ownership remains draft and is not added to canonical dictionary counts.


## Independent renderer and malformed-role evidence

`tools/lib/era_zero_ownership.rb` independently validates the fixed ownership
contract, three references, allowed scope, runtime and semantic identity, then
renders the convention through existing Ruby reference and scheduling machinery.
All 18 authored JavaScript cases have byte-identical Ruby MIDI. Default draft
use and rehashed attempts to add custody, exclusivity, invalid runtime or move
the framework outside negation reject independently.

Two malformed performances remain structurally valid to the strict musical
reader but fail both the ownership semantic inverse and shared dispatch: an
absent framework role and a duplicate owner role replacing the object role.
This checks semantic completeness beyond distinct MIDI hashes. A coherently
changed audible participant is a different message, not detectable corruption
without an external expected message; no authentication claim is made.
Interface integration, desired ownership, implicit context, co-ownership and
physical audio recordings remain unfinished. These targeted checks do not
supersede the last full regression report.


## Ownership preview integration

The ordinary analysis route now recognizes ownership statements/questions and
explicit pronoun plans, presenting a draft preview with a required framework
field. It reuses the existing playback mechanism and exports ownership MIDI and
full validated JSON. Pronoun references are explicit, including one/group
selection for they/them; unsupported groups still reject. There is no default
framework and no claim that the reference name provides or verifies its rules.

Actual handler tests exercise framework gating, complete exported meaning/MIDI,
a past negated question with runtime 2, singular-they and object binding, stale
asynchronous generation and invalidated old downloads. Drinking preview tests
still pass. These VM handler tests are not live-browser or physical-audio checks.
Nested desired ownership, broader references/contexts, release validation and
physical recordings remain unfinished.


## Desired ownership semantic and musical composition

Desired ownership now reuses the existing desire foundation and the ownership
contract. Explicit finite or infinitival owners remain distinct from the desire
holder; subject-controlled infinitives bind the proposed owner to that holder.
The framework remains inside the ownership proposition, which is intensional
and desired rather than asserted. Past time, negation, question and outer/inner
runtime states remain separate. Explicit neutral pronoun bindings are supported.

Draft +/-39 subcodes 15 and 16 distinguish controlled and explicit-owner desire
frames. These reuse the ownership subtree reader and existing role/proposition
frames. Eighteen semantic cases plus eighteen music cases exercise independent
runtime pairs and subject control, transposition and unique draft dispatch;
rehashed asserted-outcome, wrong-foundation and false-control documents reject.
Standalone ownership rendering/decoding tests still pass. Independent rendering
and blind WAV recovery for the nested form, object-desire clarification and UI
routing remain unfinished. This addition is not canonical vocabulary approval.


## Independent desired-ownership rendering and blind audio

The independent Ruby renderer now validates desired ownership, the pinned desire
foundation, the entire nested ownership contract, and controlled subject identity.
All 18 authored runtime/control contrasts produce identical Ruby and JavaScript
MIDI. Rehashed attempts to assert the desired outcome, substitute its foundation,
or claim false subject control reject.

The blind synthetic-WAV case “Didn't Nora want Eli to not own this tea [0]? [2]”
with explicit Harbor charter recovers distinct holder/owner, framework inside
ownership, outer past negation/question, inner negation and independent runtime
2/0. The decoder process receives only WAV path and draft opt-in, not the source
sentence, framework selection, expected notes or semantic document. See
`reports/desired_ownership_acoustic_probe.json`. This is one clean authored sample;
physical recordings, channel perturbations and broader independently chosen
messages remain untested for this form. Object-desire and UI integration are next.


## Explicit object-desire ownership resolution

`composeObjectDesiredOwnership` connects an explicitly supplied desired proposition
and framework to the existing object-desire resolver. It preserves original input
and clarification provenance separately from the hashed semantic document and
requires a successful full shared musical inverse before returning. Matching is
against the ownership object, not merely a name mentioned as owner or framework.
Normalized noun/name identity and definite/proximal/distal mode remain distinct;
bare nominal input may be clarified to a particular nominal reference, not a
proper name with the same sounds.

Nine outer/inner runtime pairs with separate negations and question scope pass.
Unrelated objects, this/that substitution, noun-to-name substitution, absent
outcomes and absent frameworks reject. The outcome audit keeps unclarified
ownership unresolved and adds a separate explicit-framework case with recovered
meaning. This is authored coverage, not held-out validation. UI routing and a
blind audio test beginning from the original object-desire input remain open.


## Desired and clarified ownership preview completion checkpoint

The ownership preview now handles direct desired ownership and explicit ownership
outcomes entered through the object-desire clarification field. Both require a
framework and preserve the desired-not-asserted status. Clarified exports retain
original input, selected outcome and provenance alongside the validated meaning.
Playback and MIDI export use the nested ownership performance. Input, framework,
pronoun and revision guards invalidate old results and downloads.

Actual handler tests recover complete nested meanings from exported MIDI for
both paths, checking distinct holder/owner, distal object, independent negation
and runtime 2/0. Foundation routing, existing drinking previews and foundation
pronoun checks pass. The desired-ownership WAV probe now starts from “Didn't Nora
want this tea? [2]” plus the explicit outcome “Eli does not own this tea [0].” and
Harbor charter selection. Waveform-only decoding recovers the nested meaning
without original input or clarification. This updates the current report; earlier
direct-desire waveform evidence remains in Git history. Live-browser validation,
physical recordings and broader ownership/context coverage remain unfinished.
