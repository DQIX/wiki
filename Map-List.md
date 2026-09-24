# Map-List

`maplist9.bin` is the cartridge's index of every map. It is a [tagged data table](Tagged-Data-Table), and it says what the maps *are*: each entry has an id, a region, a map code that names the map's archive, a builder's label, a space kind and (INFERRED) a music track. Seven of the 22 values per entry are read. The other fifteen are not established. Counts are from the European release (game code `YDQP`).

## Layout

| tag | meaning |
|---|---|
| `0x66` | number of map entries |
| `0x67` | one per map, 22 values |

Four of the 22 values are byte offsets into the string table, and three more are read. Slots count from 0, with each record header read as the shared table's: `u16` tag, `u8` count, two type bits per value, padded to a word.

| slot | meaning |
|---|---|
| 0 | the map's own id, which is how placements and triggers name the map |
| 2 | region, for example "Angel Falls" or "Gleeba" |
| 4 | **map code**, which is also the name of the map's archive |
| 5 | the name its builder wrote, for example "Inn", "Church", "Erinn's House Lv 1" |
| 6 | **the music**: an index into `bgm.sdat`'s sequence list (INFERRED, below) |
| 11 | a second code, usually one with a real attribute table, but not this map's |
| 17 | the space: `1` indoors, `2` outdoors, `0` neither |

Slot 0 is `0` on the 139 entries for maps that do not ship, and distinct on the rest (see [Area-Cast](Area-Cast) for how it was identified).

### Zero means empty, not "the first string"

A blank field holds zero. Zero is also the offset of the build stamp that opens the string table. If you resolve it as a string, every unset field comes out as a date. This is the one trap in this file, and it looks plausible until you notice every map was apparently built at 10:39:39.

## The music — INFERRED

This reading was made in September 2026, from the values alone. No code has been read.

Slot 6 is read as the track that plays on the map. On every one of the 871 shipping entries, it holds an index into the music archive's sequence list (see [SDAT](SDAT)):

- 844 name a sequence that has a file.
- 25 hold 80. These are the grotto boss floors. 80 is `BG_100`, the one sequence past the `ME_` jingles, which pins the numbering to the list's own.
- 2 hold 25, which has no file on the `YDQP` cartridge.

The values follow what the labels say:

| value | maps |
|---|---|
| 10 | all nine "Church" maps and the one "Chapel", and nothing else |
| 11 | the castle's 26 maps |
| 12 | the observatory's 22 maps |
| 13 | the abbey |
| 14 | the 85 field regions |
| 15 | the temple |
| 17 | the ship's five |
| 18 | "Field - Sky" |
| 19 | 94 dungeon maps across 67 regions |
| 22 | the 140 grotto floors |
| 23 | every `B01` battle stage: 137 of them, with the "Monster Modifier" test floor |
| 24 | the `B02` boss stages |
| 27 to 38 | the twelve legacy bosses' stages, one value each, in the bosses' order |

A village and its houses share one value, and its church has another. Angel Falls is 5, its church 10, the region round it 14, the Hexagon 19, and the Hexagoon stage `B02M15` is 24.

Not read:

- Whether anything else changes the track, such as the time of day or the story.
- `data/bin/mapbgm.bin`: 68 records pairing map ids with values from `0x0580` to `0x0857`. These values are not sequence indices.

## What it gives

1,010 entries, 872 distinct codes. The code names the archive: `M01` is `M01.amdj`. So this is the bridge from a place to the files that draw it. 667 of the codes name an archive that ships. The rest are development maps the cartridge kept an entry for, with names like "Debug Floor", "Bed Test" and "For Encounter Testing".

## Evidence

| check | result |
|---|---|
| map entries read | **1,010** |
| entries carrying a code | **1,010 / 1,010** |
| distinct codes naming an archive that ships | 667 / 872 |
| entries carrying an archive code with a real `.bats` | 722 / 731 |

Slot 0 joins exactly to the map word of every cast placement block on the cartridge (1,289 / 1,289, see [Area-Cast](Area-Cast)). Doorway destinations name a code this file knows on 1,149 of 1,150 doorways (see [Map-Textures](Map-Textures)).

## Not established

- Slots 1, 3, 7, 8, 9, 10, 12, 13, 14, 15, 16, 18, 19, 20 and 21.
- One reading was tried and **disproved**: slots 10 and 12 look like an exterior/interior pair on the ten maps of one village. They are not. Across the whole list, 48 maps labelled "Exterior" and 49 labelled "Interior" share the same combination of them.
- What slot 11's second code is for.
- Whether the music (slot 6) is the whole rule for which track plays.

## Earlier readings

An earlier reading took the record header as four bytes. That put every slot number two higher than the ones above.

## The places, by code

**An index, not a dump.** The file has 1,010 map entries and 1,006 of them
name a region, most being one floor of somewhere — "Stornway Castle - Lv 2".
What follows is one row per *place*: the area map's own code where there is
one, and otherwise the first interior that stands for it. Eighty-one rows out
of 213 distinct region names.

