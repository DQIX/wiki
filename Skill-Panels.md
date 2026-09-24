# Skill panels — `/data/prm/skilltable.bin`

What a skill point buys. [Vocation skill trees](Vocation-Skill-Trees) gives
each vocation its five tree *numbers*; this is what is **in** a tree.

A loose [tagged data table](Tagged-Data-Table): one `0x64` record, one `0x65`,
and **287 `0x66` records of nine integers**. 287 is **26 trees × 11 panels**,
plus one record belonging to no tree. 12,704 bytes on the European release
(game code `YDQP`).

## How it was found, which is also why the fields are trustworthy

The ARM9 carries a **per-tag handler table for the file immediately before the
file's own path string**. In the unpacked European ARM9 the path
`data/prm/skilltable.bin` is at `0xF1628`, and at `0xF1608` is
`(0x64, …)`, `(0x65, …)`, `(0x66, 0x0209A228)`, terminated `(0, 0)` — exactly
this file's three record tags. The next such table along has four tags and
belongs to `spelltable.bin`, so the assignment is not ambiguous.

**The `0x66` handler reads exactly nine values** and packs them into a
twelve-byte record, which is where the nine fields below come from rather than
from counting bytes in the file.

## The record

| value | meaning | evidence |
|---|---|---|
| 0 | the panel's id, 0–286 | every id present exactly once; it is the join to `sklname` and `sta_skl` |
| 1 | its tree, 1–26; `0` on the one odd record | eleven to a tree for all twenty-six |
| 2 | **skill points it costs** | rises within a tree; each tree has one panel at 0 and one at 100 |
| 3 | the action it teaches, `0` for none | keys `skl_art`, `actexp`, `actname` |
| 4 | **what it gives** — the list below, INFERRED | each value goes with exactly one `str_gskl` message, and the message says what it does |
| 5 | how much: the message's `<val_1>` | |
| 6 | a second action, on ten panels — INFERRED to be the out-of-battle form | all ten are field-usable abilities, and it equals value 3 on eight of them |
| 7 | a second 0–286 index, also eleven to a tree, ordering the trees differently — **not established** | the game keeps both, so both matter to something |
| 8 | the `str_gskl` message shown when it is bought, 1–23 | |

The in-RAM record is twelve bytes and packs them: value 0 is bits 0–10 of the
halfword at `+0`, value 4 bits 11–15; value 3 is `+2`; value 1 is bits 0–4 of
the word at `+4`, value 2 bits 5–11, value 5 bits 12–19, value 8 bits 20–24;
value 6 is `+8` and value 7 is `+0xA`.

### What value 4 means — INFERRED

Read off the message each value appears with, not from a table in the game.

`0` the message says it all · `1` an ability · `2` attack · `3` critical hit
rate · `4` may equip the tree's weapon whatever the vocation · `5` shield
block chance · `6` strength · `7` resilience · `8` agility · `9` deftness ·
`10` charm · `11` maximum HP · `12` maximum MP · `13` MP absorption · `14`
evasion · `15` magical mending · `16` magical might · `17` spell critical
rate.

Value `0` is the panels whose whole effect is their sentence — Auto MP
Recovery, Critical Hit Guard, Auto Counter, Tension Retention, Autofilch,
Fighting Falcon, MP Consumption −25%.

### An example, Sword (tree 1)

Costs 3, 7, 13, 22, 35, 42, 58, 76, 88, 100, and one at 0.

## The joint witness

`/data/prm/sklname.gp2` names the same 287 panels in a **separate file**, and
its tree and cost agree on every one of them, as does its "grants an ability"
flag against value 4 being 1. `sta_skl` holds all 287 ids too. Two files
written by different hands agreeing everywhere is better evidence than reading
either alone.

## Where the words are

| what | file | shape |
|---|---|---|
| tree names, the 26 | `str_sklc` 15–26 ([system strings](System-Strings)) | |
| panel label, long | `/data/prm/sklname.gp2` | 287 `0x66` records of six values: panel id, name offset, 1 if it grants an ability, tree, cost, 1 if the weapon noun is appended. `0xFFFFFFFF` = no name, on six panels |
| panel label, short | `/data/bin/menu/sta_skl.gp2` | `0x67` records of (panel id, string offset), all 287 |
| ability name | `/data/prm/skl_art.gp2` → `.nat` | head word, then 16-byte records (name offset, `0x0D`, flags, action id); 154 of them |
| ability description | `/data/prm/actexp.gp2` → `.nat` | the [system strings](System-Strings) shape; 234 records, action ids 0–804 |
| the sentence on unlock | `/data/prm/str_gskl.gp2` | 1–22 the messages, 101–114 the weapon nouns, 202–216 the stat nouns |

Substituting into a `str_gskl` message — **INFERRED**, and every one of the
287 panels is consistent with it: the weapon noun is `100 + tree`, the stat
noun `200 + value 4`, and `<val_1>` is value 5.

## Where the spending is kept

See [Party](Party) for the character record. The **skill-point pool is one per
character**, at `+0xF4`, and the points spent are **per tree**, 27 bytes at
`+0xF6`, each 0–100.

## Not established

- **Why each tree's eleventh panel costs nothing.** It is a real panel with a
  real reward — Sword's Gigagash, Fisticuffs' Miracle Moon — and it is **not**
  the hundred-point reward, which is a separate panel in every tree.
- What value 7 orders by. Its tree order is 1,2,3,4,**6,5**,7,8,9,10,**12,11**,
  13–21,**23,22**,**26,24,25**.
- The one record with tree 0: values `[286, 0, 0, 168, 1, 0, 0, 286, 0]`, named
  "Egg On". Outside the 26 trees.
- Panel 230 (Force, cost 0) is `<Cap><str_1>` in `sklname` — a placeholder —
  and "Fource Majeure" in `sta_skl`, which is the usable label.
- The `skl_art` record's `0x0D` and flag words.

## See also

- [Vocation skill trees](Vocation-Skill-Trees) — which five trees a vocation has
- [Party](Party) — the character record, where the points spent are kept
- [Actions](Actions) — what an action id names
- [Tagged data table](Tagged-Data-Table)
- [System strings](System-Strings)
