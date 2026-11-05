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
