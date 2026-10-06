# Gathering spots

Where ingredients lie on a field, sparkling, and come back. Read 6 October 2026.

> **USA only** for the code (the ARM9 and overlay 17), read through the [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the files and their values.

## The files

All three are `Script` command files ([Tagged data table](Tagged-Data-Table)), loaded by `func_0208e520` on entering a map whose code is a field's — `F` and two digits, three letters in all (`func_0208e824`) — or `R01M07`, Stornway's Guardian Fountain.

**`/data/scenario/flditem.pac`**, a NARC: `F01flditem.bin` … `F63flditem.bin` (**EU only:** 40 fields have one) and `fldbias.bin`. A field's member is named `F%02dflditem.bin` (`data_020f1356`). The NARC also carries a `.svn` folder's copies, which the game never names.

### `F<nn>flditem.bin` — a field's spots

Tag `0x66`, one spot each, 32 values (`func_0208e0c4`):

| value | meaning |
|---|---|
| 0 | the spot's id, 0–97, game-wide (**EU only:** 87 spots, none repeated) |
| 1 | the item it gives |
| 2 | when it is there: 1 always, 2 once flag `0x798` is set, 3 once `0x796` is (**EU only:** 1 on all 87) |
| 3 | nothing reads it (**EU only:** 1 on all 87) |
| 4 | 8: values 5–7 are the spot's own; 0–7: they come from that row of `fldbias.bin` |
| 5 | minutes between refills (**EU only:** 30, 60, 90, 120, 240, 360) |
| 6 | the fewest an empty spot refills with |
| 7 | the most it holds — where value 4 is 8, the number of places listed |
| 8–31 | eight places, x y z in the files' units; the unused at 0 |

Flag `0x798` is set by [Triggers](Triggers) action 224, `0x796` by action 231 (the credits).

### `fldbias.bin` — timings by variant

Tag `0x67`, one row per value-4 number 0–7 (`func_0208e2c0`): the number, then eight (minutes, fewest, most), one for each **variant**. A game uses one variant, `GameState+0x5cda`: none (8) until its first start, which draws `rand() % 8` (`func_0208ea10`), and saved.

**EU only:** the rows are one cycle, each a step on: (60, 1, 3), (120, 1, 3), (180, 1, 3), (360, 1, 3), (60, 3, 4), (120, 4, 5), (180, 5, 6), (360, 7, 8).

### `/data/bin/izmitm.bin` — the Guardian Fountain

- Tag `0x66`: its two spots, **98 and 99**, an id and seven places as floats (`func_0208e35c`).
- Tag `0x68`: a variant's number and 16 items (`func_0208e444` keeps the game's variant's).

## What the game keeps

A word a spot, 100 of them at `GameState+0x5cdc + 4·id` (`func_0208e894`):

| bits | |
|---|---|
| 0–8 | minutes to the next refill |
| 9–12 | the most it holds |
| 13–16 | the fewest an empty one refills with |
| 17–24 | which of its places have an item lying |
| 25–28 | minutes between refills ÷ 30 |
| 29–30 | when it is there (value 2) |
| 31 | set up |

**When play begins** — the field's start, `func_ov017_0218b688`, at a new game and at a game continued from the title — `func_0208ea10` runs:

- **No variant yet:** one is drawn, and every spot of the 40 files is set up empty with its refill due. The Fountain's two are set up with most 1, fewest 1, every 60 minutes, there always.
- **Otherwise** (`func_0208ec04`): every spot with anything lying is emptied, and its refill put a tenth of its minutes off (minutes ÷ 30 × 3).

## The refill

`func_0208ec78`, every frame of the field (overlay 17 `0x0218cee8`), except while a map is changing:

1. **A minute of play** is counted: each frame's milliseconds (`GameState::GetEffectiveDeltaTime`) over 1000, to 60.0. Then the count starts again and **a sweep** begins, visiting one spot a frame, 0 to 99.
2. A spot not set up, or not there yet (value 2), is passed over.
3. **If its refill is due** (0 minutes):
   - empty, it gets `max(rand() % (most + 1), fewest)` items;
   - part-full with `n`, it gets `rand() % (most − n + 1)` when `n < most`.

   They go to free places from `rand() % most` on, wrapping round. Its minutes start again.
4. Then, **unless it is full, a minute comes off.**

So a spot's items come back its minutes after it was last refilled or picked from, and a full spot waits.

**The Fountain** fills differently (`func_0208f048`): the count is a field total ÷ 100 + 4, at most 14 — 7 to spot 98, the rest to 99. That total counts the guests canvassed (overlay 3 adds to it), so with none the Fountain holds 4.

## Seen and picked up

- **The sparkle** is `data/effect/ev999990300.chr` (overlay 17 `0x0219b834`), at the characters' scale `0x10a`, its motion looped from a random frame of its range. One is placed at each place with an item **on entering the map** (`func_0208f168`), 0.1 above the floor found from 1 above the place to 10 below (`func_02018fbc`). Nothing found adds one afterwards, so a refill while the Hero is there shows on the next entry.
- **Picking up** (overlay 17 `func_ov017_021986fc`): the Hero within 0.7 of a place in both x and z (`0xb33`), and A pressed or the place touched. The item is taken off the word, the spot's minutes start again, and flag `0xc12 + id` is set (nothing found reads it). The Fountain's spots give one of the variant's first 8 items, or all 16 from story 19 on (`func_0208e7d0`).
- **Service 35** (`func_ov017_021ae85c`): the Hero is set to state 8 and sound 91 plays; 30 frames on, the item's icon (`/data/ani/d_%c%03d.spr`) rises over the Hero; the item is obtained as a chest's is (`func_0207d538` kind 2), sound 14 plays and **system string 84** says so: "`<Cap><ACTOR> acquires <INDEF_ART_SGL_I_NAME>.`" (see [System strings](System-Strings)).

Both changes are also sent to a multiplayer session as message `0xb7` (`func_ov017_021d38f8`).

## Not found

- What the Hero's state 8 plays — the state's motion lookup (`func_02033dd4`) was not read; `hirou`, *picking up*, by its name.
- What reads flag `0xc12 + id`.
- What seeds the `rand()` these draws use.
