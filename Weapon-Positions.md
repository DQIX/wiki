# Weapon Positions

`/data/bin/wpnpos.bin` says where a character carries its weapon: on which bone, at what offset and turned how, for each kind of weapon. It is a [tagged data table](Tagged-Data-Table) that the game runs as a script. The record's layout and the bone slots are read from the game's code; which placement is the back and which the hands, and that the kind is the item's subtype, are INFERRED. Read on 29 September 2026.

> **EU only.** Code addresses are the USA release's, from the decomp; the file was read on the European release (`YDQP`) and is not yet checked on the US one (`YDQE`).

## How it is loaded

`func_02099f6c` runs the file as a script. Its one handler, for tag `100` (`0x02099ef4`), fills a table of `0x1c`-byte entries at `0x02109a54`, one for each kind of weapon. The event script's function 556 re-mounts a weapon from it (see [Engine functions](Engine-Functions)).

## Layout

A record, tag `100`:

| value | what |
|---|---|
| 0 | the kind of weapon, 0 to 11: the entry's index |
| 1 | the first placement's bone slot |
| 2–4 | its offset, `fx16` |
| 5–7 | its turn about x, y and z, in radians |
| 8 | the second placement's bone slot |
| 9–11 | its offset |
| 12–14 | its turn |

### Bone slots

A bone slot names one of seven bones a character looks up by name when it is made (`func_02053e10`, into its `+0x1a0` on). The names are those of the character rig (see [Character parts](Character-Parts)).

| slot | bone |
|---|---|
| 0 | `head` |
| 1 | `waist` |
| 2 | `chest` |
| 3 | `arm1L` |
| 4 | `arm1R` |
| 5 | `leg1L` |
| 6 | `leg1R` |

## How a weapon is hung

`func_ov017_021917f0` attaches the weapon's object to the slot's bone, sets its position to the offset (`func_020407b4`) and its rotation to the turn (`func_0203db34`). Drawn attached, its transform is composed onto the bone's: translate, then turn about z, y and x (`Object3D::Draw` with `COMPOSE_TRANSFORM`, `SendTransformToFifo`).

## What the file holds

| kind | first | second |
|---|---|---|
| 0, 1, 3, 5, 8, 9 | `chest`, a turn of its own | `arm1R` at (−2.4, −0.4, 0) |
| 2, 7, 10 | `chest` at (2.3, 1, 2.3), turned (6.23, 2.62, 4.88) | `arm1R` at (−2.4, −0.4, 0) |
| 4 | `chest`, nothing | `chest`, nothing |
| 6 | `arm1R`, nothing | `arm1R`, nothing |
| 11 | `chest` at (0, 0, −3) | `arm1L` at (2.4, 0, 0) |

**The shield is not in the file.**

### Which is which — INFERRED

- **The first placement is the back and the second the hands.** The second names a forearm on eleven kinds, the first the chest on eleven.
- **The kind is the item's subtype**, the 0 to 11 of `itemsort` (see [Item kinds](Item-Kinds)): the weapon kinds the equipment screen's icons count. 11, the one held in the left hand, is the bow; 6, worn on the hand, the claws.

What the game reads the kind from is its character's `+0x29c`, bits 4 to 8. That is not traced to the item.

## The motion set a weapon gives

A weapon also chooses how its wielder moves. The motion set is word 4, bits 12 to 19, of the weapon's stats entry in `itemdt_w` (see [Items](Items)). It is the second number of the motion packs `mp%02d%02d` the wielder moves by, the body's being the first (`func_02072c9c`, `sprintf` at `0x02072d48`; 0 with no weapon).

It is one value a kind:

| set | weapons |
|---|---|
| 1 | swords |
| 3 | hammers |
| 4 | knives |
| 5 | wands |
| 6 | spears |
| 7 | axes |
| 8 | boomerangs |
| 9 | bows |
| 10 | whips |
| 11 | staves |
| 12 | claws |
| 13 | fans |

It is 2 on every body piece and 0 on the rest. `mp0200` is bare-handed, and the Hero with the copper sword moves by `mp0201`. What each set's packs hold is on [Battle action scripts](Battle-Action-Scripts).

## Functions read

USA addresses, from the decomp. None is named upstream.

| address | what it does |
|---|---|
| `0x02099f6c` | load `wpnpos.bin` |
| `0x02099ef4` | its tag `100`: one entry |
| `0x02053e10` | a character's seven bone slots, by name |
| `ov017 0x021917f0` | hang a character's weapon by `wpnpos` |
| `0x020407b4`, `0x0203db34` | an object's position; its rotation |
| `0x02072c9c` | a character's motion set's name, `mp%02d%02d`, from body and weapon |

## Not established

- That the first placement is the back and the second the hands (INFERRED, above).
- That the kind is `itemsort`'s subtype. The game reads it from the character's `+0x29c`, bits 4 to 8, and what sets those is not traced.
- Where a shield hangs.

## See also

- [Character parts](Character-Parts): the rig and its bones
- [Items](Items), [Item kinds](Item-Kinds)
- [Battle action scripts](Battle-Action-Scripts): the motion sets in battle
- [Motion tables](Motion-Tables)
- [Engine functions](Engine-Functions): event function 556
