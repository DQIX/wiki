# Battle Stages

A battle is not fought where it starts. It is fought on a map of its own, a *stage*, chosen by the ground under the encounter. This page covers the stages, who stands where on one, and the battle camera. All of it was read from the game's code on 29 September 2026. The stage itself is a map like any other; where the fighters stand and where the camera goes are the code's, not a file's.

> **EU only.** Code addresses are the USA release's, from the decomp (ARM9 and overlays 0, 17, 23 and 25); the files were read on the European release (`YDQP`) and are not yet checked on the US one (`YDQE`).

## The stages

The stages are the `B` archives (see [Map archive](Map-Archive)): 80 `B01` stages for the fields, by region and ground ("F01 - Field", "F01 - Forest", "F03 - Poison Swamp (Flat)"), and `B02` on for the dungeons, the bosses and the rest. Each is a small patch of ground. `B01M16`, "F01 - Field", is one model of 457 triangles and no [collision](Map-Collision).

### The ground names the stage

A collision's trailing records are indexed by a triangle's top seven bits (see [Starflight Express](Starflight-Express)). A record's first halfword holds three five-bit digits, and `func_0204bd7c` reads them as **30000 + 100a + 10b + c**, a stage's map id. The sky's own decoder, `func_0204bef4`, reads the same digits from 20000.

The field's encounter code in overlay 17 (its calls at `0x021b76ac`, `0x021b7750` and `0x021b7840`) takes the record under the encounter and hands it to the battle request, at the request's `+0x02` (`func_ov017_021b848c`, `strh` at `0x021b865c`). The request is made with 30116 there (`func_020a3578`).

| collision | its records, as stages (triangles) |
|---|---|
| `F01A0000`, Angel Falls Region | 30116 "F01 - Field" (714), 30117 "F01 - Forest" (112) |
| `F03A0000`, Zere Region | 30105 Field (301), 30106 Forest (24), 30107 Barley Field (1), 30108 Poison Swamp (21) |
| `F02A0000`, Western Stornway | 30103 (698), 30112 Forest (37), 30113 Field (115) |
| `D01A0100`–`0400`, the Hexagon | 30214 "D01 - Inside" |
| `D01A05E2`, Hexagoon's piece | 30215 "D01 - Hexagoon" |

### A stage the map list does not have is 30116

Overlay 0, switching to the stage (`func_ov000_02166880`, from `0x021668e4` on), looks the id up in the [map list](Map-List) (`func_02099950`). It puts 30116 in its place when the id is not there, or is 30000, the record of nothing. So Western Stornway's 30103, which the list has no entry for, is fought on Angel Falls' field.

### A set battle names its own — INFERRED

Overlay 0 takes the request's `+0x20` over `+0x02` when `+0x20` is not 0 and the request's `+0x0c` is not negative (`0x021668c8`–`0x021668dc`). The stage is INFERRED to be [`eventbattle.bin`](Event-Battles)'s `+0x28`. That the set battle's stage is what fills `+0x20` is not read.

### A stage's kind of ground

The kind of ground is the map list's value 18:

| value | ground |
|---|---|
| 0 | field |
| 1 | forest |
| 2 | coast |
| 3 | wilderness |
| 4 | flowers |
| 5 | barley |
| 6 | pampas |
| 7 | swamp |
| 8 | the `B02` stages on |

The kinds are INFERRED from the stages' labels. The game keeps the value in its map-list entry's byte `+0x0e` and turns it into a bit (`func_02099a68`, 8 giving none). Overlay 17 asks it of the ground under a field object (`func_ov017_021a26e8`); what for is not read.

### A stage's pieces

`B01M1600` is the ground and its backdrop. Beside it are `B01M1601`, and `L1`–`L4` and `N1`–`N4`, the day's and the night's: the sky, two layers of fog and a backdrop. They are told apart by their names' last letter and digit, as a field's lighting sets are. The fog's polygons are see-through, alpha 11 and 14 of 31 (see [NSBMD](NSBMD)). The stage is lit by its own `.bats` and sky gradient (the decomp's `LightingInfo::LoadFromScript` and `DrawBackgroundGradient`).

## Who stands where on the stage

**The fight is centred on the stage's own origin.** The stage's `.bmbl` places its ground model at (0, 0, 0) (`B01M16`, `B02M14` and `B02M15` were looked at), and every place below is built about x 0, z 0. **The party is on +z facing π, the monsters on −z facing 0**, toward each other.

Every fighter's height is `0xcc`, 0.05, from the templates. Nothing is read that puts them on the ground, and the stage has no collision to put them on.

The set-up (`func_ov000_02164d74`, from `0x02164f08`) fills two formations for everyone, the row and the grid, and then puts them all on the grid.

### The grid

