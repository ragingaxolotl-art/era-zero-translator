# DAT:000–022 Adversarial Semantic Design Review

Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**

This packet challenges all nine provisional Data entity meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes 113 English concepts without forcing broad words into atoms.

## Packet-level design decision

The strongest architecture makes `DAT:0xx` the substrate-neutral entity layer for information objects. The inward triplet identifies one bounded datum maintained within a reference entity, the outward triplet identifies one bounded datum whose content denotes one distinct referent, and the systemic triplet identifies one coordinated shared dataset across multiple participants. Persistence, manifestation, and dormancy supply the exact third-trit contrast.

Each `...0` member asserts persistence of information-object identity and is neutral about present manifestation, so it may co-occur with either its `...1` or `...2` sibling. The manifest `...1` and dormant `...2` siblings are mutually exclusive for the same object at the same reference time. Runtime `[2]/num` remains uncertainty about the selected claim. The design rejects the provisional mixture of input, update, transmission, delivery queues, streaming, replication, access, indexing, and storage-medium states. Data transformation and flow remain for `DAT:1xx`; storage, access, provenance, and transmission affordances remain for `DAT:2xx`; media, cognition, communication, formal rules, and time remain other families.

## DAT:000 — persistent internal datum

### A. Fixed generated forms

- Universal slot: **stable inward entity**
- Transliteration: **li·nam**
- Local compact root: **nam**
- Formal carrier: **li-ma-ma-ma**
- Harmonic signature: **0–4–7–11**
- Relative note path: **0 → 0 → 0 → 0**

### B. Why the current meaning was probably chosen

The provisional titles use familiar data vocabulary and roughly follow inward scope and persistent status.

### C. Candidate comparison

| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| local record | 6 | 7 | 8 | 4 | 4 | 7 | 8 | 7 | **51/80** |
| persistent internal datum | 10 | 10 | 10 | 10 | 10 | 10 | 10 | 10 | **80/80** |
| persistent internal representation | 9 | 8 | 10 | 8 | 8 | 9 | 9 | 10 | **71/80** |
| persistent local record | 9 | 8 | 9 | 7 | 7 | 9 | 10 | 10 | **69/80** |
| persistent internal message | 8 | 7 | 7 | 6 | 3 | 9 | 10 | 9 | **59/80** |

#### local record

**Invariant candidate:** A stable inward record, symbol, identifier, or datum is stored as one bounded information object.

- Fit: The provisional titles use familiar data vocabulary and roughly follow inward scope and persistent status.
- Useful coverage: They cover records, inputs, messages, signals, datasets, streams, archives, identifiers, and packets.
- Territory consumed: Across the block they mix information entities, storage state, communication processes, data flow, delivery queues, access, indexing, and active updating.
- Conflicts and limitations: The triplets do not preserve one entity center: manifest roots absorb input or flow processes, target roots absorb CON delivery, and dormancy is mixed with inaccessible, queued, unread, and unindexed states.

#### persistent internal datum

**Invariant candidate:** A persistent bounded information object maintained within one reference entity, independently of whether that information object is presently manifest.

- Fit: The first trit remains an information entity; the second changes only internal containment, reference to one distinct target, or coordinated sharing across participants; the third changes only persistent, manifest, or dormant status.
- Useful coverage: It supports datum, record, value, identifier, reference, pointer, metadata, dataset, corpus, catalogue, and shared state without encoding transmission or computation.
- Territory consumed: Only bounded information-object identity and manifestation at the selected scope. Media, storage mechanics, communication, transformation, access, truth, belief, and formal validity remain separate.
- Conflicts and limitations: Encoding and value-type distinctions remain broad in Era Zero and must be supplied compositionally when exact syntax, schema, provenance, or medium matters.

#### persistent internal representation

**Invariant candidate:** A persistent symbolic representation organized at inward information scope.

- Fit: Symbols and representations are central Data entities and can occur internally, refer to targets, or form shared representational systems.
- Useful coverage: It would cover symbols, tokens, codes, names, labels, icons, formulas, maps, and representational systems.
- Territory consumed: It specializes every datum to an explicitly symbolic representation.
- Conflicts and limitations: Measurements, opaque blobs, sensory traces, and non-symbolic information objects would be under-served, while representational relation details risk LOG, MIN, and STR collisions.

#### persistent local record

**Invariant candidate:** A persistent stored record situated at inward information scope.

- Fit: Records naturally persist, become open or loaded, and become archived at internal, target-addressed, or shared scope.
- Useful coverage: It would cover files, rows, documents, logs, archives, databases, indexes, and stored records.
- Territory consumed: It makes durable storage or record structure essential to every Data entity.
- Conflicts and limitations: Signals, ephemeral values, references, and computed data need not be records; physical storage and access also risk MAT and STR collisions.

#### persistent internal message

**Invariant candidate:** A persistent communicative message organized at inward scope.

- Fit: Messages contain information, can remain local, target recipients, or be shared among groups, and can be manifest or dormant.
- Useful coverage: It would cover message, packet, signal, notification, post, broadcast, queue, and inbox item.
- Territory consumed: It makes communicative intent, sender-recipient structure, and delivery context obligatory.
- Conflicts and limitations: CON owns participants, transmission, delivery, and reception, while most data objects are not messages at all.

### D. Recommended permanent semantic specification

**Title:** persistent internal datum

**Invariant:** A persistent bounded information object maintained within one reference entity, independently of whether that information object is presently manifest.

**Inclusion boundary:** Includes only the persistent internal datum as a substrate-neutral information entity at inward scope. The claim is about an information object maintained within one reference entity, not the physical medium, an observer's memory, a reference to another target, or a shared collection. It is neutral about truth, validity, belief, access, observation, transmission, processing, mutation, physical realization, ownership, provenance, probability, timing, and cause.

**Excluded meanings:**

- Truth, falsity, validity, evidential support, assertion, belief, understanding, memory, or certainty concerning the information.
- Creation, mutation, computation, parsing, indexing, querying, copying, transmission, delivery, reception, or deletion of data.
- Physical inscription, storage medium, device, energy, signal carrier, file-system structure, access path, or network topology.
- Sender, recipient, communication act, social ownership, authority, privacy policy, permission, or responsibility.
- Formal rule, proposition role, proof status, evaluation, satisfaction, entailment, consistency, or semantic correctness.
- Accessibility, observability, discoverability, provenance, version, schedule, future activation, possibility, necessity, probability, or cause.

**Address justification:**

- `first_trit_0`: Selects an information entity rather than a data transformation, transmission event, storage/access affordance, or physical medium.
- `second_trit`: Selects inward/self scope: one bounded information object maintained within one reference entity and no other Data-family column.
- `third_trit`: Selects the persistent/manifestation-neutral member by information-object identity or present manifestation while leaving runtime truth status, access, observation, transmission, tense, probability, and process phase separate.

**Nearest neighbors:** `DAT:001`, `DAT:002`, `DAT:010`, `DAT:020`, `DAT:100`, `DAT:200`

**Same-family boundary:** `DAT:0xx` owns information entities and their persistent, manifest, or dormant status. `DAT:1xx` remains reserved for information transformations or flow processes, and `DAT:2xx` for storage, access, provenance, transmission, or other information affordances and relations. A manifest datum does not entail access, observation, truth, transfer, or processing, and an identified datum does not entail a usable storage or communication relation. The persistent member is manifestation-neutral: it may co-occur with the manifest sibling or the dormant sibling at the same reference time. It asserts continuity of information-object identity rather than a third mutually exclusive manifestation value.

**Runtime-state interpretation:**

- `[0]`: Denies that this internal datum persists as the same identified information object; it does not select the manifest or dormant sibling and does not erase every related datum.
- `[1]`: Affirms the persistent identity of this internal datum while leaving current manifestation, accessibility, truth, encoding, medium, and provenance undecided.
- `[2/num]`: Leaves unresolved whether this persistent internal datum remains identified; uncertainty about the assertion does not change the lexical root into a manifest or dormant datum.

**Lexical/runtime distinction:** Lexical third trit `0` permanently selects the persistent/manifestation-neutral member of this information-entity triplet. Runtime `[2]/num` instead leaves that already-selected assertion unresolved; it never changes manifestation status. Thus a dormant root affirmed with `[1]` is a confirmed maintained-but-unmanifest information object, while a persistent or manifest root carrying `[2]/num` remains lexically persistent or manifest but uncertain as a token claim.

### E. Examples

| Type | Semantic graph | Literal gloss | Natural English | State | Result |
| --- | --- | --- | --- | ---: | --- |
| ordinary_conversation | `DAT:000[1](ENTITY=device,DATUM=d)` | affirm persistent internal datum | That information object remains identified whether or not it is visible now. | 1 | valid |
| physical_or_spatial | `MAT(MEDIUM=m)+DAT:000[1](ENTITY=device,DATUM=d)` | material medium plus persistent data entity | A mark on the device realizes the datum while MAT separately describes its physical medium. | 1 | valid |
| temporal_or_sequential | `DAT:000[1](ENTITY=device,DATUM=d)+ORI(INTERVAL=w)` | persistent data entity during interval w | During interval w, the information object has the stated lexical status. | 1 | valid |
| cross_family_compound | `LOG(CRITERION=c)+DAT:000[1](ENTITY=device,DATUM=d)` | formal criterion plus persistent data representation | The datum represents a criterion without becoming the formal rule itself. | 1 | valid |
| executable_or_programming | `DAT:000[1](ENTITY=device,DATUM=d)` | assert persistent information-object status | A runtime registers information-object status without asserting transfer, parsing, mutation, or truth. | 1 | valid |
| counterexample | `CON(TRANSFER=d,SOURCE=s,TARGET=t)` | data transmission | The packet is being sent to a recipient. | 1 | must_not_use_this_root |

## DAT:001 — manifest internal datum

### A. Fixed generated forms

- Universal slot: **active inward entity**
- Transliteration: **li·nak**
- Local compact root: **nak**
- Formal carrier: **li-ma-ma-ki**
- Harmonic signature: **0–4–7–11**
- Relative note path: **0 → 0 → 0 → 2**

### B. Why the current meaning was probably chosen

The provisional titles use familiar data vocabulary and roughly follow inward scope and manifest status.

### C. Candidate comparison

| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| current input | 5 | 7 | 8 | 4 | 4 | 7 | 8 | 7 | **50/80** |
| manifest internal datum | 10 | 10 | 10 | 10 | 10 | 10 | 10 | 10 | **80/80** |
| manifest internal representation | 9 | 8 | 10 | 8 | 8 | 9 | 9 | 10 | **71/80** |
| open local record | 9 | 8 | 9 | 7 | 7 | 9 | 10 | 10 | **69/80** |
| manifest internal message | 7 | 7 | 7 | 6 | 3 | 9 | 10 | 9 | **58/80** |

#### current input

**Invariant candidate:** A signal or datum is presently entering, updating, or occupying an entity's local information state.

- Fit: The provisional titles use familiar data vocabulary and roughly follow inward scope and manifest status.
- Useful coverage: They cover records, inputs, messages, signals, datasets, streams, archives, identifiers, and packets.
- Territory consumed: Across the block they mix information entities, storage state, communication processes, data flow, delivery queues, access, indexing, and active updating.
- Conflicts and limitations: The triplets do not preserve one entity center: manifest roots absorb input or flow processes, target roots absorb CON delivery, and dormancy is mixed with inaccessible, queued, unread, and unindexed states.

#### manifest internal datum

**Invariant candidate:** A bounded information object that is presently manifest within one reference entity.

- Fit: The first trit remains an information entity; the second changes only internal containment, reference to one distinct target, or coordinated sharing across participants; the third changes only persistent, manifest, or dormant status.
- Useful coverage: It supports datum, record, value, identifier, reference, pointer, metadata, dataset, corpus, catalogue, and shared state without encoding transmission or computation.
- Territory consumed: Only bounded information-object identity and manifestation at the selected scope. Media, storage mechanics, communication, transformation, access, truth, belief, and formal validity remain separate.
- Conflicts and limitations: Encoding and value-type distinctions remain broad in Era Zero and must be supplied compositionally when exact syntax, schema, provenance, or medium matters.

#### manifest internal representation

**Invariant candidate:** A manifest symbolic representation organized at inward information scope.

- Fit: Symbols and representations are central Data entities and can occur internally, refer to targets, or form shared representational systems.
- Useful coverage: It would cover symbols, tokens, codes, names, labels, icons, formulas, maps, and representational systems.
- Territory consumed: It specializes every datum to an explicitly symbolic representation.
- Conflicts and limitations: Measurements, opaque blobs, sensory traces, and non-symbolic information objects would be under-served, while representational relation details risk LOG, MIN, and STR collisions.

#### open local record

**Invariant candidate:** A manifest stored record situated at inward information scope.

- Fit: Records naturally persist, become open or loaded, and become archived at internal, target-addressed, or shared scope.
- Useful coverage: It would cover files, rows, documents, logs, archives, databases, indexes, and stored records.
- Territory consumed: It makes durable storage or record structure essential to every Data entity.
- Conflicts and limitations: Signals, ephemeral values, references, and computed data need not be records; physical storage and access also risk MAT and STR collisions.

#### manifest internal message

**Invariant candidate:** A manifest communicative message organized at inward scope.

- Fit: Messages contain information, can remain local, target recipients, or be shared among groups, and can be manifest or dormant.
- Useful coverage: It would cover message, packet, signal, notification, post, broadcast, queue, and inbox item.
- Territory consumed: It makes communicative intent, sender-recipient structure, and delivery context obligatory.
- Conflicts and limitations: CON owns participants, transmission, delivery, and reception, while most data objects are not messages at all.

### D. Recommended permanent semantic specification

**Title:** manifest internal datum

**Invariant:** A bounded information object that is presently manifest within one reference entity.

**Inclusion boundary:** Includes only the manifest internal datum as a substrate-neutral information entity at inward scope. The claim is about an information object maintained within one reference entity, not the physical medium, an observer's memory, a reference to another target, or a shared collection. It is neutral about truth, validity, belief, access, observation, transmission, processing, mutation, physical realization, ownership, provenance, probability, timing, and cause.

**Excluded meanings:**

- Truth, falsity, validity, evidential support, assertion, belief, understanding, memory, or certainty concerning the information.
- Creation, mutation, computation, parsing, indexing, querying, copying, transmission, delivery, reception, or deletion of data.
- Physical inscription, storage medium, device, energy, signal carrier, file-system structure, access path, or network topology.
- Sender, recipient, communication act, social ownership, authority, privacy policy, permission, or responsibility.
- Formal rule, proposition role, proof status, evaluation, satisfaction, entailment, consistency, or semantic correctness.
- Accessibility, observability, discoverability, provenance, version, schedule, future activation, possibility, necessity, probability, or cause.

**Address justification:**

- `first_trit_0`: Selects an information entity rather than a data transformation, transmission event, storage/access affordance, or physical medium.
- `second_trit`: Selects inward/self scope: one bounded information object maintained within one reference entity and no other Data-family column.
- `third_trit`: Selects the manifest/presently instantiated member by information-object identity or present manifestation while leaving runtime truth status, access, observation, transmission, tense, probability, and process phase separate.

**Nearest neighbors:** `DAT:000`, `DAT:002`, `DAT:011`, `DAT:021`, `DAT:101`, `DAT:201`

**Same-family boundary:** `DAT:0xx` owns information entities and their persistent, manifest, or dormant status. `DAT:1xx` remains reserved for information transformations or flow processes, and `DAT:2xx` for storage, access, provenance, transmission, or other information affordances and relations. A manifest datum does not entail access, observation, truth, transfer, or processing, and an identified datum does not entail a usable storage or communication relation. The persistent sibling may also hold because it asserts information-object identity across time. Manifest and dormant siblings are mutually exclusive for the same object at the same reference time, while runtime `[2]/num` may leave either selected claim unresolved.

**Runtime-state interpretation:**

- `[0]`: Denies that this internal datum is presently manifest; it does not erase the information object, affirm dormancy, or state whether anyone can access or understand it.
- `[1]`: Affirms that this internal datum is presently manifest in the stated information scope, without asserting truth, access, observation, transmission, storage medium, or use.
- `[2/num]`: Leaves unresolved whether this internal datum is presently manifest; runtime uncertainty does not select persistent identity or lexical dormancy.

**Lexical/runtime distinction:** Lexical third trit `1` permanently selects the manifest/presently instantiated member of this information-entity triplet. Runtime `[2]/num` instead leaves that already-selected assertion unresolved; it never changes manifestation status. Thus a dormant root affirmed with `[1]` is a confirmed maintained-but-unmanifest information object, while a persistent or manifest root carrying `[2]/num` remains lexically persistent or manifest but uncertain as a token claim.

### E. Examples

| Type | Semantic graph | Literal gloss | Natural English | State | Result |
| --- | --- | --- | --- | ---: | --- |
| ordinary_conversation | `DAT:001[1](ENTITY=device,DATUM=d)` | affirm manifest internal datum | That information object is manifest now. | 1 | valid |
| physical_or_spatial | `MAT(MEDIUM=m)+DAT:001[1](ENTITY=device,DATUM=d)` | material medium plus manifest data entity | A mark on the device realizes the datum while MAT separately describes its physical medium. | 1 | valid |
| temporal_or_sequential | `DAT:001[1](ENTITY=device,DATUM=d)+ORI(INTERVAL=w)` | manifest data entity during interval w | During interval w, the information object has the stated lexical status. | 1 | valid |
| cross_family_compound | `LOG(CRITERION=c)+DAT:001[1](ENTITY=device,DATUM=d)` | formal criterion plus manifest data representation | The datum represents a criterion without becoming the formal rule itself. | 1 | valid |
| executable_or_programming | `DAT:001[1](ENTITY=device,DATUM=d)` | assert manifest information-object status | A runtime registers information-object status without asserting transfer, parsing, mutation, or truth. | 1 | valid |
| counterexample | `CON(TRANSFER=d,SOURCE=s,TARGET=t)` | data transmission | The packet is being sent to a recipient. | 1 | must_not_use_this_root |

## DAT:002 — dormant internal datum

### A. Fixed generated forms

- Universal slot: **dormant inward entity**
- Transliteration: **li·nan**
- Local compact root: **nan**
- Formal carrier: **li-ma-ma-nu**
- Harmonic signature: **0–4–7–11**
- Relative note path: **0 → 0 → 0 → -2**

### B. Why the current meaning was probably chosen

The provisional titles use familiar data vocabulary and roughly follow inward scope and dormant status.

### C. Candidate comparison

| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| dormant record | 5 | 7 | 8 | 4 | 4 | 7 | 8 | 7 | **50/80** |
| dormant internal datum | 10 | 10 | 10 | 10 | 10 | 10 | 10 | 10 | **80/80** |
| dormant internal representation | 9 | 8 | 10 | 7 | 8 | 9 | 9 | 10 | **70/80** |
| archived local record | 9 | 8 | 9 | 7 | 7 | 9 | 10 | 10 | **69/80** |
| dormant internal message | 8 | 7 | 7 | 6 | 3 | 9 | 10 | 9 | **59/80** |

#### dormant record

**Invariant candidate:** Information is preserved inwardly but is archived, inaccessible, unread, or not currently loaded.

- Fit: The provisional titles use familiar data vocabulary and roughly follow inward scope and dormant status.
- Useful coverage: They cover records, inputs, messages, signals, datasets, streams, archives, identifiers, and packets.
- Territory consumed: Across the block they mix information entities, storage state, communication processes, data flow, delivery queues, access, indexing, and active updating.
- Conflicts and limitations: The triplets do not preserve one entity center: manifest roots absorb input or flow processes, target roots absorb CON delivery, and dormancy is mixed with inaccessible, queued, unread, and unindexed states.

#### dormant internal datum

**Invariant candidate:** A bounded information object that remains maintained within one reference entity without being presently manifest.

- Fit: The first trit remains an information entity; the second changes only internal containment, reference to one distinct target, or coordinated sharing across participants; the third changes only persistent, manifest, or dormant status.
- Useful coverage: It supports datum, record, value, identifier, reference, pointer, metadata, dataset, corpus, catalogue, and shared state without encoding transmission or computation.
- Territory consumed: Only bounded information-object identity and manifestation at the selected scope. Media, storage mechanics, communication, transformation, access, truth, belief, and formal validity remain separate.
- Conflicts and limitations: Encoding and value-type distinctions remain broad in Era Zero and must be supplied compositionally when exact syntax, schema, provenance, or medium matters.

