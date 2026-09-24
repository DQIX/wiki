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
| 1 | its tree, 1–26; `0` on the one odd record | eleven to a tree for all twenty-six, and **`str_sklc`'s own number for it** — see below |
| 2 | **skill points it costs** | rises within a tree; each tree has one panel at 100 and one reading 0, which is not a price — see below |
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
| tree names, the 26 | `str_sklc` **1–26** ([system strings](System-Strings)) — the same numbers the panels use: 1 "Sword Skill" to 14 "Fisticuffs Skill", then 15 "Courage" to 26 "Ruggedness" | |
| panel label, long | `/data/prm/sklname.gp2` | 287 `0x66` records of six values: panel id, name offset, 1 if it grants an ability, tree, cost, 1 if the weapon noun is appended. `0xFFFFFFFF` = no name, on six panels |
| panel label, short | `/data/bin/menu/sta_skl.gp2` | `0x67` records of (panel id, string offset), all 287 |
| ability name | `/data/prm/skl_art.gp2` → `.nat` | head word, then 16-byte records (name offset, `0x0D`, flags, action id); 154 of them |
| ability description | `/data/prm/actexp.gp2` → `.nat` | the [system strings](System-Strings) shape; 234 records, action ids 0–804 |
| the sentence on unlock | `/data/prm/str_gskl.gp2` | 1–22 the messages, 101–114 the weapon nouns, 202–216 the stat nouns |

Substituting into a `str_gskl` message — **INFERRED**, and every one of the
287 panels is consistent with it: the weapon noun is `100 + tree`, the stat
noun `200 + value 4`, and `<val_1>` is value 5.

## Spending, and how a panel is had

Read 24 September 2026. The skill menu is **overlay 13** — the only module
carrying the string `data/prm/sklname.gp2`.

**A point at a time, into the tree.** There is no "buy this panel". The menu
keeps five deltas beside the five trees, `+1` at `ov013 0x02186398` and `−1` at
`0x021862e4`, and on leaving writes `tree += delta` and `pool -= Σ delta`
(`ov013 0x02184c8c`, which is the only thing besides the record sync and the
network apply that writes `live+0x464+tree`):

```
02184cc8  ldrb r1, [r1, #0x6a9]   ; the tree for this slot
02184ccc  ldr  r3, [r2, #0x674]   ; points already in it
02184cd0  ldr  r2, [r2, #0x688]   ; points added in this session
02184cd8  add  r2, r3, r2
02184cdc  strb r2, [r1, #0x464]   ; live +0x464 + tree
```

Three guards, `ov013 0x02186324`: the pool must be above zero, the tree must
not already be at 100, and base + delta must stay below 100.

**No refunds.** The delta clamps at zero (`0x02186308`), so you can only take
back what you put in during this visit; the tree byte never goes down.

**A panel is had once the tree's total reaches its cost.** The walk is
`0x0209a678`: go through the tree's eleven records in file order, counting
while the points *exceed* the cost, take one more if they *equal* it, and
stop. Each panel counted has its id set as a bit in the per-character array at
`live+0x8EC` (`0x02083acc`), which the record sync keeps at `+0x11A`.

### Where the pool comes from

- **A level.** The [level table](Level-Tables) handler at `0x02082064` packs
  each row into 0x14 bytes with the level in bits 0–6 of `row+4` and column 10
  — the cumulative skill points — in bits 7–15. The level-up record is
  `{old, new, delta}`, and `0x020826e8` writes the delta as **new minus old**:

```
020826e8  ldrh r0, [r4, #4]        ; old row
020826ec  ldrh r2, [r4, #0x18]     ; new row
020826fc  lsr  r1, r1, #0x17
02082700  rsb  r1, r1, r2, lsr #23 ; new cumulative - old cumulative
0208271c  strh r0, [r4, #0x2c]     ; into the delta row
```

  `ov023 0x021f0c40` adds it to `live+0x564`, **clamping the award to the
  headroom under 2,600** first. The level written is the *current vocation's*,
  from its own table — so taking up a second vocation earns its column again.
- **An item**, `0x02084df4`: `pool += 2`, same 2,600 cap. INFERRED to be the
  seed of skill, from the shape of the switch it sits in.
- **Character setup**, `0x020898b8`, which writes the same 9-bit field
  outright.

Those three, the record sync and the menu commit are every writer of
`live+0x564` in the image.

**2,600 = 200 × 13** — one level table's whole column, once per vocation.

## Where the spending is kept

See [Party](Party) for the character record. The **skill-point pool is one per
character**, at `+0xF4`, and the points spent are **per tree**, 27 bytes at
`+0xF6`, each 0–100.

## The eleventh panel is unreachable

**Settled 24 September 2026**, and it is not "costs nothing".

In all twenty-six trees the cost-0 record is **eleventh**: last in the file and
last by value 7, sitting after the hundred-point panel. Tree 1 reads
`3, 7, 13, 22, 35, 42, 58, 76, 88, 100, 0`; tree 13
`6, 12, 18, 25, 32, 40, 52, 66, 82, 100, 0`.

Run the ownership walk above against that. The tree byte caps at 100, so at
100 points the walk counts nine, meets the tenth with `points == cost == 100`,
takes it and **stops**. The eleventh is never reached at any total.

The menu agrees from the other side: `ov013 0x02187a60` draws **ten** entries
a tree — `0x02187b64: cmp r7, #0xa` — and styles each by `points >= cost`. The
eleventh is not in the list.

So it is a real panel, with a real id in the 0–286 space and a real reward
(Sword's Gigagash, Shield's Critical Hit Guard, Courage's Auto Counter), that
**neither of the game's two consumers can reach**. What, if anything, grants it
is **not established** — no code was found that reads it.

## Not established
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
