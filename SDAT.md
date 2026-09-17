# SDAT

SDAT is the Nitro sound archive: one file holding sequences (SSEQ), sequence archives (SSAR), instrument banks (SBNK), wave archives (SWAR) and streams (STRM), with name and info tables that tie them together. The Dragon Quest IX cartridge has three: `bgm.sdat` (music), and `se_norm.sdat` and `se_btl.sdat` (sound effects). The container, the record lists, and the SSEQ, SBNK, SWAR and SSAR files are read and checked against all three archives. One reading — the empty-slot marker in SSAR — is INFERRED against the published specification. What the leading bytes of player and group records hold, and the STRM stream format, are not covered.

All observations were made on the European release (game code `YDQP`).

## Sources

- GBATEK, "DS Files"
- Nintendo DS file formats wiki: *SDAT*, *SSEQ*, *SBNK*, *SWAR*
- Gota7's *Nitro Studio 2* specifications (sequence, bank, wave, wave archive, sequence archive), https://gota7.github.io/NitroStudio2/specs/
- fincs's FeOS Sound System, https://github.com/fincs/FSS (WTFPL), whose `sbnkswar.h` reads the same bank and wave-archive layouts
- GBATEK, "DS Sound Notes", for IMA-ADPCM

Every field in the SSEQ, SBNK, SWAR and SSAR sections is taken from these sources; the only inference is marked.

## Layout

### Container

| offset | size | type | meaning |
|---|---|---|---|
| `0x00` | 4 | `char[4]` | `SDAT` |
| `0x04` | 2 | `u16` | byte-order mark, `0xFEFF` |
| `0x06` | 2 | `u16` | version |
| `0x08` | 4 | `u32` | file size |
| `0x0C` | 2 | `u16` | header size, `0x40` |
| `0x0E` | 2 | `u16` | block count, 4 |
| `0x10` | 8 | `u32`×2 | `SYMB` offset and size |
| `0x18` | 8 | `u32`×2 | `INFO` offset and size |
| `0x20` | 8 | `u32`×2 | `FAT` offset and size |
| `0x28` | 8 | `u32`×2 | `FILE` offset and size |

The four blocks tile the archive exactly: each ends where the next begins, and the last ends on the declared file size. This holds on all three archives on the cartridge.

The FAT stamp is **`FAT ` with a trailing space** — four characters like the others.

### The eight record lists

`SYMB` and `INFO` both hold eight lists, in the same order. That is what lets a name be paired with a record by index:

| index | kind | refers to a file |
|---|---|---|
| 0 | sequence (SSEQ) | yes |
| 1 | sequence archive (SSAR) | yes |
| 2 | bank (SBNK) | yes |
| 3 | wave archive (SWAR) | yes |
| 4 | player | **no** |
| 5 | group | **no** |
| 6 | player2 | **no** |
| 7 | stream (STRM) | yes |

Each list is a `u32` count, then that many `u32` offsets relative to its own block's start. A zero offset is an empty slot. Archives leave gaps in the numbering: about a third of the cartridge's records are gaps.

### Not every record starts with a file id

**Confirmed by observation.** The kinds marked "yes" put a FAT index in their leading `u16`. The others do not. A player or group record starts with something else, and reading it as a file id gives a small integer that happens to index an early file. It looks entirely plausible.

The evidence: taking the leading `u16` of every record and resolving it, the four file-bearing kinds plus streams land on a file whose stamp is exactly the one that kind implies — **1,714 of 1,714** across the three archives. The excluded kinds produce stamps that contradict their type and, for the single `player2` record, an index past the end of the file table.

### Records

Sequence, 12 bytes:

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 2 | `u16` | file id |
| `+0x04` | 2 | `u16` | bank id |
| `+0x06` | 1 | `u8` | volume |
| `+0x07` | 1 | `u8` | channel pressure |
| `+0x08` | 1 | `u8` | polyphonic pressure |
| `+0x09` | 1 | `u8` | player priority |

The bytes at `+0x02` and `+0x0A`–`+0x0B` are not described by the sources used here.

Bank, 12 bytes: a `u16` file id, then four `u16` wave-archive ids at `+0x04`, with `0xFFFF` marking an unused slot.

Wave archive: a `u16` file id.

Records do not declare their own length. Each can be taken to run to the next one's offset.

### FAT

A `u32` count at `+0x08`, then 16-byte entries: `u32` offset, `u32` size and two reserved words. Offsets are absolute within the archive.

## The files inside

### Common header

SSEQ, SBNK, SWAR and SSAR share one header:

| offset | size | type | meaning |
|---|---|---|---|
| `0x00` | 4 | `char[4]` | `SSEQ`, `SBNK`, `SWAR`, `SSAR` |
| `0x04` | 2 | `u16` | byte-order mark, `0xFEFF` |
| `0x06` | 2 | `u16` | version |
| `0x08` | 4 | `u32` | file size |
| `0x0C` | 2 | `u16` | header size, `0x10` |
| `0x0E` | 2 | `u16` | block count, 1 |
| `0x10` | 4 | `char[4]` | `DATA` |
| `0x14` | 4 | `u32` | DATA block size |

### SSEQ

`0x18` holds the absolute offset of the command stream, which runs to the end of the DATA block. It is `0x1C` on every sequence on the cartridge. Jump and call targets in the commands are offsets into the stream. The command set itself is not described on this page.

### SBNK