#### dormant internal representation

**Invariant candidate:** A dormant symbolic representation organized at inward information scope.

- Fit: Symbols and representations are central Data entities and can occur internally, refer to targets, or form shared representational systems.
- Useful coverage: It would cover symbols, tokens, codes, names, labels, icons, formulas, maps, and representational systems.
- Territory consumed: It specializes every datum to an explicitly symbolic representation.
- Conflicts and limitations: Measurements, opaque blobs, sensory traces, and non-symbolic information objects would be under-served, while representational relation details risk LOG, MIN, and STR collisions.

#### archived local record

**Invariant candidate:** A dormant stored record situated at inward information scope.

- Fit: Records naturally persist, become open or loaded, and become archived at internal, target-addressed, or shared scope.
- Useful coverage: It would cover files, rows, documents, logs, archives, databases, indexes, and stored records.
- Territory consumed: It makes durable storage or record structure essential to every Data entity.
- Conflicts and limitations: Signals, ephemeral values, references, and computed data need not be records; physical storage and access also risk MAT and STR collisions.

#### dormant internal message

**Invariant candidate:** A dormant communicative message organized at inward scope.

- Fit: Messages contain information, can remain local, target recipients, or be shared among groups, and can be manifest or dormant.
- Useful coverage: It would cover message, packet, signal, notification, post, broadcast, queue, and inbox item.
- Territory consumed: It makes communicative intent, sender-recipient structure, and delivery context obligatory.
- Conflicts and limitations: CON owns participants, transmission, delivery, and reception, while most data objects are not messages at all.

### D. Recommended permanent semantic specification

**Title:** dormant internal datum

**Invariant:** A bounded information object that remains maintained within one reference entity without being presently manifest.

**Inclusion boundary:** Includes only the dormant internal datum as a substrate-neutral information entity at inward scope. The claim is about an information object maintained within one reference entity, not the physical medium, an observer's memory, a reference to another target, or a shared collection. It is neutral about truth, validity, belief, access, observation, transmission, processing, mutation, physical realization, ownership, provenance, probability, timing, and cause.

**Excluded meanings:**

- Truth, falsity, validity, evidential support, assertion, belief, understanding, memory, or certainty concerning the information.
- Creation, mutation, computation, parsing, indexing, querying, copying, transmission, delivery, reception, or deletion of data.
- Physical inscription, storage medium, device, energy, signal carrier, file-system structure, access path, or network topology.
- Sender, recipient, communication act, social ownership, authority, privacy policy, permission, or responsibility.
- Formal rule, proposition role, proof status, evaluation, satisfaction, entailment, consistency, or semantic correctness.
- Accessibility, observability, discoverability, provenance, version, schedule, future activation, possibility, necessity, probability, or cause.

**Address justification:**

- `first_trit_0`: Selects an information entity rather than a data transformation, transmission event, storage/access affordance, or physical medium.
- `second_trit`: Selects inward/self scope: one bounded information object maintained within one reference entity and no other Data-family column.
- `third_trit`: Selects the dormant/maintained but unmanifest member by information-object identity or present manifestation while leaving runtime truth status, access, observation, transmission, tense, probability, and process phase separate.

**Nearest neighbors:** `DAT:000`, `DAT:001`, `DAT:012`, `DAT:022`, `DAT:102`, `DAT:202`

**Same-family boundary:** `DAT:0xx` owns information entities and their persistent, manifest, or dormant status. `DAT:1xx` remains reserved for information transformations or flow processes, and `DAT:2xx` for storage, access, provenance, transmission, or other information affordances and relations. A manifest datum does not entail access, observation, truth, transfer, or processing, and an identified datum does not entail a usable storage or communication relation. The persistent sibling may also hold because it asserts information-object identity across time. Manifest and dormant siblings are mutually exclusive for the same object at the same reference time, while runtime `[2]/num` may leave either selected claim unresolved.

**Runtime-state interpretation:**

- `[0]`: Denies that this internal datum is presently dormant; it does not by itself affirm current manifestation, deletion, corruption, inaccessibility, or replacement.
- `[1]`: Affirms that this internal datum remains maintained but is not presently manifest, without encoding archive medium, access denial, hiddenness, future activation, uncertainty, or loss.
- `[2/num]`: Leaves unresolved whether the selected dormant internal datum claim holds; lexical third-trit 2 names maintained-but-unmanifest status, while runtime `[2]/num` marks assertion-level uncertainty.

**Lexical/runtime distinction:** Lexical third trit `2` permanently selects the dormant/maintained but unmanifest member of this information-entity triplet. Runtime `[2]/num` instead leaves that already-selected assertion unresolved; it never changes manifestation status. Thus a dormant root affirmed with `[1]` is a confirmed maintained-but-unmanifest information object, while a persistent or manifest root carrying `[2]/num` remains lexically persistent or manifest but uncertain as a token claim.

### E. Examples

| Type | Semantic graph | Literal gloss | Natural English | State | Result |
| --- | --- | --- | --- | ---: | --- |
| ordinary_conversation | `DAT:002[1](ENTITY=device,DATUM=d)` | affirm dormant internal datum | That information object is still maintained, but it is not manifest now. | 1 | valid |
| physical_or_spatial | `MAT(MEDIUM=m)+DAT:002[1](ENTITY=device,DATUM=d)` | material medium plus dormant data entity | A mark on the device realizes the datum while MAT separately describes its physical medium. | 1 | valid |
| temporal_or_sequential | `DAT:002[1](ENTITY=device,DATUM=d)+ORI(INTERVAL=w)` | dormant data entity during interval w | During interval w, the information object has the stated lexical status. | 1 | valid |
| cross_family_compound | `LOG(CRITERION=c)+DAT:002[1](ENTITY=device,DATUM=d)` | formal criterion plus dormant data representation | The datum represents a criterion without becoming the formal rule itself. | 1 | valid |
| executable_or_programming | `DAT:002[1](ENTITY=device,DATUM=d)` | assert dormant information-object status | A runtime registers information-object status without asserting transfer, parsing, mutation, or truth. | 1 | valid |
| counterexample | `CON(TRANSFER=d,SOURCE=s,TARGET=t)` | data transmission | The packet is being sent to a recipient. | 1 | must_not_use_this_root |

## DAT:010 — persistent target reference

### A. Fixed generated forms

- Universal slot: **stable outward entity**
- Transliteration: **li·nom**
- Local compact root: **nom**
- Formal carrier: **li-ma-ki-ma**
- Harmonic signature: **0–4–7–11**
- Relative note path: **0 → 0 → 2 → 2**

### B. Why the current meaning was probably chosen

The provisional titles use familiar data vocabulary and roughly follow outward scope and persistent status.

### C. Candidate comparison

| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| addressed message | 6 | 7 | 8 | 4 | 4 | 7 | 8 | 7 | **51/80** |
| persistent target reference | 10 | 10 | 10 | 10 | 9 | 10 | 10 | 10 | **79/80** |
| persistent target symbol | 9 | 6 | 10 | 8 | 8 | 9 | 9 | 10 | **69/80** |
| persistent addressed record | 9 | 8 | 9 | 7 | 5 | 9 | 10 | 10 | **67/80** |
| persistent outbound message | 8 | 7 | 7 | 6 | 5 | 9 | 10 | 9 | **61/80** |

#### addressed message

**Invariant candidate:** A stable external message, reference, packet, or record is identified as a target.

- Fit: The provisional titles use familiar data vocabulary and roughly follow outward scope and persistent status.
- Useful coverage: They cover records, inputs, messages, signals, datasets, streams, archives, identifiers, and packets.
- Territory consumed: Across the block they mix information entities, storage state, communication processes, data flow, delivery queues, access, indexing, and active updating.
- Conflicts and limitations: The triplets do not preserve one entity center: manifest roots absorb input or flow processes, target roots absorb CON delivery, and dormancy is mixed with inaccessible, queued, unread, and unindexed states.

#### persistent target reference

**Invariant candidate:** A persistent bounded information object whose content denotes one distinct reference target, independently of whether that referential content is presently manifest.

- Fit: The first trit remains an information entity; the second changes only internal containment, reference to one distinct target, or coordinated sharing across participants; the third changes only persistent, manifest, or dormant status.
- Useful coverage: It supports datum, record, value, identifier, reference, pointer, metadata, dataset, corpus, catalogue, and shared state without encoding transmission or computation.
- Territory consumed: Only bounded information-object identity and manifestation at the selected scope. Media, storage mechanics, communication, transformation, access, truth, belief, and formal validity remain separate.
- Conflicts and limitations: Encoding and value-type distinctions remain broad in Era Zero and must be supplied compositionally when exact syntax, schema, provenance, or medium matters.

#### persistent target symbol

**Invariant candidate:** A persistent symbolic representation organized at outward information scope.

- Fit: Symbols and representations are central Data entities and can occur internally, refer to targets, or form shared representational systems.
- Useful coverage: It would cover symbols, tokens, codes, names, labels, icons, formulas, maps, and representational systems.
- Territory consumed: It specializes every datum to an explicitly symbolic representation.
- Conflicts and limitations: Measurements, opaque blobs, sensory traces, and non-symbolic information objects would be under-served, while representational relation details risk LOG, MIN, and STR collisions.

#### persistent addressed record

**Invariant candidate:** A persistent stored record situated at outward information scope.

- Fit: Records naturally persist, become open or loaded, and become archived at internal, target-addressed, or shared scope.
- Useful coverage: It would cover files, rows, documents, logs, archives, databases, indexes, and stored records.
- Territory consumed: It makes durable storage or record structure essential to every Data entity.
- Conflicts and limitations: Signals, ephemeral values, references, and computed data need not be records; physical storage and access also risk MAT and STR collisions.

#### persistent outbound message

**Invariant candidate:** A persistent communicative message organized at outward scope.

- Fit: Messages contain information, can remain local, target recipients, or be shared among groups, and can be manifest or dormant.
- Useful coverage: It would cover message, packet, signal, notification, post, broadcast, queue, and inbox item.
- Territory consumed: It makes communicative intent, sender-recipient structure, and delivery context obligatory.
- Conflicts and limitations: CON owns participants, transmission, delivery, and reception, while most data objects are not messages at all.

### D. Recommended permanent semantic specification

**Title:** persistent target reference

**Invariant:** A persistent bounded information object whose content denotes one distinct reference target, independently of whether that referential content is presently manifest.

