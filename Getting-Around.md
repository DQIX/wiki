# Getting around

Ladders and vines, locked doors and chests, the ferry, and where the ship's code lives. Read 6 October 2026.

> **USA only** for the code (the ARM9 and overlay 17), read through the [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the files and their values.

## Ladders and vines

A ladder is **two regions of a map's link table** (its `.bmbl`, see [Map archive](Map-Archive)): a `0x73` of **type 9** at each end, each followed by its `0x74`. There is no ladder object, collision attribute or map flag. Vines are the same thing; there is one climbing code.

The `0x73` is read as every region's is (`func_0201d530`): a centre, a size, an angle for the box, and a second angle, value 8, which for a ladder is **its facing** — the way the Hero faces climbing up.

The `0x74` (`func_0201d638` case 9, `0x0201dbf8`):

| value | kept at | what |
|---|---|---|
| 0 | `+0x2c` | this end's number |
| 1 | `+0x2e` | the other end's number |
| 2 | `+0x30` | 0 on all 56; nothing found reads it |
| 3 | `+0x31` | flags: bit 0 this end is the **top**; bit 1 leaving by it **changes map**; bit 2 the new map is entered **on a ladder** |
| 4 (bit 1) | `+0x32` | the map, by code |
| 7–10 | `+0x38`, `+0x68` | where the Hero arrives, and the facing there |
| 12–20 | `+0x44`, `+0x50`, `+0x5c` | three more positions, as a doorway's `0x74` has |
| 21, 22 (bit 2) | `+0x6c`, `+0x6e` | how far up the ladder, and which end, in the new map |

**EU only:** 56 ends, 28 ladders, in 20 maps — Dourbridge (`M08`), the Heights of Loneliness (`D07`), `D08`, the Bad Cave (`D09`), `D13`, the Tower of Nod (`T02M08`) and the Realm of the Mighty (`X04`). Every pair names each other, and one of each is the top. Eleven ends lead out of their map, and carry a map code in the same slot a doorway's does, so a reader that takes every `0x73` with a map name for a doorway takes these too: only type 2 is a doorway.

### Starting a climb

`func_ov017_021975e4`, the first of the field's checks each pass. Nothing happens while B or X is held, while the Hero is already climbing or held, while the field is busy, or unless the Hero is walking (state 1).

For each type-9 region the Hero stands in (`func_02094b9c`), with **l** the ladder's facing, **f** the Hero's and **p** the +Control Pad's direction in the world (`field+0x4438`):

- At the **bottom** the Hero must face it (`l·f > 0`); at the **top**, face away (`l·f < 0`).
- A count (`field+0x42ee`) goes up each pass that `|l·p|` or `|l·f|` is over 0.8 (`0xccc`), and back to 0 otherwise. **On the third pass in a row the climb starts.**

The climb is a record kept on the Hero (`+0x26c`): which end it began at, the facings for leaving at each end (the bottom's − π, the top's), the bottom's centre, **the top's centre one unit lower**, and the two places it is left at — `bottom − d/4` and `top + d`, `d` the starting end's facing.

### Climbing

`func_02038598`, each pass, after the Hero's own update:

0. Turn at once toward the starting end, play `hasigo_in` once.
1. Move from where the Hero stood to just above the bottom (`+0x51`) or just below the top (`− 0xa3`) by the motion's progress. From the bottom the motion is advanced twice more each pass. When it ends, `hasigo_loop`.
2. **Down** goes down and **Up** up, `0xf5` a pass, x and z following y along the line from bottom to top. Going down plays `hasigo_loop` forward, going up backward; held still, it stops where it is and goes on from there. Below the bottom, walk off there; above the top, `hasigo_out` once. Either way, an end that leads out changes map instead.
4. Getting off at the top, y goes a tenth of the way to the top's own height each pass. When the motion ends, walk off.
5. Walk straight to the place at `0x189` a pass, running. Then the climb is over.
6. Another map: a map request of that end's map, place and facing, as a doorway's.

The touch screen's drag also climbs.

## Locked doors

A locked door is **its doorway's records**, kind 17 (the field's doorways, see [Triggers](Triggers)), which test the keys by **condition 18, the party holds an item**, and 19, holds none (`func_0205faf4`, through `func_02086aec`: what each member carries and wears, and the bag). The keys are items 22042 (the thief's), 22043 (the magic) and 22044 (the ultimate).

Each door's records, the first that holds:

- the door's flag set: `109`, unblocked;
- the key that fits held: `108`, blocked for now, and a talk with the door's own "character" (`118`) with a label whose talk record does `109` and sets the flag;
- any other key, or none: `108` and a talk with another label — "It doesn't look like any of the keys in `<LEADER>`'s possession will open it." — and nothing after.

**EU only:** 175 records test a key this way, in 17 areas.

## Locked chests

A treasure's value 1 (see [Treasure](Treasure)) keeps **the lock in bits 0–1** (`unk_4_0` in `LootManager_CreateContainer`): 1 a thief's lock, 2 a magic lock. The chest's opening (`func_ov017_021adcb0`, `0x021ade84`) counts the three keys: the ultimate opens any, a thief's lock the thief's or the magic key, a magic lock the magic key.

- Opened: system strings 41 and 43 together, "The treasure chest is locked. `<ACTOR>` unlocks the chest.", and after 15 frames the chest opens.
- Held no key of the two: 41 alone.
- Held one that does not fit: 41 and **44, which neither the European nor the US cartridge has**.

**EU only:** six chests are locked, all thief's locks: `C01M16`, `M05M05`, `M08M07`, `M09M05`, `M09M14`, `S08`.

## The ferry

Porth Llaffan's ferryman (character 9 of `M05`, map 1500), from 8.1: his talk asks, and on Yes his talk record sets flag 63 and plays `ev09710`, "Anchors aweigh!", which goes on to `ev09715` at Slurry Quay (`S08`). It is records and scenes only. It goes one way.

## The ship

Not read yet. Its code is the ARM9 run just before the Starflight Express's, `func_020a6084` to `func_020a7eb8`, which names `data/chara_sub/s201.chr`, `data/bin/percol.bin` and `data/ani/bg_slime3.pac`. The field calls `func_020a654c` each pass and `func_020a6aac` as a map loads. Its place goes through `func_ov017_021d1a18`, which Zoom's landing also calls (see [Travel](Travel)), with game-wide flag `0x2b` set.

## See also

- [Map archive](Map-Archive), [Map collision](Map-Collision)
- [Triggers](Triggers)
- [Treasure](Treasure)
- [Travel](Travel)
