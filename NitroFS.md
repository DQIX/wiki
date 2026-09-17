# NitroFS

NitroFS is the DS cartridge filesystem: a file allocation table (FAT) and a file name table (FNT) addressed from the cartridge header. NARC is the same filesystem packed into a single file. Both are documented platform formats; every field described here is named in the sources below, and nothing is inferred. What this page adds is what was observed on the Dragon Quest IX cartridge: the CRC-16 algorithm confirmed against the stored checksums, filenames that are not ASCII, and the NARC chunk stamp spelling actually used.

All observations were made on the European release (game code `YDQP`). Offsets are into the cartridge image unless stated.

## Sources

- GBATEK, [DS Cartridge Header](https://problemkaputt.de/gbatek.htm#dscartridgeheader)
- GBATEK, [DS Cartridge NitroROM and NitroARC File Systems](https://problemkaputt.de/gbatek.htm#dscartridgenitroromandnitroarcfilesystems)
- GBATEK, [BIOS Decompression Functions](https://problemkaputt.de/gbatek.htm#biosdecompressionfunctions) (for the CRC-16 polynomial in use)
- Nintendo DS file formats wiki, *NitroFS* and *NARC*

## Cartridge header

The header is read from offset `0x000`, size `0x200`. Its fields are as GBATEK lists them.

### CRC-16

Reflected polynomial `0xA001` (reversed `0x8005`), initial value `0xFFFF`, no final XOR. The CRC RevEng catalogue calls this algorithm CRC-16/MODBUS.

**Confirmed by observation.** On the cartridge, this algorithm reproduces both stored checksums exactly:

| region | stored | computed |
|---|---|---|
| Nintendo logo, `[0x0C0, 0x15C)` | `0xCF56` | `0xCF56` |
| header, `[0x000, 0x15E)` | `0xF9CC` | `0xF9CC` |

`0xCF56` is a fixed constant for every retail cartridge, so a match is a useful signal that an image is an unmodified retail dump. A trimmed or patched image may fail the checks and still be readable.

## FAT

`fatSize / 8` entries, each two little-endian `u32`s: `start` and `end`. `end` is exclusive. Both are absolute within the image.

Overlay files occupy the leading entries. The FNT root's `firstFileId` is therefore normally equal to the overlay count.

## FNT

A directory table of 8-byte entries, root first:

| offset | size | type | meaning |
|---|---|---|---|
| `+0` | 4 | `u32` | sub-table offset, relative to the FNT start |
| `+4` | 2 | `u16` | file ID of the first file listed in the sub-table |
| `+6` | 2 | `u16` | parent directory ID; **for the root, the total directory count** |

Sub-tables are runs of variable-length entries, ended by a `0x00` type byte:

| type byte | meaning |
|---|---|
| `0x01`..`0x7F` | file; that many name bytes follow |
| `0x81`..`0xFF` | directory; `type & 0x7F` name bytes, then a `u16` directory ID |

Directory IDs are `0xF000`-based. The root is `0xF000`.

### Filenames are bytes, not text

**Confirmed by observation.** Two archives on the cartridge carry names containing Shift-JIS bytes, apparently because a developer typed fullwidth characters by accident:

| archive | name bytes | rendering |
|---|---|---|
| `/data/chara/ms04_tanatos.chr` | `6d 73 30 34 5f` **`82 94`** `61 6e 61 74 6f 73 2e 62 63 66 67` | `ms04_` `ｔ` `anatos.bcfg` |
| `/data/chara_sub/s043f01.chr` | `73 30 34 33` **`82 86`** `30 31 2e 6e 73 62 6d 64` | `s043` `ｆ` `01.nsbmd` |

A decoder that accepts only ASCII rejects both archives. Names should be handled as raw bytes, so that they round-trip losslessly and compare exactly. To display a name, apply whatever encoding there is evidence for; the filesystem itself does not declare one.

## NARC

A whole NitroFS packed into one file.

### Header

| offset | size | type | value |
|---|---|---|---|
| `0x00` | 4 | `char[4]` | `NARC` |
| `0x04` | 2 | `u16` | byte-order mark, `0xFFFE` (little-endian) |
| `0x06` | 2 | `u16` | version, `0x0100` |
| `0x08` | 4 | `u32` | total file size |
| `0x0C` | 2 | `u16` | header size, `0x10` |
| `0x0E` | 2 | `u16` | chunk count, `3` |

### Chunks

Three chunks follow. Each is a `char[4]` stamp and a `u32` size; the size covers the stamp and size fields themselves.

| stamp | contents |
|---|---|
| `BTAF` | `u16` file count, `u16` reserved, then a FAT whose offsets are **relative to the `GMIF` payload** |
| `BTNF` | an FNT, byte-identical in layout to the cartridge's own, padded to 4 bytes with `0xFF` |
| `GMIF` | the file image |

**Stamp spelling.** Some references transcribe these reversed, as `FATB`/`FNTB`/`FIMG`. Only the spelling in the table above was observed on the cartridge, across all 4,129 archives.

Many NARCs in other games carry a names-free FNT (a single root directory with an empty sub-table) and are addressed purely by index. That case does not occur on the Dragon Quest IX cartridge.

## Evidence

Checked against a retail cartridge (European release, `YDQP`):

| check | result |
|---|---|
| named files walked | 7,481 across 23 directories |
| FAT entries | 7,516 (35 ARM9 overlays + 7,481 named files) |
| NARC archives parsed | 4,129 / 4,129 |
| archive members enumerated | 24,556 |
| header and logo CRC-16 | both match |

## Not established

Not examined, and left as opaque bytes:

- The icon/title banner at the header's banner offset.
- The secure area, the RSA signature and any DSi-only header extension.
- The reserved and DSi-only header regions.
- Anything inside an archive member. See the format pages below.

## See also

- [DS-Compression](DS-Compression) — 11,179 NARC members on the cartridge are LZ77-compressed; the ARM9 binary and overlays use backwards LZ
- [GPC2](GPC2) — Level-5's own archive container, also found on the cartridge
- [NSBMD](NSBMD) · [2D-Graphics](2D-Graphics) · [SDAT](SDAT)
