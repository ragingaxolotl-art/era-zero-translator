# Experience foundation prerequisite: bind the qualification to the experiencer

Status: renderer repair implemented; experience vocabulary remains a design task.
No sensory-experience compound is approved by this review.

LIF:011 denotes another conscious, awake or responsive being; LIF:001 denotes the
conscious self. MIN:001 is specifically a representation of the cognizer's own
identity or condition, while MIN:011 represents a distinct target. They cannot be
freely exchanged or loosely combined into a generic experience alias. A future
experience definition must state the cognizer, the content and whether actual
external access is asserted. It must not inherit physical registration merely
because both are sensory concepts.

One sound graph construction is to qualify the **experiencer slot** with the
appropriate consciousness restriction and bind the actual person at that slot.
This ensures the restriction applies to that person. Putting a conscious-being
root elsewhere in the graph and an unrelated named experiencer outside it would
leave that identity relation unexpressed.

The prior expansion kept the qualifier's role register but not its participant
binding chain. Its music could therefore put the qualifying root outside the
role frame around the named argument. The repaired expansion carries the exact
qualified slot path through the qualifier subtree. The renderer places its
roots, nested convention frames and bound participants inside the same outer
participant role frame. A convention around the whole predicate stays outside
that participant frame; the two scopes must never cross.

The same review exposed a broader timing discrepancy: the documented compound
architecture calls for no extra gap between a modifier and what it qualifies,
but the renderer inherited the generic half-beat event gap. The correction
applies to ordinary root modifiers as well as nested compound modifiers. When a
nested qualifier ends with a convention frame, the no-gap attachment follows
that closing frame. Typed argument boundaries and unrelated grammar frames keep
their existing short gaps.

Tests compare qualification of experiencer versus target, atomic versus nested
qualifiers, all three outer runtime endings, independently retained argument
endings, exact MIDI note adjacency, and Ruby/browser output. The fixtures use
artificial lexical records to test attachment; they do not assert that the
fixture combinations are approved experience meanings.

Before adding experience vocabulary, the remaining design work is to choose the
exact experiential invariant and content reference semantics, preserve self versus
other where the LIF root requires it, and support these explicit bound templates
in ordinary browser sentence composition. Conscious registration, sensory
appearance, successful access, attention and understanding remain separate.
