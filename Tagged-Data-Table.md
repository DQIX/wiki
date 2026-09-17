# Tagged Data Table

A generic container of tagged records followed by a string table. It is used by the map descriptors (`.bmdj`, see [Map-Objects](Map-Objects)), the map attribute tables (`.bats`), and standalone tables such as `data/bin/mapbgm.bin`. The header, record framing and string table are confirmed on every file of the European release (game code YDQP); type `0x02` is confirmed as float; the other type bytes and what most tags mean are not established.

## Layout

### Header

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 4 | `u32` | `unknown_0x00` |
| `+0x04` | 4 | `u32` | string table offset; the file size when there is no table |
| `+0x08` | 4 | `u32` | string table size |
| `+0x0C` | 4 | `u32` | string count |
| `+0x10` | | | the record stream, running up to the string table |

### Records

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 2 | `u16` | tag |
| `+0x02` | 1 | `u8` | value count |
| `+0x03` | 1 | `u8` | type |
| `+0x04` | 4 × count | | the values, 4 bytes each |

Type `0x02` means the values are IEEE floats. This is confirmed by reading them: the first record of a map descriptor is tag `0x71`, type `0x02`, value `1.2`. The other type bytes seen (`0x00`, `0x01`, `0x51`, `0xA5`, `0x55`) are not identified.

### Padding and end of stream

`0xFF` fill appears **between** records as alignment padding, as well as after the last one. It has to be skipped a word at a time rather than treated as an end: three files carry eight bytes of it mid-stream, and a parser that stops at the first run silently truncates them. The fill is `0xFF`, not zero, so stopping on zeroes reads rubbish first.

The stream ends on a record with tag `0x6E` and type `0xFF`, or by reaching the string table.

### String table

In a `.bmdj` the string table lists a map's resources by name (`M01M0000.imd`, `M01M00D1.imd`, and so on). `.imd` is the source-format name for what ships as [NSBMD](NSBMD). Records address those names by byte offset; see [Map-Objects](Map-Objects).

## Tags

What the tags mean is not established in general. A reader should expose tags as numbers and carry each value as a raw `u32` alongside its float reading.

Known uses in map descriptors are on [Map-Objects](Map-Objects) (`0x6A`, `0x6C`, `0x6F`). Also observed there:

- The first record is tag `0x71`, type `0x02`. A map descriptor carries a per-map float that is `1.20` on 728 maps and `1.00` on 18; neither value tracks whether a map is indoors or outdoors. What it controls is not established.
- Tags `0x6A` and `0x6D` each occur exactly once per map descriptor and hold small integers: `0x6A` in 1..47 and `0x6D` in 1..57. **They are not music ids**, though that is the shape a music id would have. The two track each other almost everywhere, and their values vary from map to map *within a single village*, which a background track does not. They are more likely counts.

## Evidence

| check | result |
|---|---|
| tables parsed | **1,260 / 1,260**, no failures |
| string count matching the header | 1,260 / 1,260 |
| record stream reaching the string table | 1,260 / 1,260 |
| resource names listed | 5,342 |

Two independent checks hold on every file: the string section decodes to exactly the count the header declares, and the record stream, walked by nothing but its own length fields, arrives precisely at the string table rather than before or past it.

## Not established

- `unknown_0x00` in the header.
- Record types other than `0x02`: `0x00`, `0x01`, `0x51`, `0xA5`, `0x55`.
- The meaning of most tags, including `0x6D` and `0x71`.
- **The map-to-music link.** No field in `.bmdj` or `.bats` has been shown to select a BGM track. `mapbgm.bin`'s values do not fall in the sequence archive's 0–81 index range either.

## See also

- [Map-Objects](Map-Objects): the `.bmdj` resource and placement records
- [Map-Archive](Map-Archive)
- [SDAT](SDAT): the sequence archive
