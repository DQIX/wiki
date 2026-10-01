# Quests

A quest is a number from 0 to 203 with a few bits of state kept by the game. Who offers it is a data file, `questorder3.bin`; its name and texts are `questmsg_<lang>.bin`, reached through `questidtbl.bin`. The [trigger](Triggers) records take, clear and test quests by their operations. Everything here was read from the game's code on 28 September 2026, and the files' counts were taken over the whole cartridge. Of the 204 quests, 64 are the game's downloaded ones: their data is on the cartridge, and only a "delivered" bit locks them.

> **EU only.** Code addresses are the USA release's, from the [dqix-decomp](https://github.com/DQIX/dqix-decomp); the files were read on the European release (`YDQP`) and are not yet checked on the US one (`YDQE`).

## A quest's state

A quest's state is a **nibble**, one for each of 204 quests: `func_0206e120` refuses `0xcc` and on. The nibbles are kept at the trigger object's `+0x2cc`.

| bits | meaning | read and set by |
|---|---|---|
| 0–1 | the state: **0** not on offer, **1** on offer, **2** taken, **3** cleared | `func_0206e120` reads it; `func_0206e164` sets it; `func_0206e100` clears the quest (3) |
| 2 | the **first flag** | `func_0206e260` tests it; `func_0206e218` sets it together with state 1 |
| 3 | the **second flag: the quest has been delivered** | `func_0206e2a0` sets it, `func_0206e2dc` tests it. Only the online service sets it (below) |

`func_0206e31c` says whether a quest may be used: a guest in a multiplayer session cannot use quests from 174 on.

**Who sets the delivered bit.** Overlay 23, whose strings are the DQVC shop's auction, an encryption key and `quest_btl_%d.stb`, sets it for a list of quests (ov023 `0x021f5a74`). Overlay 17 copies every quest's from another console (ov017 `0x021c3bc8`).

## Who offers a quest — `questorder3.bin`

A [tagged data table](Tagged-Data-Table). Each tag-`0x66` record is one quest's **giver**. Its loader (`func_02094d88`) is run as a script's opcode over the file each time a map loads (`func_02095578`, `func_0209562c`, opcode table `0x020f1444`), with the map and the story's major and minor stage.

| value | meaning |
|---|---|
| 0 | the quest |
| 1 | the map. The loader keeps only the map's own givers; on any of the Quester's Rest's floors, maps 50101 to 50405, it keeps those for 50101 |
| 2 | the character who offers it, the giver's `+4` byte |
| 3, 4 | the major and minor stage it is offered from: kept only once 100 × major + minor has reached them |
| 5 | bit 9. **Not established**: the offer passes a record without it to a guest in a session. Set on 171 of 184 |
| 6 | a quest that must be cleared first, or −1 |
| 7, 8, 9, 10 | bits 11, 10, 12 and 13. **Bit 10 is "offered only once delivered"**: see [Downloaded quests](#downloaded-quests). Bits 11, 12 and 13 are not established |
| 11 on | conditions, as trigger words, parsed by the trigger parser itself (`func_0205ec70`) |

There are 184 givers, one for each quest offered. The first record, quest 0, has six values and names map 1; it is read as a placeholder (INFERRED) and left out.

## The offer

The offer (`func_02095924`, with `func_02095ae0` for "at 0 or 1") belongs to the talk. Talking to someone runs it over the map's givers before the character's records and lines are asked (ov017 `0x021a4d40`), and what it returns is discarded. For each giver of the character talked to, in order:

1. one wanting delivery whose quest has not been delivered is passed;
2. one whose conditions hold (`func_02064704`, with the character talked to in the context) and whose quest is at 0 or 1 puts the quest at 1, and that ends the offer;
3. one whose quest is taken or cleared is passed;
4. one whose conditions do not hold takes its quest back to 0, unless it is taken or cleared.

The character's records and lines then read the states the offer left. A [character's talk file](Character-Dialogue) has a line kind of its own for a quest's state (tag 2, ov017 `func_ov017_021b9e30`): it names a quest and tests its state, and one that holds silences the ordinary lines.

## The quest log

The object `func_02094d6c` returns:

| offset | meaning |
|---|---|
| `+0x00` | a count, eight at most |
| `+0x04` | 16-byte entries, one for each quest in the log: the quest in the low nine bits, and its **progress**, 0 to 7, in bits 11 to 13 |
| `+0x178` + 4 × quest | the date and time the quest was cleared, packed from the clock |

`func_02096134` finds a quest's entry. The `+0x178` words are the ones [`<QUEST_SE>`](Text-Markup#the-quest-family) writes.

## Operations

On a trigger record, an operation's argument is the quest (see [Triggers](Triggers) for the word layout). These are cases of the action switch `0x02061c04`.

| operation | what it does |
|---|---|
| `125 : q` | **accept**: into the log (`func_020961b0`, refused when the log holds eight) and taken (`func_020962f4`). The first quest ever taken also sets bit `0x119d` and starts a task (`0x020d9ae8`), which is not read |
| `126 : q` | handled beside them; its task is not read |
| `127 : q` | **clear**: the clock's date and time packed into the log's `+0x178` + 4q, then `func_02095cfc` — the quest cleared (state 3) and taken out of the log |
| `129 : q` | puts the quest on offer (`func_0206e164`, state 1) |
| `130 : q`, `131 : q` | set and clear the flag the value's high half names, by its number (`func_0206eb64`). The quest is for a session's other players |
| `144 : q` | sets a taken quest's progress to the value's high half |
| `176`, `190`, `191` | a taken quest's own numbers: a bit, a random value, and one of a table of 14. Not read further |

