# Bitmap Font

The game draws text from two kinds of 1-bit-per-pixel font, neither of them Nintendo's. The Japanese glyph fonts are `.mes` files inside `data/pack/font.gp2` and `data/pack_lv5/font_lv5.gp2` (see [GPC2](GPC2)), named like `f8.mes`, `f10111.mes` and `f12C01B.mes`. The Latin glyphs of the European build are two loose strips, `/data/pack_lv5/fd_me.bin` and `fd_s7.bin`, each with an index file beside it. There is no NFTR resource anywhere on the cartridge: the standard DS font format is not used. Everything here was established by observation of the European release (game code YDQP). The `.mes` header, character map and glyph packing are confirmed; the Latin strip and index layouts are confirmed apart from their version fields (INFERRED) and most glyph flag bits (not established).

## `.mes` fonts

### Header

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 1 | `u8` | line height |
| `+0x01` | 1 | `u8` | `unknown_0x01`, always 0 |
| `+0x02` | 1 | `u8` | cell width |
| `+0x03` | 1 | `u8` | cell height |
| `+0x04` | 1 | `u8` | `unknown_0x04`, always equal to the cell width |
| `+0x05` | 1 | `u8` | `unknown_0x05`, always 0 |
| `+0x06` | 2 | `u16` | glyph count |
| `+0x08` | 4 | `u32` | character map offset |
| `+0x0C` | 4 | `u32` | glyph bitmap offset |

There is no magic number. The header's shape is distinctive enough to identify a font anyway: two reserved zero bytes, a repeated width, and two offsets that must agree with the glyph count. That test accepts all 529 fonts on the cartridge and nothing else among its 88,000 files.

A glyph count of **zero is legitimate**. 17 fonts are empty, belonging to scenarios that need no extra glyphs.

### Character map

`count` **big-endian** `u16` codepoints, in glyph order.

Big-endian is not a guess. Read that way the values are Shift-JIS: `0x8140` the ideographic space, `0x824F`–`0x8258` the fullwidth digits, `0x8260`–`0x8279` the fullwidth Latin capitals. Byte-swapped they are nothing at all.

### Glyphs

One bit per pixel, most significant bit first, packed **continuously with no row padding**: a glyph occupies exactly `ceil(width * height / 8)` bytes.

This matters. A 10×10 cell takes **13** bytes, not the 20 that row alignment would need, and the three 10×10 fonts are unreadable under the other assumption. It is confirmed arithmetically (`glyphOffset + count * ceil(w*h/8)` lands on the end of the file, within a few bytes of padding, for every font) and visually (below).

### What the `.mes` fonts contain

Every one of the 529 fonts is Japanese: 70,540 of their codepoints are in the Shift-JIS kanji range, 54 in the punctuation range, and **none is a single-byte Latin codepoint**. The `f12C01B`-style names match scenario area codes, so these are per-scenario kanji subsets: the cartridge ships only the characters each scene needs.

`/data/pack_lv5/font_lv5.gp2` holds one font, `f8.mes`, whose Latin is the 26 fullwidth capitals and the ten digits. No `.mes` font on the cartridge has a lowercase letter.

## Latin fonts: `fd_me.bin` and `fd_s7.bin`

Two loose files in `/data/pack_lv5/` that are **strips of the Latin glyphs, one bit a pixel**. `fd_me` is a serifed face; `fd_s7` a smaller one without serifs, which also has `+1` to `+9`.

### Strip header

| offset | size | type | `fd_me.bin` | `fd_s7.bin` | meaning |
|---|---|---|---|---|---|
| `+0x00` | 4 | bytes | `1.0` and a zero | the same | a version, INFERRED |
| `+0x04` | 2 | `u16` | 1,600 | 1,312 | the strip's width, in pixels |
| `+0x06` | 2 | `u16` | 12 | 12 | its height |
| `+0x08` | 4 | `u32` | 2,400 | 1,968 | the pixels' size in bytes |
| `+0x0C` | 4 | `u32` | 16 | 16 | where the pixels start |

**Width × height ÷ 8 is the size on both** (1,600 × 12 ÷ 8 = 2,400; 1,312 × 12 ÷ 8 = 1,968) and the pixels end the file. Drawn row by row, each byte's **most significant bit on the left**, both read as text: digits, `A`–`Z`, `a`–`z`, punctuation, `€ £ © ®`, the accented capitals and small letters of the European languages, arrows and shapes. With the bits the other way every glyph is mirrored in eight-pixel pieces.

### Index: `fi_me.bin` and `fi_s7.bin`

Each strip has an index beside it. It is not a [Tagged-Data-Table](Tagged-Data-Table), though its head passes for one's: a version, then five `u32`s.

| offset | size | type | `fi_me` | `fi_s7` | meaning |
|---|---|---|---|---|---|
| `+0x00` | 4 | bytes | `1.1` and a zero | the same | a version, INFERRED |
| `+0x04` | 4 | `u32` | 242 | 245 | glyph count |
| `+0x08` | 4 | `u32` | 105 | 22 | kerning pair count |
| `+0x0C` | 4 | `u32` | 24 | 24 | where the pairs start |
| `+0x10` | 4 | `u32` | 444 | 112 | where the glyphs start |
| `+0x14` | 4 | `u32` | 2,380 | 2,072 | where the names start |

