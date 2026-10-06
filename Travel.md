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
   - to the battle's own map, for a set battle (its request's `+0x3e`; not read);
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

**Arriving** (`func_ov017_0219bfb4`, mode 2): the map request carries only the map, with no position. Then **`data/scenario/chur_messet.bin`** picks what the priest says.

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

## Not established

- Where the party stands in the revival map. The request carries no position, and how the map's load places a party then was not followed.
- What fills a set battle's `+0x3e`.
- The flight task's states (overlay 17 `0x021ad3c8` on).
- Bit 0 of `GameState+0x63dc` (`func_02011b50`), which sends Zoom off at once.
- A `loola` entry's value 1 and value 10.
