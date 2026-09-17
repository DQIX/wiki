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

## See also

- [Tagged-Data-Table](Tagged-Data-Table)
- [Map-Archive](Map-Archive): `.dat` supplies the region that dungeon entries leave blank
- [Map-Textures](Map-Textures)
- [Area-Cast](Area-Cast)
- [Triggers](Triggers)
- [Mini-Map](Mini-Map)
- [SDAT](SDAT)