**Inclusion boundary:** Includes only the persistent target-referential datum as a substrate-neutral information entity at outward scope. The claim preserves one distinct referent of the datum. Sender, recipient, transmission, delivery, access, truth, and the target entity itself remain separate. It is neutral about truth, validity, belief, access, observation, transmission, processing, mutation, physical realization, ownership, provenance, probability, timing, and cause.

**Excluded meanings:**

- Truth, falsity, validity, evidential support, assertion, belief, understanding, memory, or certainty concerning the information.
- Creation, mutation, computation, parsing, indexing, querying, copying, transmission, delivery, reception, or deletion of data.
- Physical inscription, storage medium, device, energy, signal carrier, file-system structure, access path, or network topology.
- Sender, recipient, communication act, social ownership, authority, privacy policy, permission, or responsibility.
- Formal rule, proposition role, proof status, evaluation, satisfaction, entailment, consistency, or semantic correctness.
- Accessibility, observability, discoverability, provenance, version, schedule, future activation, possibility, necessity, probability, or cause.

**Address justification:**

- `first_trit_0`: Selects an information entity rather than a data transformation, transmission event, storage/access affordance, or physical medium.
- `second_trit`: Selects outward/target scope: one bounded information object whose content denotes one distinct reference target and no other Data-family column.
- `third_trit`: Selects the persistent/manifestation-neutral member by information-object identity or present manifestation while leaving runtime truth status, access, observation, transmission, tense, probability, and process phase separate.

**Nearest neighbors:** `DAT:011`, `DAT:012`, `DAT:000`, `DAT:020`, `DAT:110`, `DAT:210`

**Same-family boundary:** `DAT:0xx` owns information entities and their persistent, manifest, or dormant status. `DAT:1xx` remains reserved for information transformations or flow processes, and `DAT:2xx` for storage, access, provenance, transmission, or other information affordances and relations. A manifest datum does not entail access, observation, truth, transfer, or processing, and an identified datum does not entail a usable storage or communication relation. The persistent member is manifestation-neutral: it may co-occur with the manifest sibling or the dormant sibling at the same reference time. It asserts continuity of information-object identity rather than a third mutually exclusive manifestation value.

**Runtime-state interpretation:**

- `[0]`: Denies that this target-referential datum persists as the same identified information object; it does not select the manifest or dormant sibling and does not erase every related datum.
- `[1]`: Affirms the persistent identity of this target-referential datum while leaving current manifestation, accessibility, truth, encoding, medium, and provenance undecided.
- `[2/num]`: Leaves unresolved whether this persistent target-referential datum remains identified; uncertainty about the assertion does not change the lexical root into a manifest or dormant datum.

**Lexical/runtime distinction:** Lexical third trit `0` permanently selects the persistent/manifestation-neutral member of this information-entity triplet. Runtime `[2]/num` instead leaves that already-selected assertion unresolved; it never changes manifestation status. Thus a dormant root affirmed with `[1]` is a confirmed maintained-but-unmanifest information object, while a persistent or manifest root carrying `[2]/num` remains lexically persistent or manifest but uncertain as a token claim.

### E. Examples

| Type | Semantic graph | Literal gloss | Natural English | State | Result |
| --- | --- | --- | --- | ---: | --- |
| ordinary_conversation | `DAT:010[1](DATUM=d,REFERENT=record)` | affirm persistent target-referential datum | That information object remains identified whether or not it is visible now. | 1 | valid |
| physical_or_spatial | `MAT(MEDIUM=m)+DAT:010[1](DATUM=d,REFERENT=record)` | material medium plus persistent data entity | A mark on the device realizes the datum while MAT separately describes its physical medium. | 1 | valid |
| temporal_or_sequential | `DAT:010[1](DATUM=d,REFERENT=record)+ORI(INTERVAL=w)` | persistent data entity during interval w | During interval w, the information object has the stated lexical status. | 1 | valid |
| cross_family_compound | `LOG(CRITERION=c)+DAT:010[1](DATUM=d,REFERENT=record)` | formal criterion plus persistent data representation | The datum represents a criterion without becoming the formal rule itself. | 1 | valid |
| executable_or_programming | `DAT:010[1](DATUM=d,REFERENT=record)` | assert persistent information-object status | A runtime registers information-object status without asserting transfer, parsing, mutation, or truth. | 1 | valid |
| counterexample | `CON(TRANSFER=d,SOURCE=s,TARGET=t)` | data transmission | The packet is being sent to a recipient. | 1 | must_not_use_this_root |

## DAT:011 — manifest target reference

### A. Fixed generated forms

- Universal slot: **active outward entity**
- Transliteration: **li·nok**
- Local compact root: **nok**
- Formal carrier: **li-ma-ki-ki**
- Harmonic signature: **0–4–7–11**
- Relative note path: **0 → 0 → 2 → 4**

### B. Why the current meaning was probably chosen

The provisional titles use familiar data vocabulary and roughly follow outward scope and manifest status.

### C. Candidate comparison

| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| live signal | 5 | 7 | 8 | 4 | 4 | 7 | 8 | 7 | **50/80** |
| manifest target reference | 10 | 10 | 10 | 10 | 9 | 10 | 10 | 10 | **79/80** |
| manifest target symbol | 9 | 6 | 10 | 8 | 8 | 9 | 9 | 10 | **69/80** |
| open addressed record | 9 | 8 | 9 | 7 | 5 | 9 | 10 | 10 | **67/80** |
| manifest outbound message | 7 | 7 | 7 | 6 | 5 | 9 | 10 | 9 | **60/80** |

#### live signal

**Invariant candidate:** An external signal or message is presently arriving, changing, or available for reception.

- Fit: The provisional titles use familiar data vocabulary and roughly follow outward scope and manifest status.
- Useful coverage: They cover records, inputs, messages, signals, datasets, streams, archives, identifiers, and packets.
- Territory consumed: Across the block they mix information entities, storage state, communication processes, data flow, delivery queues, access, indexing, and active updating.
- Conflicts and limitations: The triplets do not preserve one entity center: manifest roots absorb input or flow processes, target roots absorb CON delivery, and dormancy is mixed with inaccessible, queued, unread, and unindexed states.

#### manifest target reference

**Invariant candidate:** A bounded information object whose content presently manifests a reference to one distinct reference target.

- Fit: The first trit remains an information entity; the second changes only internal containment, reference to one distinct target, or coordinated sharing across participants; the third changes only persistent, manifest, or dormant status.
- Useful coverage: It supports datum, record, value, identifier, reference, pointer, metadata, dataset, corpus, catalogue, and shared state without encoding transmission or computation.
- Territory consumed: Only bounded information-object identity and manifestation at the selected scope. Media, storage mechanics, communication, transformation, access, truth, belief, and formal validity remain separate.
- Conflicts and limitations: Encoding and value-type distinctions remain broad in Era Zero and must be supplied compositionally when exact syntax, schema, provenance, or medium matters.

#### manifest target symbol

**Invariant candidate:** A manifest symbolic representation organized at outward information scope.

- Fit: Symbols and representations are central Data entities and can occur internally, refer to targets, or form shared representational systems.
- Useful coverage: It would cover symbols, tokens, codes, names, labels, icons, formulas, maps, and representational systems.
- Territory consumed: It specializes every datum to an explicitly symbolic representation.
- Conflicts and limitations: Measurements, opaque blobs, sensory traces, and non-symbolic information objects would be under-served, while representational relation details risk LOG, MIN, and STR collisions.

#### open addressed record

**Invariant candidate:** A manifest stored record situated at outward information scope.

- Fit: Records naturally persist, become open or loaded, and become archived at internal, target-addressed, or shared scope.
- Useful coverage: It would cover files, rows, documents, logs, archives, databases, indexes, and stored records.
- Territory consumed: It makes durable storage or record structure essential to every Data entity.
- Conflicts and limitations: Signals, ephemeral values, references, and computed data need not be records; physical storage and access also risk MAT and STR collisions.

#### manifest outbound message

**Invariant candidate:** A manifest communicative message organized at outward scope.

- Fit: Messages contain information, can remain local, target recipients, or be shared among groups, and can be manifest or dormant.
- Useful coverage: It would cover message, packet, signal, notification, post, broadcast, queue, and inbox item.
- Territory consumed: It makes communicative intent, sender-recipient structure, and delivery context obligatory.
- Conflicts and limitations: CON owns participants, transmission, delivery, and reception, while most data objects are not messages at all.

### D. Recommended permanent semantic specification

**Title:** manifest target reference

**Invariant:** A bounded information object whose content presently manifests a reference to one distinct reference target.

**Inclusion boundary:** Includes only the manifest target-referential datum as a substrate-neutral information entity at outward scope. The claim preserves one distinct referent of the datum. Sender, recipient, transmission, delivery, access, truth, and the target entity itself remain separate. It is neutral about truth, validity, belief, access, observation, transmission, processing, mutation, physical realization, ownership, provenance, probability, timing, and cause.

**Excluded meanings:**

- Truth, falsity, validity, evidential support, assertion, belief, understanding, memory, or certainty concerning the information.
- Creation, mutation, computation, parsing, indexing, querying, copying, transmission, delivery, reception, or deletion of data.
- Physical inscription, storage medium, device, energy, signal carrier, file-system structure, access path, or network topology.
- Sender, recipient, communication act, social ownership, authority, privacy policy, permission, or responsibility.
- Formal rule, proposition role, proof status, evaluation, satisfaction, entailment, consistency, or semantic correctness.
- Accessibility, observability, discoverability, provenance, version, schedule, future activation, possibility, necessity, probability, or cause.

**Address justification:**

- `first_trit_0`: Selects an information entity rather than a data transformation, transmission event, storage/access affordance, or physical medium.
- `second_trit`: Selects outward/target scope: one bounded information object whose content denotes one distinct reference target and no other Data-family column.
- `third_trit`: Selects the manifest/presently instantiated member by information-object identity or present manifestation while leaving runtime truth status, access, observation, transmission, tense, probability, and process phase separate.

**Nearest neighbors:** `DAT:010`, `DAT:012`, `DAT:001`, `DAT:021`, `DAT:111`, `DAT:211`

