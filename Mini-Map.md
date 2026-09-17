# Mini-Map

The DS's top screen shows a map of where the party is. It is drawn from the archive `/data/pack_lv5/minimap.gp2` (see [GPC2](GPC2)): 283 `.bmmp` layouts and 268 `.obg` pictures, plus other files not covered here. The `.obg` picture format is confirmed on all 268 files. The `.bmmp` tags are read, with the scale, the corner, and the mapping from a map position to a pixel **INFERRED** from fits. Several tags, and how the party's dots are coloured, are not established. Counts are from the European release (game code `YDQP`).

## The archive

Besides the `.bmmp` and `.obg` files, `minimap.gp2` holds files not described here:

- `z01` to `z05` as `.bncg` (`CHAR` head, 256 tiles) and `.bncl` (`PALT` head, 256 colours)
- `pd_ab_kari.bncg` / `.bncl` / `.bnsc` (`SCRN` head)
- `C01M0000.MAP` / `.MBK`
- `shipMPos.bin`

The ARM9 binary contains the names `minimapbg2`, `z%02d.bncg`, `z%02d.bncl`, `data/ani/obj_mm_w.pac` and `O00M0001.obg`.

## `.obg` — a picture

| offset | type | meaning |
|---|---|---|
| `+0x00` | `u8` | width, in 8×8 tiles |
| `+0x01` | `u8` | height, in tiles |
| `+0x02` | `u8` | `unknown_0x02`: 0 on all 268 |
| `+0x03` | `u8` | `unknown_0x03`: 137 on 117 files, 247 on 132, nine other values |
| `+0x04` | `u16` | tile count |
| `+0x06` | `u16` | `unknown_0x06`: 0 on all 268 |
| `+0x08` | `u16` × 16 | the colours, BGR555 |
| `+0x28` | 32 bytes × count | the tiles: eight rows of four bytes |
| then | `u16` × width × height | the tile in each cell, row by row |

- **Every one of the 268 is exactly `40 + 32 × count + 2 × width × height` bytes.** The village's `M01M0001` is 35×19 cells of 659 tiles, 22,458 bytes. The field's `F01M0001` is 32×28 of 822, 28,136 bytes. The pass's `S01M0100` is 21×25 of 507, 17,314 bytes.
- No cell names a tile past the count, and none sets a bit above bit 9, so no flip or palette bit is in use.
- **A pixel is a nibble, the low nibble on the left.** Drawn this way, the village's `INN` sign reads correctly. With the nibbles swapped, every pair of pixels is mirrored. That is the DS's own order for sixteen-colour tiles (GBATEK, "LCD VRAM Character Data").
- **Colour 0 is taken as clear — INFERRED.** It is the DS's rule for a sixteen-colour background. Here colour 0 lies only outside a picture's torn paper edge: 5,735 pixels of the village's picture, none of the field's, whose paper fills its rectangle.
- The sixteen colours of the village's picture are the first sixteen of `z01.bncl`, `1f 7c 0f 09 71 0d …`. What the `z` sets are for is not established.
- Besides the maps, `.obg` holds the screen's other pieces: `minimapbg`, `minimapbg2` to `4` (8×8 tiles of paper), `marker0` to `4`, `name*`, `barhp`, `barmp`, `pd_ab_*`.

### The markers are coloured dots

`marker0` to `marker4` are one tile each: a round dot with a darker rim, in **blue, green, pink, yellow and red**, in that order.

The same five dots, in the same order, are cells 3 to 7 of `/data/ani/obj_minimap.NCER` (see [2D-Graphics](2D-Graphics)). The party panels beside them in that file come in four colours, **blue, green, pink and orange**, which suggests one dot per party member, blue the first. `/data/ani/obj_mm.pac`, the sprite file the ARM9 names for the screen, holds a blue dot and a red one among its cells (5 and 7), along with a church, crossed swords and the HP/MP panels.

**On screen, each party member is a dot in their own colour.** A screenshot of the game in Stornway's church, with a party of four, shows:

- four dots in a two-by-two cluster on the town's map
- no arrow and no facing
- each dot in the colour of that member's name panel along the foot of the screen: the first member green, then lime, grey and dark red

So a dot's colour belongs to the character, not to a place in the party, and **the first member's dot is not blue**. None of those four colours is exactly a marker's colour, or one of the palette entries of `obj_minimap` or `obj_mm.pac`. The screenshot is blurred, and where the game takes a character's colour from is not established. No string in the code names `marker`. What the red dot marks is not known.

### The party panel

**The party panel is `obj_minimap`'s cell 2**: one 64×64 part, a dark name strip with a coloured bar at each end, then HP and MP bars and `:Lv`.

- Its other cells are the five dots (3 to 7, all in palette slot 4, one colour per tile), the level's digits `0`–`9`, `+1`–`+9`, and two HP and MP bars.
- Drawn in palette slots 0 to 3 (the part is in slot 0), the end bars are **blue, green, pink and orange**. Slot 0's is `(115, 189, 230)`. Slots 4 to 7 recolour the whole panel and are not member colours.
- The strip is rows 0 to 15: a border, dark from row 2 to 14 with the bars in columns 2–6 and 57–61, and a white line on row 15.

