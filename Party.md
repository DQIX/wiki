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

## The character record: thirteen of everything

Read 24 September 2026. A character's **persistent** record is `0x23C` bytes,
in an array at **GameState + 0x3984** with a count byte at **+0x5690**; the
capacity read from the indexer is **13** (`func_0208660c`, `cmp r6, #0xd`).
This is not what `GetPartyMemberByIndex` returns — that gives a `GameObject`,
whose `+0x150` points at a live struct that mirrors this one.

| offset | size | what |
|---|---|---|
| `+0x00` | byte | bits 0–5 the character id (`0x3F` none); bits 6–7 flags |
| `+0x02` … `+0x0E` | 13 × 1 | **level, one per vocation** (1 at creation) |
| `+0x0F` … `+0x1B` | 13 × 1 | 0–10 each; a **revocation count**, INFERRED from the range and a row of stars drawn from it |
| `+0x1C` … `+0x4F` | 13 × 4 | **experience, one per vocation** (0 at creation) |
| `+0x50` | word | **the current vocation** |
| `+0x54` | halfword | bit *v* set once vocation *v* has been held |
| `+0x58` … `+0xF3` | 13 × 0x0C | a per-vocation sub-record; contents **not established** |
| `+0xF4` | halfword | **the skill-point pool — one per character** |
| `+0xF6` … `+0x110` | 27 × 1 | **points spent per [skill tree](Skill-Panels)**, each 0–100 |
| `+0x111` … `+0x119` | 9 | a 72-bit set; spells or abilities learned, INFERRED |
| `+0x11A` … `+0x13D` | 0x24 | the **skill panels learned**, a bit each — the live mirror's `+0x8EC`, which [`HasLearnedSkillPanel`](Skill-Panels) tests |
| `+0x140` | 0xC | the name |
| `+0x14C` … `+0x15F` | 5 words | **the stats**, fourteen 10-bit fields, three to a word — see below |
| `+0x160` … `+0x17B` | 0x1C | **equipment and appearance**, the live struct's `+0x488` copied whole — see below |
| `+0x17C` … `+0x23B` | 0xC0 | the live struct's `+0x4A4`, the twelve per-vocation equipment blocks. Init fills it with `0xFF` |

### `+0x14C` is the stats, not the appearance

**Corrected 25 September 2026.** This page read those five words as the
appearance. They are the character's **stats**: fourteen 10-bit fields packed
three to a word, `(bits 0-9, 10-19, 20-29)`, bits 30-31 unused.
`func_020830cc` packs them from the live struct's `+0x00`, `+0x04`, `+0x08`,
`+0x0C`, `+0x1C`, `+0x1E`, `+0x6C`, `+0x6E`, `+0x70` and `+0x72`; the one field
at `+0x15C` bits 20-29 is never written.

What settles it is `func_02083e28`, which computes those live words by summing
each worn piece's own modifier and **clamping to 999** — the game's stat cap:

```
02084504  ldr  r2, [r3]             ; an equipped part
02084518  ldrne r2, [r2, #8]
0208451c  lslne r3, r2, #0x16
02084524  addne r4, r4, r3, asr #22 ; a signed 10-bit modifier
02084558  ldr  r2, [pc, #0x4f4]     ; literal @0x02084a54 = 999
02084560  cmp  r4, r2
02084564  movgt r4, r2
```

The initialiser `func_02086404` zeroes all fourteen and sets exactly two to 1
(`+0x154` bits 10-19 and `+0x158` bits 0-9). **Which stat each field is has not
been chased.**

### The appearance is `+0x160`, and it is the live struct's `+0x488`

`func_020830cc` copies 0x1C bytes straight across —
`0208340c add r0, r4, #0x160 / mov r2, #0x1c / bl memcpy` with `r1 = live+0x488`
— so the record's `+0x160` block and the live `+0x488` block are the same
thing, and `GetEquipmentArray` (`0x02052e2c`) proves that base with
`addne r0, r0, #0x88 / addne r0, r0, #0x400`.

