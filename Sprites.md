# Sprites (`.spr`)

`.spr` files are sprite sheets. They hold the 2D characters, and the pots and barrels. There are 1,316 sheets on the cartridge, 1,298 of them loose in `/data/ani`. A sheet holds frames built from rectangular parts, a palette, and named animations. The frame and part layout and the palette are confirmed. In the animation records, the `order` field and the duration unit are **INFERRED**. Which way the eight standing directions turn was settled by looking at the sheets, not from the data.

All counts on this page are from the European release (game code YDQP).

## Which things are sprites

Every `kind` 0 character in a map's cast list (see [Area-Cast](Area-Cast)) has a `<name>.spr` in `/data/ani`, and no 3D model anywhere on the cartridge. Every `kind` 2 character has a model and no sprite.

The pots and barrels are sprites too. `tsubo_01` is the pot and `taru_01` the barrel. `tsubo_02` and `taru_02` are their breaking animations.

**The pots' and barrels' sheets are in two places, and the field uses the second.** All six are in `/data/ani`, and again in `/data/bin/icon.nsarc` with different bytes. The field's overlay, overlay 17, names all six next to `icon.nsarc` and `ARC:ev_icon0.spr`. That archive also holds other things drawn in the world: the chests and the round shadow.

The two copies of the barrel's breaking animation differ. The `/data/ani` copy has three frames of shards. The `icon.nsarc` copy has the same three frames, then the first frame again, held twice for 60.

24 sprite names occur more than once on the cartridge. The copies differ on 18 of them. None of those 18 is a villager.

## Layout

A frame is built from parts, just as the DS's own hardware sprites are. Each part is a rectangle 8, 16, 32 or 64 pixels on a side. Each part has a position in the frame and its own pixels.

| offset | type | meaning |
|---|---|---|
| `+0x00` | `u16` | frame count |
| `+0x02` | `u16` | version: `3` on 1,315 of 1,316 |
| `+0x04` | | the frames, one after another. Each frame is: |
| | `u16` ×2 | the frame's width and height |
| | `u16` | the frame's part count |
| | `u16` | 0 on all 4,251 frames |
| | | the frame's parts, one after another. Each part is: |
| | `s16` ×2 | the part's x and y position in the frame |
| | `u16` ×2 | the part's width and height as powers: `8 << n` |
| | | the part's pixels: 4bpp, one row of the part at a time, low nibble first |
| after | `u32` | the palette's colour count |
| | `u16` × count | the colours, BGR555. Index 0 is transparent |
| after | | the animations (below) |

## The palette

The palette is a count followed by that many colours. Most sheets have 16. Some have fewer: the barrel's shards have 12 and the pot's have 14.

A pixel names one of sixteen colours. A pixel whose index is past the count has no colour, and nothing is drawn.

A few sheets set bit 15 of a colour. The arrows are among them. Bit 15 is not part of a DS colour and is ignored.

## Animations

The animation names come first, in fixed-size slots. The slots are written over a longer string, and fragments of "…create an Animation" survive between the names. A real name contains an underscore, or it is the single word that a breaking sheet carries: `tsuboware` or `taruware`.

After the names comes one record per animation:

```
u32 steps
u32 order[steps]      // the step that follows (INFERRED, see below)
u32 duration[steps]   // 8 on a walk step, 60 on a stand, 4 on a breaking step
u32 frame[steps]      // which frame of the sheet to show
```

**Finding the records.** Nothing gives the start of the records directly. A start that works is found by trying every start two bytes apart. Two bytes, not four, because a palette of 12 or 14 colours leaves the records off a four-byte boundary. The right start is the run of records that:

- ends exactly at the end of the file,
- names a frame that exists at every step, and
- gives as many records as there are names.

A wrong start fails on the first record or two.

**Duration** is in 60ths of a second. This is **INFERRED** from the walks' 8 and the stands' 60.

**A step's `order` is the step that follows it.** This is **INFERRED**. The cartridge has 2,510 records. In 2,502 of them each step names the next, and the last step names the first, so the animation loops. The other eight are one character's turn to talk: `n303`'s `talk_*` records. In those, the last step names itself, which would hold the last frame.

So nothing in a record says when a looping animation stops. The breaking pots and barrels loop like all the rest. What removes the shards is not in the record.

### A villager's animations

