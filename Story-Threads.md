# Story threads

The game keeps the story's progress as **five threads**, each with its own stage, step, flags and marks. The map the Hero is in decides which thread is live. [Trigger](Triggers) records are kept by the live thread's stage, and test and move it. This is how the chapters after 5.2 can be played in any order. Nothing here is a file of its own: it is the game's state, read from its code on 28 September 2026.

> **EU only, checked in part.** Code addresses are the USA release's (`YDQE`) ARM9 and overlay 17, from the decomp. The records given as evidence were read on the European release (`YDQP`); every trigger file has since been checked byte for byte the same on the US release.

## The thread record

The trigger object (`0x02108844`, returned by `func_0205ec34`) opens with five records of `0x1c` (28) bytes, one a thread, and holds the live thread's index at `+0x332`.

| offset | size | what | written by | cleared when |
|---|---|---|---|---|
| `+0x00` | `u8` | stage, major | `132`, `148`, `214`, and `GameState`'s setters | — |
| `+0x01` | `u8` | stage, minor | as above | — |
| `+0x02` | `u8` | step | as above | — |
| `+0x03` | 32 bits | **marks**: action `102` sets (`0x02061ee4`), `103` clears | `func_0206df6c` | the major changes |
| `+0x08` | 64 bits | not established | — | the major changes |
| `+0x10` | 32 bits | **flags**: action `104` sets (`0x02061f9c`), `105` clears | `func_0206df6c` | the major or minor changes |
| `+0x14` | 64 bits | not established | — | the major or minor changes |

Actions `149` and `150`, which set a map piece on and off, set a bit of `+0x08` or `+0x14` instead when the piece is not in the map (`func_0206ea8c`).

Conditions `2` and `3` test a mark of the live thread, `4` and `5` a flag (see [Triggers](Triggers)). The scene functions `601` and `602` read the same two fields of the live record: **`601 : n` is mark *n*, `602 : n` flag *n*** (see [Event-Scripts](Event-Scripts)). Gortress's `ev14640` sums `602(11)` to `602(14)`, the four flags its `155` records set, and chains into `ev14903` (`538(14903)`) when the sum is four.

## Which thread is live

`func_02064b98(object, map)` picks the live thread from the map's id:

| thread | maps | the stage `ev25524` starts it at |
|---|---|---|
| 1 | 4200–4202, 9000–9008: Alltrades Abbey, the Tower of Trades | 6.1 |
| 2 | 1700–1706, 1800–1808, 6000–6001, 7700–7709: Zere Rocks, Dourbridge, the Lonely Plains, the Heights of Loneliness | 8.1 |
| 3 | 200–219, 7802–7809: Gleeba, the Plumbed Depths | 11.1 |
| 4 | 2100–2109, 8301–8303: Swinedimples Academy and its Old School | 12.1 |
| 0 | every other map | 7.1 |

It then copies that thread's stage, minor and step into `GameState` through three setters (`func_02010774`, `func_020107a8`, `func_020107dc`; `GameState` `+0x5cb0`, `+0x5cb4`, `+0x5cb8`). Each setter also writes its value back into the live thread's record. Their getters are `func_0201079c`, `func_020107d0` and `func_02010804`. `func_0206df14` copies the live thread's stage into `GameState`.

## Moving the story

- **`132` moves the live thread.** Its three values are the stage *a.b* and step *c*.
- **`214 : n` moves thread *n*,** with three values as `132` (`0x02063e40`). `ev25524`, on the Starflight Express at 5.2, starts all five, at the stages in the table above. The table is also the check: each thread's maps are where that chapter's records are.
- **`148` moves all five.** `ev28800` at 13.1 brings the threads back together at 13.2. Winning set battle 25 at 17.2 plays `ev29300` and sets all five to 19.2.

All three queue their record (`func_0206445c`) instead of writing the stage on the spot. The queue is applied once the record's actions have run (`func_0206f81c`).

**The story only moves forward.** Each move goes through `func_020703c8(thread, major, minor, step)`. The thread's point and the new one compare as `major × 10000 + minor × 100 + step`, and a move to one at or before where it stands does nothing. A move forward clears the thread's banks: all four on a new major, the flags and `+0x14` on a new minor (`func_0206e080`, `func_0206e0d0`). Then the live thread is copied back into `GameState`. `132`'s action also clears before queuing, by the live stage, whichever way the move goes.

Flags and marks change as each action runs, and stage moves are applied after. So a flag a record sets on its way into a new sub-stage is cleared by the move.

**A story reset.** `func_0206dfe8` clears a range of bits. At `0x02071740` it clears 0–511 and 910–1909, a story reset.

`ev28800` is played by the Starflight Express: Stella's ride to the Observatory at 10.8 step 1, with game-wide flags 4 to 10 set (one at each thread's end), plays it in place of the ride's own arrival (see [Starflight Express](Starflight-Express)).

## Game-wide flags

A bank at `+0x8c` of the trigger object is outside any thread, so no stage move clears it.

- Actions `100` and `101` set and clear a bit of it. Conditions `0` and `1` test one.
- Conditions `26` and `27` name a flag by its number (`func_0206eb98`): below `0x400` the bit itself, from there displaced by 1,786. The cast's placement script (its tag 17) tests the same bank, by the raw bit (`func_0206dfb0`) or by number (see [Area-Cast](Area-Cast)), and so does the scene function `603`.
- Conditions `88` and `89` test the block from bit 830; action `220`, the Quarantomb's switches, sets two of it (see [Triggers](Triggers)).
- The party tricks learnt are bits of it, from `0xbf1` (see [Triggers](Triggers#party-tricks--kind-19)).

## A scene's start raises the story

The scene's start (`func_ov017_021bbfc4`, at `0x021bc424`) compares the live thread's major and minor, as `1000 × major + minor`, with the event-list entry's (context `+0xc`, `+0xd`; see [Event lists](Event-Lists)). It **sets the entry's when the story's is less**, the major 19 at most and not 0.0. The step is left as it was.

This is why the Starflight Express's arrival scenes are listed at 20.1: a major of 20 is left as it is. It is also what opens 16.1: no record moves the story there; the ride's scene at 16.1 does.

**INFERRED:** arriving at Gittingham Palace's field stop by the Express at 15.3 step 5 plays `ev29150`, Celestria opening the way, listed at 16.1 in map 20034. Nothing read names 29150; the field's own code must. Read this way, the step stays at 15.3's 5 on that way in, so 16.1's steps 2 to 4 cannot then be set, since moves only go forward. That wants checking in the game.

## A debug start, probably

`0x020716a4`, tag `0x66` of the event lists (table `0x020f0ba0`), sets the stage, step and flags in the three banks for the chosen event. It is probably a debug start, since `evlist6_d.bin` and `evlist_lv5_d.bin` sit beside it.

## Evidence

- Read from the USA release's ARM9 and overlay 17, disassembled from the decomp's extract, on 28 September 2026. The functions are named here by their decomp addresses; upstream has not named them.
- The thread table's map ranges are checked against `ev25524`'s `214` records: each thread's maps are where the records of the chapter it starts are.

## Not established

- What the 64-bit fields at `+0x08` and `+0x14` of a thread record hold, beyond the map pieces `149` and `150` keep there.
- What plays `ev29150` at 16.1.

## See also

- [Triggers](Triggers)
- [Area-Cast](Area-Cast)
- [Event-Scripts](Event-Scripts)
- [Event-Lists](Event-Lists)
- [Starflight-Express](Starflight-Express)
- [Quests](Quests)
