# Battle Action Scripts

A `.bact` file is the script a battle action plays: the motions, the steps in, the camera, the effects, the moment a blow lands. It is a [tagged data table](Tagged-Data-Table) whose tags are opcodes. This page also covers what a blow shows: its swing trail, its hit-stop, and the numbers that rise from the one struck (`btarc.nsarc`). All of it was read from the game's code (overlays 0 and 25, and the ARM9) and the files on 29 September 2026, and opcode by opcode on 1 October 2026, when the blow's step in, the hit's effect and flash, and the sounds were corrected.

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

## How a script is read

A `.bact` is a data table the game runs once through the decomp's `Script` (`func_ov000_0216d1c4`). Each record's tag picks a builder from overlay 0's table at `0x02183b5c` (139 `{tag, builder}` pairs), and the builder turns the values into a command of the same number, appended to the section being filled (`func_ov000_02169b78`). `1 k…` opens a section keyed by action numbers — **a key of 1 brings 2 and 219 with it** (`0x02169bf0`) — and `16` opens one keyed exactly {1, 2, 219}, the blow files' opening (`0x0216a438`). **`2` and `17` build nothing**: a section runs on to the next `1` or `16`, and a command with no section open is built and dropped (`0x02169b88`). **Values a record lacks are stale, not zero**: `Script` fills only as many parameters as the record has (`ExecuteSingleInstruction`, `src/Resource/Script.cpp`), so a bare `10` or `26` reads the record before it.

## Which script an action plays

In order (`func_ov025_021dbe10`, then `021dc694` once a file is in):