**Same-family boundary:** `DAT:0xx` owns information entities and their persistent, manifest, or dormant status. `DAT:1xx` remains reserved for information transformations or flow processes, and `DAT:2xx` for storage, access, provenance, transmission, or other information affordances and relations. A manifest datum does not entail access, observation, truth, transfer, or processing, and an identified datum does not entail a usable storage or communication relation. The persistent sibling may also hold because it asserts information-object identity across time. Manifest and dormant siblings are mutually exclusive for the same object at the same reference time, while runtime `[2]/num` may leave either selected claim unresolved.

**Runtime-state interpretation:**

- `[0]`: Denies that this target-referential datum is presently manifest; it does not erase the information object, affirm dormancy, or state whether anyone can access or understand it.
- `[1]`: Affirms that this target-referential datum is presently manifest in the stated information scope, without asserting truth, access, observation, transmission, storage medium, or use.
- `[2/num]`: Leaves unresolved whether this target-referential datum is presently manifest; runtime uncertainty does not select persistent identity or lexical dormancy.

**Lexical/runtime distinction:** Lexical third trit `1` permanently selects the manifest/presently instantiated member of this information-entity triplet. Runtime `[2]/num` instead leaves that already-selected assertion unresolved; it never changes manifestation status. Thus a dormant root affirmed with `[1]` is a confirmed maintained-but-unmanifest information object, while a persistent or manifest root carrying `[2]/num` remains lexically persistent or manifest but uncertain as a token claim.

### E. Examples

| Type | Semantic graph | Literal gloss | Natural English | State | Result |
| --- | --- | --- | --- | ---: | --- |
| ordinary_conversation | `DAT:011[1](DATUM=d,REFERENT=record)` | affirm manifest target-referential datum | That information object is manifest now. | 1 | valid |
| physical_or_spatial | `MAT(MEDIUM=m)+DAT:011[1](DATUM=d,REFERENT=record)` | material medium plus manifest data entity | A mark on the device realizes the datum while MAT separately describes its physical medium. | 1 | valid |
| temporal_or_sequential | `DAT:011[1](DATUM=d,REFERENT=record)+ORI(INTERVAL=w)` | manifest data entity during interval w | During interval w, the information object has the stated lexical status. | 1 | valid |
| cross_family_compound | `LOG(CRITERION=c)+DAT:011[1](DATUM=d,REFERENT=record)` | formal criterion plus manifest data representation | The datum represents a criterion without becoming the formal rule itself. | 1 | valid |
| executable_or_programming | `DAT:011[1](DATUM=d,REFERENT=record)` | assert manifest information-object status | A runtime registers information-object status without asserting transfer, parsing, mutation, or truth. | 1 | valid |
| counterexample | `CON(TRANSFER=d,SOURCE=s,TARGET=t)` | data transmission | The packet is being sent to a recipient. | 1 | must_not_use_this_root |

## DAT:012 — dormant target reference

### A. Fixed generated forms

- Universal slot: **dormant outward entity**
- Transliteration: **li·non**
- Local compact root: **non**
- Formal carrier: **li-ma-ki-nu**
- Harmonic signature: **0–4–7–11**
- Relative note path: **0 → 0 → 2 → 0**

### B. Why the current meaning was probably chosen

The provisional titles use familiar data vocabulary and roughly follow outward scope and dormant status.

### C. Candidate comparison

| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| queued message | 5 | 7 | 8 | 4 | 4 | 7 | 8 | 7 | **50/80** |
| dormant target reference | 10 | 10 | 10 | 10 | 9 | 10 | 10 | 10 | **79/80** |
| dormant target symbol | 9 | 6 | 10 | 7 | 8 | 9 | 9 | 10 | **68/80** |
| archived addressed record | 9 | 8 | 9 | 7 | 5 | 9 | 10 | 10 | **67/80** |
| queued outbound message | 8 | 7 | 7 | 6 | 5 | 9 | 10 | 9 | **61/80** |

#### queued message

**Invariant candidate:** A message or data object is defined for a target but has not been delivered or made accessible.

- Fit: The provisional titles use familiar data vocabulary and roughly follow outward scope and dormant status.
- Useful coverage: They cover records, inputs, messages, signals, datasets, streams, archives, identifiers, and packets.
- Territory consumed: Across the block they mix information entities, storage state, communication processes, data flow, delivery queues, access, indexing, and active updating.
- Conflicts and limitations: The triplets do not preserve one entity center: manifest roots absorb input or flow processes, target roots absorb CON delivery, and dormancy is mixed with inaccessible, queued, unread, and unindexed states.

#### dormant target reference

**Invariant candidate:** A bounded information object whose content denotes one distinct reference target without presently manifesting that reference.

- Fit: The first trit remains an information entity; the second changes only internal containment, reference to one distinct target, or coordinated sharing across participants; the third changes only persistent, manifest, or dormant status.
- Useful coverage: It supports datum, record, value, identifier, reference, pointer, metadata, dataset, corpus, catalogue, and shared state without encoding transmission or computation.
- Territory consumed: Only bounded information-object identity and manifestation at the selected scope. Media, storage mechanics, communication, transformation, access, truth, belief, and formal validity remain separate.
- Conflicts and limitations: Encoding and value-type distinctions remain broad in Era Zero and must be supplied compositionally when exact syntax, schema, provenance, or medium matters.

#### dormant target symbol

**Invariant candidate:** A dormant symbolic representation organized at outward information scope.

- Fit: Symbols and representations are central Data entities and can occur internally, refer to targets, or form shared representational systems.
- Useful coverage: It would cover symbols, tokens, codes, names, labels, icons, formulas, maps, and representational systems.
- Territory consumed: It specializes every datum to an explicitly symbolic representation.
- Conflicts and limitations: Measurements, opaque blobs, sensory traces, and non-symbolic information objects would be under-served, while representational relation details risk LOG, MIN, and STR collisions.

#### archived addressed record

**Invariant candidate:** A dormant stored record situated at outward information scope.

- Fit: Records naturally persist, become open or loaded, and become archived at internal, target-addressed, or shared scope.
- Useful coverage: It would cover files, rows, documents, logs, archives, databases, indexes, and stored records.
- Territory consumed: It makes durable storage or record structure essential to every Data entity.
- Conflicts and limitations: Signals, ephemeral values, references, and computed data need not be records; physical storage and access also risk MAT and STR collisions.

#### queued outbound message

**Invariant candidate:** A dormant communicative message organized at outward scope.

- Fit: Messages contain information, can remain local, target recipients, or be shared among groups, and can be manifest or dormant.
- Useful coverage: It would cover message, packet, signal, notification, post, broadcast, queue, and inbox item.
- Territory consumed: It makes communicative intent, sender-recipient structure, and delivery context obligatory.
- Conflicts and limitations: CON owns participants, transmission, delivery, and reception, while most data objects are not messages at all.

### D. Recommended permanent semantic specification

**Title:** dormant target reference

**Invariant:** A bounded information object whose content denotes one distinct reference target without presently manifesting that reference.

**Inclusion boundary:** Includes only the dormant target-referential datum as a substrate-neutral information entity at outward scope. The claim preserves one distinct referent of the datum. Sender, recipient, transmission, delivery, access, truth, and the target entity itself remain separate. It is neutral about truth, validity, belief, access, observation, transmission, processing, mutation, physical realization, ownership, provenance, probability, timing, and cause.

**Excluded meanings:**

- Truth, falsity, validity, evidential support, assertion, belief, understanding, memory, or certainty concerning the information.
- Creation, mutation, computation, parsing, indexing, querying, copying, transmission, delivery, reception, or deletion of data.
- Physical inscription, storage medium, device, energy, signal carrier, file-system structure, access path, or network topology.
- Sender, recipient, communication act, social ownership, authority, privacy policy, permission, or responsibility.
- Formal rule, proposition role, proof status, evaluation, satisfaction, entailment, consistency, or semantic correctness.
- Accessibility, observability, discoverability, provenance, version, schedule, future activation, possibility, necessity, probability, or cause.

**Address justification:**

- `first_trit_0`: Selects an information entity rather than a data transformation, transmission event, storage/access affordance, or physical medium.
- `second_trit`: Selects outward/target scope: one bounded information object whose content denotes one distinct reference target and no other Data-family column.
- `third_trit`: Selects the dormant/maintained but unmanifest member by information-object identity or present manifestation while leaving runtime truth status, access, observation, transmission, tense, probability, and process phase separate.

**Nearest neighbors:** `DAT:010`, `DAT:011`, `DAT:002`, `DAT:022`, `DAT:112`, `DAT:212`

**Same-family boundary:** `DAT:0xx` owns information entities and their persistent, manifest, or dormant status. `DAT:1xx` remains reserved for information transformations or flow processes, and `DAT:2xx` for storage, access, provenance, transmission, or other information affordances and relations. A manifest datum does not entail access, observation, truth, transfer, or processing, and an identified datum does not entail a usable storage or communication relation. The persistent sibling may also hold because it asserts information-object identity across time. Manifest and dormant siblings are mutually exclusive for the same object at the same reference time, while runtime `[2]/num` may leave either selected claim unresolved.

**Runtime-state interpretation:**

- `[0]`: Denies that this target-referential datum is presently dormant; it does not by itself affirm current manifestation, deletion, corruption, inaccessibility, or replacement.
- `[1]`: Affirms that this target-referential datum remains maintained but is not presently manifest, without encoding archive medium, access denial, hiddenness, future activation, uncertainty, or loss.
- `[2/num]`: Leaves unresolved whether the selected dormant target-referential datum claim holds; lexical third-trit 2 names maintained-but-unmanifest status, while runtime `[2]/num` marks assertion-level uncertainty.

**Lexical/runtime distinction:** Lexical third trit `2` permanently selects the dormant/maintained but unmanifest member of this information-entity triplet. Runtime `[2]/num` instead leaves that already-selected assertion unresolved; it never changes manifestation status. Thus a dormant root affirmed with `[1]` is a confirmed maintained-but-unmanifest information object, while a persistent or manifest root carrying `[2]/num` remains lexically persistent or manifest but uncertain as a token claim.

### E. Examples

