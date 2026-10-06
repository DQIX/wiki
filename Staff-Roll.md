# The staff roll

The credits that scroll up the bottom screen at the end of the story, and the cards on the top screen around them. Read 6 October 2026.

> **USA only** for the code (overlays 1, 17 and 28 and the ARM9), read through the [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the files and their values.

## How the ending reaches it

**EU only:** winning the last set battle at 17.2 plays `ev29300`, which chains on (engine function `538`) through `ev29301` … `ev29350`, `ev29352` … `ev29373`. Those from `ev29350` play in the maps `E01M01` to `E01M11`, which have no collision; the scenes place everyone themselves. `ev29350` calls `811` and starts the roll, and is the one script on the cartridge using [VM opcodes](Event-Scripts) `0x1D` and `0x1E`, the sine and cosine. `ev29352` to `ev29373` keep time by `838`, waiting for set times — 21,500 ms, …, 238,500 ms — and `ev29373` calls `812` at **268,550 ms**.

| fn | handler | does |
|---|---|---|
| `811` | `func_ov001_0216224c` | pages in overlay group 5, sets bit `0x1000` of a display word, starts the roll (`func_ov028_021d96bc`) |
| `812` | `func_ov001_0216227c` | stops it (`021d9714`) — **brightness −16 at once**, the display put back — and pages the overlay out |
| `838` | `func_ov001_02163228` | the roll's stopwatch (`021d9748`): ticks since `811` × 64 ÷ 33,514, milliseconds, truncated |
| `592`–`594` | `func_ov001_021619bc`, `02161a1c`, `02161a60` | a second, untimed roll at the scene's `+0x160`, stepped two frames at a time. **EU only:** no script calls them |

## Overlay 28

One object, `data_ov028_021d9b14`, `0xB0` bytes: the speed (`+0x00`, a float, 1.0 until set), the lines (`+0x04`, count `+0x08`, room `+0x0A`), a 256 × 256 four-bit bitmap for the sub screen's BG1 (`+0x40`), the scroll and the band counter (`+0x60`, `+0x68`, `fx32`), where the next group goes (`+0x64`), the next line (`+0x6C`), the state (`+0x80`, 0–3) and its step (`+0x81`), the timestamps (`+0x84` the scroll's start, `+0xA0` `811`'s) and the ticks since `811` (`+0xA8`).

**Starting** (`021d96bc`): reset, allocate the bitmap and a 20 KiB heap, take the timestamp, and set a periodic V-count alarm (`func_020c93d0` — it reads `VCOUNT`) at line `0xD7` calling `021d9668` every frame.

**State 0, the set-up** (`021d8dd0`), one step a frame from overlay 17's frame (`0x0218cfd4` → `021d9734` → `021d9624`):

0. a request (`func_02094b34`, `0x7A`, `0x20B`) — not followed; 1. wait for it;
2. the sub screen: BG1 to `(old & 0x43) \| 0x1000`; the window colours from the resource at `GameResources+0x2C` (`func_0204b3a0`); **colour 5 set to `0x67F5`**; BG1's map tiles 0–`0x3FF` in order; the bitmap filled with colour 1; BG1 alone on the sub screen;
3. queue `data/evspt_lv5/staffroll.bin`; 4. run it once loaded (below);
5. `SetBrightness(…, 0, 0x1E)`, a 30-frame fade; 6. when it ends, state 1, and the scroll's clock starts.

**Every frame** (`021d9668`), by turns: **move on** (`021d9574`) — frames = (now − start) × 60 ÷ `0x7FD88`, the tick rate; if that changed, the state's job with the frames since last time, and `+0xA8` renewed — or **show** (`021d9188`): BG1's vertical offset to the scroll mod 256, and the bitmap copied. So the roll moves every other V-blank, by the clock.

**State 1** (`021d9208`), given *d* frames: the scroll goes on by `ffix(2 × (d × speed × 0.5) × 4096)` (`021d8a74`); every 32 px the band behind is cleared to colour 1 (`021d8ad4`). Then lines are placed while they fit: **a line of the same group as the one before goes at once, at the same height; a new group waits until `scroll + 192 ≥ next + gap`, then `next += gap`.** A line is drawn at `next mod 256` (again 256 higher if it runs past the bottom), at an x by its alignment, in font 1 if its size is 12 and font 0 otherwise, in its colour. Out of lines: state 2.

**State 2** (`021d942c`): the scroll goes on until `next + 16 ≤ scroll`, then state 3, which has no job: the roll stands. The stopwatch keeps counting.

## `staffroll.bin`

A [tagged data table](Tagged-Data-Table) run as a script (`021d98e0`) with three functions (`data_ov028_021d9ac0`):

| tag | function | values | does |
|---|---|---|---|
| `0x64` | `021d97b0` | count | room for that many lines |
| `0x65` | `021d97d8` | group, flags, gap, text | one line, while there is room; the text copied with `sprintf` |
| `0x66` | `021d9898` | speed | pixels a frame |

A line's flags: bits 0–3 the **size** (12 sets it in `me`, else `s7`); bits 4–5 the **alignment** — 0 at x 0, 1 centred `(256 − w) / 2`, 2 ending at x 120, 3 starting at x 136; bits 7–10 the **colour**. Bit 6 and bits 11 up are read by nothing. *w* is the text's [measured width](Bitmap-Font) — kerned, though the line is drawn unkerned.

**EU only:** 472 instructions: speed **0.86**, room for 470, 470 lines in 418 groups, "SQUARE ENIX CO., LTD." to "Shuhei Yamaguchi". Headings size 10, colour 5; names size 12, colour 15; pages of two columns put a pair in one group, at alignments 2 and 3. Gaps: 209 between companies, 37 between roles, 23 under a heading, 13 between names. The last line lands at 13,650 px, so the roll runs out **265.45 s** after `811` (set-up included), three seconds before `ev29373` stops it.

## The cards

`820` (`func_ov001_021624cc`) loads `data/<name>.pac` — `chara_sub/horii.pac`, `toriyama`, `sugiyama`, `hino`, `fujisawa` in `ev29350`, `ichimura` in `ev29373`, `tobe_<LG>` in `ev29306` — onto the top screen's BG3 with BG3 alone switched on; `826` clears it; `821` and `822` save and restore the display around them. See [Engine functions](Engine-Functions).

## Not established

- **Colours 1 and 15**, the roll's ground and its names' ink: the window colours from the resource at `GameResources+0x2C`.
- Which screens the set-up's fade covers.
- Step 0's request.
