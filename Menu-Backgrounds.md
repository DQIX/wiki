# Menu Backgrounds (`.bncg`, `.bncl`, `.bnsc`)

`.bncg`, `.bncl` and `.bnsc` are this game's own tile, palette and screen files, used for the menus' backgrounds. They sit beside Nitro files in [Pac](Pac) packs, and alone in archives such as the mini-map's `z01` to `z05`. The headers, tile data, palettes and screen entries are confirmed. Drawn this way, the equipment screen matches screenshots of the game. A few header words are not established.

All counts on this page are from the European release (game code YDQP).

| file | magic | holds |
|---|---|---|
| `.bncg` | `CHAR` | tiles |
| `.bncl` | `PALT` | a palette |
| `.bnsc` | `SCRN` | a screen of tile entries |

## Layout

### `.bncg` (tiles)

| offset | type | meaning |
|---|---|---|
| `+0x00` | `char[4]` | `CHAR` |
| `+0x04` | `u16` | tile count |
| `+0x06` | `u16` | width in tiles |
| `+0x08` | `u16` | height in tiles |
| `+0x0A` | `u16` | `unknown_0x0a` |
| `+0x0C` | `u32` | the tiles' size |
| `+0x10` | | the tiles: 32 bytes each at 4 bits per pixel, 64 bytes each at 8 bits per pixel |

### `.bncl` (palette)

| offset | type | meaning |
|---|---|---|
| `+0x00` | `char[4]` | `PALT` |
| `+0x04` | `u32` | `unknown_0x04` |
| `+0x08` | `u32` | the colours' size |
| `+0x0C` | | the colours, BGR555 |

### `.bnsc` (screen)

| offset | type | meaning |
|---|---|---|
| `+0x00` | `char[4]` | `SCRN` |
| `+0x04` | `u16` | width in tiles |
| `+0x06` | `u16` | height in tiles |
| `+0x08` | `u16` | `unknown_0x08` |
| `+0x0A` | `u16` | `unknown_0x0a` |
| `+0x0C` | `u32` | the entries' size |
| `+0x10` | `u16` × width × height | the entries, row by row |

### Screen entries

An entry is the DS's text background entry, as described in GBATEK, "LCD VRAM BG Screen Data Format (BG Map)":

| bits | meaning |
|---|---|
| 0–9 | the tile |
| 10 | horizontal flip |
| 11 | vertical flip |
| 12–15 | the palette. GBATEK marks these "unused" at 256 colours |

A 4-bit tile's low nibble is its left pixel, as GBATEK's "LCD VRAM Character Data" describes.

## Drawing a screen

A screen uses the tiles and palette in the same pack. **On all 659 screens whose pack holds both tiles and a palette:**

- the tile numbers stay inside the pack's largest `.bncg`, and
- the palette numbers stay inside its `.bncl`.

171 screens use the flip bits.

Drawn this way, the equipment screen's pieces come out whole: its backdrop, the frame of sixteen slots, the eight tabs, the sort buttons, and `bg_ii1.pac`'s parchment for the top screen. They match screenshots of the game.

## Evidence

The cartridge has 408 `.bncg`, 370 `.bncl` and 690 `.bnsc` files.

- **Every file is exactly as long as its head says.** That is 16 bytes plus the tiles, 12 bytes plus the colours, and 16 bytes plus the entries.
- **`.bncg`:**
  - Tiles are 32 bytes each on 376 files and 64 bytes on 32 files.
  - **Width × height equals the tile count on 408 of 408.**
  - `+0x0A` is `0x7C00` on exactly the 376 four-bit files, and `0x7C01` on exactly the 32 eight-bit files.
- **`.bncl`:**
  - Every file holds 256 colours, 370 of 370.
  - `+0x04` is 0 on 276 files and `0x101` on 94.
- **`.bnsc`:**
  - The entries take width × height × 2 bytes on 690 of 690.
  - **`+0x08` is 1 exactly where the pack's tiles are 8-bit** (32 screens), and 0 elsewhere.
  - `+0x0A` follows no pattern found: it is `0x1300` on one full 32×24 screen and `0x1304` on another.

## Not established

- `.bncg`'s `+0x0A` (`0x7C00`) beyond its lowest bit, which matches 8-bit tiles.
- `.bncl`'s `+0x04`.
- `.bnsc`'s `+0x0A`.
- Which `.bncg` a screen uses when its pack holds two. All 659 screens fit the largest one.
- Where a screen is placed on the DS's screen. The `.lia` layouts would say, and they have not been read.

## See also

- [Pac](Pac)
- [2D-Graphics](2D-Graphics)
- [Mini-Map](Mini-Map)
- [Item-Icons](Item-Icons)
