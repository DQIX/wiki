# Battle Action Scripts

A `.bact` file is the script a battle action plays: the motions, the steps in, the camera, the effects, the moment a blow lands. It is a [tagged data table](Tagged-Data-Table) whose tags are opcodes. This page also covers what a blow shows: its swing trail, its hit-stop, and the numbers that rise from the one struck (`btarc.nsarc`). All of it was read from the game's code (overlays 0 and 25, and the ARM9) and the files on 29 September 2026.

> **EU only.** Code addresses are the USA release's, from the decomp; the files were read on the European release (`YDQP`) and are not yet checked on the US one (`YDQE`).

## Where the scripts are

| file | what |
|---|---|
| `/data/bin/actdef.nsarc/default.bact` | the actions without a script of their own: Defend, Flee, Psyche Up, an item, calling for help |
| `enemy.gp2/<code>.mon/<code>.bact` | a monster's attack, in its own archive (see [Monsters](Monsters)) |
| `chara_mp.gp2/mp02xx*.chr/mp02xx.bact` | a party member's, in its motion set's archive (below) |
| `chara_sub/<code>.chr/<code>.bact` | a story companion's, where there is one |
| `actspl.nsarc`, `actskl.nsarc`, `sp%03d.bact` | among them, the scripts of spells, skills and the other actions with their own. Which holds which, and what is in them, is not described here |

There are 930 scripts in all, 602 of them monsters'.

## Opcodes

Overlay 0's table at `0x02183b5c` builds a command of the same kind for each tag. Overlay 25 plays kind *k* by the word at `0x021ef538 + 4k`. The dispatcher is at `0x021e9830`.

| tag | what | handler (overlay 25) |
|---|---|---|
| `1`, `2` | open and close a section keyed by action numbers | |
| `3` | play a motion | |
| `5` | the lunge within a motion (below) | `0x021e2ca4` |
| `8` | wait, in milliseconds | |
| `9` | skip to the matching `10` when its condition holds (below) | `0x021e3178` |
| `10` | where a skip ends | `0x021e3c3c` |
| `11` | the end of the script | |
| `12` | **the camera** (see [Battle stages](Battle-Stages)) | `0x021e3c80` |
| `18` | preload a file | `0x021e40e4` |
| `20 id "path"` | name an effect by path | `0x021e4168` |
| `21` | play an effect | `0x021e41a0` |
| `22` | a scene flag | |
| `26` | wait for a motion to be so far through | `0x021e4868` |
| `29` | load an effect by number | `0x021e4a08` |
| `30` | give an effect an id | `0x021e4a58` |
| `61` to `67`, `93`, `55`, `80` | the reaction record (below) | |
| `66 id` | the reaction's effect on the one struck | `0x021e62a8` |
| `68 1` | raise that effect by half the struck one's height | `0x021e6304` |
| `70` | a sound | `0x021e6340` |
| `77` | step in (below) | `0x021e6a08` |
| `79` | **the formation** (below) | `0x021e6cf4` |
| `116` | the hit-stop (below) | overlay 0 `0x02163440` |

### Skips

**`9` and `10` are a skip, not a block.** `9 id type …` skips to `10 id` when its condition holds:

| type | condition |
|---|---|
| 0 | always |
| 1 to 4 | the gap between the two sides, edge to edge, against its float |
| 7, 10, 11 | by the targets' results |

The dispatcher runs nothing else while skipping. A script is one sequence; `11` ends it.

### The formation

`79` moves the fighters (see [Battle stages](Battle-Stages), "Who stands where"):

| mode | what |
|---|---|
| 0 | everyone to their row |
| 1 | to the grid |
| 2 | two fighters squared up |
| 3 | to their slot |

**Across all 930 scripts, `79` is used 462 times with mode 0, 234 with 2, about 60 with 3, and never with 1.** Only code puts fighters on the grid, and a battle stays on it unless a special action moves it. In `default.bact` **only calling for help changes formation**, to the rows. Neither the slime's script nor the Hero's changes formation.

### The camera

`default.bact`'s sections nearly all open on the camera's mode 5 with (0, 0.21, 1.1): the actor close-up, with `a` 0.21 and `b` 1.1. The modes are listed on [Battle stages](Battle-Stages).

## A blow

The Hero's, `mp0200.bact`, in order:

1. `9 3 2 2.0 / 77 0.75 / 10 3`: **step in** while 2 or more apart. `77` (`0x021e6a08`) moves a quarter of the way a frame to 0.75 plus the two radii's mean short, at most 0.2, with the target turned to face.
2. `attack1b` is played to half, only if still 2 or more apart.
3. Else `3 7 attack1a`, then **the lunge** `5 60 330 0.25`: from 6% to 33% of the motion, on to 0.25 apart edge to edge (`0x021e2ca4`).
4. `26 7 60` and `26 7 0.61`: wait for the motion to be so far through.
5. `70 40` and `70 85`: a number handed to `func_0205ebfc`, INFERRED a sound.
6. **The blow lands** at 61%, with the reaction record `61 … 93 17 … 62 67`.

The reaction record (tags 61 to 67, 93, 55 and 80) is a record the presentation manager plays: INFERRED the damage shown and the flinch.

**Nothing steps back.** The next action's start puts everyone back on the grid.

### Each fighter's own blow

Each fighter's own script says its blow. The lunge, its gap and when it lands differ:

| script | lunge | to | lands |
|---|---|---|---|
| the Hero, `mp0200.bact` | 6% to 33% | 0.25 apart | 61% |
| the slime, `z000a.bact` | 12% to 40.7% | 0.3 | 58% |
| Ivor, `s017b.bact` | 0 to 55% | 0.75 | 60% |

**A monster's ordinary blow is `attack1a`**, as a party member's is (537 of the scripts). `attack0a` is the one it swings when it could not close in.

### The motion set

A party member moves by the packs `mp<body><weapon>`, the weapon's number being the motion set its weapon gives (see [Weapon positions](Weapon-Positions)). Each set holds its own `b` (battle), `be` (the blow), `bi`, `bm`, `f`, `n`, `ne` and `s` packs; `func_02072c9c` names them. In the bare-handed set, `mp0200`, `bi` holds the item motions, `bm` the casting, `ne` the walk, and `n` and `f` a `stand` each. How fast each motion plays is on [Motion tables](Motion-Tables).

## A blow's swing trail

**A plain hit puts nothing on the one struck.** The reaction record names an effect (tag `66`, `0x021e62a8`) only for some monsters' blows.

**Each weapon's set plays its own trail on the one striking**, as the blow's motion begins: `29` loads an effect by number, `30` gives it an id and `21` plays it. The swords' is `eb0500`, the spears' `eb0600`. `21` hands the effect the actor's object (INFERRED: tied to them).

**An effect's number is its file.** The millions pick `em`, `et`, `eb`, `b` or `z`, and the rest is the number (overlay 25 `0x021e278c`, the table at `0x021ef520`). `eb0500.chr` holds a model, its joint, material and texture animations (see [NSBTA and NSBMA](NSBTA-and-NSBMA)) and a `.bcfg`: one motion, `"0"`, frames 1 to 15 at 0.25.

`20 id "path"` names an effect by path as `30` does by number. `18` only preloads a file.

A reaction's effect on the one struck is `66 id`, raised by half their height when `68 1` (`0x021e6304`, `0x021de380`–`0x021de3e0`). Three monster scripts' plain blows have one, `z069000.chr`.

