# Original desire/preference requirements audit

Original authored acceptance requirements, executed against candidate preview. Not held-out validation or vocabulary approval.

Full translator completion: **not established**.

| Requirement | Input | Current evidence |
|---|---|---|
| relative_not_absolute | Nora prefers tea to coffee. | candidate_semantic_checks_pass |
| reversed | Nora prefers coffee to tea. | candidate_semantic_checks_pass |
| both_unpleasant | Nora prefers the painful treatment to the more painful treatment. | candidate_semantic_checks_pass_with_explicit_context |
| unattended | Nora still prefers tea while thinking about the gate. | not_composed |
| fleeting | For this instant Nora prefers tea to coffee. | not_composed |
| without_choice | Nora prefers tea but chooses coffee. | not_composed |
| negation | Nora does not prefer tea to coffee. | candidate_semantic_checks_pass |
| question | Does Nora prefer tea to coffee? | candidate_semantic_checks_pass |
| past | Nora preferred tea to coffee yesterday. | candidate_semantic_checks_pass |
| desire_not_need | Nora wants the unnecessary ornament. | not_composed |
| need_not_desire | Nora needs water but does not want water. | not_composed |
| desire_without_pleasure | Nora wants the unpleasant treatment. | not_composed |
| desire_without_plan | Nora wants to leave but has no plan to leave. | not_composed |
| unrealized_content | Nora wants the nonexistent fountain to exist. | not_composed |
| object_reading | Nora wants tea. | not_composed |
| curiosity_not_attention | Orin is curious about the map. | candidate_semantic_checks_pass |
| attention_not_curiosity | The alarming noise captures Orin’s attention, but Orin does not want to learn about it. | not_composed |
| participant_change | Eli prefers tea to coffee. | candidate_semantic_checks_pass |
| runtime_independence | Nora prefers tea to coffee [2]. | candidate_semantic_checks_pass |
| kind_not_cup | Nora prefers tea to coffee. | candidate_semantic_checks_pass |

Passing cases recover holder, ordered alternatives, kind/entity typing, speech act, scope and runtime from MIDI. Changed direction, holder, negation, time, question and runtime have distinct performances. Curiosity now recovers epistemic interest and unresolved topic inquiry without asserting information acquisition or current attention. The painful-treatment preference passes only with explicit contextual choices; this is not automatic interpretation of the underspecified sentence. Missing cases include object desire, temporariness, other modified noun phrases and preference combined with choice.