The sections meet end to end on both (24 + 105 × 4 = 444, 444 + 242 × 8 = 2,380) and the names run exactly to the file's end.

#### Glyph record (8 bytes)

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 4 | `u32` | offset of the glyph's name |
| `+0x04` | 1 | `u8` | width |
| `+0x05` | 1 | `u8` | flags (below) |
| `+0x06` | 2 | `u16` | x position in the strip |

Every glyph begins one pixel after the one before it ends (241 of 241 and 244 of 244), and the last ends at the strip's width, 1,600 and 1,312. The names follow one another in glyph order, each ending with a zero.

**A name is the character as the game's text spells it**: `A`, `0`, `/`, and for the rest the tags the text uses. `<'A>` is Á, `<ss>` ß, `<66>` “, `<1>` the apostrophe of `warrior<1>s shield`. Every tag read from the game's text (identified by where each stands in the text) names a glyph in both fonts. Three are the name-entry keyboard's: `<capslock>`, `<shift>` and `<back>`.

#### Flags

- **Bit 7** is set on exactly the small letters whose capital is in the font: 51 in both, a to z and the accented and joined ones. The one small letter without a capital here, ß, lacks it. INFERRED: marks a letter that can be made a capital.
- **Bit 6** is set on the vowels, capital and small, plain and accented, and on Æ and æ, and on ñ, though not on Ñ, nor on Œ or œ: 55 glyphs, the same in both fonts. So it is not simply "a vowel", and what it marks is not established.
- Neither bit is set on anything but a letter.
- **The low six bits** are 1 on the letters and digits and 3 or 4 on most of the rest. Not established.

#### Kerning pair (4 bytes)

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 1 | `u8` | left glyph |
| `+0x01` | 1 | `u8` | right glyph |
| `+0x02` | 1 | `s8` | adjustment: −1 on every pair |
| `+0x03` | 1 | `u8` | 0 on all 127 pairs |

Pairs include `AT`, `AV`, `AW`, `AY`, `LT`, `Ty`, `F.`, `P.` and on, 105 in `fi_me` and 22 in `fi_s7`.

### The space glyph

The first glyph in both, named `< >`, draws a bar (18 of its 24 pixels inked in `fd_me`, 8 of 12 in `fd_s7`): a cursor or a marker, not a space. The only glyph with no ink is `//`, zero pixels wide, which is no space either. So how wide the game makes a space is not in the index.

## NFTR names in the code

**The NFTR fonts the code names are the Wi-Fi utility's, not the game's.** Overlay 31 names three (`msg/lc_s.NFTR.l`, `msg/lc_m.NFTR.l`, `msg/kc_m.NFTR.l`) and the ARM9 binary carries the `RTFN` stamp, but no file on the cartridge is called any of them. Every other place those names and stamps occur is inside `/dwc/utility.bin`: Nintendo's Wi-Fi Connection setup, which draws its own screens.

## Evidence

The decisive check for `.mes` is that decoded glyphs *look like* the characters their codepoints name. From `f8.mes`, an 8×8 font:

```
0x8250  fullwidth 1      0x8252  fullwidth 3      0x8261  fullwidth B
    ##                     ######                   ########
    ####                 ##      ##               ##      ##
    ##                   ##                       ##      ##
    ##                     ####                     ########
    ##                   ##                       ##      ##
    ##                   ##      ##               ##      ##
    ##                     ######                   ########
```

Nine consecutive glyphs were also checked by hand (space, period, colon, dash, solidus, both parentheses, plus and minus) and each matched its codepoint.

| check | result |
|---|---|
| fonts parsed | 529 / 529 |
| glyphs decoded | 70,604 |
| cell sizes | 525 × 12×12, 3 × 10×10, 1 × 8×8 |

For the Latin strips: pixel size = width × height ÷ 8 on both files; index sections meet end to end; glyphs abut with one-pixel gaps across the whole strip (241/241, 244/244).

The party's name panels in a screen capture of Stornway's church are in a face without serifs, as `fd_s7` is. How wide the names stand cannot be measured from that capture, whose edges its scaling blurs.

## Earlier readings

The Latin glyphs were first searched for in the `.mes` format, and not found. The search covered every file matching the `.mes` header's shape across the whole extraction; files whose names suggest a font; the NCGR and NCLR resources, including the per-language `tf_*` set in `data/ani/tf.gp2` (512-byte 4bpp UI graphics, seventeen per language, far too small for an alphabet); and `data/bin`, the ARM9 binary and all 35 overlays, scanned for runs of fixed-size 1bpp cells at seven plausible geometries. The only scan matches were data tables that match at *every* offset and *every* geometry, the tell for a false positive. The glyphs were in the loose `fd_*.bin` strips, outside the archives that search covered.

## Not established

- The meaning of `unknown_0x01`, `unknown_0x04` and `unknown_0x05` in the `.mes` header beyond their observed constant values.
- The version bytes of the strip and index files (INFERRED as versions).
- Glyph flag bit 6 and the low six flag bits; bit 7 is INFERRED.
- Which Latin face the game uses where.
- The space the game leaves between Latin glyphs. The strip's one-pixel gap suggests one.
- How wide the game makes a space.

## See also

- [GPC2](GPC2): the archives holding the `.mes` fonts
- [2D-Graphics](2D-Graphics): NCGR/NCLR
- [Event-Text](Event-Text), [System-Strings](System-Strings): the text the tags come from
