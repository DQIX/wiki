# The party

Not a file format — the shape the game keeps the party in at runtime, which is
what anyone reimplementing it has to match. The characters themselves are read
from [attending characters](Attending-Characters); this is how the game holds
which of them are with you, and in what order.

**Addresses are into the USA release's ARM9**, unpacked (see
[DS compression](DS-Compression)), with the
[dqix-decomp](https://github.com/DQIX/dqix-decomp) names where they exist.

## Everyone who could ever join is in one table of 233

`GameState::GetPartyMemberByIndex` (**`0x0200fdf0`**) is the accessor, and its
name is slightly misleading: the index is into the table of every character,
not into the party.

```
0200fdf0  cmp   r1, #0
0200fdf4  movlt r0, #0            ; below zero: nobody
0200fdfc  cmp   r1, #0xe9         ; 233
0200fe00  movge r0, #0            ; at or above: nobody
0200fe08  add   r0, r0, r1, lsl #2
0200fe0c  ldr   r0, [r0, #8]      ; a pointer array at +8, 233 entries
0200fe1c  ldrh  r1, [r0]
0200fe20  tst   r1, #0x800        ; a flag; clear means "not one of them"
0200fe24  moveq r0, #0
```

So a character has an entry whether or not they are with you, and **bit
`0x800` of the halfword at the start of that entry** decides whether this
accessor will hand them over. What the bit means precisely is **not
established** — "currently in the party" fits every use seen, but it has not
been traced to where it is set.

## The party is an ordered slot array and a count

| field | offset off the game state | what |
|---|---|---|
| slots | `+0x397c` | one byte each, a character index into the 233 |
| count | `+0x3980` | how many of the slots are filled |

The walk at **`0x02010644`** shows both, and shows the slots being used as
indices for the accessor above:

```
02010644  add  r0, sl, r6
02010648  add  r0, r0, #0x3000
0201064c  ldrb r7, [r0, #0x97c]   ; slot r6 -> a character index
02010658  bl   #0x200fdf0         ; GetPartyMemberByIndex
...
020106d4  add  r6, r6, #1
020106d8  ldrb r0, [r4, #0x980]   ; r4 = sl + 0x3000, so +0x3980: the count
020106dc  cmp  r6, r0
020106e0  blt  #0x2010644
```

**Four slots — INFERRED.** The count sits at `+0x3980`, immediately after
`+0x397c`, leaving exactly the four bytes `+0x397c`–`+0x397f` for the slots.
That is an argument from the layout: **no bound check against 4 has been
found**, so the number is what fits rather than something an instruction
states.

## Slot 0 is the leader

**`0x0200fddc`** reads `+0x397c` with no index at all and hands it straight to
the accessor:

```
0200fddc  ldr  ip, [pc, #8]
0200fde0  add  r1, r0, #0x3000
0200fde4  ldrb r1, [r1, #0x97c]   ; slot 0
0200fde8  bx   ip                 ; -> GetPartyMemberByIndex
```

It is the function the message system calls to decide who a speaker should
turn to face — see [text markup](Text-Markup), where every message turns the
speaker toward the party leader unless `<N_TURN>` says otherwise. So the
ordering is not cosmetic: **slot 0 is who the world talks to.**

## Not established

- **What writes the slots or the count.** Three reads of `+0x397c` exist in
  the ARM9 (`0x0200fde4`, `0x020100b4`, `0x0201064c`) and no write, in the
  ARM9 or in any of the 32 overlays; `+0x3980` has the one read above and
  nothing else. Searched as both `[base + 0x3000, #0x97c]` and
  `[base, #0x397c]` forms. Recruitment must reach them another way — through a
  held pointer, or as part of a bulk copy when a save is loaded.
- What bit `0x800` means, beyond fitting "in the party".
- That four is a limit rather than what the layout leaves room for.
- **Where a party member's vocation lives.** It is not in
  [attnpc](Attending-Characters), which has no vocation column — see that
  page. The [level tables](Level-Tables) number the vocations, and what
  selects one for a given character has not been found.

## See also

- [Attending characters](Attending-Characters) — the five who go along for a
  stretch of the story, and their models, names and numbers
- [Level tables](Level-Tables) — thirteen files, one per vocation
- [Text markup](Text-Markup) — where the leader decides who a speaker faces
- [Engine functions](Engine-Functions) — the event VM, whose `205` and `206`
  bring characters in and send them away
