# Map Objects

A map archive holds a dozen loose files with no index between them. The `.bmdj` beside them is the list: the map-to-model manifest that says which models, collision meshes and animations compose a map, and where some of them are placed. It is an ordinary [Tagged-Data-Table](Tagged-Data-Table). All figures are from the European release (game code YDQP). The resource count, resource records and their string offsets are confirmed on all 755 manifests; three fields of the placement record are established; the remaining placement values, two values of each resource record and the tag that follows each placement record are not.

## Layout

| tag | meaning |
|---|---|
| `0x6A` | number of resources |
| `0x6C` | one per resource: position, **byte offset into the string table**, two unknowns |
| `0x6F` | one per resource, in the same order: where the map puts it (fourteen values) |

### Names are addressed by byte offset

Records address a string by where it begins in the string table, not by its position in the list. A reader that counts names instead gets the first one right and drifts thereafter.

Names are **authoring** names, such as `C01M0300.imd` (`.imd` being the source-format name for what ships as [NSBMD](NSBMD)). The built files beside the manifest carry the same stem with whatever extension they were compiled to.

### A resource is not one file

One authored `.imd` compiles to everything it needs, and all the outputs keep its stem. `C01M0300.imd` is `C01M0300.nsbmd` *and* `C01M0300.nsbta`, and `C01M03G1.imd` is a model, a joint animation and a config. Resolving a name must return every file with that stem rather than choosing one. Choosing looks harmless and is not: taking the first match loses a map's **main geometry** to the manifest file sitting beside it under the same stem, and the map still assembles, just without most of itself.

### Placement: `0x6F`

Some map pieces are authored **at their own origin** and moved into place. The village's ten doorways are ten models each spanning about a unit and a half from the origin; drawn unplaced they stack on top of each other in the middle of the map, with their collision boxes stacked there too.

Fourteen values per record. Three groups are established:

| value | type | meaning |
|---|---|---|
| 3, 4, 5 | float | translation |
| 6 | `u32` | the slot of the resource this one is attached to, or `0xFFFFFFFF` for none |
| 8, 9, 10 | float | scale. `1, 1, 1` on every resource on the cartridge |

The other values are not read.

**Attachment matters.** A door's collision has no translation of its own: value 6 names the door model's slot (value 1 of that resource's record) and it goes wherever the door goes. Following that link is what puts the wall in the doorway rather than leaving it at the origin while the door moves away. Checked on the village: each of `M01A00D1`..`DA` names the slot of the `M01M00D1`..`DA` beside it, and none carries a translation.

**The unit is the file's own**: the one models are in at their own `upScale` and collision at `2 ** shift` (see [Map-Collision](Map-Collision)). No further divisor applies.

**Placements pair one-to-one with resources only on some manifests.** They match resources by position. 696 of the 755 manifests have exactly one placement per resource; the other 59 carry *more* placements than resources. Pairing positionally through an extra record places every piece after it in the wrong spot, so how those 59 pair is not established.

Other pieces already hold their own world coordinates. On `C01M03` the main geometry, a lamp and a night overlay occupy three distinct, non-overlapping regions of one space, and a field's terrain tiles are each authored in world coordinates (see [Map-Collision](Map-Collision#fields)).

## Evidence

| check | result |
|---|---|
| manifests parsed | **755 / 755** |
| the `0x6A` count equals the number of `0x6C` records | 755 / 755 |
| every resource record resolves a string by its offset | 755 / 755 |
| every name so resolved ends in `.imd` | 755 / 755 |
| **resources present in their own archive** | **5,342 / 5,342** |

What the resources turn out to be: 2,985 models, 1,133 collision meshes, 702 `.nsbta` texture animations, 521 `.nsbtp` pattern animations.

**Assembly is worth doing, measurably.** A map's collision mesh should sit inside the ground the map draws. Across the cartridge it does so for 939 of 1,133 meshes against the whole assembly, and 798 against the largest single model in it, so the pieces beyond the main geometry account for real walkable ground. The remainder is collision that extends past what the archive draws, which is what an invisible boundary at a map edge looks like.

**The placement translation, checked by fitting.** Over every map with both placed pieces and unplaced ground, counting the pieces authored to sit at their own origin (local `minY` ≈ 0) that end up standing on that ground, a divisor applied to placements peaked at 8, which is the village terrain's own `upScale`:

| divisor | on the ground, cartridge-wide | on the village |
|---|---|---|
| 5 | 62.2% | — |
| 7 | 67.9% | 9/10 |
| **8** | **74.4%** | **10/10** |
| 8.5 | 74.8% | 10/10 |
| 10 | 71.1% | 8/10 |
| 12 | 65.4% | 5/10 |

This was measured while the village terrain was drawn at an eighth of its size. With models drawn at their own `upScale`, placements need no divisor.

## Earlier readings

- **Placements an order of magnitude too large.** The village's doors sit at x −28.56 and 26.10 while its terrain was then drawn from −4.38 to 7.61. The terrain was being drawn at an eighth of its size (see [NSBMD](NSBMD) for `upScale`), and a divisor of 8 was fitted to the placements (table above). The fit rediscovered the terrain's `upScale`; the placements themselves were right.
- **"There is no placement."** An earlier note said a manifest carries no transforms and a map's pieces all hold their own world coordinates, with the `G1` resource (centred on the origin, with a joint animation and a config) as the one exception placed by something other than the manifest. The `0x6F` translation and attachment fields above were read after that note.

## Not established

- The two unknown values in each `0x6C` record.
- `0x6F` values other than 3–6 and 8–10.
- The small tag that follows each `0x6F` record. It is **not** a resource kind: `.nsbmd` and `.col2` alike are followed by `0x3F` most of the time.
- How `0x6F` records pair with resources on the 59 manifests that carry more placements than resources. The `0x6F` records are numbered in order on only 534 of 755 files.
- What places the `G1` resource.

## See also

- [Tagged-Data-Table](Tagged-Data-Table): the container
- [Map-Archive](Map-Archive): the archive the manifest indexes
- [Map-Collision](Map-Collision): `.col2` and `shift`
- [NSBMD](NSBMD): models and `upScale`
- [Map-Textures](Map-Textures)
- [Doors](Doors)
