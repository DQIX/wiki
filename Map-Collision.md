# Map Collision

`.col2` is a map's collision mesh: a header, a triangle list, a grid index over it, and a short trailing section. There are 1,178 files, 4.3 MiB, one or more per [Map-Archive](Map-Archive). It has no magic number. All figures are from the European release (game code YDQP). The header, triangle layout, face normal format, bounding box and grid tiling are confirmed on every file; the `shift` scale rule is INFERRED from three agreeing measurements; the grid origin is not established. **EU only:** the trailing records are ground records, read from the game's code, and a triangle's top seven bits are INFERRED to index them; the rest of the attribute word is not established. No published reference for `.col2` is known.

## Layout

### Header

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 4 | `u32` | `3` on all 1,178 files |
| `+0x04` | 4 | `u32` | `shift`, 0–5: coordinates are stored halved this many times. INFERRED, see below |
| `+0x08` | 12 | `s16[6]` | bounding box: min x, y, z then max x, y, z |
| `+0x14` | 4 | `u32` | triangle count |
| `+0x18` | 2 | `u16` | grid cell size |
| `+0x1A` | 2 | `u16` | `unknown_0x1a` |
| `+0x1C` | 4 | `u32` | `gridX` |
| `+0x20` | 4 | `u32` | `gridZ` |
| `+0x24` | 4 | `u32` | offset of the triangles |
| `+0x28` | 4 | `u32` | offset of the per-cell counts |
| `+0x2C` | 4 | `u32` | offset of the per-cell starts |
| `+0x30` | 4 | `u32` | offset of the triangle indices |
| `+0x34` | 4 | `u32` | count of the trailing records |
| `+0x38` | 4 | `u32` | offset of the trailing records |

The five offsets ascend on 1,177 of 1,178 files, and the last section runs to the end of the file. Which words were offsets was found by asking which of the leading sixteen words are word-aligned values inside the file: indices 9–12 and 14 are, on 1,006 files, and no other index is on more than 159.

### Triangle (28 bytes)