| Type | Semantic graph | Literal gloss | Natural English | State | Result |
| --- | --- | --- | --- | ---: | --- |
| ordinary_conversation | `DAT:012[1](DATUM=d,REFERENT=record)` | affirm dormant target-referential datum | That information object is still maintained, but it is not manifest now. | 1 | valid |
| physical_or_spatial | `MAT(MEDIUM=m)+DAT:012[1](DATUM=d,REFERENT=record)` | material medium plus dormant data entity | A mark on the device realizes the datum while MAT separately describes its physical medium. | 1 | valid |
| temporal_or_sequential | `DAT:012[1](DATUM=d,REFERENT=record)+ORI(INTERVAL=w)` | dormant data entity during interval w | During interval w, the information object has the stated lexical status. | 1 | valid |
| cross_family_compound | `LOG(CRITERION=c)+DAT:012[1](DATUM=d,REFERENT=record)` | formal criterion plus dormant data representation | The datum represents a criterion without becoming the formal rule itself. | 1 | valid |
| executable_or_programming | `DAT:012[1](DATUM=d,REFERENT=record)` | assert dormant information-object status | A runtime registers information-object status without asserting transfer, parsing, mutation, or truth. | 1 | valid |
| counterexample | `CON(TRANSFER=d,SOURCE=s,TARGET=t)` | data transmission | The packet is being sent to a recipient. | 1 | must_not_use_this_root |

## DAT:020 — persistent shared dataset

### A. Fixed generated forms

- Universal slot: **stable collective entity**
- Transliteration: **li·nim**
- Local compact root: **nim**
- Formal carrier: **li-ma-nu-ma**
- Harmonic signature: **0–4–7–11**
- Relative note path: **0 → 0 → -2 → -2**

### B. Why the current meaning was probably chosen

The provisional titles use familiar data vocabulary and roughly follow systemic scope and persistent status.

### C. Candidate comparison

| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| dataset | 6 | 7 | 8 | 2 | 4 | 7 | 8 | 7 | **49/80** |
| persistent shared dataset | 10 | 10 | 10 | 10 | 9 | 10 | 9 | 10 | **78/80** |
| persistent shared representation system | 9 | 8 | 10 | 8 | 8 | 9 | 9 | 10 | **71/80** |
| persistent shared archive | 9 | 8 | 8 | 7 | 7 | 9 | 10 | 10 | **68/80** |
| persistent message collection | 8 | 7 | 7 | 6 | 5 | 9 | 10 | 9 | **61/80** |

#### dataset

**Invariant candidate:** A stable shared collection of records, symbols, mappings, or messages forms one information system.

- Fit: The provisional titles use familiar data vocabulary and roughly follow systemic scope and persistent status.
- Useful coverage: They cover records, inputs, messages, signals, datasets, streams, archives, identifiers, and packets.
- Territory consumed: Across the block they mix information entities, storage state, communication processes, data flow, delivery queues, access, indexing, and active updating.
- Conflicts and limitations: The triplets do not preserve one entity center: manifest roots absorb input or flow processes, target roots absorb CON delivery, and dormancy is mixed with inaccessible, queued, unread, and unindexed states.

#### persistent shared dataset

**Invariant candidate:** A persistent coordinated collection of information objects maintained as one shared dataset across multiple participants in one information domain, independently of whether that dataset is presently manifest.

- Fit: The first trit remains an information entity; the second changes only internal containment, reference to one distinct target, or coordinated sharing across participants; the third changes only persistent, manifest, or dormant status.
- Useful coverage: It supports datum, record, value, identifier, reference, pointer, metadata, dataset, corpus, catalogue, and shared state without encoding transmission or computation.
- Territory consumed: Only bounded information-object identity and manifestation at the selected scope. Media, storage mechanics, communication, transformation, access, truth, belief, and formal validity remain separate.
- Conflicts and limitations: Encoding and value-type distinctions remain broad in Era Zero and must be supplied compositionally when exact syntax, schema, provenance, or medium matters.

#### persistent shared representation system

**Invariant candidate:** A persistent symbolic representation organized at systemic information scope.

- Fit: Symbols and representations are central Data entities and can occur internally, refer to targets, or form shared representational systems.
- Useful coverage: It would cover symbols, tokens, codes, names, labels, icons, formulas, maps, and representational systems.
- Territory consumed: It specializes every datum to an explicitly symbolic representation.
- Conflicts and limitations: Measurements, opaque blobs, sensory traces, and non-symbolic information objects would be under-served, while representational relation details risk LOG, MIN, and STR collisions.

#### persistent shared archive

**Invariant candidate:** A persistent stored record situated at systemic information scope.

- Fit: Records naturally persist, become open or loaded, and become archived at internal, target-addressed, or shared scope.
- Useful coverage: It would cover files, rows, documents, logs, archives, databases, indexes, and stored records.
- Territory consumed: It makes durable storage or record structure essential to every Data entity.
- Conflicts and limitations: Signals, ephemeral values, references, and computed data need not be records; physical storage and access also risk MAT and STR collisions.

#### persistent message collection

**Invariant candidate:** A persistent communicative message organized at systemic scope.

- Fit: Messages contain information, can remain local, target recipients, or be shared among groups, and can be manifest or dormant.
- Useful coverage: It would cover message, packet, signal, notification, post, broadcast, queue, and inbox item.
- Territory consumed: It makes communicative intent, sender-recipient structure, and delivery context obligatory.
- Conflicts and limitations: CON owns participants, transmission, delivery, and reception, while most data objects are not messages at all.

### D. Recommended permanent semantic specification

**Title:** persistent shared dataset

**Invariant:** A persistent coordinated collection of information objects maintained as one shared dataset across multiple participants in one information domain, independently of whether that dataset is presently manifest.

**Inclusion boundary:** Includes only the persistent shared dataset as a substrate-neutral information entity at systemic scope. The claim requires one coordinated information collection shared across multiple participants. A coincidental set of unrelated data objects is not one systemic dataset, and storage or communication topology remains separate. It is neutral about truth, validity, belief, access, observation, transmission, processing, mutation, physical realization, ownership, provenance, probability, timing, and cause.

**Excluded meanings:**

- Truth, falsity, validity, evidential support, assertion, belief, understanding, memory, or certainty concerning the information.
- Creation, mutation, computation, parsing, indexing, querying, copying, transmission, delivery, reception, or deletion of data.
- Physical inscription, storage medium, device, energy, signal carrier, file-system structure, access path, or network topology.
- Sender, recipient, communication act, social ownership, authority, privacy policy, permission, or responsibility.
- Formal rule, proposition role, proof status, evaluation, satisfaction, entailment, consistency, or semantic correctness.
- Accessibility, observability, discoverability, provenance, version, schedule, future activation, possibility, necessity, probability, or cause.

**Address justification:**

- `first_trit_0`: Selects an information entity rather than a data transformation, transmission event, storage/access affordance, or physical medium.
- `second_trit`: Selects systemic/collective scope: one coordinated collection maintained as a shared dataset across multiple participants in one information domain and no other Data-family column.
- `third_trit`: Selects the persistent/manifestation-neutral member by information-object identity or present manifestation while leaving runtime truth status, access, observation, transmission, tense, probability, and process phase separate.

**Nearest neighbors:** `DAT:021`, `DAT:022`, `DAT:000`, `DAT:010`, `DAT:120`, `DAT:220`

**Same-family boundary:** `DAT:0xx` owns information entities and their persistent, manifest, or dormant status. `DAT:1xx` remains reserved for information transformations or flow processes, and `DAT:2xx` for storage, access, provenance, transmission, or other information affordances and relations. A manifest datum does not entail access, observation, truth, transfer, or processing, and an identified datum does not entail a usable storage or communication relation. The persistent member is manifestation-neutral: it may co-occur with the manifest sibling or the dormant sibling at the same reference time. It asserts continuity of information-object identity rather than a third mutually exclusive manifestation value.

**Runtime-state interpretation:**

- `[0]`: Denies that this shared dataset persists as the same identified information object; it does not select the manifest or dormant sibling and does not erase every related datum.
- `[1]`: Affirms the persistent identity of this shared dataset while leaving current manifestation, accessibility, truth, encoding, medium, and provenance undecided.
- `[2/num]`: Leaves unresolved whether this persistent shared dataset remains identified; uncertainty about the assertion does not change the lexical root into a manifest or dormant datum.

**Lexical/runtime distinction:** Lexical third trit `0` permanently selects the persistent/manifestation-neutral member of this information-entity triplet. Runtime `[2]/num` instead leaves that already-selected assertion unresolved; it never changes manifestation status. Thus a dormant root affirmed with `[1]` is a confirmed maintained-but-unmanifest information object, while a persistent or manifest root carrying `[2]/num` remains lexically persistent or manifest but uncertain as a token claim.

### E. Examples

| Type | Semantic graph | Literal gloss | Natural English | State | Result |
| --- | --- | --- | --- | ---: | --- |
| ordinary_conversation | `DAT:020[1](DOMAIN=workspace,PARTICIPANTS={a,b,c},DATASET=d)` | affirm persistent shared dataset | That information object remains identified whether or not it is visible now. | 1 | valid |
| physical_or_spatial | `MAT(MEDIUM=m)+DAT:020[1](DOMAIN=workspace,PARTICIPANTS={a,b,c},DATASET=d)` | material medium plus persistent data entity | A mark on the device realizes the datum while MAT separately describes its physical medium. | 1 | valid |
| temporal_or_sequential | `DAT:020[1](DOMAIN=workspace,PARTICIPANTS={a,b,c},DATASET=d)+ORI(INTERVAL=w)` | persistent data entity during interval w | During interval w, the information object has the stated lexical status. | 1 | valid |
| cross_family_compound | `LOG(CRITERION=c)+DAT:020[1](DOMAIN=workspace,PARTICIPANTS={a,b,c},DATASET=d)` | formal criterion plus persistent data representation | The datum represents a criterion without becoming the formal rule itself. | 1 | valid |
| executable_or_programming | `DAT:020[1](DOMAIN=workspace,PARTICIPANTS={a,b,c},DATASET=d)` | assert persistent information-object status | A runtime registers information-object status without asserting transfer, parsing, mutation, or truth. | 1 | valid |
| counterexample | `CON(TRANSFER=d,SOURCE=s,TARGET=t)` | data transmission | The packet is being sent to a recipient. | 1 | must_not_use_this_root |

## DAT:021 — manifest shared dataset

### A. Fixed generated forms

- Universal slot: **active collective entity**
- Transliteration: **li·nik**
- Local compact root: **nik**
- Formal carrier: **li-ma-nu-ki**
- Harmonic signature: **0–4–7–11**
- Relative note path: **0 → 0 → -2 → 0**

### B. Why the current meaning was probably chosen