`func_ov000_0216f74c` places slot *s* at column *s* mod 9, row *s* div 9:

- x = 2.598 × column − 10.392, plus 1.299 on an odd row;
- z = 2.25 × row − 9.

That is a staggered 9 by 9, computed in floats (`0x462646e1`, `0xc72646e1`, `0x45a646e1`). By how many there are, the slots come from the tables at `0x02183108` (the party) and `0x02183118` (the monsters):

| how many | party slots | places (x, z) | monster slots | places (x, z) |
|---|---|---|---|---|
| 1 | 58 | (0, 4.5) | 22 | (0, −4.5) |
| 2 | 57, 59 | (±2.598, 4.5) | 21, 23 | (±2.598, −4.5) |
| 3 | 48, 58, 50 | (−1.299, 2.25), (0, 4.5), (3.897, 2.25) | 29, 22, 32 | (−3.897, −2.25), (0, −4.5), (3.897, −2.25) |
| 4 | 56, 66, 67, 60 | (−5.196, 4.5), (−1.299, 6.75), (1.299, 6.75), (5.196, 4.5) | 20, 12, 13, 24 | (−5.196, −4.5), (−1.299, −6.75), (1.299, −6.75), (5.196, −4.5) |
| 5 to 8 | — | — | 28 11 22 14 33; 20 11 12 13 14 24; 20 11 12 22 13 14 24; 19 10 11 12 13 14 15 25 | by the same sum |

The party's three is lopsided as read: 48 and 50 are not mirror images. A fighter's own slot, once it has one, is taken over the table's.

### The row

- **The party** stands at z +2.5, 1.5 apart and centred: x = (n − 1) × 0.75 − 1.5i. They are turned in by the table at `0x02183158` (π ± 0.2 at the ends).
- **The monsters** stand at z −2.5, facing 0, side by side by their widths. Each is its radius ([monster data](Monsters) `+0x0C`) × 4, × 0.7 for monsters `0xbd`–`0xbf`, `0x110` and `0x155` in company. The gap is 0.7, or less to keep the row within 4 + 0.1(n − 1), down to 0.1 (`func_ov000_02167b5c`).

### Which one is used

Everyone starts on the grid (`0x02167dd8`). `0x02167e6c`, called from overlays 4, 25 and 26, moves them to the row. It is called from an action's script, and the scripts ask for it only in calling for help and some special attacks (see [Battle action scripts](Battle-Action-Scripts)). So an ordinary battle stays on the grid. Fighters change slot during a fight (`func_02048cf0`, from overlays 23 and 25).

A fighter's two places are kept in its battle record at object `+0x13c`: `+0x04` and `+0x0c` the row's x and z, `+0x10` and `+0x18` the grid's, `+0x1c` the slot. Its drawn place is the object's `+0x44`.

### Around the fight

The party's field places are kept (`func_ov000_021643d4`) and put back after (`0x02168d08`). The other roamers in the fight, the list the encounter keeps, are each moved toward the one touched until they stand the mean of their radii plus 1 from it, and turned to face it (`0x02164600`–`0x02164710`).

## The battle camera

**The camera is the code's, not a file's.** The camera object keeps:

| offset | what |
|---|---|
| `+0x04` | the eye |
| `+0x10` | the look-at |
| `+0x58` | the field of view |
| `+0x70`, `+0x74`, `+0x78` | an orbit: yaw, height and distance. The eye is the look-at plus (0, h, √(d² − h²)) turned by the yaw |
| `+0xf0` | a frame that eye and look-at pass through when its flag is set (`0x0202e0a4`) |

It also keeps a roll. A battle resets it to a field of view of 15, a half-angle: 30° (`func_ov000_0216d370`).

### Framing a side

`func_ov000_0216d600` sets no frame. The eye is at (0, h, ±d) looking at (0, h, 0), on the stage's z axis, the sign by which side.

- d is the larger of width × cos 15° ÷ (sin 15° × 2.2) and depth × cos 15° ÷ (sin 15° × 1.5), less 2.5, and at least 6.5.
- h is half the depth, at least 1.2, the eye at most 2.
- A wide variant sets a half-angle of 22 (44°) and does the same sums by 22°, at least 3.

The extents are the formation's: the party row's width (n − 1) × 1.5 + 1 and depth 1.5; the monster row's width, and its tallest monster's height + 0.5.

### The opening

`func_ov000_0216118c`: the wide side shot, with side 1, eased in by 0.95 a frame (INFERRED: what reads the 0.95 is not read). Which side 1 is, is not read.

### Shots on the fighters

Each is in a frame on a fighter (`0x0216d234`):

