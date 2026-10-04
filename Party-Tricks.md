# Party tricks

How a party trick is assigned, started and performed in the field, and the
files it plays from.

> **USA only** for the code (the ARM9; overlay 2, the field menu; overlay 17,
> the field), read through the [dqix-decomp](https://github.com/DQIX/dqix-decomp).
> **EU only** for the files.

## The slots

**Seven bytes** at `GameState + 0x2a04 + 0x2c8d + i` (setter `func_0203970c`,
getter `func_02039730`), global rather than per character:

| slot | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| place | Up | Left | Right | Down 1 | Down 2 | Down 3 | Down 4 |

Each holds a **trick number**, 1 to 31; 0 is none. The menu's Assign Party
Tricks lists its rows as Up, Right, Left and then Down four times
(`str_tm` 4501–4504). Row r is slot `data_ov002_0216c9c0[r]`, which is
`0, 2, 1, 3, 4, 5, 6`. No gate was found on the four Down rows.

## Starting one

- **B pressed** in the field opens a cross of four windows (`func_ov017_02199f08`,
  `0219a388`): each place's trick name from `/data/bin/menu/str_sgs.gp2`. For
  Down, the window shows Down 1, or else the first of Down 2–4 that is set.
  Releasing B closes the cross.
- **With B held**, a direction **newly pressed** starts that place's trick
  (`func_02037d88`, `0x02037e48`–`0x02038094`). The directions are tested in
  the order Up, Right, Left, Down.
- **Down plays its four in order**, the empty ones left out
  (`func_02052f44`).
- **Only the controlled character performs**, where they stand and facing
  as they were. In one-player play that is the Hero (INFERRED from the party
  loop, `func_ov017_0218e674`).

## The performance

`func_02053634`, each frame:

1. **Load** `data/chara/sg<nn><m|w>.chr` (`func_0205308c`), where `<nn>` is the
   trick number and the letter is `"mw"[sex]`.
2. **Play what the pack's `.bcfg` names**:
   - `sigusa` once; or
   - `in` once, then `loop`, then `out` once.

   The motion replaces the one before with **no blend**, at its `.bcfg`
   speed. A trick of three motions performed alone (Sit, Recline, Belly Dance,
   Sultry Dance, Weird Dance) **holds its loop until A, B, X or Y is pressed**.
   In a Down sequence the loop plays once.
3. At each trick's start, its **sound** (below), and for six tricks a
   **bubble** over the head.
4. **When the last ends**: the first trigger record of **kind 19** whose
   conditions hold is run, once, with all the tricks performed (see
   [Triggers](Triggers)). Then the character goes back to standing
   (`func_02033b88(obj, 0)`).

There is no fixed wait anywhere: each motion lasts its own length at its own
speed. While B is held or a trick plays, the camera eases in toward a height
of 3.3 and a distance of 6.0, 1/10 of the remaining way each frame. Each start
adds one to two 10-bit counters in the records block at `GameState+0x7540`;
nothing else is set.

## Sounds

Sequence *n* of sequence archive **100**, `data/sound/se_norm.sdat`:

| trick | sound |
|---|---|
| 2 Clap | 90 |
| 6 Despair, 7 Tantrum, 8 Surprised, 9 Jump | 72, 73, 74, 75 |
| 12 Hello!, 13 Thanks!, 14 Goodbye! | 71 |
| 15 Eek! | 6 |
| 16 Hmm... | 28 |
| 18 Dive | 76 |
| 23 Cap'n's Curtsy | 77 |
| 25 Weird Dance | 78, stopped when its `out` ends |
| 26 Wallop, 27 Cheer, 28 Provoke | 79, 80, 81 |
| 30 Inspiration | 70 |
| 31 Professor's Pose | 82 |

The other tricks are silent.

## Files

- **`/data/chara/sg<nn><m|w>.chr`**: 64 packs, `sg00`–`sg31` in each sex.
  Each is one `.bcfg` and its `.nsbca`s; there is no model. The motions use
  the player's 14-bone rig (as `mp0200` in `chara_mp.gp2`), animated on bones
  2–13.
  - What plays is **what the `.bcfg` names**: `sg11w.chr` holds a
    `sigusa.nsbca` that its table does not name, and it is never played.
  - `sg00`'s table names `sigusa` but the pack has no motion of that name.
- **`/data/bin/menu/str_sgs.gp2`** › `str_sgs_<lang>.nat`: the trick names by
  number, with 0 as `------`. These are the same names as `str_tm` 4509 + n.
- **`/data/ani/sg.gp2`**: the bubbles, one-frame sprites.
  - `sg12`, `sg13` and `sg14` (Hello!, Thanks!, Goodbye!) in each language:
    `_en`, `_fr`, `_de`, `_it`, `_es`, 48 × 24.
  - `sg15` and `sg16` (Eek!, Hmm...) at 24 × 24, and `sg30` (Inspiration) at
    16 × 16, one each for all languages.
  - Each is drawn at the head raised 1.7 (`0x1B33`), as the camera projects
    it, with its top left at (−24, −18) for the words, (−8, −8) for
    Inspiration, and (−12, −12) for the rest (`func_0205337c`).

## Not established

- Why the other party members never perform; the reading rests on the party
  loop.
- The meanings of several of the start's gates (listed in the code at
  `func_02037d88`).
- What the two record counters are called.
- Condition `32`, the four in order.