`ev50030` clears quest 3 with `127:3` (see [`questidtbl.bin`](#questidtblbin)).

## Conditions

Cases of the condition switch `0x0205faf4`.

| condition | holds when |
|---|---|
| `20 : q` | the quest is taken (state 2) and may be used (`func_0206e31c`) |
| `21 : q` | the quest has its first flag |
| `22 : q` | the quest is cleared |
| 53 to 61 | **composites**: each names a character, and a quest by the first value's halves — the quest and a mode — tested by `func_0206474c` |

The modes of `func_0206474c`: −1 and 5 hold at state 0; 0 when taken; 1 while the first flag is set; 2 when cleared; 3 when on offer; 4 never. The composites then test more:

| composite | also tests |
|---|---|
| 53 | a label and an answer (conditions `11` and `16`) |
| 54 | an item held (condition `18`) |
| 56 | condition `36` |
| 57, 58 | **the flag the third half names, set and clear**, and the players (condition `23`) |
| 59, 60 | **the flag, set and clear** |
| 61 | the players (condition `23`) |

The test for 20, 21 and 22 is at `0x0205ff84`.

## Downloaded quests

Bit 10 of a giver (value 8) is set on **64 quests**: quest 2 and most of 122 to 202, the game's downloaded ones. The offer passes such a giver until the quest's delivered bit is set, so their data is on the cartridge and only that bit locks them. The Quester's Rest's quests 174 to 193 are among them.

The Quester's Rest's trigger records at stages 19.3 to 19.7, after the credits, test quests 174 to 193 (composites 55, 57 and 61). With every quest delivered, the records at 19.3 hold. The later ones also want flags that only the quests' own content would set — 194 for "Perk Up, Patty!", which no record on the cartridge sets. So each downloaded quest is content of its own, with its scripted battles (`quest_btl_%d.stb`, named in overlay 23) among it. That content is not read.

## `questidtbl.bin`

A tagged data table of tag-`0x68` records: a quest's internal number and its number in `questmsg`. Internal 3 is `questmsg`'s 2, "Pleased as Punch", which `ev50030` clears with `127:3` and whose clear text says it teaches Pirouette.

## `questmsg_<lang>.bin`

Inside `questmsg.gp2` (see [GPC2](GPC2)). A tagged data table of tag-`0x67` records: a quest's `questmsg` number and twelve string offsets.

| string | meaning |
|---|---|
| 0 | the quest's name |
| 1 | as offered — INFERRED |
| 2–9 | one for each progress, 0 to 7 — INFERRED |
| 10 | once cleared — INFERRED |
| 11 | a hint before the quest is found — INFERRED |

The meanings after the name are INFERRED from reading the texts. "The Puff-Puff Performance"'s second by progress says the goods are got and to go for the reward.

## Elsewhere

- **Scenes** numbered from 40,000 are listed in `evl_quest.bin` (see [Event lists](Event-Lists)). `evl_quest_d.bin` is shaped otherwise and is not opened by a scene's start.
- **Party tricks**: the Quester's Rest's first two quests are trigger records of kind 19, the kind asked for when a party member has finished performing tricks, with the tricks performed — one an Air Punch, one a sequence (condition `32`, not read; INFERRED to be the same four tricks in order). They teach Pirouette and Pray. The quest "We Like to Party" carries `32:0 4866:2307`.
- **The cast**: [Area-Cast](Area-Cast) tag 14 places a character by a quest's state (`func_0206e120`). It is not read.
- **The text**: `<QUEST=n>` binds a quest to a message window by its slot (see [Text markup](Text-Markup#the-quest-family)).
- **Recipes** are among quest rewards (see [Alchemy](Alchemy)).

## Evidence

- The state's two bits and two flags, the log, the offer and the operations are read from their functions in the USA ARM9 and overlays 17 and 23 (addresses above).
- 184 givers in `questorder3.bin`; bit 9 on 171 of them; bit 10 on 64 quests. Counts over the European cartridge.
- That state 3 is cleared: `127` sets it through `func_0206e100`, and "Pleased as Punch" is cleared so by `ev50030`, whose clear text says it teaches Pirouette.
- `questmsg`'s texts, read against the quests: "The Puff-Puff Performance"'s second by progress.

## Not established

- What `questcancel.bin` holds. It is not read.
- Bits 9, 11, 12 and 13 of a giver. Bit 9 only decides whether a guest in a session is passed the record.
- Operation 126's task, and the task the first quest ever taken starts (`0x020d9ae8`).
- Operations 176, 190 and 191 beyond what is above.
- The Quest List screen's own code (`0x0208bfa0`), and which `questmsg` text it shows when.
- What `questmsg`'s strings after the name are for, beyond what reading them suggests.
- Each downloaded quest's own content, and its scripted battles `quest_btl_%d.stb`.

## See also

- [Triggers](Triggers)
- [Character-Dialogue](Character-Dialogue)
- [Event-Lists](Event-Lists)
- [Text-Markup](Text-Markup)
- [Tagged-Data-Table](Tagged-Data-Table)
- [GPC2](GPC2)
- [Area-Cast](Area-Cast)
- [Starflight-Express](Starflight-Express)
