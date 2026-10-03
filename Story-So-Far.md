# The Story So Far

What the **Y Button** shows in the field: a page summing up where the story
stands, on the bottom screen, with the world map on the top. "Press the Y
Button to have a goose at the world map, or remind yourself of the story so
far" — the game's own tip (`Header_en.bin` 1009).

> **USA only** for the code, read through the
> [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the
> files and the text quoted, from the European release.

## One number for the whole game

| what | where |
|---|---|
| the number | `GameState+0x5CBC`, a word — getter `func_0201081c`, setter `func_02010810` |
| on a new game | **1** (`func_0200f3a4`, `0x0200f4d4`) |
| saved | yes: `func_020a9eb8` writes it, `func_020a9a50` puts it back (`0x020a9a90`) |
| set by | **[trigger](Triggers) action `197 : n` only** — case 97 of `func_02061c04`, `0x020636b4` — to *n* at once, forwards or back |

It sits beside the stage's own fields but is **not one of the five
[story threads](Story-Threads)**: changing the live thread leaves it alone.

**EU only:** 183 action `197`s across the trigger files set 145 numbers from 1
to 148; 94, 129 and 137 are set by none. Every `197:0` is a talk label after
`118` or `53`, never this action. A battle's win and loss records set
neighbouring numbers: the Hexagoon lost, `12:2 104:4 197:10`, gives page 10,
"…he was defeated"; won, `ev2555`'s record, page 11. The strategy guide's
screenshot of the screen shows page 35 word for word.

When the old and new numbers fall in different ranges of the table at
`0x020636b4`, a 40-byte block at `GameState+0x75a8` is cleared. The ranges
are the groups of `cmtFileTbl.bin`, from which the continue screen (overlay 8)
picks a comment by the same number.

## The page

- **Text**: message *n* of `/data/scenario/str_ol.gp2` › `str_ol_<lang>.bin`,
  a [tagged data table](Tagged-Data-Table) whose tag-`0x67` records are
  (number, text): 1 to 148 (no 137) and 1000, which a multiplayer session
  shows instead.
- **`<val_1>`** is the fyggs found: how many of game-wide flags **4 to 10**
  are set (the table at `0x02170138`, `func_ov004_0216aaec`). The pages that
  use it read "fygg number `<val_1>`".
- **One page.** No paging, no list of past entries.

## The screen

Y, in the field with the player free (`func_ov017_021a51a4`, `0x021a544c`;
X is tested first), queues **service 45** with the menu script
`/data/menu/story.stb`, overlay 4's handlers at `0x02170154`:

| | |
|---|---|
| bottom screen | the parchment `/data/menu/bg_strdw.pac`: `st_01.bncg`, `.bncl`, `.bnsc`, its English title "The story so far…" drawn in. `st_01_fr`, `_it`, `_de`, `_es.bnsc` are the other languages' title strips, copied over it by handler 6 |
| the text | resource 402, `str_ol`; text object 50 at (20, 35), wrapped at 215 (INFERRED pixels); colours 12 and 15 of the parchment's palette, 15 the dark brown it is written in (INFERRED from the colours) |
| top screen | **the world map**: sub-screen mode 4 (`func_020dc2d0(3)` → `func_020227dc`) — `O00M0001.obg` from `minimap.gp2`, `obj_mm_w.pac` and `data/map/w_offset.bin`, the mode the Ocean and Sky maps use |
| closing | **B** — section 999: a fade to black, the top screen back, done |

While a treasure map is being searched outdoors, Y asks instead whether to
put the treasure map away (service 53, `tms_end` line 1).

## Not established

What A does on the page (only B was traced); what `w_offset.bin` holds and
how the party is marked on the world map; the fade's units; the text's
colours and units, INFERRED above.
