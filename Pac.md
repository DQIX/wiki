# Pac (`.pac`)

A `.pac` file is a plain pack of named files: a chain of entries, each an `0x50`-byte head followed by its data. `.pac` files hold the 2D screens' palettes, characters and cells, as well as some models and effects. For example, `/data/ani/obj_mm.pac` holds the mini-map's sprites. The chain structure is confirmed on 463 of the cartridge's 468 `.pac` files. The last head word is not established.

All counts on this page are from the European release (game code YDQP).

## Layout

Each entry is a head followed by its data.

| offset | type | meaning |
|---|---|---|
| `+0x00` | `char[0x40]` | the name, terminated by a NUL. Bytes after the NUL are leftovers: one name field holds `\test\test` |
| `+0x40` | `u32` | the head's size, `0x50` |
| `+0x44` | `u32` | the data's size |
| `+0x48` | `u32` | the distance from this entry to the next |
| `+0x4C` | `u32` | `unknown_0x4c` |

The data follows the head.

**The step to the next entry** is the head plus the data, rounded up to a multiple of 16.

**The chain ends with an end marker at the end of the file.** The end marker is either:

- a head of `0x50` zero bytes, or
- in the seven files in `/data/effect/`, a head whose size and step are both `0xFFFFFFFF`, with leftovers in its name field.

## Members

A pack's members can be:

- Nitro 2D files: `RECN`, `RGCN`, `RLCN`, and `RNAN` animations (see [2D-Graphics](2D-Graphics))
- this game's own `CHAR`, `PALT` and `SCRN` files: `.bncg`, `.bncl` and `.bnsc` (see [Menu-Backgrounds](Menu-Backgrounds))
- models (`BMD0`, see [NSBMD](NSBMD))
- effect files

### Example: `obj_mm.pac`

`/data/ani/obj_mm.pac` holds `obj_mm.NCER`, `.NCGR` and `.NCLR`, with 28 cells. The cells include the HP and MP panels, the digits, a church, crossed swords, and dots.

- **Cell 5 is an 8×8 light-blue dot with a black rim.**
- Cell 7 is a red dot.

Which dot marks the Hero on the mini-map, and in what colour, is not established. See [Mini-Map](Mini-Map).

## Evidence

The cartridge has 468 files named `.pac`.

| check | result |
|---|---|
| files with this layout | **463 of 468** |
| every entry that is not an end: step equals head plus data, rounded up to 16 | holds on all |
| chain ends on an end marker that ends the file | **463 of 463**: 456 with a zero head, 7 with an `0xFFFFFFFF` head |

The other five `.pac` files are `tdata_<lang>.pac` in `/data/tmap/tdata.gp2`. Their word at `+0x40` is `0x1600` to `0x1687`, so they are some other format.

## Not established

- `unknown_0x4c`.
- The format of `/data/tmap/tdata.gp2`'s five `tdata_<lang>.pac` files.
- Which mini-map dot is the Hero's, and its colour.

## See also

- [2D-Graphics](2D-Graphics)
- [Menu-Backgrounds](Menu-Backgrounds)
- [Mini-Map](Mini-Map)
- [NSBMD](NSBMD)
- [GPC2](GPC2)
