# The Quester's Rest: Erinn's counter and the bank

What `<RIKKA>`, `<RIKKAFIRST>` and `<BANK>` open. See [Text events](Text-Events)
for the tags, and [Inns and churches](Inns-and-Churches) for the inn's own flow,
which Erinn's inn is.

> **USA only** for the code (overlay 3: the counter is service 42, its steps at
> `0x0217f578`; the bank is service 17, `func_02168438`), read through the
> [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the
> files and text.

## Talking across a counter

**Neither keeper is talked to directly.** Each counter has a **stand-in**: a
cast entry with **no name** (slot 4 `0xFFFFFFFF`), kind 0, placed at the
counter, and with a [talk box](Area-Cast) of **label 80** on the near side.
INFERRED: nothing is drawn for them, since there is no sprite to draw.

| | stand-in | its talk file | label 80 says |
|---|---|---|---|
| Erinn's counter | **208** | 208 | a bare `<RIKKA>`; labels 113–118 are her news, each ending `<PAGE><RIKKA>` |
| Ginny's bank | **212** | 212 | a bare `<BANK>` |

**In `R01M01` the box characters are 99, 208, 210, 211 and 212**, all of label
80, in every chapter from C to Q. Erinn herself (character 98) stands behind
the counter with talk of her own: "Do you think I'm doing alright here?" A
parser that drops unnamed entries loses the counter and the bank.

## Erinn's counter

`<RIKKA>` (code 6) and **`<RIKKAFIRST>` (code 12) dispatch identically**.
`<RIKKAFIRST>` is on no line on the cartridge.

1. **"What can I do for you today?"** (`strstd` 68), appended to her talk
   line's text in the same box.
2. **The menu** is `str_rkm` 92 (`/data/bin/menu/str_rkm.gp2`):
   `<N=0>Stay at the inn</N> <N=1>Canvass for guests</N> <N=2>View the guestbook</N> <N=3>Leave</N>`.
   A pick plays effect 1.
3. **Leave**, or B: line 28, "You're leaving already?…", and the visit ends.
4. **Canvass** (step 5) is tag mode, and **the guestbook** (step 4) is
   multiplayer.
5. **Stay at the inn** runs the [general inn](Inns-and-Churches) with its
   **Quester's Rest switch** (`+0x3f0`) on:
   - **words** from `/data/bin/menu/str_rki.gp2`, not a `str_in` file;
   - **price** a flat **3 gold a head for the living**, a constant in code
     (`0x0215d0c4`);
   - **lines**:

     | line | when |
     |---|---|
     | 100 | "…a special staff rate, naturally." |
     | 101 / 104 | the welcome by day / at night |
     | 103 | the Sinndicate's welcome, when a word at `func_02012fe4()+0x237c` is 6 (not established) |
     | 102 / 105 | the offer by day (Stay or Rest) / at night (Stay) |
     | 106 | paid |
     | 107 / 109 | "Good morning…" after Stay / after Rest |
     | 108 | too poor |
     | 110 | changed your mind |

   - **on 108 or 110 it goes back to the counter** (`+0x3f1`), which says
     `str_rkm` 41, "So what can I do for you today?", and shows the menu again.

## The bank

`<BANK>` (code 3). Ginny's Rainbow's End Gold Bank, every line from
`/data/bin/menu/str_bank.gp2` except the gold window's label (`strstd` 1009).
**It reads no story flag.**

| what | where | most |
|---|---|---|
| gold on hand | `GameState+0x3970` (party block `+0xf6c`) | 9,999,999 |
| **gold banked** | **`GameState+0x396c`** (party block `+0xf68`) | **999,999,000** |

1. Line 1000, every visit (three pages); then 1002 with the balance, or 1001
   with none.
2. **Deposit, Withdrawal, Leave** (lines 0, 1, 2), beside the purse.
3. **The most allowed**, in thousands, or a refusal:
   - **Deposit**: none if the vault is full (1015) or the purse is under 1,000
     (1013); else ⌊purse / 1000⌋.
   - **Withdrawal**: none with nothing banked (1023) or a purse at 9,999,000 or
     more (1024); else min(⌊banked / 1000⌋, 9999 − ⌊purse / 1000⌋).
4. The ask line (1010, or 1020 with the balance), then **the number window**:
   - four digits of thousands, then `0 0 0 G`, the cursor starting on the last
     digit at 0000;
   - up and down turn a digit (INFERRED: one a press, wrapping);
   - left and right move the cursor; **left past the first sets the most,
     right past the last sets 0000**;
   - any value over the most is held to it.
5. **A or X** confirms; **B, or an amount of 0, is a cancel** (1030).
6. **The money moves**: 1011 deposited, or 1021 withdrawn (purse clamped);
   1014 when a deposit would pass the vault's most. Then **the farewell**:
   1091 with the balance, or 1090 with none.
7. **One transaction a visit**: the visit ends.

**Banked gold is spared at a wipe-out.** The wipe-out's return
(`func_02010604`, from service 0x1A) halves only the purse, **rounding down**:
`ldr r1,[r0,#0x970]; mov r1,r1,lsr #1; str r1,…` at `0x020106e4`–`0x020106f4`.
Nothing there touches `+0x396c`. 7 gold leaves 3.

## Trigger 145's values

Case 31 of `func_0206f81c`, its table at `0x02070134` (from raw bytes):

| value | opens |
|---|---|
| 0, 1, 3, 4 | **nothing** |
| 2 | **the Rapportal**: Patty's flow in mode 1, as `<LAVIELL>` (code 8) does — Pavo, character 99 |
| 5 | **DQVC**, connected: `auction.stb` |
| 6 | **DQVC without connecting**: sets bit `0x20` of `GameState+0x5f78`, then runs 5's arm. Sellma's labels 113, 126, 127 and 131 ask "…use DQVC without connecting instead?" (INFERRED: the bit means "not connected") |
| 7 | the mini medals, `medal.stb` |
| 8 | `memory2.stb` |

## Not established

- The word that picks the Sinndicate's welcome.
- What `auction.stb` does.
- The number window's d-pad step: its scroller object (`func_0205bf3c`) was not read.
- What the field does after a night (`func_ov017_021a2fa0`, `0219bd1c`, `021921fc`).
