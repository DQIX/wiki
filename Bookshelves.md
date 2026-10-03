# Bookshelves, recipe books, and the recipes known

> **USA only** for the code, read through the
> [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the
> files and counts.

## The recipes known

**A list, not a bitfield**: `GameState+0x7AC0` is a `u32`, how many times
alchemy has been done (capped at 99,999), then **471 `u16` slots** at
`+0x7AC4`, each `recipe << 2 | made << 1 | known`, 0 empty, filled from the
front. Zeroed on a new game (`func_0200f3a4`) — **a new game knows no recipe**
— and saved whole (`0x3B4` bytes). `func_020ac104` writes slots, `func_020ac234`
copies them out, `func_020ac2d4` reads some.

What teaches a recipe:

| who | sets | where |
|---|---|---|
| a recipe book, read for the first time | known | ov017 `0x021ac8bc`–`0x021ac918` |
| [trigger](Triggers) action **`161 : r`** | known on *r* | `func_02061c04` case 61, `0x0206301c` |
| successful alchemy | known and made on what was made; known on what was attempted, after an alchemiracle | ov006 `func_ov006_02153cbc` |

**EU only:** the Krak Pot's first talk teaches six by `161` (440–445, the
strong and special medicines and antidotes, softwort) and quest rewards 43; 54
books teach 327; the other 94 — the upgrade tiers, Erdrick's and the metal
king's — are learnt only by making them.

The same first talk runs `202 : 0` — action **`202 : n`** sets game-wide flag
`0x1198 + n` (case 102, `0x02063a34`), INFERRED "has the Alchenomicon" — and
`224 : 1`, which sets flag `0x798` to its value (case 124, `0x02064054`), what
it means not read.

## The Alchenomicon's list

`func_02071ffc`, `func_020722a4`, ov006 `func_ov006_0215f7e8`: the
[recipes](Alchemy-Recipes) in the book's own order — By Type or By Name —
narrowed to a category and type, **without the 22 better recipes an
alchemiracle makes** (value 17 set, `0x020721cc`); then **cut into pages of
16, and a page with no known recipe dropped**. On a kept page an unknown
recipe is a line, `str_ren` 37 "???".

**The alchemiracle draw**, ov006 `0x0215ce64`–`0x0215cf38`: when the recipe's
value 16 names a better one, `NextRandomMax(GetBTRandom(), 10000) / 100 <
chance`, the chance worked out by `func_ov006_02153f24` from the **better**
recipe's values 8 to 12 — 100 when value 8 is 0; otherwise one of the Hero's
numbers (value 8 picks which, not read) scaled between values 9 and 10 by 11
and 12, in floats.

## Bookcases

**A bookcase is a region**: a `0x73` record of **type 8** in a map's `.bmbl`
link table and the `0x74` after it, holding its number — the same pair
[doors](Doors) and areas use (`func_0201d638` case 8). Values 1–3 the centre,
4–6 the size, 7 the box's turn, **8 the way the Hero is turned to read it**.
163 on the cartridge, in 64 maps. The Hero reads one standing in its box and
facing within about 117° of value 8 (`func_ov017_021984f4`, `< 8364.2` fx32),
the nearest way winning; the A Button then runs service 30
(`func_ov017_021ac3b0`).

**What a shelf holds** is `/data/scenario/htana<L>.gp2` ›
`htana<L>_<lang>.bin` — *hon-dana*, bookshelf — one file for each first letter
of a map's code (C, D, H, M, R, S, X; INFERRED from all 162 records), a
[tagged data table](Tagged-Data-Table) run as a script. Each tag-`0x66` record:

| value | what |
|---|---|
| 0 | the map, by its [map list](Map-List) id |
| 1 | the bookcase's number |
| 2 | 1 a recipe book, 0 a book to read |
| 3 | the recipe book's number; its flag is `0x114C` + it |
| 4 | text 0 — a plain book's text, or a recipe book's "nothing of interest" |
| 5 | text 1, or `0xFFFFFFFF` — a recipe book's first reading, "…finds recipes for … `<SE_RECIPE>`" |
| 6 | text 2, or `0xFFFFFFFF` — read again, "…already knows the recipes in this book" |
| 7 on | the recipes it teaches |

The last record naming the map and number wins.

**Reading one**: the Hero turns to value 8 and one message is shown — text 0
for a plain book, or for a recipe book **while game-wide flag `0x777` is
clear**; text 2 once the book's flag is set; otherwise text 1, and **once it is
read**, its recipes are known and its flag set. There is no "you learnt" line of
its own. **Flag `0x777` is set when the Krak Pot first opens**
(`func_ov006_02157a60`), so a bookcase teaches nothing until the pot has been
used. A shelf with no record says `strstd` 0x53.

**EU only:** 54 recipe books, numbered 1 to 55 with no 8; four stand on two
shelves, in the two story versions of Stornway's library. Stornway inn's
*Alchemical Essentials* is a plain book and teaches nothing.

## Not established

What the book-taking sound (`0x1F6`) and `<SE_RECIPE>` play; which of the
Hero's numbers the alchemiracle chance reads; what a trigger of kind 24 —
asked for after a bookcase, used by no record — would do.
