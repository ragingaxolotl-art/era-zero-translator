# Lore Conversation Presets

Status: **presentation layer; no semantic authority changes**

The Conversation tab includes five short, keyed performances drawn from the
project literature. They are designed to let a reader finish a story, enter a
small code, and hear an important exchange in alternating ocarina and warm-organ
voices.

| Key | Story | Moment |
|---|---|---|
| `FEAST-CARRY` | *The Feast with No Host* | Brindle learns to include the people who carry the meal. |
| `CURRENT-LISTEN` | *The Knocking Beneath the Current* | Pell and Suth act on the present bank rather than an old reflection. |
| `ROOMS-BESIDE` | *Lamentations for the Rooms We Did Not Carry* | Palinode keeps Serein's objection beside, rather than inside, their own. |
| `ARRIVAL-ASK` | *The Department of Arrivals* | Nacre distinguishes reaching a station from completing an arrival. |
| `TWO-DROPS-WAIT` | *Letters Between Two Drops* | Dema and Issa preserve a settlement by asking and waiting before replacement. |

## Interpretation rule

Each preset contains two layers:

1. A short source excerpt, shown for literary context.
2. A conservative performance adaptation, sent through the same English
   matcher and canonical sound compiler as a conversation typed by the user.

The performance may generalize a sentence to meanings the language currently
supports. Unsupported details remain visible in English, become nonsemantic
phonemic labels when they are referential nouns, or appear in the visible
“Not sounded” warning. No preset adds a root, compound, semantic definition, or
translation exception.

The machine-readable source is
[`examples/lore_conversation_presets.json`](../examples/lore_conversation_presets.json).

## Website behavior

- Choose a moment or type its key or alias.
- Select **Load keyed moment** to place its performance adaptation in the editor.
- Select **Translate conversation** to inspect every matched root and limitation.
- Select **Play back-and-forth** to hear alternating ocarina and warm-organ voices.
- A custom two-speaker script may use any two speaker names in `Name: sentence`
  form. The first voice is ocarina; the second is warm organ.
