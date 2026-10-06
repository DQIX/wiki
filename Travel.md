# Travel

Zoom and the chimaera wing, Evac, and where a wiped-out party comes round. Read 6 October 2026.

> **USA only** for the code (the ARM9 and overlays 2, 3 and 17), read through the [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the files and their values.

## The places reached

Each Zoom destination is a game-wide flag, **`0x200 + n`**, in the bank at `+0x8c` (the bank [Triggers](Triggers) actions 100 and 101 set).

When a map is loaded (`func_ov017_0219d250`, at `0x0219d7b0`), `func_ov017_0219e290` looks its id up in **a table of 18 halfwords** in overlay 17, `data_ov017_021d6638`. If it is there at index n, flag `0x200 + n` is set.

The table, in order: 1100, 1200, 100, 1300, **20007**, 1500, 5800, 1800, 1700, 1900, 200, 2000, 2100, 2200, 2300, **8612**, 5700, 400. Each is a village's or town's exterior (see [Map list](Map-List)), except two:

- 20007 is Newid Isle, the field the Abbey stands on.
- 8612 is the Magmaroo's summit.

## `data/map/loola.gp2` › `loola_<LG>.bin` — the list

A `Script` command file ([Event scripts](Event-Scripts) has the format), run by `func_020a818c` with opcodes at `data_020f1b6c`:

- `0x64` and `0x65` do nothing.
- `0x66 n` makes room for n places.
- **`0x67` is a place** (`func_020a7f88`), 13 values:

| value | kept at | what |
|---|---|---|
| 0 | `+0x00` | its number: flag `0x200 + n` offers it, and the list is in its order |
| 1 | `+0x02` | 1 to 6; nothing found reads it |
| 2 | `+0x04` | its name |
| 3 | `+0x18` | the town's **revival map** (a church, mostly) |
| 4 | `+0x08` | the map Zoom lands on |
| 5 | `+0x0A` | the facing there, × 4096 (0 on all) |
| 6–8 | `+0x0C` | x, y, z, × 4096 |
| 9 | `+0x1A` | the map the ship is moved to, if the party has one (flag `0x2b`) |
| 10 | `+0x1C` | passed with it to `func_ov017_021d1a18` |
| 11, 12 | `+0x20`, `+0x24` | the ship's x and z |

**EU only:** 18 places, numbered 0 to 17:

Angel Falls, Zere, Stornway, Coffinwell, Alltrades Abbey, Porth Llaffan, Slurry Quay, Dourbridge, Zere Rocks, Bloomingdale, Gleeba, Batsureg, Swinedimples Academy, Wormwood Creek, Upover, The Magmaroo - Summit, Gortress, Gittingham Palace.

**Ordering** (`func_020a8304`, `func_020a8458`): the game repeatedly takes the unplaced place with the lowest number whose flag is set. So the list is the places reached, in number order.

**Lookup by revival map** (`func_020a83fc`): only the wipe-out uses it, to place the ship. Two maps are special-cased: 5801 (Slurry Quay's inn) and 4506 (the Observatory) both look up 1800, Dourbridge.

## Zoom and the wing in the field menu (overlay 2)

**Starting:**

- **Zoom** (spell dispatcher `func_ov002_02157d40`, action `0xCA`):
  - the line is `str_tm` 9005, "X casts Zoom.";
  - too little MP gives 9007 instead.
- **The chimaera wing** (item dispatcher `func_ov002_02157634`, item `0x5603`).

**Building the list:** both build it as above.

- **Empty list, Zoom:** 9005 then 9016 "But the spell fails.", and sound 100.
- **Empty list, the wing:** 31001 "But nothing happens.", and the wing is kept.
- **Otherwise** the window opens (`func_ov002_0215f224`):
  - title `str_tm` **1400 "To where?"**;
  - **six names a page**;
  - **"n/m"** below when there is more than one page (`%d/%d`, centred on x 120, y 99).

**A place chosen** (`func_ov002_02165b44`): if the caster is fallen, back to the menu. Otherwise the outcome depends on the current map's Zoom kind:

- the [Map list](Map-List)'s **value 17**, kept as its map record's `+0x0E` bits 0–1;
- or **0** while game-wide flag **`0x113a`** is set.

| kind | what happens |
|---|---|
| **2** | Zoom: MP is spent (the action's `+0x08`). The wing: it is spent and the line is 31090 "X flings a chimaera wing!". The map request takes value 4 (map), values 6–8 (position) and value 5 (facing). With the ship, the ship goes to values 9–12. Then the flight (`func_ov017_021acd30(_, 0, 0, 0)`). |
| **1** | The same line, **nothing spent**, and the flight with its third argument 1. In its state 10 it says `strstd` 57, "… bangs … head on the ceiling!". |
| **0** | The wing: 31030 "X tries using the chimaera wing.", then 31001. Zoom: 9005, then 9016. Nothing is spent. |

**EU only:** value 17 is 2 on 119 maps (fields, exteriors), 1 on 520 (indoors, dungeon floors, grottos) and 0 on 232 (the sky, the Observatory's exteriors, the Realm of the Almighty, event and test maps).

**Flag `0x113a`** is set by trigger action **107**: `func_02061c04` case 7 sets the flag to (argument = 0), in a game of one's own. **EU only:** 57 records carry it, around story scenes.

**How the Hero learns Zoom:**

- Trigger action **166 : n** sets bit n of the Hero's spells (case 66, `func_02083b60` on `+0x910`), where n is a place in the spell list.
- **EU only:** the Observatory's record at 5.1 carries `166 : 60`, and place 60 is Zoom.

## Evac

The spell dispatcher (action `0xCD`) asks `func_ov017_021ab860`, which answers 1, 0 or 3:

1. With flag `0x113a` set it answers **1**: 9016 "But the spell fails.".
2. In a grotto, the party takes the grotto's way out.
3. Otherwise it runs **`data/map/riremito.bin`** and answers **0** (9003 "But nothing happens.") or **3**. On 3, the line becomes 9020 "X casts Evac.", the MP is spent, and the party goes.

**`riremito.bin`'s `0x66` records** (`func_ov017_021ab6b0`) hold an **area**, a **map** (0 for any), then **destinations of five values**: a map, then the facing, x, y and z as floats.

Every record is tried in the file's order:

- It is skipped unless its area is the current map's area. The area is the [Map list](Map-List)'s **value 1**, kept at the map record's `+0x02`.
- It is skipped when its area was already taken by a record that named a map.
- It is skipped when it names a map and that is not the current one.
- A record with no destinations that names the current map clears the answer.
- Otherwise it takes **the destination on the last field the Hero stood in**, or, with none, its last destination.

The last field is the protagonist's `+0x566`, written whenever a map of kind 0 is entered (`Zone3D::SwitchZone`).

**EU only:** 21 records. For example:

- the Hexagon (area 7100) leads to F01 at (50.93, 0.20, 28);
- Zere Rocks' top, D07 (7700), goes nowhere: Evac there does nothing.

## A wipe-out

`func_02010604` runs when `GameState+0x5729` says the party fell:

1. Each fallen member gets up with **full HP and MP**. The living are left alone.
2. The purse is halved (`lsr #1`). The bank is spared.
3. `func_ov017_0219bfb4(2, map)` sends the party on:
   - to the battle's own map, for a set battle whose request's `+0x3e` holds one — see **Trigger action 180** below;
   - otherwise to **the revival map**, `GameState+0x5698`.
4. At story 16.2 step 1, flag `0x113a` is cleared.

**The revival map:**

| set by | to |
|---|---|
| a new game | **1106**, Angel Falls' church |
| a save in a church (save bit 0) | **the map saved in** — unless flag `0x113c` is set |
| a save with bit 3 | 109, Stornway's church |
| trigger action **208 : m** | m |
| trigger action **179** | its second value, with flag `0x113c` (**EU only:** on no record) |
| the battle that opens the postgame | 109 |

**Arriving** (`func_ov017_0219bfb4`, mode 2): the map request carries only the map, with no position, so the party stands at **the map's start point** (below). Then **`data/scenario/chur_messet.bin`** picks what the priest says.

The file's `0x67` records each hold a map, then three spans of four strings:

- the lowest and highest story major (both "0" means always);
- the voice by day;
- the voice by night.

The first span that holds the current major gives the voice (`atoi`; an empty string gives 1).

- **Voice 3** says nothing.
- **Any other voice** runs overlay 3's church in **mode 2** with words `str_ch<voice − 1>`. Its state 10 says line **1080 + mode = 1082**, and state 11 ends the visit.

**EU only:**

| maps | voice |
|---|---|
| 1106 (Angel Falls) | silent at major 1; voice 1 from 2 to 17 |
| 216 (Gleeba) | 1 by day and 2 by night, up to 16 |
| Dourbridge | 5 |
| Batsureg | 6 |
| Wormwood | 2 |
| the Observatory | 4 |
| Gittingham, Gortress | 7 |
| the rest | 1 |

Voice 5 (`str_ch4`) is the Dourbridge priest's: "Well that ain't very 'eroic, is it, gettin' wiped out like that?"

### The map's start point

A map request with no position (`+0x07` 0) puts the party at the map's **start point** (`func_ov017_0219c598`, `0x0219c648`–`0x0219c668`): the map's `+0x6c` block, filled when its **`.bmbl`** is run (`func_0201e1d0`, opcode table `data_020ef388`). **Opcode `0x6E`** (`func_0201d494`) holds four floats: x, y, z, and a facing in radians.

Every `.bmbl` on the cartridge carries exactly one (667 of 667), typed four floats. The battle stages' are all 0. Angel Falls' church, `M01M0600.bmbl`, is (0, 0.15, −2.64), facing π.

### Trigger action 180 — a set battle's own revival map

`func_02061c04` case 80 (`0x0206339c`): **`180 : b, m`** runs during a battle that is a set battle (the request's `+0x0c` ≥ 0). It writes **m** into the request's `+0x22` (the battle task's `+0x3e`) when the battle being fought is **b**, and 0 when it is another.

- **m** is the action's one parameter's high half (`func_0205ec70` case 72).
- A lost battle runs its lost-record (`func_0206f81c`) *before* the wipe-out (`func_ov017_021b790c`), so the record decides where the party wakes.

**EU only:** two records carry it.

| map | record | wakes in |
|---|---|---|
| 8612, the Magmaroo's summit | `12:14 104:1 180:14 →2309` | 2309, Upover's church (`M13M09`) |
| 5704, Gortress, floor 1 | `12:16 104:3 197:119 180:16 →5700` | 5700, Gortress's exterior |

## The flight (`func_ov017_021acdf4`)

The task `func_ov017_021acd30(gs, a, b, c)` starts. Zoom and the wing call it with `(0, 0, 0)` to fly off and `(0, 0, 1)` for the ceiling. Its **count** `+0x1d` adds the vblanks since the last pass (`GameState::GetTickCount`), which is two a pass in the field.

| state | what |
|---|---|
| 0, 14 | `data/effect/em1810.chr` loaded and made into effect 8 |
| 1 | **effect 8** at each one flown (the party's members in the field, plus object `0xCE` in a game of one's own); **sound archive `0xb2`, entry 0** |
| 2 | past **40**: each one hidden (`Object3D::EnableFlag(1)`); then 10 for the ceiling, else 3 |
| 3 | past **100**: both screens to black over 30 (`SetBrightness(_, −16, 30)`) |
| 4 | past **140**: shown again, the map changed (`func_ov017_021a65c4`); game-wide flag **`0x113d`** set |
| 5 | once the fade is done: the effect and sound let go; the task ends |
| 10 | **the ceiling**, past **55**: shown again, **9.8 above** where they stood (`+0x124` = height + `0x9ccc`); **`strstd` 57** in the message window; **the camera shaken** (`0xcc` for 1000 ms) with its point held; **archive `0xb2`, entry 1** |
| 11 | once all have landed (`+0x124` = 0), the count from 0 |
| 12 | past **10** |
| 13 | the camera given back, the effect let go, the window closed; the task ends |

**The drop** (`func_0203348c`): while `+0x124` is not 0, `+0x12c` += 1 and `+0x124` −= `0x51 × +0x12c` each pass, until it falls below `+0x128`; the object is drawn at `+0x124` while it is set. From 9.8 that takes 31 passes.

**The shake** (`func_0202e0a4`): each pass takes 33 ms off its time (`+0x1e8`) and shrinks the size `+0x1e4` by `33 × size ÷ time left`. While the size is above 0, one of four ways (`rand() & 3`) adds ± size times two fixed directions to the eye and the look-at. The directions (`data_0210a05c`) are set at run time and were not read.

`func_ov017_0219577c` starts another variant (`+0x280`): `ev999991710.chr`, sound archive `0xa3` entry 5, a count of 25. It was not followed.

## Not established

- The shake's two directions (`data_0210a05c`).
- Bit 0 of `GameState+0x63dc` (`func_02011b50`), which sends Zoom off at once. It is set by `func_02011b24`, and its callers send the party to map 10000 and use the wireless code: **INFERRED** a guest in another player's world.
- A `loola` entry's value 1 and value 10.
