# 2D-Graphics

NCLR, NCGR and NCER are Nintendo's 2D graphics files: palettes, characters (8×8 tiles) and cells (sprites built from OAM parts). The Dragon Quest IX cartridge has 501 of them — 139 NCLR, 224 NCGR, 138 NCER — alone or in packs. The file and block framing, the palette, character and cell blocks, and how a part's tile number and palette number resolve are confirmed against all of them. A part's position being signed is INFERRED. A cell's own attribute word, the `LBAL` and `TXEU` blocks beyond NitroPaint's reading, and `CEBK`'s `+0x10` are not established.

All observations were made on the European release (game code `YDQP`).

## Sources

- NitroPaint, [`NitroPaint/object/`](https://github.com/Garhoogin/NitroPaint): `PalReadNclr` in `NitroPalette.c`, `ChrReadNcgr` in `NitroCharacter.c`, `CellReadNcer` and `CellDecodeOamAttributes` in `NitroCell.c`
- GBATEK, [LCD OBJ - OAM Attributes](https://problemkaputt.de/gbatek.htm#lcdobjoamattributes) for a part's three attributes, the size table, and "OBJ0 is always having priority above OBJ1-127"; *LCD Color Palettes* for "Color 0 of all BG and OBJ palettes is transparent"; *LCD OBJ - OAM Rotation/Scaling Parameters* for the double-size area

## Layout

### The file

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 4 | `char[4]` | magic, stored reversed: `RLCN`, `RGCN`, `RECN` |
| `+0x04` | 2 | `u16` | byte-order mark, `0xFEFF` |
| `+0x06` | 2 | `u16` | version — `0x0100` palettes and cells, `0x0101` characters |
| `+0x08` | 4 | `u32` | file size |
| `+0x0C` | 2 | `u16` | header size, 16 |
| `+0x0E` | 2 | `u16` | block count |

Blocks follow one another from the header's end. Each is a stamp, stored reversed (`TTLP` is PLTT), and a `u32` size that counts the block's own eight-byte head. Unlike [NSBMD](NSBMD), these files do not list their blocks by offset.

**On all 501 files on the cartridge, every header is 16 bytes, every file-size field equals the file, and the blocks end exactly at it.** Offsets inside a block count from its content, past the head.

## NCLR — `PLTT`, and `PCMP`

`PLTT`:

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 4 | `u32` | depth: 3 sixteen colours a palette, 4 256 (NitroPaint: `1 << (depth - 1)` bits) |
| `+0x04` | 4 | `u32` | extended-palette flag |
| `+0x08` | 4 | `u32` | the colours' size, as stored — not reliable, see below |
| `+0x0C` | 4 | `u32` | where the colours start |

`PCMP`:

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 2 | `u16` | palettes stored |
| `+0x02` | 2 | `u16` | `unknown_0x02` — `0xBEEF` on 120 of 120 |
| `+0x04` | 4 | `u32` | where the slot list starts |
| then | 2 × count | `u16` | the slot each stored palette fills, in order |

- **The colours run to the block's end, and with a `PCMP` hold exactly its count of palettes: 120 of 120.** Depth is 3, the flag 0 and the colours at `0x10` on all 139.
- **The size field is not to be trusted.** With a `PCMP` it agrees on 40 and not on 80. Where it disagrees it is sixteen palettes' worth less those stored — 9 stored and 7 said, 7 and 9, 16 and 0 — which NitroPaint notes as `g2dBug`. Without a `PCMP` it agrees on 19 of 19.
- **A part's palette number names a slot**, not a stored palette: every cell's palette numbers are among its pack's `PCMP` slots, 118 of 118, and in 47 of 130 packs one is past the stored count.

## NCGR — `CHAR`

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 2 | `u16` | height in tiles; `0xFFFF` for none |
| `+0x02` | 2 | `u16` | width in tiles; `0xFFFF` for none |
| `+0x04` | 4 | `u32` | depth, as the palette's |
| `+0x08` | 4 | `u32` | OBJ VRAM mode, as NitroPaint keeps it |
| `+0x0C` | 4 | `u32` | type: 1 for bitmap data (NitroPaint) |
| `+0x10` | 4 | `u32` | the characters' size |
| `+0x14` | 4 | `u32` | where they start |

A tile is 8×8. At four bits per pixel it is eight rows of four bytes, the low nibble the left pixel.

On all 224: depth 3, no width or height, type 0, the characters at `0x18` and ending at the block's end. The mode is `0x10` on 214 and `0x200010` on 10 — **beside cells of mapping 0 and 2 respectively, on all 130 packs that pair them**.

## NCER — `CEBK`

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 2 | `u16` | cell count |
| `+0x02` | 2 | `u16` | 1 when cells carry bounding boxes |
| `+0x04` | 4 | `u32` | where the cells start |
| `+0x08` | 4 | `u32` | mapping: 0 to 3 one-dimensional, 32K to 256K; 4 two-dimensional |
| `+0x0C` | 4 | `u32` | VRAM transfer data, 0 for none |
| `+0x10` | 4 | `u32` | `unknown_0x10` |
| `+0x14` | 4 | `u32` | user-extended attributes, 0 for none |

A cell:

| field | type |
|---|---|
| part count | `u16` |
| attribute (not established) | `u16` |
| offset to its parts, from the end of the cell table | `u32` |
| with boxes only: max x, max y, min x, min y | `i16` each |

A part is GBATEK's three OAM attributes.

On all 138: no boxes, cells at `0x18`, `+0x0C` to `+0x14` zero, and `LBAL` and `TXEU` blocks besides. Mapping 0 on 128, 2 on 10. Of 4,476 parts: shape 0 ×2,882, 1 ×1,218, 2 ×376; none use 256 colours; 130 are affine.

### A tile number counts 32 bytes shifted left by the mapping

In mode 0, every part's tiles fit its characters at one tile a number, 120 of 120, and at four would not on 118. **In mode 2, at four tiles a number, the furthest part ends exactly at the characters' end on 5 of 10** — 320 of 320 tiles — and two tiles short of it on the other 5, 714 of 716. At one tile a number they would use about a quarter. That matches NitroPaint's mode names, 1D 32K to 256K, as a unit of `32 << mode` bytes.

### A part's place is signed — INFERRED

Nine bits of x and eight of y, read as signed. A 32×8 part at x `0x1F0`, y `0xFC` then sits centred on its cell's origin, as the file's other cells do. GBATEK gives the ranges as 0–511 and 0–255, for the screen; a cell's origin is not the screen's.

## Drawing a cell

As the DS would draw them: part 0 in front (GBATEK: "OBJ0 is always having priority above OBJ1-127"), colour 0 transparent, and in one-dimensional mapping a part's tiles following one another.

An affine part's rotation matrix is set at run time, not in the file, so the file alone does not give an affine part's final appearance. The cartridge has no two-dimensional mapping and no 256-colour parts.

## Evidence

- 501 files — 139 NCLR, 224 NCGR, 138 NCER: header size, file size and block extents all exact.
- `PLTT` colours fill exactly the `PCMP` count of palettes, 120 of 120.
- Cell palette numbers fall among the pack's `PCMP` slots, 118 of 118.
- NCGR VRAM mode tracks the paired cells' mapping, 130 of 130 packs.
- Tile numbers at `32 << mode` bytes: mode 0, 120 of 120 fit at one tile a number; mode 2, 5 of 10 end exactly at the characters' end and the other 5 two tiles short.

## Not established

- What a cell's own `u16` attribute says — 6 on 1,271 cells, 5 on 283, 3 on 207, and others.
- What `LBAL` and `TXEU` hold beyond NitroPaint's reading of them.
- `CEBK`'s `unknown_0x10`.
- `PCMP`'s `unknown_0x02` (`0xBEEF` on every sample).
- A part's signed position is INFERRED (see above).
- Two-dimensional mapping and 256-colour parts do not occur on the cartridge.

## See also

- [NSBMD](NSBMD) — the 3D model and texture formats
- [NitroFS](NitroFS) — the cartridge filesystem and NARC archives
- [Sprites](Sprites) · [Menu-Backgrounds](Menu-Backgrounds) · [Item-Icons](Item-Icons)
