# Map Objects

A map archive holds a dozen loose files with no index between them. The `.bmdj` beside them is the list: the map-to-model manifest that says which models, collision meshes and animations compose a map, and where some of them are placed. It is an ordinary [Tagged-Data-Table](Tagged-Data-Table). All figures are from the European release (game code YDQP). The resource count, resource records and their string offsets are confirmed on all 755 manifests; five fields of the placement record are established, among them which resource it places; the remaining placement values, two values of each resource record and the tag that follows each placement record are not.

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

Fourteen values per record. Five groups are established (**EU only:** values 1 and 2 were read after the other three):

| value | type | meaning |
|---|---|---|
| 1 | integer | **EU only:** the placement's instance number: what another placement's value 6 names (below) |
| 2 | integer | **EU only:** the index of the resource it places (below) |
| 3, 4, 5 | float | translation |
| 6 | `u32` | the slot of the resource this one is attached to, or `0xFFFFFFFF` for none |
| 8, 9, 10 | float | scale. `1, 1, 1` on every resource on the cartridge |
| 11, 12, 13 | | **EU only:** zero in all 4,242 placement records, so there is no rotation there |

Values count from 1 here; counting from 0, value 1 is `values[0]` and value 2 `values[1]`. **EU only:** the record is otherwise accounted for: the values not in the table, 7 and 14, are zero or integers, and are not read.

**Attachment matters.** A door's collision has no translation of its own: value 6 names the door model's slot (value 1 of that resource's record) and it goes wherever the door goes. Following that link is what puts the wall in the doorway rather than leaving it at the origin while the door moves away. Checked on the village: each of `M01A00D1`..`DA` names the slot of the `M01M00D1`..`DA` beside it, and none carries a translation.

**The unit is the file's own**: the one models are in at their own `upScale` and collision at `2 ** shift` (see [Map-Collision](Map-Collision)). No further divisor applies.

Other pieces already hold their own world coordinates. On `C01M03` the main geometry, a lamp and a night overlay occupy three distinct, non-overlapping regions of one space, and a field's terrain tiles are each authored in world coordinates (see [Map-Collision](Map-Collision#fields)).

### A placement names its resource

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`).

**Value 2 of a `0x6F` record is the index of the resource it places, and value 1 is which instance it is.** Placements do not pair with resources by position. The counts differ on 56 of the 755 manifests because **a resource can be placed more than once**. `D03M06` lists two door models and places each twice, a pair of doors at z 12.34 and another at z 17.70, so thirteen placements serve nine resources. Each door's collision is placed twice too, each hanging off one of the door's instances: value 6 names an instance, not a resource.

Pairing by value 2 is checked three ways:

- On `D03M06` the doors take their positions, and their collision follows by the parent link. Positional pairing cannot pair this manifest at all; left unplaced, its doors stand as slabs through the floor at the origin.
- **It is right where the counts agree, too.** On maps whose counts match, it moves 22 pieces that positional pairing had off by one: doors in `C04M01` and `C04M02` leaving the origin.
- On `S07M0000`, Gortress (29 resources, 45 placements), it puts six door models and both gates (`S07M00D1`, `D6`, `DB`, `DC`, `DD`, `DE`, `G1`, `G2`) where a fortress's gates belong. Unpaired, they lie at the origin and the fortress can be walked straight through.

Pairing by value 1 instead puts a door's collision on the far side of the room from its door and loses the parent link.

### A resource placed more than once

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`).

Across the cartridge **81 resources are placed more than once: 144 placements beyond the first, in 45 maps**, every one at a distinct position. Each placement is a piece of its own, with its own collision hanging off its own instance.

- **76 are doors**, `…D1` and `…D2`. Coffinwell's `M03M00D1` is placed five times. The Observatory's doors have 12 placements beyond the first in `X01` and 14 in `X05`.
- **Four are other repeated pieces**: `D03M06`'s door models, which are named `M0602` and `M0603` rather than `D…`; `D17M03G5`, four gates in a row; and `S07M0612`, three on a diagonal.
- **One is not several of a thing.** The Hexagon's sliding statue `D01M01S1` is placed at each end of its slide, each end with its own collision (see [Doors](Doors)). It is the only resource so placed whose name is a sliding piece's. Nothing in the manifest marks it apart: its placements and flags are shaped exactly as a door's.

### More than one manifest in an archive

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`).

Six of the cartridge's 1,348 archives hold more than one `.bmdj`. Only `M12`, Wormwood Creek, is one where it matters: its archive holds `M12M0000.bmdj` with 24 resources and `M12M0001.bmdj` with one. A reader that keeps one manifest per archive, and keeps the second, loses the map's collision.

### A manifest that looks compressed

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`).

54 map `.bmdj` begin with the word 16, the table header's own size. Read as an LZ10 header, that is `0x10` and a declared size of 0: an empty stream, which decodes to nothing whatever follows. A reader that tries every file as LZ10 first takes them for empty. They are not (see [DS-Compression](DS-Compression)). The Hexagon's `D01M0000` is among the map files that begin so.

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

**EU only:** pairing positionally, 56 manifests left 1,010 resources unplaced against 4,332 placed. Pairing by value 2 leaves 4,251 of those 4,332 untouched, moves 22 (above), and pairs 59 with a different record carrying the same position.

## Earlier readings

- **Placements an order of magnitude too large.** The village's doors sit at x −28.56 and 26.10 while its terrain was then drawn from −4.38 to 7.61. The terrain was being drawn at an eighth of its size (see [NSBMD](NSBMD) for `upScale`), and a divisor of 8 was fitted to the placements (table above). The fit rediscovered the terrain's `upScale`; the placements themselves were right.
- **Placements paired by position.** Placements were matched to resources by their order, and the manifests whose counts differ were recorded as 59 with more placements than resources, their pairing not established. They are 56, and they pair by value 2, the resource index (see [A placement names its resource](#a-placement-names-its-resource)).
- **"There is no placement."** An earlier note said a manifest carries no transforms and a map's pieces all hold their own world coordinates, with the `G1` resource (centred on the origin, with a joint animation and a config) as the one exception placed by something other than the manifest. The `0x6F` translation and attachment fields above were read after that note.

## Not established

- The two unknown values in each `0x6C` record.
- `0x6F` values 7 and 14.
- The small tag that follows each `0x6F` record. It is **not** a resource kind: `.nsbmd` and `.col2` alike are followed by `0x3F` most of the time. The `0x6F` records are numbered in order on only 534 of 755 files.
- What places the `G1` resource.
- **EU only:** which resources placed more than once are one thing at several moments rather than several things. Nothing in the manifest says; on the cartridge the only such case found, the Hexagon's statue, is told apart by its sliding piece's name.

## See also

- [Tagged-Data-Table](Tagged-Data-Table): the container
- [Map-Archive](Map-Archive): the archive the manifest indexes
- [Map-Collision](Map-Collision): `.col2` and `shift`
- [NSBMD](NSBMD): models and `upScale`
- [Map-Textures](Map-Textures)
- [Doors](Doors)