It is here because the code is what everything else refers to: a map archive
is `<code>.amdj`, a doorway names its destination by code, and a
reimplementation loading a map asks for one. The region is what to call it.

A place's interiors are its code with a suffix — `M01M07` is a house in
`M01` — so this table is also the way in to the rest of the file.

Two of these are worth a word. **`O00` and `O01` carry no collision mesh**,
so a reimplementation has nowhere to stand a character and the map never comes
up; whether they are backdrops rather than places is open. And **`M07` has a
doorway to `M07M07`**, which is the one destination on the cartridge that
names no archive.

Generated from the European release (`YDQP`); a different release may number
differently.

### Towns and villages

| code | region |
|---|---|
| `M01` | Angel Falls |
| `M02` | Zere |
| `M03` | Coffinwell |
| `M05` | Porth Llaffan |
| `M07` | Zere Rocks |
| `M08` | Dourbridge |
| `M10` | Batsureg |
| `M11` | Swinedimples Academy |
| `M12` | Wormwood Creek |
| `M13` | Upover |

### Cities and castles

| code | region |
|---|---|
| `C01` | Stornway |
| `C02` | Gleeba |
| `C04` | Gittingham Palace |

### The overworld

| code | region |
|---|---|
| `F01` | Angel Falls Region |
| `F02` | Western Stornway Region |
| `F04` | Doomingale Forest |
| `F05` | Eastern Coffinwell Region |
| `F06` | Western Coffinwell Region |
| `F07` | Newid Isle |
| `F09` | Slurry Coast |
| `F10` | Bloomingdale |
| `F11` | Dourbridge Region |
| `F12` | Lonely Plains |
| `F15` | Djust Desert |
| `F16` | Hermany |
| `F17` | Pluvi Isle |
| `F18` | Snowberia |
| `F19` | Cringle Coast |
| `F20` | Urdus Marshland |
| `F21` | Iluugazar Plains |
| `F22` | Mt Ulzuun |
| `F23` | Mt Ulbaruun |
| `F24` | Khaalag Coast |
| `F25` | Ondor Cliffs |
| `F26` | Eastern Wormwood Region |
| `F27` | Western Wormwood Region |
| `F28` | Wormwood Canyon |
| `F29` | Wyrmtail Region |
| `F30` | Wyrmwing Region |
| `F32` | Wyrmsmaw Region |
| `F33` | Wyrmneck Region |
| `F34` | The Gittish Empire |
| `F38` | Eastern Stornway Region |
| `F39` | Snowberian Coast |
| `F40` | Lonely Coast |
| `F63` | Zere Region |
| `F99` | For Encounter Testing |

### Dungeons and caves

| code | region |
|---|---|
| `D01` | The Hexagon |
| `D03M01` | Brigadoom |
| `D04` | Quarantomb |
| `D06M01` | Tywll Cave |
| `D07` | Heights of Loneliness |
| `D08M02` | Plumbed Depths - B1 |
| `D09` | The Bad Cave |
| `D12M01` | Gerzuun |
| `D13M01` | Swinedimples - The Old School, B1 |
| `D14` | The Bowhole |
| `D16M02` | The Magmaroo - Lv 1 |
| `D17M01` | Oubliette - B1 |

### Story places

| code | region |
|---|---|
| `S01M01` | Mountain Pass |
| `S02` | Loch Storn |
| `S05` | Cuddiedig Cliff |
| `S06` | Hunters' Yurts |
| `S07` | Gortress |
| `S08` | Slurry Quay |
| `S09` | Ship - Deck |
| `S12` | Bloomingdale Region |
| `S14M01` | Starflight Express - Carriage 1 |
| `S15` | Wyrmward |

### Towers

| code | region |
|---|---|
| `T01` | Tower of Trades |
| `T02` | Tower of Nod |

### The story’s own realms

| code | region |
|---|---|
| `X01` | Observatory |
| `X02` | Alltrades Abbey |
| `X03` | Realm of the Almighty |
| `X04` | Realm of the Mighty |
| `X05M01` | Observatory - Lv 1-Lv 2 |

### Huts and small interiors

| code | region |
|---|---|
| `H17` | Eastern Wormwood |
| `H19` | Western Wormwood |
| `H20` | Wyrmtail |

### Backdrops

| code | region |
|---|---|
| `O00` | Ocean |
| `O01` | None — the index's own word, not a blank |

## See also

- [Tagged-Data-Table](Tagged-Data-Table)
- [Map-Archive](Map-Archive): `.dat` supplies the region that dungeon entries leave blank
- [Map-Textures](Map-Textures)
- [Area-Cast](Area-Cast)
- [Triggers](Triggers)
- [Mini-Map](Mini-Map)
- [SDAT](SDAT)
