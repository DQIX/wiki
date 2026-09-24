# Attending Characters

`attnpc_<lang>.bin`, one to a language in `/data/bin/attnpc.gp2`: a [tagged data table](Tagged-Data-Table) of the five characters who go along with the Hero for a stretch of the story — Aquila, Ivor, Dr Phlegming, Sterling and Erinn. Model, name, weapon and shield are confirmed; level and the stat columns are INFERRED, and the stat order is not settled. How a character joins and leaves is carried by the events' own records, INFERRED. Observations are from the European release (game code `YDQP`).

## Layout

Five `0x64` records of 19 values, value 2 a string and the rest integers, the same in every language but for the name's offset. That these are the characters who go along with the Hero is INFERRED from who they are.

| value | meaning | evidence |
|---|---|---|
| 0 | its number, 1 to 5 | |
| 1 | its model, `/data/chara_sub/s<nnn>.chr` | Ivor's 17 is the `s017.chr` the event introducing him loads (`ev02210`), Erinn's 16 the `s016.chr` of her morning (`ev02130`); so Aquila's is `s019`, Dr Phlegming's `s012` and Sterling's `s051`, INFERRED |
| 2 | the name | |
| 3 | `unknown_3` | 1, 1, 0, 0, 0 |
| 4 | `unknown_4` | 3, 0, −1, −1, 3 |
| 5 | a level, INFERRED | Aquila 20, Ivor 3, the rest 1 |
| 6 | `unknown_6` | 1 on Erinn, 0 on the rest |
| 7–15 | numbers — INFERRED to be in the [level tables'](Level-Tables) column order: strength, resilience, agility, deftness, charm, magical might, magical mending, maximum HP, maximum MP | on Ivor and Erinn, who cast nothing, both magic values are 0 and the largest value is where maximum HP is; Aquila, who has a casting pack, has a maximum MP of 84. His agility reads 0, which fits nothing, so the order is not settled |
| 16 | `unknown_16` | 26 on Aquila, −1 on Ivor and Erinn, 0 on the others |
| 17 | a weapon's item id, 0 for none | Ivor's 20004, the copper sword; Aquila's 20006 |
| 18 | a shield's item id, 0 for none | Ivor's 21296, the pot lid |

Read so, **Ivor** is level 3 — strength 15, resilience 13, agility 16, deftness 22, charm 10, 25 HP and no MP — with a copper sword and a pot lid.

## Models and motions

**Only the fighters have battle motions.** A character's motion packs in `/data/chara_sub` are its model's name and a suffix, as the Hero's are in `chara_mp` (`mp0200b`, `be`, `bm`).

| character | packs |
|---|---|
| Ivor | `s017b`: damage, death, guard, item, `sake` (a dodge), side- and backsteps, sleep and more; `s017be`: two attacks |
| Aquila | `s019b`, `s019be`, `s019bm` — the last a casting pack, as the Hero's `mp0200bm` is |
| Erinn, Dr Phlegming, Sterling | none |

Ivor's field set is `s017.chr` — the model, on a 12-bone rig, with `walk`, `run` and `stand` — with three faces, `s017f01` to `s017f03`, which an event hangs from his head (`235(10, 1, "head")` in `ev02210`, see [Event-Scripts](Event-Scripts)), and a night version, `s017n`.

## When and how a character goes along

**Ivor goes along at story stage 2.2, and returns at 2.3.** The [triggers](Triggers) put the events that speak with him at stage 2.2 — `ev02200` in Erinn's house, `ev02220` and `ev02222` in the village, `ev02230` to `ev02250` in its houses — then `ev02300`, `ev02320` and `ev02350` in map 5101, at the landslide ("We're here at last. The landslide's…"), and his return at 2.3, `ev02400` to `ev02450`. From `ev02220` on, those events do not load his model: they call `566(10, 1)` and hand character 1 his motion pack, which reads as "character 1 is the party's", INFERRED.

**Joining and leaving are the events' own records** (see [Triggers](Triggers), records `205` and `204`; INFERRED). No script does it — none on the way writes a game-wide variable or calls anything with his number or his model's — but the record that says what follows an event does:

| record | meaning |
|---|---|
| `205:n` | brings in the character at place n of this table, counting from 0 |
| `204:1` | sends whoever goes along away |

Ivor joins as his call ends (`ev02210`, whose last message is "Ivor joins the party"), goes on ahead at the pass (`ev22591`, "I'll go on ahead!"), joins again at the landslide (`ev02350`) and goes home once the mayor has heard the news (`ev02400`). A let's play video shows the same: he walks off along the pass and is found at the landslide, and from 2.4 the Hero goes to the Hexagon alone.

## Evidence

- Model numbers: `ev02210` loads `s017.chr` for Ivor; `ev02130` loads `s016.chr` for Erinn.
- Weapon and shield: Ivor's 20004 and 21296 are the copper sword and the pot lid (see [Items](Items)).
- Stat columns: magic values 0 on the two who cast nothing; maximum MP 84 on Aquila, who has a casting pack.
- Joining and leaving: the event records `205` and `204` against the events' messages, and a let's play video.

## Not established

- Values 3, 4, 6 and 16.
- The order of the numbers in values 7–15 (Aquila's agility reads 0, which fits nothing).
- **No column is a vocation.** Worth saying rather than leaving to be discovered: the record carries a level, nine stat numbers, a weapon and a shield, and nothing that selects one of the thirteen [level tables](Level-Tables). Of the four unknown values, 4 reads 3, 0, −1, −1, 3 and 16 reads 26, −1, 0, 0, −1, neither of which is a vocation number in the usual 0–12 range for all five. So where a party member's vocation comes from is open — see [Party](Party).

## See also

- [Party](Party): how the game holds which characters are with you, and in what order

- [Character-Presets](Character-Presets)
- [Level-Tables](Level-Tables)
- [Triggers](Triggers)
- [Event-Scripts](Event-Scripts)
- [Items](Items)
- [Tagged-Data-Table](Tagged-Data-Table)