The provisional titles use familiar data vocabulary and roughly follow systemic scope and manifest status.

### C. Candidate comparison

| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| data stream | 5 | 7 | 8 | 2 | 4 | 7 | 8 | 7 | **48/80** |
| manifest shared dataset | 10 | 10 | 10 | 10 | 9 | 10 | 9 | 10 | **78/80** |
| manifest shared representation system | 9 | 8 | 10 | 8 | 8 | 9 | 9 | 10 | **71/80** |
| open shared archive | 9 | 8 | 8 | 7 | 7 | 9 | 10 | 10 | **68/80** |
| manifest message collection | 7 | 7 | 7 | 6 | 5 | 9 | 10 | 9 | **60/80** |

#### data stream

**Invariant candidate:** Information is actively flowing, updating, or being replicated across a shared system.

- Fit: The provisional titles use familiar data vocabulary and roughly follow systemic scope and manifest status.
- Useful coverage: They cover records, inputs, messages, signals, datasets, streams, archives, identifiers, and packets.
- Territory consumed: Across the block they mix information entities, storage state, communication processes, data flow, delivery queues, access, indexing, and active updating.
- Conflicts and limitations: The triplets do not preserve one entity center: manifest roots absorb input or flow processes, target roots absorb CON delivery, and dormancy is mixed with inaccessible, queued, unread, and unindexed states.

#### manifest shared dataset

**Invariant candidate:** A coordinated collection of information objects that is presently manifest as one shared dataset across multiple participants in one information domain.

- Fit: The first trit remains an information entity; the second changes only internal containment, reference to one distinct target, or coordinated sharing across participants; the third changes only persistent, manifest, or dormant status.
- Useful coverage: It supports datum, record, value, identifier, reference, pointer, metadata, dataset, corpus, catalogue, and shared state without encoding transmission or computation.
- Territory consumed: Only bounded information-object identity and manifestation at the selected scope. Media, storage mechanics, communication, transformation, access, truth, belief, and formal validity remain separate.
- Conflicts and limitations: Encoding and value-type distinctions remain broad in Era Zero and must be supplied compositionally when exact syntax, schema, provenance, or medium matters.

#### manifest shared representation system

**Invariant candidate:** A manifest symbolic representation organized at systemic information scope.

- Fit: Symbols and representations are central Data entities and can occur internally, refer to targets, or form shared representational systems.
- Useful coverage: It would cover symbols, tokens, codes, names, labels, icons, formulas, maps, and representational systems.
- Territory consumed: It specializes every datum to an explicitly symbolic representation.
- Conflicts and limitations: Measurements, opaque blobs, sensory traces, and non-symbolic information objects would be under-served, while representational relation details risk LOG, MIN, and STR collisions.

#### open shared archive

**Invariant candidate:** A manifest stored record situated at systemic information scope.

- Fit: Records naturally persist, become open or loaded, and become archived at internal, target-addressed, or shared scope.
- Useful coverage: It would cover files, rows, documents, logs, archives, databases, indexes, and stored records.
- Territory consumed: It makes durable storage or record structure essential to every Data entity.
- Conflicts and limitations: Signals, ephemeral values, references, and computed data need not be records; physical storage and access also risk MAT and STR collisions.

#### manifest message collection

**Invariant candidate:** A manifest communicative message organized at systemic scope.

- Fit: Messages contain information, can remain local, target recipients, or be shared among groups, and can be manifest or dormant.
- Useful coverage: It would cover message, packet, signal, notification, post, broadcast, queue, and inbox item.
- Territory consumed: It makes communicative intent, sender-recipient structure, and delivery context obligatory.
- Conflicts and limitations: CON owns participants, transmission, delivery, and reception, while most data objects are not messages at all.

### D. Recommended permanent semantic specification

**Title:** manifest shared dataset

**Invariant:** A coordinated collection of information objects that is presently manifest as one shared dataset across multiple participants in one information domain.

**Inclusion boundary:** Includes only the manifest shared dataset as a substrate-neutral information entity at systemic scope. The claim requires one coordinated information collection shared across multiple participants. A coincidental set of unrelated data objects is not one systemic dataset, and storage or communication topology remains separate. It is neutral about truth, validity, belief, access, observation, transmission, processing, mutation, physical realization, ownership, provenance, probability, timing, and cause.

**Excluded meanings:**

- Truth, falsity, validity, evidential support, assertion, belief, understanding, memory, or certainty concerning the information.
- Creation, mutation, computation, parsing, indexing, querying, copying, transmission, delivery, reception, or deletion of data.
- Physical inscription, storage medium, device, energy, signal carrier, file-system structure, access path, or network topology.
- Sender, recipient, communication act, social ownership, authority, privacy policy, permission, or responsibility.
- Formal rule, proposition role, proof status, evaluation, satisfaction, entailment, consistency, or semantic correctness.
- Accessibility, observability, discoverability, provenance, version, schedule, future activation, possibility, necessity, probability, or cause.

**Address justification:**

- `first_trit_0`: Selects an information entity rather than a data transformation, transmission event, storage/access affordance, or physical medium.
- `second_trit`: Selects systemic/collective scope: one coordinated collection maintained as a shared dataset across multiple participants in one information domain and no other Data-family column.
- `third_trit`: Selects the manifest/presently instantiated member by information-object identity or present manifestation while leaving runtime truth status, access, observation, transmission, tense, probability, and process phase separate.

**Nearest neighbors:** `DAT:020`, `DAT:022`, `DAT:001`, `DAT:011`, `DAT:121`, `DAT:221`

**Same-family boundary:** `DAT:0xx` owns information entities and their persistent, manifest, or dormant status. `DAT:1xx` remains reserved for information transformations or flow processes, and `DAT:2xx` for storage, access, provenance, transmission, or other information affordances and relations. A manifest datum does not entail access, observation, truth, transfer, or processing, and an identified datum does not entail a usable storage or communication relation. The persistent sibling may also hold because it asserts information-object identity across time. Manifest and dormant siblings are mutually exclusive for the same object at the same reference time, while runtime `[2]/num` may leave either selected claim unresolved.

**Runtime-state interpretation:**

- `[0]`: Denies that this shared dataset is presently manifest; it does not erase the information object, affirm dormancy, or state whether anyone can access or understand it.
- `[1]`: Affirms that this shared dataset is presently manifest in the stated information scope, without asserting truth, access, observation, transmission, storage medium, or use.
- `[2/num]`: Leaves unresolved whether this shared dataset is presently manifest; runtime uncertainty does not select persistent identity or lexical dormancy.

**Lexical/runtime distinction:** Lexical third trit `1` permanently selects the manifest/presently instantiated member of this information-entity triplet. Runtime `[2]/num` instead leaves that already-selected assertion unresolved; it never changes manifestation status. Thus a dormant root affirmed with `[1]` is a confirmed maintained-but-unmanifest information object, while a persistent or manifest root carrying `[2]/num` remains lexically persistent or manifest but uncertain as a token claim.

### E. Examples

| Type | Semantic graph | Literal gloss | Natural English | State | Result |
| --- | --- | --- | --- | ---: | --- |
| ordinary_conversation | `DAT:021[1](DOMAIN=workspace,PARTICIPANTS={a,b,c},DATASET=d)` | affirm manifest shared dataset | That information object is manifest now. | 1 | valid |
| physical_or_spatial | `MAT(MEDIUM=m)+DAT:021[1](DOMAIN=workspace,PARTICIPANTS={a,b,c},DATASET=d)` | material medium plus manifest data entity | A mark on the device realizes the datum while MAT separately describes its physical medium. | 1 | valid |
| temporal_or_sequential | `DAT:021[1](DOMAIN=workspace,PARTICIPANTS={a,b,c},DATASET=d)+ORI(INTERVAL=w)` | manifest data entity during interval w | During interval w, the information object has the stated lexical status. | 1 | valid |
| cross_family_compound | `LOG(CRITERION=c)+DAT:021[1](DOMAIN=workspace,PARTICIPANTS={a,b,c},DATASET=d)` | formal criterion plus manifest data representation | The datum represents a criterion without becoming the formal rule itself. | 1 | valid |
| executable_or_programming | `DAT:021[1](DOMAIN=workspace,PARTICIPANTS={a,b,c},DATASET=d)` | assert manifest information-object status | A runtime registers information-object status without asserting transfer, parsing, mutation, or truth. | 1 | valid |
| counterexample | `CON(TRANSFER=d,SOURCE=s,TARGET=t)` | data transmission | The packet is being sent to a recipient. | 1 | must_not_use_this_root |

## DAT:022 — dormant shared dataset

### A. Fixed generated forms

- Universal slot: **dormant collective entity**
- Transliteration: **li·nin**
- Local compact root: **nin**
- Formal carrier: **li-ma-nu-nu**
- Harmonic signature: **0–4–7–11**
- Relative note path: **0 → 0 → -2 → -4**

### B. Why the current meaning was probably chosen

The provisional titles use familiar data vocabulary and roughly follow systemic scope and dormant status.

### C. Candidate comparison

| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| archive | 5 | 7 | 8 | 2 | 4 | 7 | 8 | 7 | **48/80** |
| dormant shared dataset | 10 | 10 | 10 | 10 | 9 | 10 | 9 | 10 | **78/80** |
| dormant shared representation system | 9 | 8 | 10 | 7 | 8 | 9 | 9 | 10 | **70/80** |
| archived shared corpus | 9 | 8 | 8 | 7 | 7 | 9 | 10 | 10 | **68/80** |
| dormant message collection | 8 | 7 | 7 | 6 | 5 | 9 | 10 | 9 | **61/80** |

#### archive

**Invariant candidate:** A collective body of information is preserved but is not presently indexed, loaded, or in active use.

- Fit: The provisional titles use familiar data vocabulary and roughly follow systemic scope and dormant status.
- Useful coverage: They cover records, inputs, messages, signals, datasets, streams, archives, identifiers, and packets.
- Territory consumed: Across the block they mix information entities, storage state, communication processes, data flow, delivery queues, access, indexing, and active updating.
- Conflicts and limitations: The triplets do not preserve one entity center: manifest roots absorb input or flow processes, target roots absorb CON delivery, and dormancy is mixed with inaccessible, queued, unread, and unindexed states.

#### dormant shared dataset

**Invariant candidate:** A coordinated collection of information objects maintained as one shared dataset across multiple participants in one information domain without being presently manifest.