564 of the 602 monster scripts play their own trail with `21`. Of the story companions only Ivor (`chara_sub/s017b.chr/s017b.bact`, with his own `effect/s017000.chr`) and Aquila (`s019f.bact`, the swords' `eb0500`) have a script.

## The hit-stop

Tag `116` (overlay 0 `func_ov000_02163440`). `116 0.1 200 100`, just before the reaction, is 100 ms on, then the game's speed at 0.1 for 200 ms (overlay 0 `0x021609bc`–`0x02160a60`, `GameState::SetGameSpeed`).

Tag `70` is a sound (`0x021e6340`): 40 on the swing and 80 on the hit, for the swords.

The one struck does not flash: nothing in overlay 25 changes its colour.

## The battle's numbers — `btarc.nsarc`

`/data/bin/btarc.nsarc` holds the numbers that rise from a fighter. Read from the ARM9, `0x02039f04` on. There are **five kinds**, each ten 8×16 digits and a 32×32 frame behind them, all [sprites](Sprites) (the table at `0x020e7844`, loaded by `func_02039f04`):

| kind | digits | frame | colours |
|---|---|---|---|
| 0 damage | `damage_num.spr` | `damage_waku.spr` | orange on a yellow burst |
| 1 MP damage, INFERRED | `damage_m_num.spr` | `damage_m_waku.spr` | blue on an orange burst |
| 2 recovery | `recovery_num.spr` | `recovery_waku.spr` | green on a green cloud |
| 3 MP recovery, INFERRED | `recovery_m_num.spr` | `recovery_m_waku.spr` | blue on a pale cloud |
| 4 tension | `tension_num.spr` | `tension_waku.spr` | pink on a violet star |

The MP kinds are INFERRED from the blue of `_m`.

- **Raised** (`func_0203a48c`, into a ring of 16) by the hit's presentation (overlay 25, `0x021da790` for damage, `0x021da880` for recovery), at the fighter's place raised by its height: the reaction record, at 61% of a blow. A later hit on the same fighter takes the offsets (0, −16, 16, 0, −16, 16) and (0, 8, 16, 24, 32, 40) px (`0x021eeea4`, `0x021eeebc`). A 0 shows none. There is no "miss" sheet.
- **Each frame** (`func_02039fec`): the frame's spring, from scale 1.2 and speed 0.2: scale += speed; speed += (1 − scale)/2; speed × 0.8, truncated. The timer starts at 37 and the number is freed at 0. At 34 it is nudged clear of the others.
- **The nudge** (`func_0203a5e8`), in screen pixels against every number already showing, tension never against tension. It tries, in order, (0, 0), (24, −4), (0, 0), (24, −24), (0, 20), (24, 16), (0, −20), (24, −44) … until none is nearer than 8 across and 14 up or down, with heights kept to 36–196. After sixteen it puts it 80 down, untried.
- **Drawn** (`func_0203a0b4`) at the point projected to the screen, moved by its offset and 20 up, kept 16 px in from the edges. It is hidden while the timer is 35 or more. Its alpha is 31, then 7 × (timer − 5) over its last four frames. The digits are 8 px apart and centred, each popping in 3 frames after the one to its left, swelling by (0.5, 1, 1, 1, 0.5) (`0x020e7830`). The frame behind is centred, at its spring's scale.

## Functions read

USA addresses, from the decomp. None is named upstream.

| address | what it does |
|---|---|
| `ov000 0x02183b5c`, `ov025 0x021ef538` | the opcodes: builders, and handlers by kind |
| `ov025 0x021e9830` | the dispatcher |
| `ov025 0x021e3c80` | the camera command, kind 12, modes 0 to 15 |
| `ov025 0x021e6cf4` | the formation command, kind 79 |
| `ov025 0x021e3178`, `0x021e3c3c` | a skip, and its end |
| `ov025 0x021e6a08` | the step in |
| `ov025 0x021e2ca4` | the lunge within a motion |
| `ov025 0x021e4868` | wait for a motion to be so far through |
| `ov025 0x021e278c` | an effect's file by its number |
| `ov025 0x021e4a08`, `0x021e4a58`, `0x021e41a0` | tags 29, 30, 21: load, name, play an effect |
| `ov025 0x021e4168`, `0x021e40e4`, `0x021e6304` | tags 20, 18, 68: name an effect by path; preload a file; the reaction's flags |
| `ov000 0x02163440` | tag 116, the hit-stop |
| `0x02039f04`, `0x0203a48c` | the battle's numbers: load their sheets; raise one |
| `0x02039fec`, `0x0203a0b4`, `0x0203a5e8` | a number's frame, its drawing, its nudge clear of others |
| `0x02072c9c` | a character's motion set's name, `mp%02d%02d` |

## Not established

- The reaction record's parts (tags 61 to 67, 93, 55 and 80). The damage shown and the flinch are INFERRED.
- Which sounds tag `70`'s numbers and the reaction record's tag `71` name.
- What the `s` pack is for.
- The contents of the spells' and skills' scripts (`actspl.nsarc`, `actskl.nsarc`, `sp%03d.bact`).
- That kinds 1 and 3 of the numbers are MP: INFERRED from the blue only.

## See also

- [Battle stages](Battle-Stages): the formations and the camera these scripts drive
- [Weapon positions](Weapon-Positions): the motion set a weapon gives
- [Motion tables](Motion-Tables): how fast a motion plays
- [Monsters](Monsters): a monster's archive, where its `.bact` is
- [NSBTA and NSBMA](NSBTA-and-NSBMA): the effects' texture and material animation
- [Sprites](Sprites)
- [Actions](Actions), [Battle resolution](Battle-Resolution)