| record | live | what |
|---|---|---|
| `+0x160` … `+0x173` | `+0x488` | ten `s16` equipment slots |
| `+0x174` bit 0 | `+0x49C` bit 0 | **the sex** — see [items](Items#sex) |
| `+0x174` bits 1-3 | | a colour applied to **every** body part; INFERRED skin |
| `+0x174` bits 4-7 | | a second colour, used only on the head |
| `+0x175` bits 0-3 | | added to the hair part's model number; also a head palette index |
| `+0x176` | `+0x49E` | `s16`, **not established**; set from a preset's `+0x0A` |
| `+0x178`, `+0x17A` | `+0x4A0` | **the build**: two `fx16`, 4096 = 1.0 |

**So sex does live in the record** — at `+0x174` bit 0, as a byte of the copied
block rather than a field of its own.

The build comes from a table of **ten pairs** at `0x020E6D98`, indexed
`sex * 5 + rand(5)`:

```
02010c58  bl   #0x20742fc          ; rand(5)
02010c5c  ldrb r2, [r4, #0x14]     ; record+0x174
02010c68  lsr  r2, r2, #0x1f       ; the sex bit
02010c6c  add  r2, r2, r2, lsl #2  ; sex * 5
02010c78  ldrsh r0, [r1, r2]
02010c7c  strh r0, [r4, #0x18]     ; record+0x178
```

Read out, in 4096ths: sex 0 gets (3768, 4255) (3637, 4136) (3850, 4014)
(4132, 3891) (3870, 3764); sex 1 gets (3768, 4177) (3641, 4091) (3809, 3973)
(4132, 3891) (3768, 3764) — five builds each, 0.888 to 1.039.

**The face is `+0x01` bits 0-3**, not part of that block. The filename builder
proves it: when a visible part's model id is 1000 the face index is added to it
(`02073078 cmp r0, #0x3e8 / ldrbeq r0, [fp, #0x56a] / addeq r5, r5, r0`), and
`live+0x56A` is what lands in `+0x01` bits 0-3.

The knob set is confirmed from the other side by overlay 15's debug viewer,
whose own labels are **`[Gender] [Face] [Eye Colour] [Skin Colour]
[Hairstyle] [Hair Colour]`**, then seven equipment slots, then `[Build]`.
**Which of the three colour fields is skin, hair and eye is not established.**

The visible-slot map at `0x020E6D74` pairs equipment slot to model part slot:
(0,0) (1,1) (4,5) (5,6) (6,7) (7,8) (8,9) — seven visible; slots 2 and 3 are
not drawn.

### The name at `+0x140`

**One byte per character, at most twelve, zero-terminated, `0xFF` a space.**
The bytes are a game-internal code indexing a glyph table, not ASCII or
Shift-JIS. `func_020426bc` packs (`0204274c strb r7, [sb], #1` — one byte out
per source character, `02042738 moveq r7, #0xff` for a space) and
`func_02042764` unpacks.

**The decisive instruction** is the initialiser's thirteen-iteration loop,
which writes all three per-vocation arrays together:

```
02086450  mla  r0, r5, r7, r8      ; r8 = rec+0x58, r7 = 0xC
02086454  add  r1, r6, r5, lsl #2
02086458  str  r4, [r1, #0x1c]     ; exp[v]   = 0
0208645c  add  r1, r6, r5
02086460  strb sb, [r1, #2]        ; level[v] = 1
02086464  strb r4, [r1, #0xf]      ; revoc[v] = 0
02086470  cmp  r5, #0xd            ; thirteen of them
```

and `GetExperience` (overlay 23, `0x021eea98`) reads the current vocation's:

```
021eea98  ldr r1, [r0, #0x150]   ; GameObject -> live struct
021eea9c  ldr r0, [r1, #0x950]   ; current vocation
021eeaa0  add r0, r1, r0, lsl #2
021eeaa4  ldr r0, [r0, #0x138]   ; exp[vocation]
```

**So changing vocation moves an index.** It does not re-read one number
against another [level table](Level-Tables): the old vocation's level and
experience sit untouched until the character changes back. Experience and
level are per vocation; **skill points are not** — one pool, spent per tree.

The live struct mirrors it: experience at `+0x138 + v*4`, level at
`+0x16C + v*2`, revocations at `+0x186 + v`, tree points at `+0x464 + tree`,
the pool at `+0x564`, the vocation at `+0x950` and its mask at `+0x954`. The
two are serialised back and forth by `func_02082d6c` and `func_020830cc`.

## Changing vocation: Alltrades Abbey

Read 24 September 2026. **It is a menu, dispatched exactly as the shop, the
inn and the church are** — not an event-script call.

`0x021a3544` in overlay 17 is the service dispatcher: it reads the first byte
of a service record and branches through a 79-entry table at `0x021a3564`.
**Service 46 (`0x2E`)** leads to `0x021c1404`, which calls overlay 3's step
dispatcher `0x02154af4`, whose seven-entry table at `0x0217f340` holds the
flow: slot 0 the change itself, slot 3 the confirmation, **slot 4
revocation**.

### What may be chosen

The list is built by `0x02156054`. **Six with no gate at all** — it writes 1
to 6 straight in (`mov r2, #1` … `cmp r2, #7 / blo`) — then six more from the
table at `0x0217f304`, **in the Abbey's own order, which is not numeric**:

```
7, 9, 8, 12, 10, 11
```

each appended only if the event flag **`0x113F + its number`** is set, read by
the plain bit test `0x0206dfb0`. So vocation 7 waits on flag `0x1146`.

In the [level tables'](Level-Tables) numbering the ungated six are Warrior,
Priest, Mage, Martial Artist, Thief and Minstrel — the six a game begins with
— and the gated six are the advanced ones. That the two lists fall out that
way is a good independent check on the numbering.

**Valid ids are 1 to 12.** The bounds check at `0x02155e14` is
`cmp r1,#0 / ble fail; cmp r1,#0xd / blt ok`, so **zero is rejected** — though
zero is what character creation writes, and zero is the Guardian, which is
what the Hero is before the game rather than a trade to take up.

### What changing costs

**Nothing is reset.** Level and experience are per vocation already, and the
apply routine `0x0215582c` touches neither. **Skill points survive** — neither
the pool at `+0xF4` nor the 27 tree bytes at `+0xF6` is touched by the apply
or by revocation; a whole-image scan found writers of the live tree bytes only
in the skill menu and the network apply.

There is **no level requirement, nothing consults the "has held" mask at
`+0x54`, and the vocation already held is not excluded** from the list.

**Equipment is kept per vocation.** The apply stows the outgoing vocation's
eight equipment slot ids into `live+0x4A4 + (v-1)*16` — the indexer
`0x02155e14` is `if (1 <= v && v < 13) return base + (v-1)*16`, so **zero is
not a vocation here either** — sets the new vocation, then re-equips the
incoming vocation's block.

### It does **not** check who may wear what

Corrected 24 September 2026; the earlier reading here said it dropped what the
new vocation or that character's sex may not wear, and that is wrong.
`0x0215582c` **never calls [`0x020dd4c4`](Items#who-may-wear-it)**, the
game's own "may this character equip this?" — the whole ARM9 has no caller of
it at all, and every overlay caller is an equip menu.

What it really does is two plain loops:

- `0x02155958`–`0x021559ac`: **everything worn goes into the bag,
  unconditionally.** It walks the `0xff`-terminated slot list at `0x0217f2c4`
  (`00 01 05 06 07 08 09 0a ff`) over the 0x20-byte equipment entries at
  `live+0x194 + i*0x20`, takes the item id at `+0x18` where the entry's
  category (`+0x08` low nibble) is 7 or less, and calls `0x0207c378` — bag,
  id, one.

```
02155968  ldr  r0, [r1, #8]
0215596c  lsl  r0, r0, #0x1c
02155970  lsr  r3, r0, #0x1c      ; the category
02155974  cmp  r3, #7
02155988  ldrsh r1, [r1, #0x18]   ; the item id
02155994  bl   #0x207c378         ; into the bag
021559a4  ldrb r1, [sb, r8]
021559a8  cmp  r1, #0xff          ; the slot list ends at 0xff
```

- `0x02155bcc`–`0x02155d70`: for each of the eight stored ids, **put it back
  on if the bag still holds one** (`0x0207c7a0` counting it), otherwise set the
  slot to −1. No vocation test, no sex test — the block was recorded while
  that vocation was worn, so what is in it was already legal.

There is **one** conditional removal, and it is narrow. At `0x02155b04` the
routine looks at stored index 7 — the accessory — and does nothing at all
unless it is **item 18048 (`0x4680`)** *and* the bag no longer holds one:

```
02155b04  ldrsh r0, [r6, #0xe]    ; stored[7], the accessory
02155b0c  cmp   r0, r1            ; r1 = 18048
02155b10  bne   #0x2155bc0        ; not it: no sweep at all
02155b1c  bl    #0x207c7a0        ; is one still in the bag?
02155b24  bne   #0x2155bc0        ; yes: no sweep
```

Only then does it clear the pieces whose **sex** lock that accessory had been
lifting — see [items](Items). So the rule is "18048 lets you wear the other
sex's things, and losing it takes them off", not "a new vocation undresses
you".

### Revocation

`0x02155e38`, reached from step slot 4. It touches **only the vocation
currently held**:

```
02155e5c  ldr  r5, [r1, #0x950]     ; the current vocation, and only it
02155e74  strh r2, [r0, #0x6c]      ; live+0x16C+v*2 -> level 1
02155e84  str  r2, [r0, #0x138]     ; live+0x138+v*4 -> experience 0
02155e8c  ldrb r0, [r2, r5] ; add r1, r0, #1 ; strb r1, [r2, r5]
02155e9c  cmp  r0, #0xa ; movhi r0, #0xa     ; the counter, capped at ten
```

So it resets that one vocation to level 1 and no experience, and increments
its counter at `+0x186+v` (the live mirror of `+0x0F+v`), **hard-capped at
ten**. Other vocations, skill points and equipment are untouched. A first-time
flag per vocation, `0x118B + v`, drives a message the first time.

Reaching ten matters: `0x02157c50` loops the twelve counters and, for each at
ten, collects an id and calls `0x021ed6cc`. **What that grants is not
established.**

### The record is not edited in place

Worth knowing for anyone tracing this: the flow changes the **live** mirror,
and `0x020830cc` copies it back to the record afterwards — vocation, mask,
then thirteen levels, thirteen revocation counts, thirteen experiences and
thirteen twelve-byte blocks. Looking for a writer of `rec+0x50` finds only
creation, a zero-init, a field copy and that sync.

## Not established

- **What writes the slots or the count.** Three reads of `+0x397c` exist in
  the ARM9 (`0x0200fde4`, `0x020100b4`, `0x0201064c`) and no write, in the
  ARM9 or in any of the 32 overlays; `+0x3980` has the one read above and
  nothing else. Searched as both `[base + 0x3000, #0x97c]` and
  `[base, #0x397c]` forms. Recruitment must reach them another way — through a
  held pointer, or as part of a bulk copy when a save is loaded.
- What bit `0x800` means, beyond fitting "in the party".
- That four is a limit rather than what the layout leaves room for.
- **Where the service record carrying byte `0x2E` lives** in map data, so
  nothing here ties the Abbey's flow to a map code by evidence.
- The vocation id → name mapping. No string fetch for vocation names appears
  in the list builder or the apply; whether `str_tm` 2100 on is the source is
  not established.
- What vocation id **0** means, beyond being what creation writes and what the
  Abbey refuses.
- What `0x021ed6cc` grants for a vocation at ten revocations.
- The contents of the thirteen twelve-byte blocks at `+0x58 + v*12`.
- What the thirteen `0x0C`-byte sub-records at `+0x58` hold.
- Whether thirteen character records is the whole roster or one page of it.
- How a battle's experience is split among the party. Only the award being
  read from `battleState + 0x5758 + i*4` (i < 4) was found, not how that word
  is computed.
- A story companion's vocation is still not in [attnpc](Attending-Characters),
  which has no such column.

## See also

- [Attending characters](Attending-Characters) — the five who go along for a
  stretch of the story, and their models, names and numbers
- [Level tables](Level-Tables) — thirteen files, one per vocation
- [Skill panels](Skill-Panels) — what the points in a tree buy
- [Text markup](Text-Markup) — where the leader decides who a speaker faces
- [Engine functions](Engine-Functions) — the event VM, whose `205` and `206`
  bring characters in and send them away
