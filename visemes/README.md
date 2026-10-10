# Layered viseme character rig

The character compiler keeps three independent presentation layers:

- `head/base.json`: the unchanged base head.
- `eyes/happy.json`, `eyes/sad.json`, and `eyes/angry.json`: interchangeable eye-expression layers.
- `mouth/sounds.json`: the complete carrier-sound-to-mouth-pose layer.

Changing the eyes never changes the canonical tones, carrier order, mouth timing, formal identity, or semantic identity. The emitted `.ezviseme.json` file references one head layer, one selected eye layer, and one timed mouth-sound layer.
