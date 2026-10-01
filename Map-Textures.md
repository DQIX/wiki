# Map-Textures

Each map archive has a `.bmbl` file, in the `.ambl` beside the `.amdj` that holds the geometry. It names the map's textures and the maps it connects to. Its records hold the map's **doorways**: a trigger volume, the destination map, and where you arrive. The header, string table, record walk, trigger volume, destination and arrival are confirmed. The tail after the arrival is not established. Counts are from the European release (game code `YDQP`).

## The `.ambl` archive

There are 681 `.ambl` archives in all:

- **667 per-map archives.** Each holds one `.bmbl` (144 to 4,320 bytes, median 432), the map's `.nsbtx` textures (737 in total, see [NSBMD](NSBMD)), a `.dat` (657 in total), and on five maps a `.bpos`.
- **14 grouping archives** named `ats_B`..`ats_Z`, which hold the cartridge's 504 `.bats` attribute tables instead. Only the per-map archives carry a `.bmbl`.

A map's **textures** are in the `.ambl`. A map built from its `.amdj` alone has none. (One earlier inventory said `.ambl` holds the `.bats` tables. It does not.)

## What a texture is called

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`).

**A map texture is named for what it is.** The name is the map's own code, then **three letters saying what the surface is**, then a number: `m01m00wtr01` is water, beside `m01m00grs01`, grass. Across the 4,337 models under `/data/map` the tags come out as a level artist's vocabulary:

| tag | count | | tag | count |
|---|---|---|---|---|
| `grd` ground | 3,694 | | `sdw` shadow | 868 |
| `wal` wall | 2,332 | | `dor` door | 739 |
| `clf` cliff | 2,124 | | `wtr` water | 726 |
| `grs` grass | 1,934 | | `hus` house | 694 |
| `tre` tree | 1,632 | | `sky` sky | 606 |
| `stn` stone | 1,451 | | `flw` flower | 452 |

`hus` and `tre` are also **node** names inside the same models, so geometry and materials share the vocabulary. Some tags are Japanese words: `iwa` rock, `zou` statue, `kabe` wall, `yane` roof, and `dok`, INFERRED to be *doku*, poison (see [Poison-Marsh](Poison-Marsh)).

**Water is found by its texture name, not by its collision**: the collision attribute word is not a terrain type (see [Map-Collision](Map-Collision#the-attribute-word)). The village has eight `wtr` surfaces, the river across the middle of the map and the pools at the falls.

Only the tag is read. What each means to the game (which surfaces are solid, which sound different underfoot) is not established.

## Layout

### Header

The same as the shared [tagged data table](Tagged-Data-Table) header.

| offset | type | meaning |
|---|---|---|
| `0x00` | `u32` | `unknown_0x00` |
| `0x04` | `u32` | string table offset |
| `0x08` | `u32` | string table size |
| `0x0C` | `u32` | string count |
| `0x10` | | the record stream, running up to the string table |

Each record header is `u16 tag, u8 count, two type bits per value`, **padded to four bytes**. Records address strings by byte offset, not by ordinal.

**EU only:** 25 `.bmbl` begin with the word 16, the table header's own size. Read as an LZ10 header, that is `0x10` and a declared size of 0, an empty stream; a reader that tries every file as LZ10 first takes them for empty. They are not (see [DS-Compression](DS-Compression)).

### What the names are

`M01M0000.bmbl` names twelve strings:

- its own two textures, `M01M00T1` and `M01M00T2`
- the map itself, `M01M0000`
- **nine other map codes**: `M01M01`..`M01M08` and `F01`

Every one is a code `maplist9.bin` knows (see [Map-List](Map-List)) and an archive that ships.

**You cannot classify a name from the file alone.** `M01M00T1` is this map's texture and `M01M01` is a neighbouring map, and both begin with the map's own code. To pick out the neighbours, test each name against the map index's codes and drop the map's own code.

## The doorways — `0x72`, and `0x73` + `0x74`

A doorway is a volume you walk into, the map it leads to, and where you come out. Two record forms carry one, and both are live.

| | trigger volume | destination | arrival | tail |
|---|---|---|---|---|
| `0x72`, 25 values | slots 0-6 | slot 8 | slots 11-14 | 15-24 |
| `0x73` + `0x74` | `0x73` slots 1-7 | `0x74` slot 4 | `0x74` slots 7-10 | 11-23 |

- The trigger volume is `x, y, z, width, height, depth, angle`.
- The arrival is `x, y, z, facing`.
- Positions are in the units `.bmdj` placements use (see [Map-Objects](Map-Objects)). These are the same units models and collision are in once each is read at its own size. This is confirmed by arrivals landing on the destination map's own collision floor: 1,096 of 1,098 do.
- Angles are radians and are not scaled.

**`width`, `height` and `depth` are the whole size of the volume, not half of it.** They were measured against the doorway models the triggers guard, which is the one reference that does not favour a bigger answer:

| | doorway model, as drawn | its trigger, as stored | ratio |
|---|---|---|---|
| the village's nine doors | 0.193 tall, every one | 0.250, every one | 1.30 |
| the inn, from the inside | 0.179 tall | 0.188 | 1.05 |

A trigger a little bigger than its door is what you would expect. Read as half-sizes, the village's triggers would stand 0.50 tall: two and a half doors, and nearly three times the height of the character walking through.

The `height` is a nominal doorway height, not a measurement: 2 raw units on almost every doorway on the cartridge. Do not test against it.

**Arrival is always three slots past the destination**, in both forms, and so is the rest of the tail. That is what makes these one structure rather than two.

### `0x73` and `0x74`

A `0x73` is a trigger, and the `0x74` that follows it says what the trigger does.

- They are adjacent on **2,301 of 2,301** records.
- No `0x74` that names a map lacks a `0x73` before it.
- Most `0x74` records do something other than change map. Those are not decoded. Of the 440 map-changing `0x74` records read, 415 have 24 values, and the rest are shorter.

#### A `0x73` is a region, and its first value is its type

> **EU only.** Code addresses are the USA release's, from the [dqix-decomp](https://github.com/DQIX/dqix-decomp); the files were read on the European release (`YDQP`) and are not yet checked on the US one (`YDQE`).

Read from the game's code on 28 September 2026. The link table is run by a handler table at `0x020ef3d8`, for tags `0x64` to `0x7e`.

- **The `0x73` handler** (`func_0201d530`) reads a **type**, a centre, a size (width, height, depth), an angle in radians and one more angle, and makes a squared radius from the width and depth. It adds the region through `func_0201e710`.
- **The `0x74` handler** (`func_0201d638`) fills in what the region does, by its type.
- **Type 2 is a doorway. Type 3 is an area of the map**, numbered by its `0x74`'s first value. There are 22 type-3 regions on the cartridge, in 15 maps. Stornway's throne room has areas 0 and 1; Zere's one is turned 45°. How areas are tested and what entering one runs is on [Triggers](Triggers).

The types on the cartridge:

| type | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| regions | 283 | 184 | 670 | 22 | 63 | 113 | 160 | 163 | 56 | 204 | 360 | 23 |

Types other than 2 and 3 are not read.

A region's test (`func_02094b9c`): it is off if flag 8 is set; it uses the turned-box test when the region has depth; and it carries once-only flags. What sets those flags for an area is not read.

### The destination slot

The destination is at a fixed slot, and the header's type bits mark it as a string. **1,418 records mark that slot a string, and none marks a second slot one.** Two `0x72` records mark it a string but store `0xFFFFFFFF`: a doorway with no destination.

### The tail is not established

After the arrival, each form has a marker and then **three more positions**. On 847 of 1,393 records they repeat the arrival exactly, which suggests somewhere for the party to stand. But on 407 they are more than four units from the arrival, and on one they are 170 units away, which no line-up explains.

### Where the two forms overlap

106 maps carry both forms. 315 carry only `0x72` and 23 only `0x74`, so neither form is dead data.

Where both describe the same doorway, they do not coincide. Across the village's seven shared doors, the `0x73` trigger stands **one raw unit from the `0x72` one every time**, and is one unit deeper. The two agree exactly on the angle, which is what identifies them as one door rather than two.

Where both exist, the `0x73`/`0x74` arrival is the better of the two by both measures available:

| | arrival stands on the destination's floor | arrival is within half a unit of the door back |
|---|---|---|
| `0x72` | 736/958 (76.8%) | 755/935 (80.7%) |
| `0x74` | 376/440 (85.5%) | **404/424 (95.3%)** |

A form can also repeat a doorway within itself. The village lists three of its ten `0x74` twice, alike except for two integers that are not decoded. Doors that lead to the same map from different places are distinct: of 196 same-destination pairs, 87 stand within 0.3 units, and the rest are over three times as far apart.

## Evidence

"Doorways after merging" counts a doorway described by both forms once, and drops repeats within a form.

| check | result |
|---|---|
| files whose string table reads | **667 / 667** |
| declared string count matches names found | **667 / 667** |
| files whose records walk exactly to the string table | **667 / 667** |
| directed links to a known map code | 898 |
| **links that are reciprocal** | **858 / 898 (95.5%)** |
| `0x73` immediately followed by a `0x74` | **2,301 / 2,301** |
| records marking the destination slot a string | 1,418 |
| records marking a *second* slot a string | **0** |
| transitions read | 1,416: 976 `0x72`, 440 `0x74` |
| doorways after merging the two forms | 1,150, across 444 maps |
| doorways naming a code `maplist9.bin` knows | **1,149 / 1,150** |
| **maps whose doorways match the map codes in their own string table** | **442 / 444** |
| arrival stands on the destination map's collision floor | 884 / 1,132 (78.1%) |
| arrival within half a unit of the door back | 932 / 1,099 (84.8%) |

Two independent things make the reading trustworthy.

**Reciprocity.** Each interior names exactly its exterior and nothing else: `M01M01`, `M01M02` and `M01M08` all name `M01` alone. `F01` names `M01`, `D01` and `S01M01`. Names that only happened to look like map codes would not agree in both directions 858 times.

**The two halves of the file agree.** The doorways in the record stream name exactly the map codes in the string table, on 442 of the 444 maps that have any. Angel Falls' nine doorways are its nine named neighbours (eight houses and the road out to the field), and their trigger volumes stand where its doorway models stand. The two exceptions have explanations. `M07` has a door to `M07M07` that its string table does not name. `X05M10` has a door leading back into itself, and a map's own code is excluded from its neighbour names.

The arrival checks are weaker evidence and are reported as found. They fail where the destination map has no collision mesh assembled, where the arrival stands on something the mesh does not cover, and (for the door-back check) where a map is reached from somewhere that does not lead back to it.

## Not established

- `unknown_0x00` in the header.
- The tail of both doorway forms: the marker and the three positions after the arrival.
- What non-map-changing `0x74` records do. **EU only:** a `0x73`'s type says which kind of region it is; types 2 (doorway) and 3 (area) are read, the other types are not.
- **EU only:** what the second angle of a `0x73` region is for.
- The two integers that differ between repeated `0x74` doorways.
- The `0x72`, `0x73` and `0x74` slots not given in the doorway table.

## Earlier readings

- **"The record stream does not decode."** A walk of `M01M0000.bmbl` lost sync after five records, and a generic table walk failed on 387 of the 667 files. The cause was the record header: the padding to four bytes was missing. With it, the records walk on 667 of 667.
- **"Adjacency, not per-door targeting."** It was once concluded that which doorway leads to which neighbour is not in the file. It is, in the records. The observation behind the old conclusion was sound: `M01` has ten doorway *models* (`M01M00D1`..`DA`) against nine named maps, and across the cartridge those two counts agree on only 60 of the 172 maps that have both. A doorway model is scenery and a doorway record is a trigger. There is no reason for them to correspond: an arch can be decoration, and a trigger can have no arch.
- **A trap:** scanning records for values that happen to resolve to a string offset seems to work, but does not. Offset `0` is a valid name and zero-valued fields are everywhere, so the first name in the table looks referenced by almost everything. Only the type bits let you tell a name from a coordinate.
- **Half-extents.** The trigger sizes were once read as half-extents, because a doorway more often contains the point you arrive at coming back through it: 45.2% read as half-extents, against 8.0% read as full sizes. **That comparison cannot decide the question.** A box twice as big contains more points whatever the truth is, so the count favours the larger reading by design. It measures only the size ratio. It was also the wrong question: you arrive *in front of* a doorway, not inside it, so neither number should be near 100%. Read as half-extents, every trigger stands twice as wide and deep as it should. In a room the size of the village inn, that puts the way out most of the way across the floor.

## See also

- [Map-List](Map-List)
- [Map-Archive](Map-Archive)
- [Map-Objects](Map-Objects)
- [Map-Collision](Map-Collision)
- [Doors](Doors)
- [Tagged-Data-Table](Tagged-Data-Table)
- [Mini-Map](Mini-Map): its marks stand beside these doorways
- [Triggers](Triggers): the type-3 areas
- [Poison-Marsh](Poison-Marsh): the `dok` texture tag
- [NSBMD](NSBMD)
