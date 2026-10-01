# Poison-Marsh

A map texture's name carries a three-letter tag saying what the surface is, for example `wtr` water or `grs` grass. Some of these tags are Japanese words: `iwa` rock, `zou` statue, `kabe` wall, `yane` roof. **`dok` is taken to be *doku*, poison — INFERRED.** Six textures on the cartridge carry it, drawn as flat surfaces at ground level. What the marsh does is not in the data read so far. Observations are from the European release (game code `YDQP`).

## Layout

| texture | drawn on | as |
|---|---|---|
| `d01dok01`, `d01dok02` | `D01M0000`, the Hexagon's own map | two flat planes, 13 and 31 triangles, at y −0.20 to −0.16 and −0.08, winding across x −12 to 10, z −5 to 12 in the model's units |
| the same two | `D14M04`'s `D14M0499` | the same, reused |
| `f49dok01`, `f49dok02` | `F49M0000` | two flat planes, 11 and 26 triangles |

`D01` is the Hexagon. It is map id 7100, and its floors are 7102 to 7104 in the map index (see [Map-List](Map-List)).

## Observations

- The planes lie as water's do: flat and just at the ground.
- The ground under them can be stood on. Under the middle of the marsh's triangles, the collision has ground within a character's height of the surface on nearly all of them (see [Map-Collision](Map-Collision)).
- Drawn from above, `D01M0000`'s marsh is **three purple patches** either side of the path up to the hexagon.
- The bounding box around the three patches covers most of the map between them, so the marsh area is only described accurately triangle by triangle, not as a box.

## Poison swamp in the collision

> **EU only.** Code addresses are the USA release's, from the [dqix-decomp](https://github.com/DQIX/dqix-decomp); the files were read on the European release (`YDQP`) and are not yet checked on the US one (`YDQE`).

A collision mesh's trailing records say which [battle stage](Battle-Stages) is fought on each stretch of ground (see [Map-Collision](Map-Collision#trailing-records-8-bytes-each)). Zere Region's collision, `F03A0000`, names stage 30108, a Poison Swamp, on 21 of its triangles, and the map list's kind of ground has a value for swamp, 7 (INFERRED, see [Map-List](Map-List)). That is where a battle is fought, not what walking there does. Whether the ground under the Hexagon's `dok` marsh, on `D01M0000`, has such a record is not read.

## Not established

- What the marsh does, and how much. That rule is in the game's code.
- Whether `mud`, on the fields, does anything.
- Whether the collision marks the marsh too. **EU only:** the attribute word's top seven bits are INFERRED to pick a ground record, which names a battle stage; nothing read ties a record to the marsh's toll, and the word's other bits are not read.
- The `dok` = *doku* reading itself (INFERRED from the name).

## See also

- [Map-Textures](Map-Textures)
- [Map-Collision](Map-Collision)
- [Map-Objects](Map-Objects)
- [NSBMD](NSBMD)
- [Battle-Stages](Battle-Stages)
