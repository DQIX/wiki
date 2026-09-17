# GPC2

GPC2 is a Level-5 archive container (files with the `.gp2` extension, such as `/data/pack_lv5/enemy.gp2` and `/data/prm/actdt_a.gp2`). It is not a Nintendo format and is not publicly documented; it appears to be a vendor format used across Level-5's DS output. Everything here was established by observation against the cartridge, and the evidence for each claim is given. The header, the hash-sorted entry table, the name table and the region codecs are confirmed: all 1,671 archives on the cartridge parse, and every member decodes to its declared size. Four header fields are not established, and the "stored whole" flag is INFERRED from three archives.

All observations were made on the European release (game code `YDQP`). The codecs GPC2 uses are Nintendo's; see [DS-Compression](DS-Compression).

## Layout

### Header

| offset | size | type | meaning |
|---|---|---|---|
| `0x00` | 4 | `char[4]` | `GPC2` |
| `0x04` | 12 bits | `u12` | member count — byte 4, plus the low nibble of byte 5 as its high bits |
| `0x05` | 4 bits | `u4` | `unknown_0x05`, the high nibble of byte 5 |
| `0x06` | 2 | `u16` | version; `5` on every archive observed |
| `0x08` | 2 | `u16` | name-table offset, in 4-byte words |
| `0x0A` | 2 | `u16` | data-region offset, in 4-byte words |
| `0x0C` | 2 | `u16` | entry-table size in 4-byte words; always `3 * count` |
| `0x0E` | 2 | `u16` | `unknown_0x0e` |
| `0x10` | 4 | `u32` | `unknown_0x10`; **bit 28: the members are stored whole** (INFERRED — see [Members stored whole](#members-stored-whole)); the rest not established |
| `0x14` | 4 | `u32` | `unknown_0x14` |

**The count is 12-bit, not 8-bit.** Reading only byte 4 works for most archives and fails silently on large ones. The 12-bit reading is confirmed by the identity `word count at 0x0C == 3 * count`, which holds for **1,671 of 1,671** archives on the cartridge and fails for 25 of them under the 8-bit reading.

### Entry table

At `0x18`, 12 bytes per member, **sorted ascending by hash**. It is a binary-search index.

| offset | bits | meaning |
|---|---|---|
| `+0` | 32 | CRC-32 of the member's filename |
| `+4` | 0–23 | data offset, in 4-byte words, from the data region |
| `+4` | 24–31 | low byte of the name's byte offset in the name table |
| `+8` | 0–23 | stored region length, **including** its 4-byte prefix |
| `+8` | 24–31 | high byte of the name's byte offset |

The name offset is split across two words, and is 16 bits in every archive. Reading only the byte in `+4` works for small archives and breaks on any whose names exceed 255 bytes in total — which is most of the large ones.

### The entry table's own encoding is not recorded

The entry table is stored plainly when it exactly fills the space between the header and the name table. Otherwise it is compressed, starting at `0x18`, and its decompressed size is `12 * count` — but **nothing in the header says which codec**. LZ77, 4-bit Huffman and 8-bit Huffman all occur.

Byte counts do not separate them: a correct decode may leave a few bytes of alignment padding unread, and a wrong one can consume a plausible number.

What does separate them is the *result*. A valid index has two properties a wrong decode does not reproduce: the hashes are strictly ascending, and every entry's data offset lands inside the archive. Trying the codecs and taking the first result with both properties identifies the codec. The choice is then corroborated: every filename recovered from the separately-compressed name table matches the CRC-32 in the entry its offset came from.

### Regions

The name table and every member are stored as a *region*: a `u32` prefix, then the payload.

| bits | meaning |
|---|---|
| 0–2 | codec |
| 3–31 | decompressed size in bytes |

| codec | meaning | members observed |
|---|---|---|
| 0 | stored, no compression | 32 |
| 1 | LZ77, LZ10 unit encoding, no BIOS header | 39,559 |
| 2 | Huffman, 4-bit symbols | 368 |
| 3 | Huffman, 8-bit symbols | 2,438 |
| 4 | run-length | 7,743 |
| 5–7 | not established; none occur | 0 |

The numbering is **not** the BIOS's. Each codec *variant* gets its own number, so the two Huffman symbol widths take 2 and 3, and run-length lands on 4. Against codec 4, run-length matches 7,743 of 7,743 regions exactly.

The name table decodes to plain NUL-separated names. There is no trie.

### Members stored whole

Three archives hold members with no region prefix, whose bytes are their content:

| archive | members | content |
|---|---|---|
| `/data/pack_lv5/enemy.gp2` | 601 | every one a `NARC` |
| `/data/prm/actdt_a.gp2` | 6 | action tables (see [Actions](Actions)) |
| `/data/prm/actdt_b.gp2` | 6 | action tables (see [Actions](Actions)) |

Read as region prefixes, their first words give nonsense: a codec of 6 on the `NARC`s, 7 on `actdt_a`'s tables, and on `actdt_b`'s a Huffman region two megabytes long in 41 KB — which decodes wrongly, or fails to.

**Bit 28 of the header's `0x10` marks them.** INFERRED: the bit is set on exactly those three archives and clear on every other archive on the cartridge, where the largest `0x10` value seen is `0xE337F`.

Read whole, every member identifies itself: `enemy.gp2`'s are `NARC`s, and each action table opens with a head word — record count and string size — that describes its length exactly.

## Evidence

Against the retail cartridge:

| check | result |
|---|---|
| archives parsed | **1,671 / 1,671** |
| members indexed | 53,639 |
| **member names whose CRC-32 matches the stored hash** | **53,639 / 53,639, zero mismatches** |
| members that decode, to exactly their declared size | **all**, the 613 stored whole among them |

The CRC-32 result is the strongest single piece of evidence. The hash is stored in the entry table, the name is recovered from a separately-compressed name table, and the two are brought together through a bit-split offset field. All three decodings must be right for the check to pass, fifty thousand times running.

The Huffman tree walk has a second, independent confirmation: on archives whose entry table is Huffman-compressed, the decode consumes *exactly* the bytes between the header and the name table, and yields hashes in ascending order.

Before bit 28 was read, 606 members were unreadable, five more — `actdt_b`'s — failed to decode to their declared size, and the two range tables beside them "decoded" silently to 2 and 13 bytes of nothing.

## Earlier readings

- **"Codec 4 is not run-length."** This came from a test that had been pointed at codec 3. Against codec 4, run-length matches every region.
- **"Codec 7 exists."** Five members once listed as codec 7 were members stored whole, their first word misread as a region prefix.
- **"The name table is a trie."** Readings that appeared to show one were looking at compressed bytes.
- **"The name offset is wider than 16 bits in some variant."** Eleven archives whose index could not be followed prompted this guess. It was wrong: the name offset is 16 bits throughout, and those archives simply encoded their entry table with a codec that had not been tried.

## Not established

- `unknown_0x05`, `unknown_0x0e`, `unknown_0x14`, and the bits of `unknown_0x10` below bit 28.
- Codecs 5 to 7: none occur on the cartridge.
- Bit 28 rests on three archives. A fourth archive that set it and still prefixed its members would break the reading; none does on this cartridge.

## See also

- [DS-Compression](DS-Compression) — the LZ77, Huffman and run-length unit encodings used by regions
- [NitroFS](NitroFS) — the `NARC` archives stored whole in `enemy.gp2`
- [Actions](Actions) — the action tables in `actdt_a.gp2` and `actdt_b.gp2`