A villager carries twelve animations: four walks of four steps each, and eight one-frame stands.

| animation | frames |
|---|---|
| `walk_down` | 0, 1, 2, 1 |
| `walk_up` | 3, 4, 5, 4 |
| `walk_left` | 6, 7, 8, 7 |
| `walk_right` | 9, 10, 11, 10 |
| `stand_down` / `stand_l_down` | 1 / 12 |
| `stand_left` / `stand_l_up` | 7 / 14 |
| `stand_up` / `stand_r_up` | 4 / 15 |
| `stand_right` / `stand_r_down` | 10 / 13 |

Every one of the sixteen frames is used. A stand is the middle frame of the walk facing the same way. For example, `stand_down` is frame 1, the neutral pose of `walk_down`. The four diagonals have no walk, and use frames 12 to 15.

A breaking sheet carries one animation: frames 0, 1 and 2, each held for 4.

**Which way round the eight stands go was settled by looking, not from the data.** They are listed in a consistent rotation, but nothing in the file says whether the rotation turns through the character's left or its right. Drawn one way, the village dog stands with its head where its tail should be. Drawn the other way, it is a dog. `down` and `up` look the same when mirrored, so only a character seen side-on can settle the question. That is why an animal settled it and the people did not.

## Examples

- **Villagers:** frames are 32x40, built from two parts. The top eight rows are a 32x8 part at 0,0, and a 32x32 part sits below at 0,8.
- **The village horse, `n099a`:** frames are 40x40, built from four parts: 32x32 at 0,0, 8x8 at 32,0, 8x32 at 32,8, and 32x8 at 0,32.
- **The breaking pot:** three frames of 56x32. Each is built from 8x32, 8x32, 8x32 and 32x32 parts side by side.
- **The breaking barrel:** frames built from 8x32, 16x32 and 32x32 parts.

## Evidence

The strongest check is to walk each sheet using nothing but its parts' own sizes. **On 1,314 of the 1,316 sheets, the walk lands exactly on a palette's count word.** A wrong reading does not do this. The two exceptions:

- `n001a_test`, whose count word is 0
- one sheet whose parts run past the end of the file

| check | result |
|---|---|
| sheets whose frames lead exactly to a palette | **1,314 / 1,316** |
| the word after each frame's part count | 0 on 4,251 / 4,251 frames |
| parts inside their frame | 4,250 / 4,251 |
| parts per frame | 2 on 2,928 frames, 4 on 1,303, 1 on 39, 3 on 4, 6 on 2 |
| part sizes | 32x8 on 3,195 and 32x32 on 3,189; then 8x8, 8x16, 16x16, 16x8, 8x32 |
| palette counts | 16 on 1,288 sheets; 14 on 12, 12 on 9, 10 on 3, 8 on 2 |

## Earlier readings

For a long time a sheet was read as one image: rows of pixels from the header to the palette, cut into frames. Every reading of that kind was a fit, and each one failed:

- **Dividing the image evenly** put bands of one frame inside another.
- **A pitch of 664 bytes**, measured from the bytes' own period on the villagers, cut clean figures. That pitch is exactly one villager frame read as parts: a frame header, two part headers, a 32x8 part and a 32x32 part, or `8 + 8 + 128 + 8 + 512`.
- **Eight rows were cut off and dropped** as "a strip in front of the figure", taken to be a squashed copy of it, a shadow or a reflection. Those rows were really the top of the figure, a part of its own. Characters were drawn without their heads or their legs.
- **The header's "width"** was really frame 0's width.
- **The header's "unknown" field at `0x08`**, 2 on some sheets and 4 on others, was really frame 0's part count. That is why the "stride" came out eight narrower on the four-part sheets.
- **A palette found by searching for a count of 16** missed the breaking sheets, whose counts are 12 and 14.

Those measurements were not wrong about the bytes. They were measuring the parts without knowing it.

## Not established

- When a looping animation stops, including when a breaking pot's or barrel's shards are removed. Nothing in the record says.
- Which way the stands rotate. It is known only from looking at the drawn sheets.

## See also

- [Area-Cast](Area-Cast): the cast lists whose `kind` decides sprite or model
- [Item-Icons](Item-Icons): item icons are also `.spr` sheets
- [Mini-Map](Mini-Map)
- [2D-Graphics](2D-Graphics)