- **A close-up on one object** (`func_ov000_0216d90c`), a cut: look-at (0, 1, 1), height 3, distance 8, the yaw one of eight at 22.5° + 45°k drawn at random, closing by 20/4096 a frame. It is kept to the four in front when the other fighter is shorter.
- **A two-shot** from the midpoint of two (`0x0216da34`): height 1, distance 8, the yaw 0 or π ± 17.2°.
- **A group orbit** fitted to the farthest member (`0x0216dbf0`).
- **Over the shoulder** (`0x0216de00`).
- **The actor close-up** (`func_ov000_0216df00`), below.

### The actor close-up

A cut: a frame on the fighter along its own facing, so the eye is in front of it.

- L = max(h/2, 1).
- The distance is 1.8h + 4 for a monster and `b`·h + 4 for a party member, at least (L + 0.5) × cot of the half-angle.
- The look-at is (0, L − `a`, 0), `a` only for a party member.
- The orbit's height is max(L − 1.5, 0), its yaw 0.
- It pulls in 20/4096 a tick, never nearer than 3 (`0x0216d464`).

A monster adds a value from its object's `+0x18e`, not read. `a` and `b` are the camera command's floats; `default.bact`'s sections give 0.21 and 1.1. Each one struck in turn gets a close-up with 0 and 1.8 (overlay 25 `0x021dcf14`, from a list the action player fills, `0x021dcc70`).

### An action chooses its shots

The action script's camera command (kind 12, overlay 25 `func_ov025_021e3c80`; see [Battle action scripts](Battle-Action-Scripts)) picks a shot by the mode at `+8`:

| mode | shot |
|---|---|
| 0 | the side shot on the monsters, 30° |
| 1 | a close-up on the actor (`0x0216d90c`) |
| 2 | a two-shot |
| 3, 11 | the group orbit |
| 4 | over the shoulder |
| 5, 13 | the actor close-up (`0x0216df00`) on the actor |
| 6, 14 | the same on the target |
| 7 | `0x0216e250`, on up to `+9` targets |
| 8, 9 | the side shot on the actor's side, or the target's |
| 10 | the reset: no frame, 15 |
| 12 | the target made visible, then its actor close-up |
| 15 | the opening's: side 1, wide |

### After every command and every frame

`func_ov000_0216f2b8` keeps the eye no further than 17 out and no higher than 5.

### While a command is chosen

`func_ov000_0216e3c4` is called once as overlay 23, the battle menu's overlay, opens its menu (`0x021f04b8`; the menu phase begins at overlay 23 `0x021f03a0`, with the grid, this camera and the menu). It is a cut:

- The party's places are averaged, height and all.
- The distance is 12 less how far that is from the stage's middle. When that is under 8, the middle is drawn in by it over 8 and the distance is 12.
- The look-at is that middle 0.5 up, the orbit 1 up.
- It turns `0xe`/4096 a frame for as long as the menu is up. Nothing moves it while a target is chosen.

**Its yaw is −0x999, −0.6 rad, always.** The code takes the angle to the monsters' middle (`FX_Atan2Idx`, ±0x8000), divides it by 0xffff as a whole number, which leaves 0, shifts that up 12 and adds −0x999. It seems meant to face them, and is fixed as it runs.

### The chase shot

An action begins (overlay 25 `func_021db8d8`) by putting everyone on the grid and **perhaps** cutting to the chase shot (`0x0216e678`, re-aimed each frame by `0x0216ea38`). It is never used on the first action. After that it is used on a draw of one in 5 less the actions passed without it, and always on the fifth.

- Its look-at is the one acting, carried toward the one acted on by half the distance (2 when half is past 3), at three quarters of the actor's height, following at 5% a frame.
- Its orbit is one of four at `0x021832c4`: 162° or 198° round at 5, 18° or 342° at 10, all 0.5 up.
- A target taller than 2.5 puts the eye 1.2 to 2 below, at least 8 away.

What the yaw is measured from is not read. **An action ends** with the camera left where it is (`0x021dcbf4`).

## The battle's states

The jump table at `ov000 0x021607d4` counts from 0:

| state | what |
|---|---|
| 0 | load |
| 1 | set-up |
| 4 | leave |
| 6 | the field back |
| 7, 11 | overlay 26's |
| 8 | overlay 25's action loop |
| 9, 10 | overlay 23's |
| 16 | the end |

Overlays 22 to 30 share one address, so one of 23, 25 and 26 is in at a time.

## The end of a battle — INFERRED

These were read and not yet tied to what they do:

- Overlay 25's sub-phase 5 holds the group orbit for 60 frames, INFERRED to be the victory's.
- A fallen monster fades (`TransitionInheritedAlpha` to 0 over 300 ms, overlay 25 `0x021ddbc0`), INFERRED to be the death's.
- The collapse effect, `eb0100`, plays at its shadow (ARM9 `0x02048808`), INFERRED.
- State 4 fades to black and back to the field (`SetBrightness(−16, 15)`).