1. the fighter's own file, its first section keyed by the action's number — a party member's `chara_mp.gp2/<set>b.chr/<set>.bact`, a story companion's `chara_sub/s%03db.chr`, a monster's `.mon`; read when the battle loads;
2. for action 1 by the same fighter on the same target as the action before, the **second** section keyed 1, when there is one (`func_ov025_021dfa9c`; INFERRED a double attack's second swing);
3. in battles 800 and 801, the Hero's: `default.bact`'s section 221;
4. otherwise **the action's own file**: the action's record (`actdt`) `+0x18` bits 12–15 pick the archive — 2 `data/skill/actspl.nsarc`; 1 or 4 with a party actor `actskl.nsarc`; else `actetc.nsarc` — and the file is **`sp%03d.bact`, the action's own number** (`+0x04` bits 0–11). **Its first section plays whatever its keys.** Kind 34 (`+0x18` bits 5–11) plays `func_ov025_021d8a40` instead of a script (not read);
5. failing that, `data/bin/actdef.nsarc/default.bact`'s section keyed by the number — **344** for an action of kind 12 — read once a battle.

`data/bin/defaultaction.bact` is named nowhere in the code read.

## How a script is played

Once a frame (`func_ov025_021e9778`). Nothing starts before the action's message file is in (`actmsg`, `+0x839`), nor while a hold at `+0x5ce` runs (not read what sets it). Then commands play one at a time: kind k by the word at `0x021ef538 + 4k`, as `player(cmd, action, battle+0xb30, state)`. **A player returning 0 is not done** — the run stops for this frame and plays it again next; **−1 is done but ends the frame** (only `31`); anything else is done and the next plays at once. So one command at a time, as many a frame as finish at once; what a command starts — a motion, a move, an effect, a camera move — carries on by itself. While a skip is open only `10` is played, `11` included in what is passed over; `11` ends the run, as does the section running out. **Waits are in effective milliseconds** — the real time since the last frame, at most 50, times the game's speed (`GameState::CalculateDeltaTime`) — so the hit-stop slows every `8`. **The action ends** when the run is over and the message box's line is down (`func_ov025_021e9528`; see `128`); the tidy-up (`func_ov025_021e9558`) frees every effect resource from 100 up and every instance of it, so nothing a script spawns outlives its action.

### Who a command acts on

Many commands take a number the battle resolves to objects (`func_ov000_021820bc`, the table at `0x0218409c`, 58 entries). Objects: the party 0–3, the monsters `0xc0`–`0xc7`, the effects `0xd0`–`0xdf`, a party member's parts `id×12 + 0x13…`, object 200 (`0xc8`).

| who | what |
|---|---|
| 0, 1 | the actor's side, the first target's side |
| 2, 3 | the side facing the actor, facing the first target |
| 4 | everyone: the party present, then the monsters |
| **7**–14 | **the one acting**, then actors 1–7 |
| **15**–22 | **the first one acted on**, then targets 1–7 |
| 23, 24 | all who act, all acted on |
| 25 | nothing to the resolver; `3` and `26` take it as **the camera's animated object** |
| 26–33 | **effect slots 0–7**, filled by `21` |
| 34–37 | actor k's part `id×12 + 0x1c` — INFERRED **its weapon** (`91 34 28 "weapon"`, `22 34 0`) |
| 38, 39 | the party present, the monsters present |
| 40 | object 200 |
| 50, 52 | target 0's, target 1's receiver: the last of its slots, at most the third |
| 51 | the targets walked by result code (6, 7, 8 count further slots); the whole party if any is one |
| 5, 6, 25, 41–49, 57 | nothing |

## Opcodes

"Instant" is a player returning 1. Fractions written as ints are thousandths. Builders are overlay 0's, players overlay 25's.

| tag | what | builder · player | waits |
|---|---|---|---|
| 3 | `[who] "name" [flags] [fx]` play a motion at speed 1 from its start (`MaybeSetRegularAnimation`; flags 1 once and held — the default — 0 loop, 8 restart, 0x10 blend). **The integer is who, never a motion.** A fighter not idle, dying or dead is made idle; `magic` falls back to `magic1`, then `magic_in`. Unless fx bit 1 (or the action is 1, 2 or 219) the scene dims, `LightingManager::BeginFade(0.6, 300)`, once; a magic motion plays sound 100 or 102 unless fx bit 0, dims to 0.3 over 1000 ms and starts the actor's `"1"` cast effect. `3 25 "name"` plays the animated camera's motion | `0x02169d08` · `0x021e2980` | no |
| 5 | `from to gap` **the lunge**: the actor's motion timed at 16.666 ms a frame; a straight move to `gap` edge to edge from the target over `from`–`to`, after the delay to `from`, and a turn along the line in at most 250 ms, queued (`func_ov025_021eee48`, run by `021eedb0`: linear, no easing); the target turns to face it | `0x02169e80` · `0x021e2ca4` | no |
| 6 | two fractions, kept; its player does nothing | `0x02169fa4` · `0x021e2f4c` | no |
| 7 | every target's reaction with the defaults: `61` then `62` | `0x0216a018` · `0x021e3048` | no |
| 8 | `ms [hold]` wait; `hold` ≠ 0 also keeps `ms` at battle `+0x6fd0` | `0x0216a1a4` · `0x021e30e8` | yes |
| 9, 10 | `9 id type v…` skip to `10 id` when the condition holds; one skip at a time (below) | `0x0216a208`, `0x0216a300` · `0x021e3178`, `0x021e3c3c` | no |
| 11 | the end | `0x0216a350` · the run itself | — |
| 12 | `mode [variant] [f0 f1 f2]` **a shot, cut to** — see [Battle stages](Battle-Stages); modes 5 and 6 take f2 = 1.8 unless given | `0x0216a364` · `0x021e3c80` | no |
| 18, 29 | queue a file under `data/` (`.pac` read as `.chr`), or an effect by number; 8 tracked | `0x0216a4c8`, `0x0216ab74` · `0x021e40e4`, `0x021e4a08` | no |
| 19 | wait for the queued files | `0x0216a55c` · `0x021e413c` | yes |
| 20, 30 | register a loaded file, by path or number, as effect `id` (−1 the next from 100); a file not yet in registers nothing | `0x0216a570`, `0x0216abc4` · `0x021e4168`, `0x021e4a58` | no |
| 21 | `id slot "motion" [flags] [overlay]` **play an effect on the one acting** — below | `0x0216a68c` · `0x021e41a0` | no |
| 22 | `who show` show or hide (`func_ov000_021626a0`, `MakeVisible`/`MakeHidden`); who 5 and 6 first set everyone the other way, then act on the actor's side, the target's | `0x0216a8d8` · `0x021e4450` | no |
| 24 | the actor turns to face the first target | `0x0216a948` · `0x021e45c4` | no |
| 25 | `n speed` fly effect n + 100 from the actor, half its height up, at the target; done within the mean of their heights | `0x0216a95c` · `0x021e4624` | yes |
| 26 | `[who] [point]` wait for a motion to be so far through (normalized time, `Object3D +0x24`); to the end when no point — then a looping idle (`stand`, `stand_battle`, `guard`, `sleep`, `slip`, `smile`, `dance`, `tenchi`) is taken as done. **Never in the frame a `3` started a motion** (`0x021ef9a4` bit 2) | `0x0216a9dc` · `0x021e4868` | yes |
| 27 | a sound from the battle's own archive (INFERRED) | `0x0216aad4` · `0x021e49e0` | no |
| 31 | done for this frame | `0x0216ac68` · `0x021e4a88` | one frame |
| 33 | `who "pack"` add a loaded pack's motions; the one playing carries on | `0x0216ac90` · `0x021e4aac` | no |
| 34, 35, 39 | an animated camera from a model's `eye` and `lookat` bones, made the game's camera; back to the battle camera, the framing kept; the camera follows a fighter | `0x0216ad0c`, `0x0216ad7c`, `0x0216adcc` · `0x021e4be4`, `0x021e4e10`, `0x021e4f00` | no |
| 36, 37 | push and pop a memory level | `0x0216ad90`, `0x0216ada4` | no |
| 40, 41 | remove a slot's effect; attach it to someone (255 detaches) | `0x0216ae1c`, `0x0216ae70` · `0x021e4fc8`, `0x021e5014` | no |
| 42 | `who mode …` place someone or something: 0 the stage's middle; 1/2 the actor's/target's side (0, 0, ±2.5) facing in; 5/6 the other side; 3 a vector turned by the camera's yaw; 4/11 in front of the target by its half-radius (11 raised by half its height, held between 0.4 and 1.15); 7 on another; 8 by the eye; 9 a place; 10 the actor, half its height up | `0x0216aed0` · `0x021e514c` | no |
| 43 | scale: 0 the free-standing 0.065 (`0x10a`), 2 by the camera's distance, 3 a value; as read only the first object | `0x0216b088` · `0x021e56e8` | no |
| 44, 45 | the screen's brightness, −16 to 16, over ms; wait for it | `0x0216b110`, `0x0216b16c` · `0x021e58b4`, `0x021e58d4` | 45 |
| 47 | `who alpha ms` fade (`TransitionInheritedAlpha`) — Flee's `47 7 0 500` | `0x0216b204` · `0x021e59b4` | no |
| 48–50 | the camera's eye, look-at, orbit: set, scaled by the target's height (mode 2), or added | `0x0216b26c`… · `0x021e5a2c`… | no |
| 55 | the hit's own effect, battle sound and own sound — "The reaction" | `0x0216b564` · `0x021e5f54` | no |
| 58 | lets the camera be reset each frame while set (what sets the bits it watches, not read) | `0x0216b754` · `0x021e6030` | no |
| 59 | attach one effect to another's bone | `0x0216b7b8` · `0x021e509c` | no |
| 60 | those called for appear: `appear`, and the monsters turn to the camera | `0x0216b870` · `0x021e604c` | no |
| 61–72 | the reaction record — below | | 67 |
| 73–75, 94 | a second body for a thrown weapon, object 200: load it (waits), load its pack (waits), show it striking and hide the weapon in hand; free it | `0x0216bbc4`… | 73, 74 |
| 76 | end a palette effect | `0x0216bc00` · `0x021e697c` | no |
| 77 | `gap` **the step in** — below | `0x0216bc54` · `0x021e6a08` | yes |
| 78 | `1`: a close-up (a 0, b 1.8) on each one before its reaction | `0x0216bcac` · `0x021e6cd4` | no |
| 79 | `mode [who] [face]` **the formation**, everyone placed at once: 0 to the rows, 1 to the grid (no script), 2 actor and target on a line through the stage's middle, 6 plus their mean radius apart, 3 a group to its grid places squeezed to fit 4 wide | `0x0216bcf0` · `0x021e6cf4` | no |
| 85 | wait for the caster: the party's motion 70% through, a monster's at its end | `0x0216be58` · `0x021e6f44` | yes |
| 86–89 | ease the camera's orbit, roll, look-at, eye (accelerating, then braking onto it) | `0x0216be6c`… · `0x021e6ff8`… | no |
| 91, 92 | attach to another's bone; detach | `0x0216c144`, `0x0216c1ec` | no |
| 96 | dim the lights to a level over ms | `0x0216c314` · `0x021e74f4` | no |
| 106 | hide (0) or show (1) the stage | `0x0216c584` · `0x021e7fdc` | no |
| 112, 128 | how long the line on show stays; how long new lines stay (750 ms unless set) | `0x0216c734`, `0x0216cec0` | no |
| 113 | shake the camera, falling linearly to nothing | `0x0216c7a0` · `0x021e8100` | no |
| 115 | scale a slot's effect to a fighter once it is there | `0x0216c85c` · `0x021e8148` | yes |
| 116 | **the hit-stop** `speed ms after`, in real time | `0x0216c8e4` · `0x021e821c` | no |
| 123 | the field of view's half-angle; every shot but `12 10` resets it to 15 | `0x0216cd28` · `0x021e8510` | no |
| 127 | turn the eye about the look-at, a step a tick | `0x0216ce5c` · `0x021e8584` | no |
| 129 | the action's start sound now: 7 for the party, 8 for a monster | `0x0216cf04` · `0x021e85c8` | no |
| 140 | set a facing, in degrees, at once | `0x0216d110` · `0x021e87f4` | no |

Read and nothing to show, or used by a handful of scripts and not yet played: 80 (an int and a float kept, read by nothing found), 90, 98–101, 103, 105, 107, 109, 110, 111, 114, 119–122, 124–126, 130–139, 141, 142.

### Skips

**`9` and `10` are a skip, not a block.** `9 id type …` skips to `10 id` when its condition holds; one skip is open at a time, and the dispatcher plays nothing but `10` while it is.

The conditions (`func_ov025_021e3178`):

| type | skip when | uses |
|---|---|---|
| 0, none, > 23 | always — a goto | 4,765 |
| 1–4 | the gap `<`, **`>`**, `≤`, `≥` v: the mean place of all who act to that of all acted on, less each side's mean half-radius | 518, all type 2 at 2.0 |
| 5 | one actor, one target, the same object | 1 |
| 7 | any target has result code 2–5 | 671 |
| 8 | any actor has any results of its own | 2,949 |
| 10 | any target has result code 3 | 660 |
| 11 | target 0 has code 6, 7 or 8 | 1,646 |
| 15 | the script has moved the camera (`+0x6fd5`) | 0 |
| 6, 9, 12–14, 16–23 | by the action's number or the results' flag bits | ≤ 26 each |

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

**Corrected 1 October 2026: type 2 skips when the gap is *more* than its bound** (`0x021e33b8`: `cmp gap, v; ble` past the skip). So a blow from the grid does not step in: the Hero's `mp0200.bact` —

```
9 3 2 2f       more than 2 apart → on to 10 3
77 0.75f         (near: step in)
10 3
9 2 2 2f       more than 2 apart → on to 10 2
3 7 "attack1b"   (near: the close swing …
26 7 0.5f         … to half way)
9 1            (near: on to 10 1)
10 2
3 7 "attack1a" (from apart: the running blow,
5 60 330 0.25f   its lunge from 6% to 33% to 0.25 apart,
26 7 60 / 70 40 / 26 7 0.61f   landing at 61%)
10 1
```

— **from apart, `attack1a`'s lunge covers the whole way**; the step in and `attack1b` are for one already within 2. The slime's `z000a.bact` has the same shape, `attack0a` its near swing. (This page had both the wrong way round: it read the step in as for a blow from apart.)

**The step in** (`77`): a pass at a time, a quarter of the way toward `gap` plus the two radii's mean short of the target, at most 0.2 a pass, running (mode 1, `run` blended); on the pass a step is 0.2 or less the actor goes idle and the command is done — so it stops up to 0.6 short. The target is turned to face it; the actor is not.

**Nothing steps back.** The next action's start puts everyone back on the grid.

### Each fighter's own blow

Each fighter's own script says its blow. The lunge, its gap and when it lands differ:

| script | lunge | to | lands |
|---|---|---|---|
| the Hero, `mp0200.bact` | 6% to 33% | 0.25 apart | 61% |
| the slime, `z000a.bact` | 12% to 40.7% | 0.3 | 58% |
| Ivor, `s017b.bact` | 0 to 55% | 0.75 | 60% |

**A monster's ordinary blow is `attack1a`**, as a party member's is (537 of the scripts): the running blow from apart. `attack0a` is its near swing, for one already within 2. (This page once had it the other way.)

### The motion set

A party member moves by the packs `mp<body><weapon>`, the weapon's number being the motion set its weapon gives (see [Weapon positions](Weapon-Positions)). Each set holds its own `b` (battle), `be` (the blow), `bi`, `bm`, `f`, `n`, `ne` and `s` packs; `func_02072c9c` names them. In the bare-handed set, `mp0200`, `bi` holds the item motions, `bm` the casting, `ne` the walk, and `n` and `f` a `stand` each. How fast each motion plays is on [Motion tables](Motion-Tables).

## A blow's swing trail

**A plain hit puts the hit effect on the one struck** — the reaction's `55`, id 1 (`eb0000`) unless set — and flashes it (below, "What is shown on the one struck"); this page once said it put nothing. The reaction record names an effect of its own (tag `66`, `0x021e62a8`) only for some monsters' blows.

**Each weapon's set plays its own trail on the one striking**, as the blow's motion begins: `29` loads an effect by number, `30` gives it an id and `21` plays it. The swords' is `eb0500`, the spears' `eb0600`. `21` hands the effect the actor's object (INFERRED: tied to them).

**An effect's number is its file.** The millions pick `em`, `et`, `eb`, `b` or `z`, and the rest is the number (overlay 25 `0x021e278c`, the table at `0x021ef520`). `eb0500.chr` holds a model, its joint, material and texture animations (see [NSBTA and NSBMA](NSBTA-and-NSBMA)) and a `.bcfg`: one motion, `"0"`, frames 1 to 15 at 0.25.

`20 id "path"` names an effect by path as `30` does by number. `18` only preloads a file.

A reaction's effect on the one struck is `66 id`, raised by half their height when `68 1` (`0x021e6304`, `0x021de380`–`0x021de3e0`). Three monster scripts' plain blows have one, `z069000.chr`.

564 of the 602 monster scripts play their own trail with `21`. Of the story companions only Ivor (`chara_sub/s017b.chr/s017b.bact`, with his own `effect/s017000.chr`) and Aquila (`s019f.bact`, the swords' `eb0500`) have a script.

## The hit-stop

Tag `116` (overlay 0 `func_ov000_02163440`). `116 0.1 200 100`, just before the reaction, is 100 ms on, then the game's speed at 0.1 for 200 ms (overlay 0 `0x021609bc`–`0x02160a60`, `GameState::SetGameSpeed`).

Tag `70` is a sound (`0x021e6340`): a sequence from the archive `69` names (below, "Sound").

## What a blow shows

### An effect

`21` (the effect manager at ARM9 `0x021079ec`): one of 16 instances, game objects `0xd0`–`0xdf`; with all 16 in use none is spawned. Every `21` on the cartridge is `21 id slot "motion" [flags] [overlay]`: the effect registered as `id`, **attached to the one acting** at its feet, following its place, facing and scale every frame (`func_02057ab8`), playing its `.bcfg` motion of that name — **once, then gone** (flags 1, the default), or looping (0) until `40` or the action's end. Its handle goes into slot `slot − 26`, which the scripts name as 26 + slot. With `overlay` it is unattached, at half scale, drawn in a later pass with its own projection. `41 X 255` then `42 X …` detaches and places it — 319 of the 366 times a `21` is followed by a `41`. An effect archive holding a `.beff` is a particle effect (98 on the cartridge); the rest are models.

**Scaled by a monster's size.** `115` (on a slot's effect, once it is there) and `117` mode 0 (on the reaction's effect) scale it by the fighter's size, its object's `+0x18e` — [monster data](Monsters) `+0x12` — through `func_ov000_0216352c(id, a, b)`: the size as it is up to `a`, past that `a` plus the rest times `b`; for anyone not a monster, `0x10a`. `115` takes `a` 1 and `b` 0.5; `117 0 1.2 0.3` and `117 0 1 0.4` are the spells'. `default.bact`'s Psyche Up starts its aura with `21 100 26 "0"` and scales it with `115 7 26 1`.

### The reaction

`61` opens a record, the tags between fill it, `62` submits it as one entry per fighter with something to show into a queue of 12 (`func_ov025_021ecc54`), and **`67` waits** until the queue is empty, no target is dying and no effect is playing. The queue plays one entry at a time, after the script each frame (`func_ov025_021ebb90`): the effect at `64`'s time, the sound (`71`, from `69`'s archive) at `72`'s, the results from `65`'s time, **each result waiting until its line is no longer up**; an entry stays `63`'s hold before the next may start, never after the last. `93`'s bit 1 skips the actor's own results and bit 2 the targets', so a plain hit or a spell is `93 1` or `93 5`; 0x10 and 0x20 queue the targets for a two-part showing (INFERRED: a counter-attack, then its blow landing). `66` names the effect on the one struck, raised by half its height with `68 1`, scaled (`117`) and offset (`118`); `109` and `110` replace it and its sound when a result carries flag 3.

### What is shown on the one struck

`func_ov025_021d8c30`, a result at a time, decides it **the result's own flag bits**, not the script: damage (flag 1) — **the fighter drawn untextured for a moment** (one frame for a monster; a 100 timer on a party member and its parts), `damage` (flags 9), a sound from `se_btl.sdat`'s archive 101 (`55`'s, 30 unless set; 31 on a party member), **the hit effect — `55`'s, id 1 unless set — on its surface facing the one acting**, and the number (kind 0, or 1 with flag 42); recovery (37, or 34 for MP) the green numbers; tension (35 or 7) the pink, worth 5, 20, 50 or 100; `guard` (6), the dodge `sake` (5), fleeing (36: `escape`, alpha to 0 over 500 ms, sound 9), revival (3), and a death (flag 1 with 2, or 13). The names of the flags are INFERRED from what is shown for them.

### A death

Object state 4, which plays `death`; when it ends, state 6 — and a monster then fades to alpha 0 over 500 ms, with effect 2 (`eb0100`) at its shadow, scaled (1 + (size − 1)/2) × `0x10a`, and sound 50 (`func_02048690`). For a target also the lights to 0.5 over 300 ms, a hit-stop (0.1, 600, 150), effect 27 and sound 66. (The 300 ms fade at `ov025 0x021ddbc0` is a different sequence, for fighters gathered by slot codes 6–8.)

### Sound

Every number is a sequence in a sequence archive of `data/sound/se_btl.sdat`, which a battle mounts as 101 (`ov000 0x02164028`): the presenter's from the base archive 101, `70`'s and `71`'s from the archive `69` names — or a monster actor's own, set as its action starts. The Hero's are `70 40` on the swing and **`70 85` on the hit**.


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

### The combo display

When blows chain (see [Battle resolution](Battle-Resolution), "The combo"), a count is shown **in the top left of the screen**, not over anyone. Read 1 October 2026 from overlay 0: `func_ov000_021823dc` starts it, `02182498` sends it away, `021824d8` keeps its two timers each frame, `0218251c` draws it; its sheets are `bt_combo*.spr` in `btarc.nsarc`, loaded by `func_ov000_0218214c`.

- **Started** once an action, at its first damage number (`func_ov025_021d8c30`, `0x021da794`), by the chain's count held to 3, kept in the turn record's `+0x0B` bits 5–7. Level 1, 2 and 3 show "2", "3" and "4" with the word, and "damage × 1.2", "× 1.5", "× 2". A level of 0 sends it away; so does a turn with no blow that chains (bit 3), and the end of the action's showing (`0x021db8ac`). The same level still coming in is not restarted.
- **Sounds** on each start, from the battle's base archive: 26 at level 1, 23 at 2, 24 at 3. Leaving makes none.
- **Coming in** (`t` frames of 30): pieces slide from the left by −64 × ((6 − u)/6)², truncated (−64, −44, −28, −16, −7, −1, 0). At level 1 the line and the count slide; past it the count slides a quarter as far over the last, which fades (alpha 31, 25, 20, 15, 10, 5), and the bottom row starts again from −215 over eleven frames. Level 1's bottom row waits until frame 6. The word hops 1, 2, 3, 2, 1 px up; at the top of the chain it is `bt_combo2_xx` rather than `bt_combo1_xx`.
- **Going**: the coming in is let finish, then everything slides left by 2, 10, 23 and 40 px and is gone on the fifth frame.
- **Where, in English, at rest**: the line (64×8) at (2, 31), the count (24×24) at (11, 8), the word (40×16) at (28, 20), `dama` (32×16) at (3, 33), `x` at (36, 34), `12` or `15` at (48, 33), `2` at (51, 33). The other languages' places are in the table at `0x021836d5`; Spanish puts a `¡` before the word.

### The tension number

A result with flag 35 (or 7) raises a kind-4 number on the fighter: 100 with 7, else 5, 20 or 50 by the result's amount, the level 1 to 3 (`0x021d9eb4`). See [Battle resolution](Battle-Resolution), "Tension".

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
| `ov000 0x0216d1c4`, `0x02169b78`, `0x02169bf0` | a script run once to build its commands; a command appended; a key of 1 bringing 2 and 219 |
| `ov025 0x021dbe10`, `0x021dc694` | which script an action plays |
| `ov025 0x021e9778`, `0x021e9528`, `0x021e9558` | the player, once a frame; the action's end; the tidy-up |
| `ov000 0x021820bc` | who a command acts on (the table at `0x0218409c`) |
| `ov025 0x021ecc54`, `0x021ebb90` | the reaction queue: submit; play |
| `ov025 0x021d8c30` | what is shown on the one struck, by its result's flags |
| `0x02048690` | a monster's death: its fade, effect 2, sound 50 |
| `ov000 0x0216352c` | a monster's size as a scale |
| `ov000 0x021823dc`, `0x02182498`, `0x021824d8`, `0x0218251c`, `0x0218214c` | the combo display: start, leave, timers, draw, load |

## Not established

- The names of the result flags, which are read from what each leads to rather than from a symbol.
- Tag `80`, an int and a float kept and read by nothing found; and the tags listed as not yet played: 90, 98–101, 103, 105, 107, 109–111, 114, 119–122, 124–126, 130–139, 141, 142.
- The animated cameras of `34` and `3 25`; the particle format (`.beff`, `func_02055180`).
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
