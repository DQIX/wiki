# NSBTP

NSBTP (`BTP0`) is texture pattern animation: it swaps a material's texture and palette from frame to frame, as a flipbook. It is a Nitro 3D container, a companion of [NSBMD](NSBMD), in the shape of [NSBTA and NSBMA](NSBTA-and-NSBMA). The Dragon Quest IX cartridge has 572, 525 of them in the map archives under `/data/map`; the battle effects use them too. The layout and its use are read from the game's own code. **All 572 on the cartridge read**, 895 tracks between them.

> **EU only.** The code is the USA release's, from the [dqix-decomp](https://github.com/DQIX/dqix-decomp); the files were read on the European release (`YDQP`) and are not yet checked on the US release (`YDQE`).

Read 1 October 2026.

## Sources

The decomp's own code: the animation's layout, `NSBXXAnimationMPT` in `include/Graphics/NSBXX/NSBXX.h`, and its use in `src/Graphics/NSBXX/MPT.cpp` (`InitializeModelAnimationFromMPT`, `MPTAnimationProcessingCallback`) and `src/Graphics/NSBXX/PatternAnimation.cpp` (`NSBXX_PatternAnimation_GetKeyframe`, `_GetTextureName`, `_GetPaletteName`, `_GetTrack`).

## Layout

A Nitro container of one block, `PAT0`, holding a name list of animations (see [NSBMD](NSBMD) for the name list), each an offset from the block. An animation:

| offset | type | what |
|---|---|---|
| `+0x00` | 4 bytes | `M\0PT` |
| `+0x04` | `u16` | its frame count |
| `+0x06` | `u8` | how many texture names |
| `+0x07` | `u8` | how many palette names |
| `+0x08` | `u16` | where the texture names are, 16 bytes each, from the animation |
| `+0x0a` | `u16` | where the palette names are, likewise |
| `+0x0c` | | the tracks: a name list by material, an item 8 bytes |

**A track**, 8 bytes:

| offset | type | what |
|---|---|---|
| `+0x00` | `u16` | how many keyframes |
| `+0x02` | `u16` | loaded and not used |
| `+0x04` | `s16` | the search's starting guess, `fx16`: keyframes a frame |
| `+0x06` | `u16` | where its keyframes are, from the animation |

**A keyframe**, 4 bytes: `u16` the frame it takes effect from, `u8` the texture's index, `u8` the palette's — `0xff` leaves the palette as it is.

## At a frame

**A material takes the last keyframe not past the frame.** `_GetKeyframe` starts at the guess, walks back while the keyframe is not before the frame, then on while the next is not past it.

The texture and palette are looked up **by name** among the model's own textures (`SetMaterialTextureForRender`, `SetMaterialPaletteForRender`). The material's size is set to the new texture's, so its texture coordinates scale with it. A track binds by its name to the material of the same name; one naming no material does nothing.

A map's pattern animation is loaded only where its resource's flags say so, and advances a frame every 17 ms — see [Map objects](Map-Objects).

## Not established

- What the track's `+0x02` is for: the code loads it and nothing reads it.

## See also

- [NSBMD](NSBMD), [NSBTA and NSBMA](NSBTA-and-NSBMA)
- [Map objects](Map-Objects): which animations a map piece loads
