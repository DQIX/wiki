# NSBTA and NSBMA

NSBTA (`BTA0`) animates a texture's scale, rotation and translation over time; NSBMA (`BMA0`) animates a material's colours and alpha. Both are Nitro 3D containers, the companions of [NSBMD](NSBMD). The Dragon Quest IX cartridge has 1,680 NSBTA and 2,312 NSBMA; 873 and 512 of them sit, LZ77-compressed, in the NARC archives under `/data/map`, and the battle effects use them too. Their layout, every channel, every bit and the sampling rule are read from the game's own code. **All 1,680 NSBTA and 2,312 NSBMA on the cartridge read** under it. The `u16` after an animation's frame count is not established.

> **EU only.** The code is the USA release's, from the [dqix-decomp](https://github.com/DQIX/dqix-decomp); the files were read on the European release (`YDQP`) and are not yet checked on the US release (`YDQE`).

Read 29 September 2026.

## Sources

- scurest, [nsbmd_docs](https://github.com/scurest/nsbmd_docs), "Material Animations", and apicula's `src/nitro/material_animation.rs`: NSBTA's block, its `M\0AT` animations and the track list. Both are marked incomplete. **They read the translation samples as 1.10.5; the game reads them as `fx16`**, 4096 to one: an `ldrsh` into a `fix32` used as the translation. They list NSBMA as undocumented.
- **The game's own code**, as the decompilation gives it: `MAT.cpp` and `MAM.cpp` in `src/Graphics/NSBXX/`, the evaluators that the animation table at USA ARM9 `0x020f1c90` names by stamp. Every channel, bit and sampler below is theirs. The texture matrix built from the channels is `RenderCommandProcs.cpp`'s `CreateTextureMatrix_v0_*`.

## Layout

Both files are a Nitro container of one block — `SRT0` in an NSBTA, `MAT0` in an NSBMA — holding a name list of animations (the [resource dictionary](NSBMD#resource-dictionary) a model uses), each entry an offset from the block.

An animation:

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 4 | `char[4]` | `M\0AT` in an NSBTA, `M\0AM` in an NSBMA |
| `+0x04` | 2 | `u16` | frame count |
| `+0x06` | 2 | `u16` | `unknown_0x06`: `0x0303` on the SRTs, `0x0003` on the MAMs |
| `+0x08` | | | a name list of tracks, each named for the material it moves |

Sample offsets are from the animation's stamp.

### NSBTA's track — 40 bytes

Five channels, each a metadata word and a value word, in this order: scale S, scale T, rotation, translate S, translate T.

| metadata bits | meaning |
|---|---|
| 0–15 | the last frame — on the cartridge, the frame count |
| 28 | the samples are `s16` rather than `s32` |
| 29 | the value word is the value, held for the whole animation |
| 30–31 | the frames a sample covers: bit 30 is tested first, and means 2; then bit 31, which means 4 |

A rotation's value is a sine in its low half and a cosine in its high half, `fx16` each. A translation is `fx16`, as above.

### NSBMA's track — 20 bytes

Five words: diffuse, ambient, specular, emission and alpha.

| bits | meaning |
|---|---|
| 0–15 | where the samples start, or the value held |
| 16–28 | the frames the samples cover: the decompilation names it the last frame; on the cartridge it holds the frame count, 16 on `eb0500`'s 16 |
| 29 | the value is held |
| 30–31 | the frames a sample covers |

A colour is `BGR555` in a `u16`. Alpha is a `u8`, 0 to 31, which goes into bits 16–20 of `POLYGON_ATTR` — the same bits a material's own alpha occupies (see [A material's colour and alpha](NSBMD#a-materials-colour-and-alpha)).

## Sampling

From `SampleScalarFromMATTrack`, `GetColorFromMaterialAnimation` and `GetAlphaFromMaterialAnimation`. The frame is a whole number.

- **A sample every frame:** the frame reads its sample directly.
- **A sample every second frame:** the odd frames take the mean of the two samples either side.
- **A sample every fourth frame:** the half-way frames take the mean, and the others are mixed three to one toward the nearer sample.

Colours are mixed through their red-and-blue and green masks. Past the last frame, an in-between frame reads a sample near the end.

## Example: the sword's trail, `eb0500`

16 frames. Its two materials are white, with alpha 0 up to frame 11 and then 31, 20, 10 and 0. Its texture is at scale (1, ½), still up to frame 11 and then sliding −0.011, −0.068, −0.252 and −0.5 of its height. So the trail is there only for its last four frames, fading as it slides. See [Battle-Action-Scripts](Battle-Action-Scripts) for the blow that plays it.

## Evidence

| check | result |
|---|---|
| NSBTA files read | **1,680 / 1,680** |
| NSBMA files read | **2,312 / 2,312** |

## Not established

- **`unknown_0x06`**, the `u16` after an animation's frame count: `0x0303` on the SRTs, `0x0003` on the MAMs.
- **How the texture matrix is built** from the five channels. The function is named above; its construction is not described on this page.
- **NSBTP (`PAT0`)**, pattern animation, is not read. See [NSBMD](NSBMD#the-six-containers).

## See also

- [NSBMD](NSBMD) — the models these animate, and their materials
- [DS-Compression](DS-Compression) — the LZ77 compression on the NARC members
- [NitroFS](NitroFS) — the NARC archives
- [Battle-Action-Scripts](Battle-Action-Scripts) · [Battle-Stages](Battle-Stages) · [Map-Archive](Map-Archive)
