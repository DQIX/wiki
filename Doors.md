# Doors

Doors and sliding pieces are resources named in a map's descriptor, each a model with an optional collision mesh beside it. The model and collision shapes are observed; the hinge point is **INFERRED**. Nothing in the files says how a door opens or a piece slides, so that is presumably in code. Observations come from Angel Falls (`M01`) and the Hexagon's first floor (`D01M01`) on the European release (game code `YDQP`).

## Layout

### Doors — `<area>M<nn>D<x>` and `<area>A<nn>D<x>`

A door is two resources in a map's descriptor:

| name | what it is |
|---|---|
| `M01M00D1` | the door's model |
| `M01A00D1` | its collision: the same name with `A` in place of `M` |

Each is a resource of its own with its own placement. They are not two files under one stem.

Angel Falls has ten doors, `D1` to `DA`. Of its houses, `M01M02` and `M01M09` have one each. `M01M10`, Erinn's house, has two.

- **Every door model in the village is one quad with a corner at its origin.** It has four vertices and stands 1.52 model units tall (0.19 world units). The rest of it runs out along the ground from the origin. INFERRED: the origin is the hinge.
- **No door has an animation file beside it.** However the game opens a door, that is in code.
- **The collision is two triangles facing the same way** on all of the village's doors, and on those of `M01M02` and `M01M09`. This reads as a marker: if it is kept as a wall, it seals the doorway.
- **Erinn's house's two doors are four triangles, facing both ways.** That is a wall from either side, which stands only while the door is shut.

### Sliding pieces — `<area>M<nn>S<x>` and `<area>A<nn>S<x>`

Sliding pieces are named like doors, with `S` in place of `D`. Across the maps, 13 models are named this way, and 7 of them have a collision mesh beside them.

The Hexagon's first floor has one: `D01M01S1`, with collision `D01A01S1`. The collision is eight triangles forming a box exactly under the model as the map places it. It spans x 0.29 to 0.57 and z −1.79 to −1.63 in world units, in the gap between the big hexagon and the room above.

**The piece stands where the thing you examine on it stands.** This is INFERRED from this one case:

- The cast placement record for character `202` (see [Area-Cast](Area-Cast)) that starts at story stage 2.4, step 5, stands on the middle of the piece, to within 0.006.
- Its record before that stands 0.431 to the left, in the gap.
- So until step 5, the piece and its collision are 0.431 to the left, shutting the way. From step 5 they are where the map puts them.

None of the other twelve sliding pieces has a placement record on it.

No event moves the piece. `ev02530`, the switch's event, calls function 321 sixteen times. Each call aims the camera within 0.01 of the switch over three frames, which is a camera shake. So how the game slides the piece is in code (see [Event-Scripts](Event-Scripts), [Triggers](Triggers)).

## Evidence

- Door model geometry: all door models in `M01` (four vertices, one quad, corner at origin).
- Door collision triangle counts and facings: `M01`'s doors, `M01M02`, `M01M09`, `M01M10`.
- The sliding piece reading: `D01M01S1` / `D01A01S1`, the placement records of character `202`, and the script of `ev02530`.

## Not established

- How a door opens: no animation file ships beside any door.
- Whether the origin of a door model is really its hinge (INFERRED).
- How and how fast a sliding piece moves. Its closed position is INFERRED from one case only.
- What the other twelve sliding pieces do. None has a placement record on it.

## See also

- [Map-Archive](Map-Archive): the other small files in a map archive, including `.bcfg` state names on gate and door pieces
- [Map-Objects](Map-Objects)
- [Map-Collision](Map-Collision)
- [Map-Textures](Map-Textures): the doorway trigger volumes that change map
- [Area-Cast](Area-Cast)
- [Motion-Tables](Motion-Tables)
