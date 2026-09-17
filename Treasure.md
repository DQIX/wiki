# Treasure

Each map that has treasure has one member in `/data/scenario/treasure.nsarc`, named `<map>.bin`, plus three random-treasure tables named for no map. Every non-empty member is a [tagged data table](Tagged-Data-Table). The record layout, the game-wide treasure numbering, positions and facings are read; the contents of chests are read for items (confirmed) and gold (INFERRED); which kind is a chest, pot or barrel is only partly settled; the chest model is identified from its shapes. Several fields are not established.

All observations were made on the European release (game code `YDQP`).

## The archive

268 members. Two are empty (`M09M05`, `D13M02`). Three — `randTBox`, `randTD`, `randTTT` — are named for no map. Every non-empty member walks to its string table, and the first header word, `unknown_0x00` to the tagged data table, is the record count on all 266.

| tag | values | seen | meaning |
|---|---|---|---|
| `0x65` | a string | 266 files | a date and time, 2009 — when the file was written, by the look of it |
| `0x64` | a string | 266 files | the same date as `yymmdd` |
| `0x66` | an integer | 263 files | **the game-wide number of the file's first treasure** — below |
| `0x67` | 3, 5 or 6 | 821 records in 263 files | one treasure |
| `0x6A` | an integer | the three `rand*` tables | their row count |
| `0x69` | an integer | the three `rand*` tables | a row — see [Random treasure](#random-treasure) |

### Treasure numbering

**`0x66` numbers every treasure in the game.** Take each file's span as its `0x66` value up to that plus its count of `0x67` records. The 263 spans run from 0 to 847 without overlapping. The only two gaps, 13 wide each, fall where the two empty files sort (`M09M05` after `M09M04`, `D13M02` after `D13M01`). So a treasure's number is its file's first plus its place in the file.

INFERRED: that number is what an opened treasure is remembered by — it is the one numbering that covers every treasure exactly once.

### Integer and float values

**A number's type bits say how to read it.** A whole number is stored as an integer (type 1) and anything else as a float (type 2), so one position can mix the two. 50 coordinates are integer-typed, among them 0, −2, 2 and 7, and two facings are the integer 1.

INFERRED, and tested: in `C04M04` six treasures with integer-typed x stand in a grid at −2, 0 and 2, 0.035 world units up from a floor at 0.022 — the same lift as the float-typed treasure in that room.

## Layout

A `0x67` record, by its number of values:

| values | records | kind (value 1) | reads |
|---|---|---|---|
| 3 | 145 | all `0x30` | `unknown_0`, kind, `unknown_2` |
| 5 | 448 | `0x10` (269), `0x20` (179) | `unknown_0`, kind, x, y, z |
| 6 | 228 | `0x8` (137), `0x40` (65), `0x4` (15), `0x0` (6), `0x9` (5) | `unknown_0`, kind, x, y, z, facing |

- **Position**, values 2–4, is in the files' own units, like every other position in the map files. Scaled as the maps are, each one tested stands 0.002 to 0.02 world units above its floor: the 21 treasures of `M01M04`, `M01M07`, `M01M08`, `C02M01` and `C01M12`, and those of `C01M14`, `C01M15`, `C04M04` and `D03M05`. At a half, twice, eight or sixteen times that scale, none of them finds a floor under it at all. See [Map-Collision](Map-Collision).
- **Facing**, value 5, INFERRED to be radians: the 128 float-typed ones run 0.05 to 6.28, with 3.14 and 1.57 among the commonest, and 98 of the other 100 are 0. Only the six-value kinds have one — which a chest would need and a pot would not, also INFERRED.
- **Kind**, value 1: which kind is a chest, a pot or a barrel is not established. **`0x30`, the three-value kind with no position, is what a cabinet holds** — below. INFERRED: `0x10` is a pot and `0x20` a barrel. The random table they share with the cabinet is `randTTT` — *tsubo*, *taru*, *tansu*: pot, barrel, cabinet — and the cabinet is the third kind, `0x30`, so the first two are taken in the name's order. Nothing else says which is which.
- **`unknown_2`**, value 2 of a three-value record: in the village it is the number of the room's cabinet holding it, less one — `M01M03`'s two records read 0 and 1 beside cabinets `G1` and `G2`, `M01M09`'s and `M01M10`'s one reads 0 beside their `G1`. That holds on 45 of the 89 maps that have such records. Elsewhere it runs on across an area instead — `M03M05` 93, `M03M08` 94 and 95, `C01M14` 13 and 14 against cabinets `G1` and `G2` — so what it counts is not established.

## Cabinets

**Cabinets hold the position-less treasure.** A cabinet is a map piece whose resource ends in `G` and a number (see [Motion-Tables](Motion-Tables) for how it opens). On 62 of the 89 maps with kind-`0x30` records the map has exactly as many cabinets as records, and in the village every record's cabinet is named by its third value.

INFERRED: a map's cabinets hold its kind-`0x30` records, paired in order. The 27 maps whose counts differ are mostly names this matching does not reach — `H02`'s records against pieces named `H02M00G*`, and `R05M01` with its 22 lettered copies.

## Contents

**What is inside is value 0's low half, read by the kind.**

| kind | value 0, low half |
|---|---|
| `0x8`, `0x9` | an item's id — **all 142 of their records name an item** in the item names (a mini medal, a seed of strength, linen gloves…) |
| `0x4` | 50, 210, 1,000, 1,500, 1,700, 2,000, 3,000, 5,000 — gold, INFERRED |
| `0x10`, `0x20`, `0x30` | 0 to 20 — a rank to draw at from a random table, below |
| `0x40` | 1 to 5 — a rank to draw at from a random table, below |
| `0x0` | 0 on all six |

The high half runs on within a kind — unique on all 269 of `0x10`, 179 of `0x20` and 145 of `0x30`, on 135 of 137 of `0x8` and 62 of 65 of `0x40` — and is not established.

### Item names

`/data/prm/itemname.gp2/itemname_<lang>.nat`, as far as it is read here: a header word whose low half is the record count (1,178 in English), then 16-byte records — two offsets, a word that differs by language, and an id — then strings. An offset counts from the end of the records, and the two are singular and plural: record 0 is `wonder helm` and `wonder helms`. A chest's value names its item by that id. See [Items](Items).

## Random treasure

`randTBox`, `randTD` and `randTTT` sit beside the maps. Each `0x69` row is one word:

| bits | meaning |
|---|---|
| 26–31 | rank |
| 23–25 | what it gives: 1 gold, 2 an item, 3 a monster (INFERRED, below) |
| 7–22 | the gold amount, the item's id, or the monster's number |
| 0–6 | weight among the rank's rows |

Read off the whole cartridge: taking bits 7–22 as an item id lands on one for 61 of `randTBox`'s 68 rows, 147 of `randTD`'s 162 and 80 of `randTTT`'s 98, and every row that does not is a gold or a kind-3 row; no other alignment comes close.

`randTBox` has ranks 1 to 5, `randTD` 1 to 10, each rank's weights coming to 100. `randTTT` has 1 to 20, its weights coming to 20 to 50.

INFERRED: kind `0x40` draws from `randTBox` — its values are 1 to 5 — and pots, barrels and cabinets from `randTTT`, the shortfall below 100 being their chance of nothing. `randTD` is no village treasure's; its name and ten ranks suggest the treasure-map grottoes.

### Kind 3: a chest that is a monster

INFERRED, on three counts that agree:

- **Where its rows are.** All ten are in the chest tables: `randTBox` ranks 4 and 5, `randTD` ranks 3 to 10. `randTTT`, the pots', barrels' and cabinets', has none.
- **How its value climbs.** 38 at `randTBox` 4 and `randTD` 3; 39 at `randTBox` 5 and `randTD` 4 to 7; 40 at `randTD` 8 to 10 — each a weight of 5 to 15 of the rank's 100.
- **What 38 to 40 are.** In the [monster list](Monsters), the records numbered 38, 39 and 40 are `z009a`, `z009b` and `z009c` — cannibox, mimic and Pandora's box, the three monsters that pose as chests, weakest first. And the [system strings](System-Strings) run "Oh no! The chest was really `<str_1>`!" · "`<ACTOR>` unlocks the chest." · "It's empty!" · "a cannibox" · "a mimic" · "a Pandora's box".

The monster list's own number field settles that the chest rows' values are the monsters' own numbers, not a count of list entries (see Earlier readings). Still INFERRED: that the row gives that monster, which is what the three counts above say.

The chest's own words are system strings: message 42 is "Oh no! The chest was really `<str_1>`!", and messages 46 to 48 are the three monsters with their article — each "a " and a name in the monster list, so the phrase for a monster is found by its name.

## The chest model

**The chest model is `T00GDS01`–`04`, in `/data/bin/icon.nsarc`** — the archive of things the engine draws in the world by itself: speech bubbles, battle cursors, the pot and barrel sprites, a coffin (`kanoke`) and a round shadow (`kage`).

**They are two chests, each a body and a lid:**

| model | part | shape | texture |
|---|---|---|---|
| `T00GDS01` | body | a box 0.80 by 0.68 by 0.41 whose top face is drawn as the dark inside; 18 vertices | a 64×64 texture, red-brown |
| `T00GDS02` | lid | a dome 0.23 high reaching 0.68 along +z from its own origin; 22 vertices | the same red-brown texture |
| `T00GDS03` | body | as `01`; 18 vertices | a second texture, grey |
| `T00GDS04` | lid | as `02`; 24 vertices | the grey texture |

**How the two go together is read from the casino's prize chest**, `/data/enemy/z077a_i0.chr`. Its model's nodes are `light_off`, `T00GDS01` and `T00GDS02`. The lid's node stands at (0, 6.3, −5.2) over a body 6.29 high and 5.21 either side — on the body's top, its origin on the body's −z edge, the dome then covering the body exactly (the icon files are the same pieces at a fifteenth of the size). The lid's origin is its hinge: **the back is −z, the front +z**, as the chest in `M01M08` stands, with no floor behind its −z side.

Neither of the casino chest's motions, `GGG_i` and `777_i`, turns the lid; no file found animates one. Nothing names these as chests: that is read from the shapes.

INFERRED: they are in the map files' own units — 0.41 is 28% of a person, where in the characters' space, the coffin's, it would be 1%. The kinds with a facing are chests, and kind `0x40` takes the second, grey one.

### The opening motion

The player's figures carry `takara.nsbca` (*takara* is treasure) beside `hirou.nsbca`: 14 frames, a crouch to the forearms' lowest on frame 5, at a chest lid's height, and a lift up and forward to their highest on 9. INFERRED from the motion's shape: it is the Hero opening a chest, the lid going back with the hands. See [NSBMD](NSBMD).

## Pots and barrels

**No file on the cartridge is named for a chest**, with every leaf walked, `.gp2` members included (the chest model above was found only after this search, which went by name). `/data/chara_sub/box.chr` is a crate of five quads and one texture. `taru` and `tsubo` — barrel and pot — are 2D [sprites](Sprites) in `/data/ani` and in the menu icons, and nothing else. The rooms' own models carry no such object. Each comes in three sheets, the same in both places:

| sheet | header | decodes as a sprite? |
|---|---|---|
| `taru_01`, `tsubo_01` | 1 frame, 32×32 and 24×32 | yes |
| `taru_02`, `tsubo_02` | 3 frames of 56×32 | no |
| `taru_03`, `tsubo_03` | 1 frame of 16×16 | `tsubo_03` only |

The `_02` sheets name their one animation `taruware` and `tsuboware` — *ware* is breaking — so they are INFERRED to be the smash. They do not decode because no palette sits where the sprite format's size rule puts one: three frames of 56×32 need 2,688 bytes of pixels, and every candidate count word of 16 comes before that (or unaligned, at 48 wide). So their pixels are not laid out like a villager's, and how they are laid out is not established.

`taru_03` has no candidate palette at all. Its animation is named `tsubo_03`, which suggests a copy of the pot's small sheet, but what `_03` is — a shard, perhaps — is not established either.

Nor is a chest named inside a model or a texture set. Of 8,207 models and the 23,585 textures of 1,495 standalone texture files, the one texture named `takara` — and the one material — belong to `F99M0000`, which is not a chest: nine flat panels lying at height 0, `takara` a grid of 52 vertices beside a `num` grid the same size, with `train`, `umi` and monster names for the rest. A test sheet of textures, by the look of it. Pots and barrels turn up only as parts of a few rooms' own models (`tsubo` with a `futa`, lid, in `D04M02E4`; `taru` in `M08M0300`).

## Evidence

- Treasure numbering: the 263 `0x66` spans, 0 to 847, with two 13-wide gaps at the two empty files.
- Positions: tested against the collision floors of `M01M04`, `M01M07`, `M01M08`, `C02M01`, `C01M12`, `C01M14`, `C01M15`, `C04M04`, `D03M05`; integer-typed coordinates in `C04M04`.
- Item contents: all 142 kind `0x8`/`0x9` records name an item.
- Cabinet pairing: counts agree on 62 of 89 maps; `unknown_2` matches the cabinet number on 45 of 89.
- Random rows: item-id alignment of bits 7–22 over all three tables.
- Chest monsters: the monster list's numbers 38–40 and the system strings' chest messages.
- Chest model: node layout of `/data/enemy/z077a_i0.chr`; the `M01M08` chest's placement.

## Earlier readings

- `T00GDS01`–`04` were first read as a chest shut and the same chest open. Drawn so, a chest stood open until it was opened and then showed only its lid. They are a body and a lid, as the casino chest's nodes show.
- The kind-3 values 38–40 were first matched by counting the monster list's codes from 1 (the 38th to 40th codes are `z009a`–`z009c`). The list's own number field gives the same three, and is what settles that the values are monster numbers, not a count.

## Not established

- Which kind is a chest, a pot or a barrel (only `0x30` = cabinet is read; `0x10` pot and `0x20` barrel are INFERRED).
- What `unknown_2` counts outside the village.
- The high half of value 0.
- The kind `0x0` records (value 0 is 0 on all six).
- How the `_02` sheets' pixels are laid out; what the `_03` sheets are.
- Whether the three-count reading of kind 3 (the row gives that monster) holds.

## See also

- [Tagged-Data-Table](Tagged-Data-Table)
- [Monsters](Monsters) — the monster list and its numbers
- [System-Strings](System-Strings) — the chest's messages
- [Items](Items)
- [Sprites](Sprites)
- [Motion-Tables](Motion-Tables)
- [Map-Collision](Map-Collision)
- [Map-Objects](Map-Objects)