| offset | size | type | meaning |
|---|---|---|---|
| `0x18` | 32 | `u32[8]` | reserved |
| `0x38` | 4 | `u32` | instrument count |
| `0x3C` | 4 each | | instrument records: `u8` type, `u16` absolute offset, `u8` pad |

Instrument types:

| type | meaning | data at the offset |
|---|---|---|
| 0 | empty | — |
| 1 | PCM | one 10-byte note definition |
| 2 | PSG | one 10-byte note definition |
| 3 | noise | one 10-byte note definition |
| 4 | direct PCM | one 10-byte note definition |
| 5 | null | one 10-byte note definition |
| 16 | drum set | `u8` low key, `u8` high key, then one `u16` type and 10-byte definition per key from low to high |
| 17 | key split | eight `u8` region-end keys (zero past the last region), then a `u16` type and 10-byte definition per region |

A note definition, 10 bytes:

| field | type |
|---|---|
| wave (or PSG duty) | `u16` |
| wave archive (0–3, the bank's slot) | `u16` |
| base key | `u8` |
| attack | `u8` |
| decay | `u8` |
| sustain | `u8` |
| release | `u8` |
| pan | `u8` |

### SWAR

| offset | size | type | meaning |
|---|---|---|---|
| `0x18` | 32 | `u32[8]` | reserved |
| `0x38` | 4 | `u32` | wave count |
| `0x3C` | 4 each | `u32[count]` | absolute offset of each wave |

Each wave is a 12-byte info block, then its samples — a SWAV without its file header:

| field | type | meaning |
|---|---|---|
| format | `u8` | 0 PCM8, 1 PCM16, 2 IMA-ADPCM |
| loops | `u8` | |
| sample rate | `u16` | |
| timer | `u16` | `16756991 / rate`, the ARM7 clock over the rate |
| loop start | `u16` | in 32-bit words |
| length | `u32` | length after the loop start, in words |

**IMA-ADPCM.** A four-byte header — the initial PCM16 value and table index — then two nibbles a byte, low nibble first. The step table and index table are the standard IMA ones GBATEK lists. The value is clamped to ±`0x7FFF` and the index to 0–88. A loop start counts words of the file including its header, so its sample number is `words × 8 − 8`.

### SSAR

A sequence archive is many short sequences in one command stream, each with its own bank and volumes. Source: Gota7's sequence-archive specification.

| offset | size | type | meaning |
|---|---|---|---|
| `0x18` | 4 | `u32` | absolute offset of the command stream: `0x20 + 12 × count` |
| `0x1C` | 4 | `u32` | entry count |
| `0x20` | 12 each | | entries (below) |

Entry, 12 bytes: `u32` offset into the stream, `u16` bank, `u8` volume, `u8` channel priority, `u8` player priority, `u8` player, `u16` pad.

An entry's offset is where its sequence starts in the stream. Its track and jump offsets still count from the stream's start, as a sequence's do. The stream runs to the end of the DATA block.

**An empty slot is one whose offset is `0xFFFFFFFF`.** INFERRED, against the specification, which says 0. On the cartridge, 0 is the offset of a real sequence — the first in the stream — on 253 of `se_norm.sdat`'s 279 archives and 430 of `se_btl.sdat`'s 481. Meanwhile `0xFFFFFFFF` fills 812 and 2,513 slots there, and no offset lies past a stream's end.

## On the cartridge

### Music: `bgm.sdat`

- 64 sequences with files.
- Their banks hold 996 instruments: 225 single notes, 456 key splits, 35 drum sets, 280 empty.
- All 2,079 PCM notes resolve to a wave in the bank's wave archives.
- All 2,079 waves are IMA-ADPCM; 1,793 of them loop; every one decodes.
- 3 streams (`STRM`).

### Effects: `se_norm.sdat` and `se_btl.sdat`

The two effects archives are made of sequence archives, 1,398 records between them.

| archive | sequence-archive records | with a file | indices | sequences | wave archives |
|---|---|---|---|---|---|
| `se_norm.sdat` | 462 | 279 | 100 to 461 | 819 | 108 |
| `se_btl.sdat` | 936 | 481 | 101 to 935 | 1,081 | 105 |

In both, every sequence names the bank at its archive's own index, and every one reads. An archive's filled slots are variants of one sound: the same two-note phrase at rising keys, or at full and lesser volume.

## Evidence

| check | result |
|---|---|
| archives parsed | 3 / 3 |
| files indexed | 1,714 |
| **file ids resolving to the stamp their record kind implies** | **1,714 / 1,714** |
| overlapping file ranges | 0 |
| sequence → bank → wave-archive chains resolving | 64 / 64 |

The chain check is the strongest of these. It walks a sequence's bank id into the bank list, reads that bank's wave-archive ids, and resolves each: three lookups through separately-parsed tables, all of which must be right. It is also self-consistent by name: `BG_001` selects `BANK_BG_001`, which selects `WAVE_BG_001`.

## Not established

- What a player, group or player2 record starts with (it is not a file id).
- **Streams (`STRM`).** `bgm.sdat` has three; their format is not covered here.
- The SSEQ command set.
- Which of an SSAR's filled slots the game plays. That is a matter for the game's code, not the archive.
- The SSAR empty-slot marker `0xFFFFFFFF` is INFERRED (see above).

## See also

- [NitroFS](NitroFS) — the cartridge filesystem