- Fit: The first trit remains an information entity; the second changes only internal containment, reference to one distinct target, or coordinated sharing across participants; the third changes only persistent, manifest, or dormant status.
- Useful coverage: It supports datum, record, value, identifier, reference, pointer, metadata, dataset, corpus, catalogue, and shared state without encoding transmission or computation.
- Territory consumed: Only bounded information-object identity and manifestation at the selected scope. Media, storage mechanics, communication, transformation, access, truth, belief, and formal validity remain separate.
- Conflicts and limitations: Encoding and value-type distinctions remain broad in Era Zero and must be supplied compositionally when exact syntax, schema, provenance, or medium matters.

#### dormant shared representation system

**Invariant candidate:** A dormant symbolic representation organized at systemic information scope.

- Fit: Symbols and representations are central Data entities and can occur internally, refer to targets, or form shared representational systems.
- Useful coverage: It would cover symbols, tokens, codes, names, labels, icons, formulas, maps, and representational systems.
- Territory consumed: It specializes every datum to an explicitly symbolic representation.
- Conflicts and limitations: Measurements, opaque blobs, sensory traces, and non-symbolic information objects would be under-served, while representational relation details risk LOG, MIN, and STR collisions.

#### archived shared corpus

**Invariant candidate:** A dormant stored record situated at systemic information scope.

- Fit: Records naturally persist, become open or loaded, and become archived at internal, target-addressed, or shared scope.
- Useful coverage: It would cover files, rows, documents, logs, archives, databases, indexes, and stored records.
- Territory consumed: It makes durable storage or record structure essential to every Data entity.
- Conflicts and limitations: Signals, ephemeral values, references, and computed data need not be records; physical storage and access also risk MAT and STR collisions.

#### dormant message collection

**Invariant candidate:** A dormant communicative message organized at systemic scope.

- Fit: Messages contain information, can remain local, target recipients, or be shared among groups, and can be manifest or dormant.
- Useful coverage: It would cover message, packet, signal, notification, post, broadcast, queue, and inbox item.
- Territory consumed: It makes communicative intent, sender-recipient structure, and delivery context obligatory.
- Conflicts and limitations: CON owns participants, transmission, delivery, and reception, while most data objects are not messages at all.

### D. Recommended permanent semantic specification

**Title:** dormant shared dataset

**Invariant:** A coordinated collection of information objects maintained as one shared dataset across multiple participants in one information domain without being presently manifest.

**Inclusion boundary:** Includes only the dormant shared dataset as a substrate-neutral information entity at systemic scope. The claim requires one coordinated information collection shared across multiple participants. A coincidental set of unrelated data objects is not one systemic dataset, and storage or communication topology remains separate. It is neutral about truth, validity, belief, access, observation, transmission, processing, mutation, physical realization, ownership, provenance, probability, timing, and cause.

**Excluded meanings:**

- Truth, falsity, validity, evidential support, assertion, belief, understanding, memory, or certainty concerning the information.
- Creation, mutation, computation, parsing, indexing, querying, copying, transmission, delivery, reception, or deletion of data.
- Physical inscription, storage medium, device, energy, signal carrier, file-system structure, access path, or network topology.
- Sender, recipient, communication act, social ownership, authority, privacy policy, permission, or responsibility.
- Formal rule, proposition role, proof status, evaluation, satisfaction, entailment, consistency, or semantic correctness.
- Accessibility, observability, discoverability, provenance, version, schedule, future activation, possibility, necessity, probability, or cause.

**Address justification:**

- `first_trit_0`: Selects an information entity rather than a data transformation, transmission event, storage/access affordance, or physical medium.
- `second_trit`: Selects systemic/collective scope: one coordinated collection maintained as a shared dataset across multiple participants in one information domain and no other Data-family column.
- `third_trit`: Selects the dormant/maintained but unmanifest member by information-object identity or present manifestation while leaving runtime truth status, access, observation, transmission, tense, probability, and process phase separate.

**Nearest neighbors:** `DAT:020`, `DAT:021`, `DAT:002`, `DAT:012`, `DAT:122`, `DAT:222`

**Same-family boundary:** `DAT:0xx` owns information entities and their persistent, manifest, or dormant status. `DAT:1xx` remains reserved for information transformations or flow processes, and `DAT:2xx` for storage, access, provenance, transmission, or other information affordances and relations. A manifest datum does not entail access, observation, truth, transfer, or processing, and an identified datum does not entail a usable storage or communication relation. The persistent sibling may also hold because it asserts information-object identity across time. Manifest and dormant siblings are mutually exclusive for the same object at the same reference time, while runtime `[2]/num` may leave either selected claim unresolved.

**Runtime-state interpretation:**

- `[0]`: Denies that this shared dataset is presently dormant; it does not by itself affirm current manifestation, deletion, corruption, inaccessibility, or replacement.
- `[1]`: Affirms that this shared dataset remains maintained but is not presently manifest, without encoding archive medium, access denial, hiddenness, future activation, uncertainty, or loss.
- `[2/num]`: Leaves unresolved whether the selected dormant shared dataset claim holds; lexical third-trit 2 names maintained-but-unmanifest status, while runtime `[2]/num` marks assertion-level uncertainty.

**Lexical/runtime distinction:** Lexical third trit `2` permanently selects the dormant/maintained but unmanifest member of this information-entity triplet. Runtime `[2]/num` instead leaves that already-selected assertion unresolved; it never changes manifestation status. Thus a dormant root affirmed with `[1]` is a confirmed maintained-but-unmanifest information object, while a persistent or manifest root carrying `[2]/num` remains lexically persistent or manifest but uncertain as a token claim.

### E. Examples

| Type | Semantic graph | Literal gloss | Natural English | State | Result |
| --- | --- | --- | --- | ---: | --- |
| ordinary_conversation | `DAT:022[1](DOMAIN=workspace,PARTICIPANTS={a,b,c},DATASET=d)` | affirm dormant shared dataset | That information object is still maintained, but it is not manifest now. | 1 | valid |
| physical_or_spatial | `MAT(MEDIUM=m)+DAT:022[1](DOMAIN=workspace,PARTICIPANTS={a,b,c},DATASET=d)` | material medium plus dormant data entity | A mark on the device realizes the datum while MAT separately describes its physical medium. | 1 | valid |
| temporal_or_sequential | `DAT:022[1](DOMAIN=workspace,PARTICIPANTS={a,b,c},DATASET=d)+ORI(INTERVAL=w)` | dormant data entity during interval w | During interval w, the information object has the stated lexical status. | 1 | valid |
| cross_family_compound | `LOG(CRITERION=c)+DAT:022[1](DOMAIN=workspace,PARTICIPANTS={a,b,c},DATASET=d)` | formal criterion plus dormant data representation | The datum represents a criterion without becoming the formal rule itself. | 1 | valid |
| executable_or_programming | `DAT:022[1](DOMAIN=workspace,PARTICIPANTS={a,b,c},DATASET=d)` | assert dormant information-object status | A runtime registers information-object status without asserting transfer, parsing, mutation, or truth. | 1 | valid |
| counterexample | `CON(TRANSFER=d,SOURCE=s,TARGET=t)` | data transmission | The packet is being sent to a recipient. | 1 | must_not_use_this_root |

## Triplet coherence

| Triplet | Shared axis | `0` | `1` | `2` |
| --- | --- | --- | --- | --- |
| DAT:000–002 | one datum maintained within one reference entity | persists independently of manifestation | presently manifest | maintained but unmanifest |
| DAT:010–012 | one datum whose content denotes one distinct referent | persists independently of manifestation | reference presently manifest | reference maintained but unmanifest |
| DAT:020–022 | one coordinated dataset across multiple participants | persists independently of manifestation | dataset presently manifest | dataset maintained but unmanifest |

**Triplet logic:** the `0` column is manifestation-neutral and may co-occur with `1` or `2`; only manifest `1` versus dormant `2` is mutually exclusive at one reference time. Manifestation never entails access, observation, truth, transmission, or processing.

## Nine-root ownership matrix

| Root | Owns | Intentionally belongs elsewhere |
| --- | --- | --- |
| DAT:000 | persistent internal datum | truth, belief, physical medium, access, transmission, processing, mutation, provenance, formal validity, authority, time, and modality |
| DAT:001 | manifest internal datum | truth, belief, physical medium, access, transmission, processing, mutation, provenance, formal validity, authority, time, and modality |
| DAT:002 | dormant internal datum | truth, belief, physical medium, access, transmission, processing, mutation, provenance, formal validity, authority, time, and modality |
| DAT:010 | persistent target reference | truth, belief, physical medium, access, transmission, processing, mutation, provenance, formal validity, authority, time, and modality |
| DAT:011 | manifest target reference | truth, belief, physical medium, access, transmission, processing, mutation, provenance, formal validity, authority, time, and modality |
| DAT:012 | dormant target reference | truth, belief, physical medium, access, transmission, processing, mutation, provenance, formal validity, authority, time, and modality |
| DAT:020 | persistent shared dataset | truth, belief, physical medium, access, transmission, processing, mutation, provenance, formal validity, authority, time, and modality |
| DAT:021 | manifest shared dataset | truth, belief, physical medium, access, transmission, processing, mutation, provenance, formal validity, authority, time, and modality |
| DAT:022 | dormant shared dataset | truth, belief, physical medium, access, transmission, processing, mutation, provenance, formal validity, authority, time, and modality |

## Concepts intentionally reserved

Physical media, observation, belief, truth, validity, access, ownership, privacy, provenance, version, parsing, computation, mutation, indexing, copying, transmission, delivery, reception, synchronization, scheduling, and modality remain other-family meanings, later DAT layers, grammar, or compounds.

## English coverage stress test

113 concepts were routed across atoms, compounds, runtime state, grammar, other families, later DAT layers, and unresolved senses. See `reviews/DAT_000_022_stress_tests.yaml`.

## Approval checklist

- [x] family domain preserved
- [x] address axes preserved
- [x] one invariant per root
- [x] triplets coherent
- [x] all current candidates challenged
- [x] cross family collisions explicit
- [x] runtime state separated
- [x] entity process relation layers separated
- [x] generated fields unchanged
- [x] gate4 not started
- [x] translator not started
- [x] canonicalized

**Disposition:** the packet passed reusable validation and was approved under delegated authority.
