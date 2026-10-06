# Accolades and the Battle Records

The titles a Hero earns, the four scripts that award them, and the Battle Records that list them. Read 6 October 2026.

> **USA only** for the code (the ARM9 and overlays 2, 3, 8, 17 and 23), read through the [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the files and their values.

## The files

**`/data/bin/ttldata.gp2/ttldata_<LG>.bin`** is a `Script` command file ([Tagged data table](Tagged-Data-Table)), loaded by `func_020a13c4`; `func_020a15bc` finds a record by number.

| tag | values | what |
|---|---|---|
| `0x65` | a string | a date |
| `0x64` | a string | a version |
| `0x66` | four integers | not read (**EU only:** 151, 21, 260, 12) |
| `0x67` | five integers, a string | one accolade |

An accolade's record:

| value | meaning |
|---|---|
| 0 | its number (**EU only:** 445 records, 2 to 454 with gaps) |
| 1 | where its man's name falls in alphabetical order, from 1; 0 when a man has none |
| 2 | the same for a woman's |
| 3 | not read: 0, 1, 2, 6 (the revocation titles 101–112) or 7 (the skill titles 121–380) |
| 4 | not read: 0, 1 or 2 |
| 5 | the line describing it, about `<ADDRESSEE>` |

Values 1 and 2 are observed, not read from code: the English names sorted give exactly them, 442 of 442 for each sex — the list's "By Name".

**The names** are system strings keyed by the accolade's number: `/data/bin/ttlname0.gp2/ttlname0_<LG>.nat` a man's, `ttlname1` a woman's. Every reader builds `ttlname%d` from the Hero's sex (bit 0 of `+0x49c`). An empty name belongs to the other sex only — 116 "Cool Customer", 117 "Haughty Beauty". `ttlname_<LG>.bin` is named by no code found.

The award's lines are `/data/bin/menu/str_tg.gp2`: 100 "… is awarded the auspicious accolade …!", 1000 "The Accolades Earnt screen can now be accessed from the Battle Records menu."

## Where they are kept

| `GameState+` | what |
|---|---|
| `0x7504`, 0x3C bytes | the accolades earned, bit `n` for accolade `n` (`func_020ac460` out, `func_020ac3c8` sets) |
| `0x7540`, 0xB0 bytes | the records block (`func_020ac4c0`, `func_020ac494`) |
| `0x75f0`, 308 words | the defeated monster list: a word by monster 1–308, the low 10 bits its count (`func_020ac020`) |
| `0x7ac4`, 471 halfwords | the item list: `id << 2` and two flags not read (`func_020ac104` adds) |

Of the records block: `+0x0c` bits 0–6 the highest grotto level cleared, 7–13 the highest grotto boss beaten, 14–27 grottoes cleared; `+0x10` bits 0–8 accolades earned, 23–31 non-zero once the first completion is recorded; `+0x4c` on, bits for Stella's comments shown; `+0x90`/`+0x92` the first completion's hours and minutes.

## The four scripts

`data/scenario/title_btl.stb`, `title_skl.stb`, `title_clr.stb`, `title_gyalel.stb` ([Event scripts](Event-Scripts)) run on the event interpreter with a table of 95 functions of their own (overlay 23 `data_ov023_021fddb8`, registered by `func_ov023_021eb000`). Section 100 calls one routine a candidate; each begins by asking whether it is earned already and returns 1 when it is due, and then function 0 adds the number to the list (`func_0209ffe0`, up to 50). The routines return early and go on after the return, reached by a jump over it.

| script | runs | accolades |
|---|---|---|
| `title_btl` | the victory's results, step 15 of 17 (`func_ov023_021f3aac`) | 89–100: the Hero at level 99 in vocation 1–12; 2: eleven monsters, 296–306, each defeated; 3–10: a grotto boss and a grotto of level 25, 50, 75, 99 |
| `title_skl` | after skill points are allocated: the victory's step 9, the field menu's (`func_ov002_021688f8`) | 121–380: points in a skill tree |
| `title_clr` | the Battle Records opening, after the ending | 425–454 |
| `title_gyalel` | the Battle Records opening, when Stella has no comment | 11–88, 113–120, 381–424 |

`title_btl` and `title_skl` award every one due; the other two stop at the first.

| function | does |
|---|---|
| 0, 50 | add a number to the list |
| 1 | whether accolade n is earned |
| 101 | a member's vocation and that vocation's level |
| 102 | a member's sex |
| 103 | whether a member wears each item given — outfits |
| 106 | a member's points in a skill tree |
| 110 | grottoes cleared |
| 118 | whether today is the Hero's birthday |
| 201 | the first completion's time |
| 251 | a monster's defeated count |
| 252, 253 | a grotto's level and its boss's, cleared — 0 outside a grotto |

A member is −1 for the character `GameState+0x3ac` names (INFERRED the Hero), the only one the four scripts ask about. The Abbey awards its revocation titles itself (overlay 3 `func_ov003_021575dc`). Every awarding screen calls `func_ov023_021ed724`, which sets the bits, adds to the count and returns whether the count was 0 — the first-time line.

## The Battle Records

Service 41, opened by `func_ov017_021c05f4` from the SELECT Button in the field or the field menu's row (`strstd` 21), both only with game-wide flag `0x119a` — what sets it was not found. Overlay 8 opens it: with flag `0x113b` set (trigger action 162, while Stella is away) nothing is said; otherwise Stella's comment (`data/scenario/cmtFileTbl.bin` entry 1000, `cmtHeader.stb`) or, after the ending, `title_clr`; and `title_gyalel` when the comment gave none.

Its menu (`func_ov008_02186cec`) has three entries always, then one each with flag `0x1198` (the Alchenomicon), the records' `0x2000`, `0x119d` (the Quest List), `0x119b` (Accolades Earnt) and the first completion (Completion Records). Its words are `str_jr` (the summary: 120–125 the counts, 130–133 the completions) and `str_tl` (the list).

`cmtFileTbl.bin` maps a number to a comment script and its text: 1–148 by the story's progress, 1000 `Header`, 1001 `Clear`, 1002 `TailC`, 1003 `TailG`.

## Not found

- What sets `0x119a`, `0x119b` and the records' `0x2000`.
- Where victories, alchemy and guests are counted.
- Title functions 119–177 and 202–215.
