# Single questions

Ten small readings taken together on 4 October 2026: what sets Alltrades
Abbey's flags, how the party's slots are ordered, what a face and a hair are,
the characters' outline colour, the drop roll's further passes, the critical
rate's doubling, what the text's sound tags play, and how a victory's level-up
ends.

> **USA only** for the code (the ARM9; overlays 0, 9, 17 and 23), read through
> the [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the
> files and their values.

## Alltrades Abbey's three flags

The Abbey tests three bits of the game-wide flag bank (`+0x8c` of the trigger
object; `func_0206dfb0`). Three [trigger](Triggers) actions set them, each
through `func_0206df6c`, in the action interpreter `func_02061c04`:

| action | case | sets | carried by (EU) |
|---|---|---|---|
| `223 : x` | 123, `0x02064038` | `0x799` := *x* ≠ 0 — the Abbey open | the two outcome records of `ev26510`, Tower of Trades map 9008, stage 6.5 |
| `231 : x` | 131, `0x0206414c` | `0x796` := *x* ≠ 0 — revocation offered | the record that plays the credits, `ev29300`, map 4403, 17.2 |
| `160 : v` | 60, `0x02062fd8` | `0x113F + v` — vocation *v* unlocked | six records, each beside a `127` (quest cleared) |
| `224 : x` | 124, `0x02064054` | `0x798` := *x* ≠ 0 — not established | `R01`–`R04` records from 4.1 |
| `202 : n` | 102, `0x02063a34` | `0x1198 + n` | the Krak Pot's first talk |

`231` skips the set when `func_0202ae18`→`func_0202c540` holds (INFERRED: a
guest in a wireless game), and then, once, stamps a record with the clock,
the Hero's `+0x134` and the play time (INFERRED: "game cleared").

The six `160`s, by the quest cleared beside them: quest 25 → 7 Gladiator,
27 → 8, 26 → 9, 124 → 10, 128 → 11, 28 → 12. **An advanced vocation is
unlocked when its quest is handed in.** Nothing clears `0x799` or `0x796`.

## The party's slots

See [Party](Party#what-writes-the-slots--found-4-october-2026): the slots are
rebuilt by `func_ov017_02191108` — **the living by their order byte, then the
fallen** — through `GameState + 0x2A04`.

## Faces and hairs are items

A character's ten equipment slots h0–h9 include **h2, the face, and h3, the
hair** (`CharaParts_GetPartNumbers`, `func_02072afc`). Each is an item:

| items | letter | |
|---|---|---|
| 9000–9013 | `h` | hairs |
| 9020–9033 | `f` | faces |

**An item's model**, `itemdt_<lang>.nat` record `+0x10` (`func_020de234`):
bits 0–9 the number for a man, 10–19 for a woman, 999 meaning the other's;
bits 20–27 the letter. So face 9024 is `p_f004` on a man and `p_f014` on a
woman; hair 9006 is `p_h060` and `p_h180`.

| hair | man | woman | shades (man) |
|---|---|---|---|
| 9000–9005 | 000–050 | 100–150 | 0 |
| 9006 | 060 | 180 | 0 |
| 9007 | 070 | 160 | 0 |
| 9008, 9009 | 080, 090 | 170, 190 | 4 |
| 9010 | 200 | (200) | 4 |
| 9011–9013 | (210–230) | 210–230 | 0 |

**Character creation** (overlay 9, `func_ov009_02188944`) writes
h3 = `9000 + remap(choice)` and h2 = `9020 + remap(choice)`, the remap by sex
(`func_ov009_02188b14`):

| | man | woman |
|---|---|---|
| hair | 0–9 as chosen | 6, 0, 1, 2, 3, 4, 5, 7, 8, 9 |
| face | 4, 0, 1, 2, 3, 5, 6, 7, 8, 9 | 1, 0, 2, 3, …, 9 |

So creation's ten hairs are items 9000–9009; 9010–9013 and faces 9030–9033
are the four named presets'.

**`presetdt`** (loaded by `func_02089de8`; record handler `func_02089b90`;
copied by `func_02086f24`): value 2 the sex, 5 the skin tone, 6 the hair
colour, 7 the eye colour, 8 the build, **9–18 the ten slots in order — so 11
is the face and 12 the hair**. `charapreset.bin` has no reader in the code;
its 77 and 78 are the face and the hair by the same order (INFERRED). See
[Character presets](Character-Presets).

**The hair's colour texture** takes its skin ramp from the hair item
(`GetItemSkinShades` on h3, `0x020731f0`) and writes it at offset 16 of the
palette data. **The hair's shape letter is the headgear's**
(`func_02072e94`): `a` with no headgear; otherwise the headgear's model
number ÷ 100 indexes `"bbdcc\0cea\0"` (`data_020e883c`) — 0–1 `b`, 2 `d`,
3–4 `c`, 6 `c`, 7 `e`, 8 `a` — and hundreds 5, 9 or ten and more **draw no
hair**. A man of hair 9001 under a 3xx takes `f`.

## The outline colour

[`palette.bin`](Character-Colours) tag `0x69`, stored at `0x02109a50`, is
**the characters' edge colour**: overlay 23's `func_ov023_021e5628` copies it
into all eight entries of the 3D engine's EDGE_COLOR table (`0x04000330`, via
`func_020c555c`) before drawing a menu or creation figure. EU value `0x1086`.

That figure is overlay 23's own, built of `d_` parts from
`chara_pd.gp2` (`func_ov023_021e5974`); its skin goes straight to VRAM
(`func_ov023_021e540c`), counted from bits 11–14 (man) and 19–22 (woman) of
the item's shade word.

## The drop roll's further passes: Autofilch

`func_ov023_021f454c` rolls five passes. Pass 0 is the ordinary one. Pass *k*
(1–4) is party member *k* − 1 (`func_02011518`), and is skipped unless they:

- are in the battle and standing (`func_02010088`);
- stood for **at least half the battle's rounds** — their counter over the
  battle's, as floats, not below 0.5 (`0x021f4678`–`0x021f468c`);
- hold **skill panel 164, Autofilch** — trait `0xa4`, tree 19's eleventh
  panel, which its book grants.

Then every kind of monster beaten is rolled again, rare first: chance step *N*
(1, 8, 16 … 256) becomes **one in `N × 100 ÷ L`**, *L* their level in their
current vocation (`func_0202053c`); step 0 never lands in these passes, and a
kind may drop twice. Such a drop is said with `str_bres` 37, "*X* manages to
steal *an item*!". Eight drops stop everything.

## The critical rate's doubling: Critical in a Crisis

`func_ov000_02156cc4`, for one of the party: after `CalculateCritRate`, **× 2.0f**
when they hold trait `0x11d` — **skill panel 285, Critical in a Crisis**, tree
26's eleventh — and `func_ov000_02155a04` is under `0.25f`. That function is
**current HP ÷ maximum HP** as floats (0 when HP is 0). The doubling comes
before the × 100 and the truncation, so deftness 159 gives 417, not twice 208.
A monster's rate (`func_020748f8`) never doubles.

## The text's sounds

A message's `<ME_n>` asks for `n + 49` and `<SE_n>` for a flat 14 (the
interpreter's arms at `0x02066860` and `0x020668b0`).

- **A jingle's id is `bgm.sdat`'s sequence number**: `func_020bd454` indexes
  the INFO sequence list directly, and sequence 50 is `ME_001`, so `<ME_n>`
  plays `ME_00n`. The text's request (`func_0209c830`) is timed by
  `func_0209c840`: the music's volume to 0 over 20 frames, the jingle 800 ms
  after the request, and the music back 500 ms after it ends. A battle's
  jingle (`func_0209c6d8`) stops the music at once instead.
- **An effect's id is an entry of the sequence archive mounted at
  `[se+0xb4]`**: 100 on the field, from `se_norm.sdat`, and 101 in battle,
  from `se_btl.sdat` (`func_0205ea20`). So `<SE_n>` is entry 14 of archive
  100. `<EXC>` and `<QES>` ask for entries 6 and 28.

## A victory's level-up

Overlay 23's sub-state 7 (`func_ov023_021f0a5c`), for each member who levels:

1. line 10 or 22, and `ME_004` starts;
2. a key, then line 38 (attributes improve);
3. **step 7 waits for the jingle to end** before it takes a key at all;
4. **each spell the levels brought**, one a key: `str_bres` 12, "*X* learns
   a new spell: *spell*!" (sub-state 10, `func_ov023_021f2368`), the spells
   from the vocation's rows of the spell table with old level < level ≤ new;
5. line 13, the skill points earned;
6. **the skill-point screen** (sub-state 8, `func_ov023_021f1234`, overlay
   13) where a tree of the vocation's five is under 100 and there are points.
   The first time — game-wide flag `0x119c` clear — it sets the flag and says
   `str_bres` 36 first. `0x119c` is also what lists Allocate Skill Points in
   the field menu's Misc. submenu ([Heal All](Heal-All)).

## Not established

- The map condition and objects `0x2347`–`0x2349` in the slots' swap; object `0xCE`.
- `presetdt` values 4, 33 and 34; a `charapreset` hair colour.
- Whether 3D edge marking is switched on.
- What reads `battle+0x5901`, set for members who stood half the rounds.
- That the 800 and 500 are milliseconds and the 20 and 30 frames (INFERRED).