**The screenshot shows exactly these strips**: four side by side across the foot of the screen, 64 pixels each (the screen's 256), each with a name in white, and nothing of the rest of the panel. `obj_mm.pac` holds the same panel cut narrower in four steps, perhaps a slide animation. Its slots 0 to 3 are all blue.

## `.bmmp` — which picture, and where on it

A [tagged data table](Tagged-Data-Table). 279 read. `F07`, `H07`, `M05` and `M12` are empty files. The tags, with the value kinds the table's type bits give:

| tag | kinds | on | read as |
|---|---|---|---|
| `0x66` | integer, string | 279 of 279, once | `unknown` (0 on all), then the picture's name: an `.obg` in the archive on 279 of 279 |
| `0x6a` | string | 219 | the backdrop: `minimapbg2` ×205, `minimapbg3` ×13, `minimapbg4` ×1. The fields have none |
| `0x69` | float ×264, integer ×15 | 279, once | the scale (INFERRED, below). 3.2 in the village, 1 on the field, 2 in the pass. The integers are 4 on fourteen `C02`/`C04`/`D17` maps and 1 on `O00` |
| `0x64` | two integers ×278, two floats ×1 | 279, once | the picture's corner, in tiles (INFERRED, below). −18, −12 in the village. `S07M01`'s are the floats −15, −12 |
| `0x6b` | integer, one or more records | 278 | the maps the picture is drawn for: **the map index's id for the file's own map on 242 of 279**, for example `M01` 1100, `F01` 20001, `S01M01` 5101. Most of the 37 others are the `H` overviews, whose ids are fields' (`200xx`). `T00` has none |
| `0x6c` | float, float, integers | 249 records | a mark: a position, then the maps it stands for |
| `0x70` | (integer, string) pairs | 264 | map codes by id: **the id is the map index's for the code on 497 of 498 pairs** (`C02M07` has 206; the index has 207) |
| `0x65`, `0x67`, `0x68`, `0x6d` | | | `unknown`: `0x65` is 1, `0x67` 1 and `0x68` 0, 0, 0, 0 on all 279. `0x6d` is 3 ×60, 0 ×10, 4 ×6 |

Map ids are those of [Map-List](Map-List).

### Marks and doorways

The village's marks, beside its doorways in `M01M0000.bmbl` (see [Map-Textures](Map-Textures)):

| mark | stands for | at | the doorway to it |
|---|---|---|---|
| 1101 | `M01M01` | −3.29, 3.60 | −4.78, 3.74 |
| 1102 | `M01M02` | −20.20, −14.50 | −19.50, −13.00 |
| 1103 | `M01M03` | 18.44, 0.16 | 16.56, 0.38 |
| 1104 | `M01M04` | −28.28, −1.45 | −26.70, 0.27 |
| 1105, 1109 | `M01M05`, `M01M09` | −32.40, −10.09 | −28.80, −9.00 |
| 1106 | `M01M06` | −8.66, −6.44 | −7.36, −3.90 |
| 1107, 1110 | `M01M07`, `M01M10` | 27.58, −15.48 | 26.80, −13.50 |
| 1108 | `M01M08` | 31.10, −6.23 | 31.25, −6.00 |
| 20001 | `F01` | −7.16, 16.31 | −6.50, 18.00 |

So a mark is in the map's own units, the units a doorway is in. Every mark is within four units of its doorway, and eight of nine are within three. A mark naming two maps stands for a house and the floor above it.

## Where a point falls on the picture — INFERRED

**pixel = position × scale − corner × 8**, with x across and z down.

Drawn this way:

- the village's eight house marks land on its eight houses
- the road's mark (z 16.31) lands at pixel row 148 of 152, on the road off the bottom edge
- the field's marks land on the village, the pass and its other ways off
- the pass's two marks land at rows 4 and 187 of 200, its two ends

That the scale is pixels per unit and the corner counts tiles is read from these fits, not from code.

## Evidence

- `.obg` size formula holds on 268 of 268 files. No cell exceeds the tile count or sets a bit above bit 9.
- Nibble order: the village's `INN` sign.
- `.bmmp` tag counts across 279 non-empty files. `0x6b` and `0x70` checked against the map index.
- Marks against the doorways of `M01M0000.bmbl`.
- The pixel formula against the village, field and pass pictures.
- Dot and panel colours: a screenshot of the game in Stornway's church with a party of four.
- A room is shown on its area's picture: **observed** in that screenshot, taken inside Stornway's church, which shows the town's map with the party's dots on the church, just below its icon. The village's `0x70` and marks, which name all its rooms, suggested this.

## Not established

- `0x65`, `0x67`, `0x68`, `0x6d`, `0x66`'s first value, and the `.obg`'s `unknown_0x03`.
- Exactly where a room's party stands on its area's picture: whether the dots sit on the room's mark or beside it is not measured.
- How the DS scrolls a picture larger than its 256×192 screen, and how it lays out the backdrop.
- Which dot the game gives the Hero, how a character's dot colour is chosen, and what the other dots and `obj_mm.pac`'s church and swords mark.
- `obj_minimap`'s `.NCGR`, `.NCLR` and `.NCER` are standard Nitro 2D files, and `obj_mm.pac` wraps the same three. They are not decoded beyond the cells described above.
- The `z` sets, `pd_ab_*`, `C01M0000.MAP` / `.MBK` and `shipMPos.bin`.

## See also

- [Map-List](Map-List)
- [Map-Textures](Map-Textures)
- [GPC2](GPC2)
- [Tagged-Data-Table](Tagged-Data-Table)
- [2D-Graphics](2D-Graphics)
- [Pac](Pac)
- [Menu-Backgrounds](Menu-Backgrounds)
- [Sprites](Sprites)