## Functions read

USA addresses, from the decomp. None is named upstream.

| address | what it does |
|---|---|
| `0x0204bd7c` | a collision record's battle stage, 30000 + 100a + 10b + c |
| `0x02099950` | a map-list entry by its id, or none |
| `0x02099a68` | a map's kind of ground as a bit, 8 giving none |
| `0x020a3578` | a battle request made, stage 30116 |
| `ov017 0x021b848c` | the encounter hands the request its stage (`+0x02`) |
| `ov017 0x021a26e8` | the ground kind under a field object |
| `ov000 0x02166880` | switch to the stage: the set one's `+0x20`, 30116 for one not listed |
| `ov000 0x02164d74` | battle set-up: rows, then grids, then all to the grid |
| `ov000 0x021675a0`, `0x021676a8` | the party's row places, grid places |
| `ov000 0x021677fc`, `0x02167cd4` | the monsters' row places, grid places |
| `ov000 0x02167b5c` | the gap between monsters in a row |
| `ov000 0x021681f8` | a monster's width factor, 0.7 for five kinds in company |
| `ov000 0x02167dd8`, `0x02167e6c`, `0x02167f10` | everyone to the grid; to the row; to the current slot |
| `ov000 0x0216f74c` | a grid slot's place: 9 by 9, staggered |
| `0x02049b20`–`0x02049c60` | a fighter's row and grid place and facing, `+0x13c` on |
| `0x02049e00`, `0x02049d6c`, `0x02048cf0` | put a fighter at its grid place, its row place, its slot |
| `ov000 0x021643d4`, `0x02168d08` | keep the party's field places and gather the fight's other roamers in; restore after |
| `0x0202e5c0`–`0x0202ecfc` | the camera: eye, look-at, orbit, yaw, distance, roll, frame |
| `0x0202e9a4` | `Camera_SetFov`, half-angle in degrees |
| `0x0202e0a4` | the camera each frame, through its frame when set |
| `ov000 0x0216d234` | a camera frame on a fighter |
| `ov000 0x0216d370`, `0x0216d464` | reset (field of view 15); each frame (yaw and distance drift) |
| `ov000 0x0216d600` | frame a side |
| `ov000 0x0216d90c`, `0x0216da34`, `0x0216dbf0`, `0x0216de00`, `0x0216df00` | close-up, two-shot, group orbit, over the shoulder, actor |
| `ov000 0x0216118c` | the opening |
| `ov000 0x0216e3c4` | the camera while a command is chosen |
| `ov000 0x0216e678`, `0x0216ea38` | the chase shot; its per-frame aim |
| `ov000 0x0216f2b8` | the eye kept within 17 and under 5 |
| `ov000 0x021607d4` | the battle's states |
| `ov023 0x021f03a0` | the menu phase begins |
| `ov025 0x021db8d8` | an action begins: grid, chase shot |
| `ov025 0x021dcf14`, `0x021dcc70` | a close-up on each one struck in turn; the list of them |

## Not established

- What fills the battle request's `+0x20`. The data suggests `eventbattle.bin`'s `+0x28`; the code that writes it is not read.
- The battle request's `+5`, a lighting slot, 2 unless set.
- What the kind of ground under a field object is asked for.
- Which side is side 1 in the opening, and what reads its 0.95 ease.
- What the chase shot's yaw is measured from.
- The value a monster's close-up takes from its object's `+0x18e`.
- The tables at `ov000 0x02183280` and `0x0218328c`.
- Shot `0x0216e250`, mode 7's, beyond its taking up to `+9` targets.
- The fade up into a battle from the load's black.
- **The battle loop's frame rate.** The opening's ease, the close-ups' pull, the command camera's turn and the step in are each so much a frame. At 60 frames a second the command camera would turn about 12° a second; a recording of play would settle it.
- **The party of three.** Slots 48, 58 and 50 read as lopsided (above). A fight with three in the party would show whether the left one stands nearer the middle than the right.
- **Whether the opening shows every monster.** The opening's shot is fitted to the monsters' row, but an ordinary battle keeps everyone on the grid, where it frames only the middle of three. Either the grid is right for the opening, or something not yet read moves them. A recording at a battle's start, as "draw near" is said, would settle it.

## See also

- [Battle action scripts](Battle-Action-Scripts): the camera and formation commands
- [Weapon positions](Weapon-Positions)
- [Map list](Map-List), [Map collision](Map-Collision), [Map archive](Map-Archive)
- [Encounters](Encounters), [Event battles](Event-Battles), [Monsters](Monsters)
- [Starflight Express](Starflight-Express): the sky's collision records
- [Engine functions](Engine-Functions)
