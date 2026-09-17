# Map-Archive

A map archive holds more than its geometry, its collision and its two descriptors. It also holds several small files: `.dat`, `.bats`, `.bcfg`, `.bpos` and `.bmed`. **Every one of these small files is the same [tagged data table](Tagged-Data-Table)**. `.bmdj`, `.bmbl`, `.dat`, `.bats`, `.bcfg`, `.bpos` and `.bmed` all parse as one, on every file of each kind. Only the tags and record widths differ, so a reader for one reads them all. The structure of each is confirmed. What each is for is mostly INFERRED or not established. Counts are from the European release (game code `YDQP`).

**A caveat on the strings below.** A value is reported as a string when it is an offset that lands on a printable string, and a small integer can do that by accident. Where a record mixes what look like names and numbers, treat the names in first position as sound and the rest as unconfirmed.

## `.dat` — which region a map belongs to

**657 files, 48 or 64 bytes.** This is the smallest format here: two or three records.

| tag | values | meaning |
|---|---|---|
| `102` | 1 | `21` on 650 of 657, `8` on 2 |
| `104` | 1 | a **map code**, as a string |
| `109` | 1 | on 15 files |
| `105` | 1 | on 1 file |

**INFERRED: tag `104` names the region the map belongs to.** Of the 657 files:

- **400 name the file's own area.** Every `M01M*` says `M01`, every `F01M*` says `F01`, every `M02M*` says `M02`.
- **150 name `T00`**, which the map index ([Map-List](Map-List)) does not have at all. They are all `B*` archives (47 in `B01`, 36 in `B02`), plus a handful of `F99`, `S14`, `Z01` and `Z02`. This reads as the unset value.
- **107 name some other map the index knows.** `B01M28`..`B01M30` name `F16`, labelled *Hermany*. `B01M31` and `B01M32` name `F18`, *Snowberia*. `B01M36`..`B01M38` name `F15`, *Djust Desert*. These are dungeon maps naming the overworld field they sit in. **Their own index entries carry no region**, so the `.dat` supplies what the index leaves blank.

What the region is used for is not established.

## `.bats` — per-map colour and lighting

**504 files, 560 to 1,072 bytes.** These are the attribute tables, in three shapes. They live in 14 grouping archives named `ats_B`..`ats_Z`, not in the per-map `.ambl` archives (see [Map-Textures](Map-Textures)).

| tag | values | on |
|---|---|---|
| `100` | 1 | 236 files, always `0` |
| `103` | 0 or 1 | 268 files |
| `104` | 12 | 715 records |
| `105` | 15 | 3,529 records |
| `106` | 18 | 1,652 records |

`105` and `106` records open with an index that counts from zero within the file, so both are per-slot settings. Their values mix IEEE floats around `1.0` and `0.2` with 16-bit values that read as `fx16`: `32767` for one, `22528` for 0.6875, `20479` for 0.625. That is what colour and intensity values look like. A map ships its lit pieces twice, once per lighting, so a per-slot table of colours is the shape this should have.

**What the slots are is not established**, and neither is which value is which. Earlier notes record that these are float-valued fog and lighting settings, and that they carry no music selection.

## `.bcfg` — a piece's named states

**145 files, 80 or 160 bytes.** They sit beside `G1`-suffixed pieces (gates and doors) and beside `I00`.

| tag | values | meaning |
|---|---|---|
| `100` | 1 | how many `102` records follow: `1` or `4` |
| `102` | 4 | a **state name**, then three numbers |
| `101` | 0 | a separator |
| `112` | 1 | `0xFFFFFFFF` |

The names give it away: **`open`, `closed`, `close`, `opend`, `open2`** on the door pieces, and `in` on `C01I00`. So a `.bcfg` lists the states its piece can be in, with three numbers each. A frame range and a speed is plausible, though these map-archive files alone do not confirm it.

Tags here are written in decimal. The same files are described with hex tags (`0x64`, `0x65`, `0x66`, `0x70`) on [Motion-Tables](Motion-Tables), which reads the three numbers of a cabinet's `.bcfg` as first frame, last frame and speed.

## `.bpos` — a grid of codes, on the `Z` maps only

**5 files, 1,056 bytes each**: `Z01M0100`..`Z05M0100`.

| tag | values | meaning |
|---|---|---|
| `125` | 1 | `18`, the number of `126` records |
| `126` | 11 | eleven codes |

Eighteen records of eleven values is an **11 by 18 grid**. Most values resolve to four-character codes: `W01A` overwhelmingly, then `W02A`, `W03A`, `W04A`, `R01A`..`R04A` and `E01A`. `W`, `R` and `E` reading as wall, room and entrance is the obvious guess, and it is **not confirmed**.

## `.bmed` — the `E1` pieces

**12 files, 80 to 176 bytes**, each named for an `E1` piece, for example `F17E1.bmed` or `D04M02E1.bmed`.

| tag | values | meaning |
|---|---|---|
| `102` | 1 | a name, usually the matching `.chr` archive |
| `108` | 1 or 2 | `44` on every record seen |
| `106` | 1 | a float, `2.0` or `4.0` |
| `101`, `100`, `105`, `107`, `103`, `104`, `109` | 1–2 | not established |

A `102` record names a `.chr`, for example `D04M02E1.chr` or `F18E1.chr`. So an `E1` piece is backed by a character archive rather than by map geometry. `105` pairs that name with the string `copy`, which appears 14 times across the twelve files.

## Evidence

- All seven small file kinds parse as the tagged data table on every file of each kind.
- `.dat`: the region counts (400 / 150 / 107) are across all 657 files, checked against [Map-List](Map-List).
- `.bats`: record and file counts across all 504 files. The `fx16` readings are of observed values.
- `.bcfg`: state names observed on door pieces and `C01I00`.
- `.bpos`: all five `Z` files.
- `.bmed`: all twelve files.

## Not established

- What a map's `.dat` region is used for. The meaning of tags `102`, `109` and `105` in `.dat`.
- Which `.bats` slot is which, and which value in a slot is which.
- In `.bcfg`, confirmation from these files that the three numbers are a frame range and speed.
- In `.bpos`, what the `W`/`R`/`E` codes mean, and what the grid is for.
- In `.bmed`, tags `100`, `101`, `103`, `104`, `105`, `107`, `109`, the meaning of `108`'s `44` and `106`'s float.

## See also

- [Tagged-Data-Table](Tagged-Data-Table)
- [Map-List](Map-List)
- [Map-Textures](Map-Textures) (`.bmbl`)
- [Map-Objects](Map-Objects) (`.bmdj`)
- [Map-Collision](Map-Collision)
- [Doors](Doors)
- [Motion-Tables](Motion-Tables)
