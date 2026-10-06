# Tagged Data Table

A generic container of tagged records followed by a string table. It is used by the map descriptors (`.bmdj`, see [Map-Objects](Map-Objects)), the map attribute tables (`.bats`), and standalone tables such as `data/bin/mapbgm.bin`. The header, record framing and string table are confirmed on every file of the European release (game code YDQP); type `0x02` is confirmed as float; the other type bytes and what most tags mean are not established.

**EU only:** the same container carries much of the rest of the cartridge, and the game runs several of these tables as scripts, a record's tag being its opcode (see [Where it is used](#where-it-is-used) and [Tables the game runs as scripts](#tables-the-game-runs-as-scripts)).

## Layout

### Header

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 4 | `u32` | the instruction count: the records, the `0x6E` terminator among them where there is one |
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

### A table that looks like an empty LZ77 stream

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`).

A table whose first word is 16 begins with the bytes `10 00 00 00`. That is also an LZ77 header (type `0x10`) declaring a size of 0 (see [DS compression](DS-Compression)). A stream of 0 bytes decodes to nothing, whatever follows, so a check that the stream decoded to its declared size passes. **A reader that tries a file as LZ77 before anything else will read such a table as empty.** Decline a declared size of 0 when asking whether bytes are a compressed stream at all.

On the cartridge, **372 files** begin this way, in every language:

| kind | files |
|---|---|
| talk files ([Character-Dialogue](Character-Dialogue)) | 225, 41 of them English, the king's file for chapter C (`C01C0.gp2/045_en.bin`) among them |
| map `.bmdj` ([Map-Objects](Map-Objects)) | 54 |
| `.bmbl` link tables ([Map-Textures](Map-Textures)) | 25, the Hexagon's `D01M0000` among them |
| event text files ([Event-Text](Event-Text)) | 25, `ev03050`'s messages among them |
| event scripts ([Event-Scripts](Event-Scripts)) | 10, Loch Storn's `ev23193` and `ev29410` among them |
| mini-map layouts ([Mini-Map](Mini-Map)) | 4: `F07`, `H07`, `M05`, `M12` |
| treasure files ([Treasure](Treasure)) | 2: `M09M05` and `D13M02` |

## Where it is used

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`), except where a page says so.

Besides the map descriptors, attribute tables and `mapbgm.bin`, the files below are this container. Each page has its own tags.

- Maps: [Map-List](Map-List) (`maplist9.bin`), the small files of a [map archive](Map-Archive) (`.dat`, `.bats`, `.bcfg`, `.bpos`, `.bmed`), [Map-Textures](Map-Textures) (`.bmbl`), [Mini-Map](Mini-Map) (`.bmmp`), [Treasure](Treasure), [Area-Cast](Area-Cast) (`npc.bin` and `place.bin`), [Triggers](Triggers)
- Text: [Event-Text](Event-Text), [Character-Dialogue](Character-Dialogue), [Item-Kinds](Item-Kinds), [Mini-Medals](Mini-Medals) (`str_mdl`)
- Game data: [Level-Tables](Level-Tables), [Spell-Table](Spell-Table), [Skill-Panels](Skill-Panels), [Alchemy-Recipes](Alchemy-Recipes), [Encounters](Encounters), [Character-Presets](Character-Presets), [Attending-Characters](Attending-Characters), [Character-Colours](Character-Colours), [Items](Items) (`shopdata1.bin`), [Given-Names](Given-Names) (`keyboard_cm.bin`), [Quests](Quests) (`questorder3.bin`), [Event-Lists](Event-Lists), [Motion-Tables](Motion-Tables) (`.bcfg`)

**On the treasure files, the first header word is the record count**, on all 266 read (see [Treasure](Treasure)). What it is in general is not established.

## Tables the game runs as scripts

**The container is the game's `Script` command file** (USA, read 6 October 2026 from the decomp's `src/Resource/Script.cpp`): a record is an instruction — a `u16` opcode, a `u8` parameter count, then two bits of type per parameter (0 a string's offset into the string section, 1 an integer, 2 a float), padded to a word, then the parameters — run in order by `Script::Execute`, which hands each to whatever function its reader registered for that opcode (`Script::SetOpcodeLookup`). The header is `FileHeader`: **the first word is the instruction count**. **EU only:** it equals the records on all 5,675 tables in the cartridge's files, counting the terminator on the 854 that have one. The type "byte" above is the first of those two-bit fields: `0x15` is three integers and a string, `0x55` four integers.


> **EU only.** Code addresses are the USA release's, from the decomp; the files were read on the European release and are not yet checked on the US one.

The game does not read every table as data. Several it loads and runs as a script, with an opcode table of `{tag, handler}` pairs: each record's tag picks its handler, and the handler reads the record's values (with `Script::Parameter::ToInt`, in the colour script's case). `palette.bin`'s opcode table is six pairs ended by a zero pair.

| file | run by | opcode table |
|---|---|---|
| `trigger<area>.bin` ([Triggers](Triggers)) | `func_02064574` | `0x020f05bc` |
| `<map>place.bin` ([Area-Cast](Area-Cast)) | `func_0206da80` | `0x020f0994`, tags 3 to 22 |
| talk files ([Character-Dialogue](Character-Dialogue)) | overlay 17 `func_ov017_021ba810` | `0x021d7c58` |
| event lists ([Event-Lists](Event-Lists)) | `func_02071488` | one opcode, 102, handled by `func_02071208` (table `0x020f0b80`) |
| `questorder3.bin` ([Quests](Quests)) | `func_02095578` | `0x020f1444` |
| `palette.bin` ([Character-Colours](Character-Colours)) | `func_02099cb8`, through `Script::Execute` | `0x020f1574` |
| `.bats` ([Map-Archive](Map-Archive)) | the decomp's `LightingInfo::LoadFromScript` | one handler a tag |

A reader that walks such a file as a table sees the same records the game does. What the game does with them depends on the order they come in: in `place.bin` and the talk files, a later record can override an earlier one.

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

- Record types other than `0x02`: `0x00`, `0x01`, `0x51`, `0xA5`, `0x55`.
- The meaning of most tags, including `0x6D` and `0x71`.
- **The map-to-music link.** No field in `.bmdj` or `.bats` has been shown to select a BGM track. `mapbgm.bin`'s values do not fall in the sequence archive's 0–81 index range either.

## See also

- [Map-Objects](Map-Objects): the `.bmdj` resource and placement records
- [Map-Archive](Map-Archive)
- [SDAT](SDAT): the sequence archive
- [DS compression](DS-Compression): the LZ77 header a table can be mistaken for
