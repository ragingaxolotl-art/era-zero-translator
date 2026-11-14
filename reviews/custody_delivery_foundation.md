# Carrying-mediated custody delivery

Status: delegated author review under the user-directed translator-completion
goal, not independent linguistic validation. This compound reuses completed
carrying-to-destination version 1.0.0 and custody-transfer version 1.0.0.
No new root or changed prior meaning is needed.

Convention 10 links carrying arrival to custody transfer as one culmination. It
identifies the carrier with the transfer source, the load with the transferred
object, and the destination referent with the recipient. All of those equalities
are structural constraints, including transitive nested load and destination
bindings inherited from earlier compounds. Arrival must occur through supporting
conveyance; throwing and later independent flight do not qualify. Custody passes
from that carrier to that recipient as the arrival culminates, not in an unrelated
later episode. A third-party dispatcher is not silently substituted for the carrier.

This is a bounded physical-delivery sense, not every use of “deliver”. Leaving a
box unattended without establishing recipient custody does not qualify. Ownership,
lawfulness, willing acceptance, third-party exclusivity and continued possession
are not asserted. A recipient may be a labeled referent; its associated contextual
position is the spatial endpoint. Names do not supply any additional hidden meaning.

## Grammar and independent state

The event type contains completed arrival and transfer. Grammar scopes that event
type: a bounded positive assertion describes its completion, an ongoing reading
presents its unfolding without entailing culmination, and habitual scope describes
a recurring practice without asserting a particular present occurrence. Negation,
questions, modalities and commands retain their scope. A negative or interrupted
progressive does not imply actual arrival or custody transfer. This is the usual
imperfective distinction encoded by the existing aspect grammar, not a claim that
the nested completed predicates are independently true at speech time.

The nested roots have no separate occurrence endings. The acquired-relation head
ORI:110 carries the outer 0/1/2 state; its lexical 110 address is unchanged. Runtime
2 does not supply future time, intention, incomplete delivery or willingness.

## Product behavior and evidence

“Pip carries the heavy box to Ada” retains explicit viewpoint and mass-standard
choices. The meaning-of-to selector now offers spatial-only carrying or carrying
that culminates in physical custody transfer. Both the single-clause and grouped
clause forms expose this choice; no default selects receipt. Past, ongoing,
habitual, negated and questioned variants and commands reuse the same choice.
Unqualified “deliver” remains ambiguous and is not made an automatic alias.

`tests/custody_delivery_test.mjs` checks 36 sentence/runtime cases with complete
Ruby/browser formal and MIDI agreement, exact manually expected participants,
ordered scope and event commitments. Three additional fixtures retain independent
lexical participant states under each outer 0/1/2 state. It contrasts spatial-only output for every
case and mutates transfer-source, object and recipient sounds while retaining
valid musical structure; the independent inverse rejects the mismatches. It also
checks identity constraints, the conditional command “If the box is heavy, carry
it to Ada”, explicit actual UI-handler selection and all 42 preceding compound
records. These are authored tests, not held-out coverage or a live browser check.

The implementation is `CMP:5200738177777915abb3f42e`, version 1.0.0. Decoder
`decodeCustodyDeliveryMidi` receives performed MIDI plus root sounds only. It
recovers the bounded linkage and scope, not external identity, arbitrary audio or
general discourse. Browser use was still disabled at the November 4 live-check attempt;
visual, listening and deployed-release validation remain pending. Broader delivery
senses, general grammar and the original seven completion gates remain open.
