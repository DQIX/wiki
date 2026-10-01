# Motion Tables

A `.bcfg` file beside a model is a [tagged data table](Tagged-Data-Table) naming stretches of that model's animation as motions. 2,844 of the cartridge's 2,854 `.bcfg` files carry one. The motion record (name, first frame, last frame, speed) is confirmed on a cabinet; the `0x65` and `0x70` records are not established. Observations are from the European release (game code `YDQP`).

## Where they are

| folder | `.bcfg` files with a motion table |
|---|---|
| `/data/effect` | 1,416 |
| `/data/event_lv5` | 554 |
| `/data/chara` | 262 |
| `/data/chara_sub` | 226 |
| `/data/pack_lv5` | 197 |
| `/data/map` | 145 |
| `/data/enemy` | 26 |
| `/data/bin` | 18 |

A motion table belongs to the model that shares its file stem.

## Layout

| tag | values | meaning |
|---|---|---|
| `0x66` | string, number, number, number | **a motion**: its name, first frame, last frame, speed |
| `0x64` | integer | the motion count, on the cabinets |
| `0x65`, `0x70` | | not established |

## Example: a cabinet

`M01M03G1.bcfg` reads:

| name | first | last | speed |
|---|---|---|---|
| `open` | 0 | 25 | 1 |
| `closed` | 0 | 0 | 1 |
| `opend` (sic) | 25 | 25 | 1 |
| `close` | 0 | 25 | 1 |

The model beside it has three nodes — the cabinet and its two doors, `a` and `b` — and a 25-frame animation that turns `a` to +135° and `b` to −135° about the vertical, from shut at frame 0 to open at frame 24. So `closed` and `opend` hold the two ends, and `open` plays between them.

**Searched, it opens and shuts again** (`func_02015554`, set going by the placement's flag `0x100`, `func_0201ba1c`; read 1 October 2026, USA): at playback speed **1.5**, `open` forward and once, with sound `0x12` (`open2` and `0x62` on a gate); held **500 ms**; then **`close` played in reverse**, with sound `0x13` (`close2` on a gate), and held at its end. `closed` and `opend` are named by no code.

**A piece with a motion table plays a motion when asked, not its animation on a loop.** A waterfall's or a sky's animation should loop; a cabinet's, played round and round, swings it open and shut for ever.

## How fast a motion plays

> **EU only.** Read from the decomp on 29 September 2026: the function names are the USA release's. The `.bcfg` files were read on the European release (`YDQP`) and are not yet checked on the US one (`YDQE`).

**A motion's speed is its own**: the fourth value of its `0x66` record. The game stores it ×4096 (`BCFGScript_Opcode_66`, `src/Resource/BCFG.cpp` in the decomp).

Each frame the game's clock gives animation a delta of 1 for every 17 ms that passed (`GameState::CalculateDeltaTime`: `4096 × ms / 17`). An object's motion advances by speed × delta × its own playback speed, which is 1 unless something sets it. It runs through its frames less one, looping or held at its end (`Object3D::AdvanceAnimations_v1`). **So time, not frames drawn, sets the pace.**

The swords' motion set, `mp0201` (see [Weapon positions](Weapon-Positions)):

| motion (pack) | frames | speed | once through |
|---|---|---|---|
| `attack1a` (`be`) | 19 | 0.25 | 72 × 17 ms, 1.22 s |
| `stand` (`f`, `n`) | 9 | 0.1 | 80 × 17 ms, 1.36 s |
| `run` (`f`, `n`) | 13 | 0.4 | 30 × 17 ms, 0.51 s |
| `damage` (`b`) | 9 | 0.2 | 40 × 17 ms, 0.68 s |

**A set's packs disagree about a name**: `stand` is 0.1 in `f` and `n`, and 0.3 in `n2`. A monster's and a story companion's own `.bcfg` name theirs.

An effect's `.bcfg` reads the same way. The swords' swing trail, `eb0500.chr`, has one motion, `"0"`, frames 1 to 15 at 0.25 (see [Battle action scripts](Battle-Action-Scripts)).

## A character's motions come in packs

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`).

**The `.bcfg` beside a character part names its motion pack.** A part in `chara_pc.gp2` names `mp0200ne`, a pack in `chara_mp.gp2` (see [Character parts](Character-Parts)). That pack holds exactly one animation, `walk`.

**A character's motions live in a family of packs, not one.** Standing is in `mp0200n` and `mp0200f`; attacking in `mp0200be`, items in `mp0200bi`, casting in `mp0200bm`. Of the cartridge's 136 packs, **56 carry a `stand`, 13 carry a `walk`, and not one carries both.** So the pack a part's `.bcfg` names is not the whole of what the character plays.

**Three animations are called `stand`, and the name does not pick between them.** `mp0200n` and `mp0200f` hold an eight-frame idle each; `mp0200n2` holds a sixteen-frame one. `mp0200n2`'s idle lifts the whole figure 1.706 model units, 7.5% of its own height, off the floor. `mp0200n` holds the figure to 0.009 units and `mp0200f` to 0.227. By that measure, the variant that moves the figure least is the one authored to be played in place.

## On the map pieces

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`).

In the map archives there are **145 `.bcfg` files, of 80 or 160 bytes** (see [Map archive](Map-Archive), where the tags are written in decimal). They sit beside `G1`-suffixed pieces, gates and doors, and beside `I00`.

| tag | values | what |
|---|---|---|
| `0x64` | 1 | how many `0x66` records follow: `1` or `4` |
| `0x66` | 4 | a motion |
| `0x65` | 0 | a separator |
| `0x70` | 1 | `0xFFFFFFFF` |

The names are **`open`, `closed`, `close`, `opend`, `open2`** on the door pieces, and `in` on `C01I00`.

## Not established

- The `0x65` and `0x70` records. On the map pieces `0x65` carries no values and `0x70` one, `0xFFFFFFFF`; what either means is not established.
- The 10 `.bcfg` files that carry no motion table.
- **EU only:** what sets an object's own playback speed to anything but 1, beyond a searched cabinet's 1.5.
- **EU only:** which pack the game takes a motion from when several of a set's packs hold the same name, such as `stand`.

## See also

- [Tagged-Data-Table](Tagged-Data-Table)
- [Map-Objects](Map-Objects)
- [Doors](Doors)
- [Map-Archive](Map-Archive)
- [Character-Parts](Character-Parts)
- [Battle-Action-Scripts](Battle-Action-Scripts)
- [Weapon-Positions](Weapon-Positions)