The count at `+0x14` divides the triangle section exactly on **1,178 of 1,178** files, which fixes the stride.

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 6 | `s16[3]` | vertex 0 |
| `+0x06` | 6 | `s16[3]` | vertex 1 |
| `+0x0C` | 6 | `s16[3]` | vertex 2 |
| `+0x12` | 6 | `fx16[3]` | face normal |
| `+0x18` | 4 | `u32` | attributes. **EU only:** the top seven bits INFERRED to index a trailing record; the rest not established (see [The attribute word](#the-attribute-word)) |

**The normal is the check.** A triangle stores both a normal and the three points it was computed from, so the stored value must be the normalised cross product of the triangle's own edges. It is, for **108,471 of 108,471** triangles that have any area. The remaining 651 are degenerate, with no normal to store and none stored. A wrong field layout cannot satisfy this: the normal is read from one place, the points from another, and they have to agree.

That also fixes the number formats. The normal is 1.3.12 fixed point (`-4096` reads as `-1.0`). **Positions are plain integers, not fixed point**, in the same units as the bounding box. The header box is `s16[6]` in those units, and it encloses every triangle on **1,178 of 1,178** files, exactly on 1,038. The other 140 are snapped outward to round numbers, never inward.

### Grid index

Three parallel sections:

| section | element | meaning |
|---|---|---|
| counts | `u8` per cell | triangles in the cell |
| starts | `u16` per cell | index into the triangle-index list |
| indices | `u16` | triangle numbers |

**They tile.** `start[i] + count[i] == start[i + 1]` for every cell, and the last pair lands on the end of the index list, on **1,178 of 1,178** files, allowing for one `u16` of alignment padding the list may carry. Every index names a real triangle, again on all 1,178.

**The cell count follows from the header:**

```
cells = floor(gridZ * (gridX + 1/2))
```

on **1,178 of 1,178** files. Equivalently `gridX * gridZ + floor(gridZ / 2)`: one extra cell on every other row, so the rows alternate `gridX` and `gridX + 1` wide.

**`gridX` and `gridZ` are the grid's dimensions in cells, and the grid covers the box.** `gridX * cellSize >= maxX - minX` and `gridZ * cellSize >= maxZ - minZ` on **1,178 of 1,178**, and on 77.7% one cell fewer would not cover it. So the header describes a grid of `cellSize` squares laid over the mesh's own bounding box, with the rows staggered as the cell count says.

**Where cell (0, 0) sits is not established**, and the staggering is the likely reason a rectangular reading fails. Taking the grid's corner as the mesh's minimum and indexing row-major puts only **36%** of the index references inside the square that names them; column-major gives 26%, and an origin at zero 4%.

The cell size is a power of two on **1,178 of 1,178**: 8192 on 667 files, 2048 on 262, 4096 on 173 and 1024 on 76.

### Trailing records (8 bytes each)

Counted at `+0x34`, which divides the section exactly on **1,178 of 1,178**. There are 1,699 records in all, and they repeat: `0,0,0,0` on 488, `23254,0,0,0` on 240, `23254,9513,32767,0` on 115. `32767` is the largest positive `s16`, which suggests a sentinel.

#### A trailing record is a piece of ground

> **EU only.** Code addresses are the USA release's, from the [dqix-decomp](https://github.com/DQIX/dqix-decomp); the files were read on the European release (`YDQP`) and are not yet checked on the US one (`YDQE`).

Read from the game's code on 29 September 2026. A record says what the ground under a triangle is, and the triangle picks its record by the top seven bits of its attribute word (INFERRED, below).

**A record's first halfword holds three five-bit digits**, `a`, `b` and `c`, and the code reads them as a map id:

| read by | as | on |
|---|---|---|
| `func_0204bd7c` | **30000 + 100a + 10b + c**: the [battle stage](Battle-Stages) fought on that ground | ordinary maps |
| `func_0204bef4` | **20000 + 100a + 10b + c**: the field region below | the sky, `O01A0000.col2` (see [Starflight Express](Starflight-Express)) |

On the sky, **bits 5 to 9 of the second halfword say whether the Express may land** (`func_0204bedc`). The field's encounter code in overlay 17 takes the record under the encounter and hands its stage to the battle request (`func_ov017_021b848c`).

Some collisions, with their records read as stages:

| collision | its records, as stages (triangles) |
|---|---|
| `F01A0000`, Angel Falls Region | 30116 "F01 - Field" (714), 30117 "F01 - Forest" (112) |
| `F03A0000`, Zere Region | 30105 Field (301), 30106 Forest (24), 30107 Barley Field (1), 30108 Poison Swamp (21) |
| `F02A0000`, Western Stornway | 30103 (698), 30112 Forest (37), 30113 Field (115) |
| `D01A0100`–`0400`, the Hexagon | 30214 "D01 - Inside" |
| `D01A05E2`, Hexagoon's piece | 30215 "D01 - Hexagoon" |

The sky's 57 records are 56 regions, 20001 to 20063, and one all zero, the sea.

What the third and fourth halfwords hold, and the second's other bits, is not established.

## The attribute word

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`). Code addresses are the USA release's, from the decomp.

**It is not a terrain type**, or not in any form found. The opening village's **82** non-vertical triangles carry **51 distinct** attribute values, nearly one per triangle. The values read as packed orderings (`0x543210` and its permutations) rather than surface flags, and the same values appear on marker volumes and on terrain alike. Water is identifiable, but from the texture name, not from collision (see [Map-Textures](Map-Textures#what-a-texture-is-called)).

**The top seven bits index a trailing record: INFERRED.** On the sky's collision, `O01A0000.col2`, all 799 triangles have an even top byte, which halved runs 0 to 56, and all 57 trailing records are used. The Starflight Express's code takes the index from the collision query `func_02017d90`, and keeps the record under it (overlay 17, `func_ov017_02193dc4`). The game's code reads ordinary maps' trailing records the same way, as battle stages (above). What the lower bits are is not established.

## Volume meshes

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`).

**INFERRED: some collision meshes are volumes, not ground.** A map's collision arrives as several meshes (see [Map-Objects](Map-Objects)). **335 of the 358** meshes of two triangles or fewer have no standable surface at all: each is a single quad standing vertically. The opening village has thirteen meshes, and eleven are such quads: one across each of its ten doorways, and a four-by-six quad 2.5 units tall in the middle of the map. All are taller than any building there, and all are invisible.

Treated as walls, they seal every doorway: walkable ground reachable from the village's middle drops from **61% to 24%**, and its largest connected region from 93% to 24%. They hold no standable surface, so no ground is lost by passing through them. The door collisions among them are described on [Doors](Doors).

What they are is not established. The shape is the only signal found.

## Scale: a mesh is stored halved `shift` times

**INFERRED**, from three measurements that agree.

### The `s16` ceiling

A vertex is an `s16` in the units an `fx32` word counts, so a coordinate cannot pass **±8.00 units** and a mesh cannot be wider than **16.00**. The cartridge reaches that bound: the furthest vertex sits at exactly 8.00 and the widest mesh is exactly 16.00, with 8 meshes past 7.9 and 93 past 7. 528 of the 1,178 reach past 4. Anything bigger than sixteen units across cannot be stored at its drawn size.

### What `shift` does

`+0x04` runs 0 to 5. On every one of the 511 files where it is not zero, the mesh's largest coordinate lies in the top octave of an `s16`, 16,384 to 32,768, while files with 0 run as low as 3,684:

| `shift` | files | largest coordinate: min · median · max | cell size |
|---|---|---|---|
| 0 | 667 | 3,684 · 10,098 · 32,768 | 8192 |
| 1 | 173 | 16,384 · 22,630 · 32,768 | 4096 |
| 2 | 171 | 16,384 · 23,552 · 32,706 | 2048 |
| 3 | 91 | 16,384 · 21,504 · 32,256 | 2048 |
| 3 | 4 | 16,461 · 20,992 · 27,676 | 1024 |
| 4 | 57 | 16,384 · 24,294 · 32,768 | 1024 |
| 5 | 15 | 16,384 · 18,686 · 21,536 | 1024 |

That is what halving a mesh until it fits the format leaves behind. The cell size halves with it at first: `cellSize << shift` is 8192 on all 1,011 files with a shift of 0 to 2, as though the grid were laid out before the halving.

Read at `stored × 2 ** shift`, the collision agrees with the models, drawn at their own `upScale` (see [NSBMD](NSBMD)), and with the doorways, which come from a different file (see [Doors](Doors)):

| across the cartridge | stored | `× 2 ** shift` |
|---|---|---|
| doorways just inside their map's collision, 1,122 | 32% | 86% |
| indoor doorways just inside, 677 | 16% | 91% |
| doorway arrivals standing on floor | 78.1% of 1,132 | 99.8% of 1,098 |
| collision floor lying on drawn floor, outdoor maps | 0.61 | 0.84 |

"Just inside" is 0.35 to 1.1 of the way from the box's middle to its edge. The floor score is taken where the reading changes anything: better on 58 outdoor maps and worse on 3. Indoors it is better on 102 and worse on 27; those 27 are rooms whose one floor quad reaches past their walls, which the score counts against the larger mesh. Drawn from above, their walls trace the room at `× 2 ** shift` and stand in open floor without it.

Indoor and outdoor maps share one space. Nothing inside a map's own archive distinguishes indoor from outdoor; [Map-List](Map-List) does.

### Fields

A field's collision has a `shift` of 4 and its terrain an `upScale` of 16. Read at those, all 116 doorway arrivals into a field land on floor, and the Angel Falls field's collision spans x −12.00 to 12.84.

Over all 663 maps, 113 of the 124 doorways in a field have floor under them, and every other kind of map 97.9% or more. The Angel Falls field's three all do. The 11 without are nine leading to `O00` (from `F44`, `F56`, `F99` and its sub-maps) and one each in `F07` and `F27`.

A field's drawn terrain is a grid of tile models named `F01M<row><col>00`: rows 1–6 step z and columns 1–6 step x, 21 tiles in a ragged rectangle, each authored **in world coordinates** rather than at its own origin. The collision mesh covers the same extent as those tiles. Collision does not follow the tile naming (there is no `F01A<row><col>00`), so it is authored once for the map rather than once per tile. The Angel Falls field archive holds exactly one `.col2` and 24 `.nsbmd`, and its manifest names all 25.

Other files ruled out as field ground: `.bats` attribute tables are 736–1,072 bytes of what read as colour and lighting settings, four to seven records deep, with no grid in them; `.dat` files are 48 to 64 bytes. Only 13 of the 1,178 `.col2` sit in an archive whose name they do not match, and they look like development leftovers.

## Maps with no collision

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`).

**196 of the cartridge's 669 maps have no collision mesh**, and nothing on the cartridge leads to any of them. 237 of the 669 have nothing leading to them, which is what a cartridge of assembled pieces looks like.

- **174 are the whole `B` family**: the [battle stages](Battle-Stages), with no doorway, cast or trigger. `B01M16`, "F01 - Field", is one model of 457 triangles and no collision.
- **The other 22 include the roots of `X01` and `X05`**, the Observatory, labelled "All Events" in the [map list](Map-List). Their sub-maps have collision. `X03`, labelled the same, has a collision mesh.
- They also include `F34M01`, whose archive holds no collision file, while `F34`'s holds 66 KB of it for the whole field.

Whether each of the 196 is meant to have none is not established. None is reachable, and none has a cast.

A map whose archive holds two manifests needs the right one before its collision is found: see [Map-Objects](Map-Objects#more-than-one-manifest-in-an-archive).

## Doorway spaces

The three things a doorway stores are in **three different spaces**:

| | space | scales with the map? |
|---|---|---|
| where it stands | the map that holds it | **yes** |
| where it comes out | the map it leads to | **yes, by that map's scale** |
| how big its trigger volume is | the character's | **no** |

A doorway's position and volume are recorded in the map that holds it; its **arrival is a spot in the map it leads to** and takes that map's scale instead.

The volume being in neither map's space is measured. These measurements were taken before `shift` was read, under the earlier eighth-scale reading (see [Earlier readings](#earlier-readings)). The ruler is the **doorway model** standing at the trigger: a placed piece (see [Map-Objects](Map-Objects)), and so already in the character's space. 154 of the cartridge's doorways have one, matched by position. Trigger size relative to its door model:

| | height | width |
|---|---|---|
| outdoors, 74 of them | 1.30 | 1.42 |
| indoors, volume not scaled, 80 of them | **1.12** | **1.49** |

A trigger is about half again the size of its own door, indoors and out. Left at its own size an indoor trigger covers 4.3% to 31.5% of the room's walkable floor, against 3.4% for the village outside: a large share of a small room, as a doorway is a large share of a small room's wall. It still leaves two thirds of the floor free in the worst of them.

## Evidence

| check | result |
|---|---|
| files parsed | **1,178 / 1,178** |
| triangles | 109,122 |
| **stored normal == the normalised cross product of its own triangle** | **108,471 / 108,471 with area** |
| **the header box encloses every triangle** | **1,178 / 1,178** (exact on 1,038) |
| **the cells tile the triangle-index list** | **1,178 / 1,178** |
| **cells == `floor(gridZ * (gridX + 1/2))`** | **1,178 / 1,178** |
| **the grid covers the header box on both axes** | **1,178 / 1,178** (tight on 77.7%) |
| every index names a real triangle | 1,178 / 1,178 |
| cell size is a power of two | 1,178 / 1,178 |
| widest mesh, against the `s16` ceiling of 16.00 | 16.00 units |

## Earlier readings

- **Cell count without the floor.** The formula was first written `(2·gridX + 1) · gridZ / 2` and read without rounding, which is exact only when `gridZ` is even. 850 of the 1,178 files have an odd `gridZ`. `gridX * gridZ` alone accounts for 511 files and the unfloored formula for 328 more, leaving 339 apparently unexplained. Floored, it is all of them.
- **A fitted factor for interiors.** Before `shift` was read, interiors' collision looked mismatched with their rooms (an inn short by 1.9x, a well long by 1.94x, a stable apparently right), and a factor of two was fitted by eye. That was two misreadings meeting. The inn and stable have an `upScale` of 1 and a shift of 1; `M01M01` and `M01M05` to `M01M07` have an `upScale` of 2 and a shift of 1; the well has an `upScale` of 2 and a shift of 0. The "stable is right" measurement had set the drawn walls against the collision's floor rather than its walls.
- **Indoor maps an eighth larger.** Models were once drawn at their size divided by their own `upScale`. With village terrain at `upScale` 8 and most rooms at 1 or 2, rooms came out eight times the village, and a divisor of eight was applied to rooms and placed pieces. It left rooms with an `upScale` of 2 at half size. Indoor and outdoor maps share one space. Doorways cannot detect such a scale: a map and its own doorways are in the same space, so scaling both changes nothing either can see (95.6% of doorways over their own floor before and after). Under that reading, scaling an indoor doorway's volume with the map made it a seventh of its door (0.14 high, 0.19 wide) and narrower than the character.
- **Fields' doorways outside their collision.** With a field's collision (`shift` 4) and terrain (`upScale` 16) both read at half size, only 19.2% of field doorways (23 / 120) had collision under them, against 87% or better for every other map kind, and doorways lay up to 11.56 units outside the field's collision box. Dividing doorway coordinates by 4 to 32 gave a climb with no peak, no translation fitted, and no missing collision file, neighbouring archive (`F01M01`, `F01M02` are small separate places with 2 triangles and none), `.bats`, `.dat` or drawn terrain accounted for it. Reading both at full size resolved it (see [Fields](#fields)).

## Not established

- `unknown_0x1a` in the header.
- The triangle attribute word below its top seven bits. Its values look like packed nibbles (`0x21`, `0x24`, `0x51`, `0x221` in the high half; `0x213`, `0x3210`, `0x513` in the low). **EU only:** it is not a terrain type in any form found (see [The attribute word](#the-attribute-word)).
- **EU only:** that a triangle's top seven bits index its trailing record. INFERRED from the sky's collision, where all 57 records are used; settling it means landing the Starflight Express over a few regions and seeing where it lands.
- Where grid cell (0, 0) sits, and so how to look a position up in the grid.
- **EU only:** the trailing records' third and fourth halfwords, and the second's bits outside 5–9.
- **EU only:** what the vertical two-triangle volume meshes are.
- `shift` as a scale is INFERRED, not confirmed.
- For the 11 field doorways without floor under them, where they stand relative to the ground.

## See also

- [Map-Archive](Map-Archive): the archive a `.col2` ships in
- [Map-Objects](Map-Objects): the manifest that lists collision meshes and places them
- [NSBMD](NSBMD): models and `upScale`
- [Doors](Doors): the doorway table
- [Map-List](Map-List): indoor/outdoor flag
- [Battle-Stages](Battle-Stages): the stages a trailing record names
- [Starflight-Express](Starflight-Express): the sky's collision and its regions
