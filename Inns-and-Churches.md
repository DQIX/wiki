# Inns and churches

What a talk line's `<INN=n>` and `<CHURCH=n>` hand over to — see
[Text events](Text-Events).

> **USA only** for the code (overlay 3: the inn `func_ov003_0215c924`, the
> church `func_ov003_02158e94`), read through the
> [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the
> files, prices and text.

## What `n` selects

**The keeper's own words**: the file `n − 1`,
`/data/scenario/str_in<k>.gp2` › `str_in<k>_<lang>.nat` for an inn, `str_ch<k>`
for a church ([system strings](System-Strings), by number). It holds the
keeper's lines, **the inn's price a head (its line 10000)**, and **which of the
church's services there are** (a label left empty is left out of the menu).
`str_in0`–`str_in14` and `str_ch0`–`str_ch7` are on the cartridge. Line 50 is
a style for the keeper's window (3 INFERRED narration; 0 and 2 not
established).

## The inn

| step | |
|---|---|
| greeting | line 1000 by day, 1001 at night (1002 a guest in another's world), `<val_1>` the beds — **the living** — and `<val_2>` the price |
| menu | **Stay Overnight, Rest, Cancel** (lines 0, 1, 2) by day; **at night, Stay and Cancel**; a guest, Rest and Cancel |
| too poor | line 1020 |
| Stay or Rest | 1010, the screen to black, **jingle 55**, a hold of 180 ticks; then **the price paid, the living's HP and MP full** — never the dead raised, nor poison or a curse touched — and **[the clock](Time-Of-Day) at the day's start (Stay) or the night's (Rest)**; then 1011 |
| Cancel | 1090 |

**The price is a head's price times the living** (`0x0215d0d4`–`0x0215d108`):
**EU only:** 5 at Ivor's (`str_in0`, `str_in1`), 4 to 12 elsewhere, 0 for the
bed (`<INN=15>`, "It's a lovely, soft bed"). The Quester's Rest's is a flat 3,
in its code. **EU only:** in `str_in3`–`str_in13`, line 1000 prints the price
as `<val_1>`, the bed count; the talk files' copies say `<val_2>` (INFERRED a
slip in the service's text).

## The church

**The menu** (labels 0–5): Confession (Save), Divination, Resurrection,
Purification, Benediction, Nothing — beside a gold window and a status window,
each member "Dead", "Poisoned", "Cursed" or "Lv. n". `str_ch3`, the
Observatory, has no Resurrection or Purification; `str_ch2` is the adventure
log on Angel Falls' table, a confession with no priest.

**The cures** — Resurrection, Purification, Benediction, lines 1030, 1040,
1050: whom (11 "On whom?"); a member not needing it, the line + 2; else the
price, 1061, and a Yes or No; refused 1062, too poor 1063; paid, the prayer
(the line + 1) to **jingle 59**, the cure, and 1070 back to the menu. **The
prices, by the member's level in their vocation L** (`0x0215a8e0`–`0x0215a99c`):

| | |
|---|---|
| Resurrection | **⌊(L² + 20) / 20⌋ × 10** — 10 at L 1, 60 at 10, 460 at 30, 4,910 at 99 |
| Purification | **5** |
| Benediction | **30 × L** |

**Resurrection** fills HP and clears every status bit but the curse
(`func_02048150`); MP is as it was. **Benediction** also takes off every worn
item marked by bit 18 of its slot word (INFERRED cursed) into the bag.

**Divination** is free: line 1020, then one line a member — 1022 at level 99
("…path of the `<str_2>` is complete", the vocation from `str_ch` 30 + its
number), 1023 when the next battle will bring a level, else 1021 with the
experience wanted.

**Confession** saves (jingle 60), then asks whether to go on; **No ends the
game**: "Please turn the power OFF" (110).

## A character's status

Bits of the word at `[member+0x130]+0`: **0 dead, 1 poisoned, 2 cursed**; HP at
`+4`, MP at `+6`; max HP and MP at `[member+0x134]` `+0x30`, `+0x32`.

## Not established

Whether the talk line and the service's own greeting both show; style values
0 and 2; what happens after a stay (`func_ov017_021a2fa0`, `0219bd1c`,
`021921fc`, INFERRED the map refreshed for the new hour); line 1100, a free
resurrection for a coffin brought in, in the step table with no setter found;
what sets the poisoned and cursed bits; `chur_messet.bin`, which picks the
church to wake in.
