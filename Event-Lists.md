# Event Lists (`eventlist6.bin`, `eventlist_lv5.bin`, `evl_quest.bin`)

Every scene plays in a map of its own, and these three lists say which. Each is a [tagged data table](Tagged-Data-Table) with one record per scene: the scene's number, its script, the map it plays in, the stage of the story it belongs to, and a set of flags. The layout and the meaning of the scene, the map, the stage and one flag were read from the game's code on 28 September 2026. Most other values are `unknown`.

> **EU only.** Code addresses are the USA release's, from the decomp. The files were read on the European release (`YDQP`) and are not yet checked on the US release (`YDQE`).

## Where the files are

| file | records |
|---|---|
| `/data/event/eventlist6.bin` | 414 |
| `/data/evspt_lv5/eventlist_lv5.bin` | 165 |
| `/data/event/evl_quest.bin` | 137 |

No scene is listed twice.

**The scene's number picks the list.** A scene's task opens one list by the scene's number (overlay 17, `func_ov017_021bbc10`):

| scene number | list |
|---|---|
| below 21,000 | `eventlist6` |
| below 40,000 | `eventlist_lv5` |
| 40,000 and above | `evl_quest` |

`/data/event/evl_quest_d.bin` is shaped otherwise, and the scene's start does not open it. `evlist6_d.bin` and `evlist_lv5_d.bin` sit beside the lists too (see [A second reader](#a-second-reader)).

## Layout

The table holds a `0x65` record and a `0x64` record once each, then one `0x66` record (tag 102) per scene. What `0x65` and `0x64` hold is not established.

**The game runs a list as a script.** `func_02071488` runs it with one opcode, 102, handled by `func_02071208`, and keeps the record whose scene is the one starting. A `0x66` record has 23 values. The table gives each one, with where `func_02071208` stores it in the scene's record:

| value | kind | kept at | meaning |
|---|---|---|---|
| 0, 1 | integers | `+0`, `+1`, bytes | **the stage the scene belongs to**, major and minor (see [Starting a scene](#starting-a-scene)) |
| 2, 3 | integers | `+2`, `+3`, bytes | `unknown`. 5 and 100 on `ev5110`; 11 and 100 on most of `eventlist6`'s; the same pair as values 0 and 1 on `eventlist_lv5`'s |
| 4 | integer | `+0xe` | **the map the scene plays in** |
| 5 | integer | `+0xa` | **the scene**: what the list is searched by |
| 6 | integer | `+0xc` | `unknown`. On the records looked at, the first scene of its chain: `ev5110`'s is 24500 |
| 7 | string | `+0x12` | a name |
| 8 | string | `+0x32` | the script file, such as `ev05110.stb` |
| 9–11 | integers | `+0x3e`–`+0x42` | `unknown`. 100, 200 and 300 on every record looked at |
| 12–15 | floats | `+0x48`, `+0x54` | a place and a facing, × 4096. Where they are used was not followed |
| 16–19 | integers | `+5`, `+0x46`, `+4`, `+6` | `unknown`, except as below |
| 20 | string | `+0x56` | a font's name |
| 21 | integer | `+0x44` | **flags**. `0x80` means the map is the Hero's own: the scene plays wherever the Hero is. 13 scenes have it. The other bits are not read |
| 22 | integer | `+0x10` | `unknown`. 6401 on the Starflight Express's chain |

**Value 17 is a "played" flag's index.** Where value 17 (kept at `+0x46`) is not negative, it becomes the record's index. The scene's start then tests game-wide flag `910 +` that index, and does not play the scene when the flag is set (`func_ov017_021bbfc4`). This was not read further. A story reset clears bits 910 to 1909 of the game-wide bank, among others (`0x0206dfe8`, called at `0x02071740`).

## Starting a scene

The scene's start is `func_ov017_021bbfc4`. It copies the scene's record into its context at `+0xc` and then does three things.

**A scene plays in its own map.** If the record's map is not the Hero's, the scene does not play here. The start fills the map-change request with the map and the scene's number (`func_0200fd0c`) and ends. The map changes, and the scene plays in its own map. This is the same request that [trigger](Triggers) operation `133` and [engine function](Engine-Functions) `807` fill. A scene whose flags have `0x80` set plays wherever the Hero is.

Across the cartridge's trigger records, 620 scenes are started by a record, and 47 of them play in a map other than the one whose record starts them.

**Starting a scene raises the story to the scene's stage.** The start compares the live thread's major and minor with values 0 and 1, as 1000 × major + minor (at `0x021bc424`). When the story is behind, the start sets the list's stage. It does this only for a major of 19 or below, and not for 0.0. The step is left as it was. See [Triggers](Triggers) for the story's threads.

- The [Starflight Express](Starflight-Express)'s arrival scenes are listed at 20.1, so they never raise the story.
- `ev29300`, the credits, is listed at 19.1. It is the one scene that a record plays before its listed stage.
- No record moves the story to 16.1. A scene listed at 16.1 opens it when it starts.

**A chained script goes back through the same start.** A script that a scene chains into with `538` (see [Engine functions](Engine-Functions)) is started the same way, so a chain can walk the Hero through several maps. Talking to `106` on the Starflight Express at 4.7 plays `ev24598`, in map 6401. That chains into `ev24500` (5102), `ev25500` (4510) and `ev5110` (4507). `ev5110`'s record moves the story to 5.1, and it belongs to the Observatory, in 4507.

**A scene's own record is looked for in the map it ended in.** That record is of kind 11, which the end of a scene asks for (`func_ov017_021bc77c`, at `0x021bcab8`). See [Triggers](Triggers).

## A second reader

`0x020716a4` (ARM9, `0x16c` bytes) handles tag `0x66` for another table of opcodes, at `0x020f0ba0`. For the chosen event, it sets the stage, the step and the flags in all three banks. It is **INFERRED** to be a debug start, because `evlist6_d.bin` and `evlist_lv5_d.bin` sit beside the lists.

## Not established

- What the `0x65` and `0x64` records hold.
- Values 2, 3, 6, 9–11, 16, 18, 19 and 22.
- Where the place and facing in values 12–15 are used.
- The bits of value 21 other than `0x80`.
- The shape of `evl_quest_d.bin`, and what reads `evlist6_d.bin` and `evlist_lv5_d.bin`.
- Whether the game applies the trigger record of each script in a chain, or only the last one's.
- Which scene a new game plays first, at 1.1.

## See also

- [Event-Scripts](Event-Scripts): the scripts the lists name
- [Event-Text](Event-Text): the events' messages
- [Engine-Functions](Engine-Functions): `538` chaining, and `807`, a scene's hand-on to another map
- [Triggers](Triggers): which event runs when, and the story's threads
- [Starflight-Express](Starflight-Express)
- [Tagged-Data-Table](Tagged-Data-Table)
