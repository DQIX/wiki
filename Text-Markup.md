# Text markup

Every string the game shows a player is authored with `<…>` markup: `<PAGE>`,
`<ADD>`, `<CEN>`, `<YESNO>`, `<'e>`. The same vocabulary runs through
[event text](Event-Text), [character dialogue](Character-Dialogue),
[item descriptions](Item-Descriptions) and [battle text](Battle-Text).

**The markup is a source form.** It never reaches the screen. At runtime the
game compiles each authored string into a stream of 16-bit codes — ordinary
characters as themselves, and every tag as a single code in the `0xFF00` range
— and a separate interpreter walks that stream. So a tag's meaning is not in
the code that recognises its name; it is in whatever reads the code it
compiles to.

That is the whole reason this page exists. The tag names are the Japanese
authors' shorthand, and two of the most common ones do not mean what they
look like.

**Addresses on this page are into the USA release's ARM9**, unpacked (see
[DS compression](DS-Compression)), with the
[dqix-decomp](https://github.com/DQIX/dqix-decomp) names where they have been
added.

## The two parsers

A string passes through two passes, in this order.

**1. The leading-tag pass**, `TextConsumeLeadingTags` at **`0x0206a3c0`**.
It runs once, before compilation, and consumes a run of tags at the *front* of
the string, writing directly into the message-window object rather than
emitting anything. Its prologue is unconditional and matters more than any of
the tags it handles:

```
0206a3cc  mov  r0, #1
0206a3e0  strb r0, [r2, #0x9b6]   ; a turn is pending
0206a3e4..0206a45c                ; atan2(player - npc)
0206a460  str  r0, [r1, #0x844]   ; target angle = face the player
```

**Every message turns the speaker to face the player.** The tags below only
override that default.

Handled here: `<N_TURN>`, `<EXC>`, `<QES>`, `<ME_n>`, `<SE_n>`,
`<VOICE_VOLUME=n>`, `<RECT=…>`, `<WIN>`, `<CEN>`, `<GYOU=n>`, `<MOJI=w,h>`,
`<COLOR=…>`, `<SKIP>`. The chain is a sequence of prefix comparisons through
`func_020d857c`/`func_020d85dc`.

**2. The compiler**, `TextCompileTags` at **`0x0206a020`**. It walks the rest
of the string a character at a time:

- `\n` (the two characters `\` and `n`), CRLF, and a bare LF all compile to
  **`0xFF18`**, the newline code.
- ASCII space `0x20` becomes **`0xFF19`** in the glyph pass that follows.
- On `<` it finds the matching `>` and looks the name up in the tag table
  below, calling the handler it finds. The handler returns how many bytes it
  wrote.
- Five tags match a second list and are **dropped entirely** — scanned past
  and not emitted: `<INN=`, `<CHURCH=`, `<BANK>`, `<SHOP`, `RENKIN`
  (`sTextTagsDropped`, `0x020e7e74`). The services are read from the authored
  source by something upstream, never from the compiled stream.

## The tag table

`sTextTagTable` at **`0x020e7f84`**: 40 entries of

```c
struct TextTag {
    const char *name;                            // no '<'; includes the '>' where the tag has one
    int (*handler)(u16 **out, const char *arg);  // returns bytes written
};
```

terminated by a `{NULL, NULL}` pair at `0x020e80c4`.

Each plain handler is nine instructions and identical but for one literal:

```
0206980c  push {r3, lr}          ; <ADD>
02069810  ldr  r0, [r0]
02069814  ldr  r3, [pc, #0x14]   ; -> 0x02069830 = 0x0000ff0a
02069818  add  r1, sp, #0
0206981c  mov  r2, #2
02069820  strh r3, [sp]
02069824  bl   #0x2001a40        ; memcpy
02069828  mov  r0, #2            ; bytes written
0206982c  pop  {r3, pc}
```

### The codes, read from each handler's own literal

| code | tag | code | tag |
|---|---|---|---|
| `0xFF01` | `<END>` | `0xFF17` | `<YAME>` |
| `0xFF02` | `<END_R_TURN>` | `0xFF18` | newline (not a tag) |
| `0xFF03` | `<CLOSE>` | `0xFF19` | space (not a tag) |
| `0xFF04` | `<YESNO>` | `0xFF1A` | `<TIME=n>` |
| `0xFF05` | `<NOYES>` | `0xFF1B` | `<ALL_RECOVER=a,b,c>` |
| `0xFF06` | `<YESNO_NOTSE>` | `0xFF1C` | `<ST=a,b>` |
| `0xFF07` | `<YESNO_NOTSE_IIE>` | `0xFF1D` | `<PAD_WAIT>` |
| `0xFF08` | `<UKEYAME>` | `0xFF1E` | `<PAD_T=n>` |
| `0xFF0A` | `<ADD>` | `0xFF1F` | `<PAD_WAIT_NOCUR>` |
| `0xFF0B` | `<AUTO=n>` | `0xFF26` / `0xFF27` | `<WIN_ON>` / `<WIN_OFF>` |
| `0xFF0C` | `<PAGE_T=n>` | `0xFF28` / `0xFF29` | `<CEN_ON>` / `<CEN_OFF>` |
| `0xFF0D` | `<PAGE>` | `0xFF2A` | `<TURN=n>` |
| `0xFF0E` | `<SHAKE>` | `0xFF2B` | `<N_TURN>` |
| `0xFF0F` | `<QUEST_SE>` | `0xFF2C` | `<R_TURN>` |
| `0xFF10` | `<QUEST=n>` | `0xFF2D` | `<TURN_P>` |
| `0xFF11` | `<QUEST_HAN>` | `0xFF2E` | `<EXC>` |
| `0xFF12` | `</QUEST>` | `0xFF2F` | `<QES>` |
| `0xFF13` | `<QUEST_FAILED>` | `0xFF34 + n` | `<ME_n>` |
| `0xFF14` / `0xFF15` | `<YES>` / `<NO>` | `0xFF4B` | `<SE_n>` |
| `0xFF16` | `<UKE>` | `0xFFD0 + i` / `0xFFE0 + i` | `<LB_x>` / `<JP_x>` |

`0xFF09` has no tag. `0xFF20`–`0xFF25` are discussed under *Not established*.

### `<LB_x>` and `<JP_x>` are a range, not a prefix

Both handlers read the single character after the underscore, subtract `0x40`
— the character before `A` — and add it to a base:

```
02069bb0  ldrsb r1, [r1]
02069bb4  ldr   r2, [pc, #0x24]  ; -> 0x02069be0 = 0x0000ffd0
02069bbc  sub   r1, r1, #0x40
02069bc4  add   r3, r2, r1, lsr #16
```

So `<LB_A>` is `0xFFD1` and `<JP_A>` is `0xFFE1`, and a label is **one letter**.
The layout pass at `0x0206ab3c` resolves a jump by `eor`-ing off the `0xFFE0`
base to get the index and rebuilding the matching `0xFFD0 + i`, then searching
the stream for it. `<JP_x>` jumps to `<LB_x>`.

### An argument never enters the stream

Every `=` tag parses its argument at compile time with `TextParseTagArgs`
(`0x020696bc`), which accepts **comma-separated decimal integers with an
optional leading `-`** and stops at `>`. It then writes the value into a field
of the message-window object, and emits only the bare two-byte code. The
clearest case is `<VOICE_VOLUME=n>`:

```
0206a1b0  bl   #0x2005a94       ; atoi
0206a1d8  strb r0, [r1, #0x94a] ; -> win + 0x1000 + 0x94a + slot
0206a1dc  add  r0, r6, #0x4d
0206a1e0  add  r3, r0, #0xff00  ; the code is 0xFF4D + slot
0206a210  and  r6, r0, #3       ; the slot rotates, four deep
```

Two consequences follow, and they are real constraints on the format:

- **Only the last `<QUEST=n>`, `<AUTO=n>` or `<PAGE_T=n>` in a message takes
  effect**, because each overwrites a single field.
- `<ST=a,b>` and `<VOICE_VOLUME=n>` have **four slots each**, round-robin; a
  fifth overwrites the first.

Confirmation that nothing is inline: `MessageCodeOperandCount` (`0x0206abf8`)
returns a non-zero trailing-halfword count only for `0xFF20`–`0xFF25`, and
zero for every other code.

## What the codes do

The interpreter is `MessageInterpretCodes` at **`0x02065990`–`0x02066a60`**.
It is worth knowing *why* these codes look dead to a search: **it loads one
literal, `0xFF4B` at `0x02066958`, and derives every comparand by
subtraction.** There is no `cmp rX, #0xff0a` anywhere in the binary.

### `<ADD>` `0xFF0A` — the commonest tag, and not an "add"

1,724 uses across 429 of the 687 events with text. Its arm:

```
02066054  mov r1, #3
0206605c  str r1, [sl, #0x9a0]   ; wait-state 3
02066060  bl  #0x2045688         ; stop the typing sound
02066064  b   #0x2066a5c         ; return without advancing the cursor
```

**Wait-state 3 is written nowhere else in the ARM9.** The payoff is in
`MessageShow` (`0x0204500c`) at `0x0204513c`, which branches on it:

```
0204513c  ldr r0, [sl, #0x9a0]
02045140  cmp r0, #3
02045144  bne #0x204515c          ; normal path: tear the window down and rebuild
02045154  bl  #0x2044f3c          ; APPEND path
```

The append path sets a continuation flag and rebuilds the text buffer without
the teardown, so the drawn text, the current line and the scroll position
survive. **`<ADD>` ends a message and leaves the window standing, so that the
next message is drawn into it.** It is punctuation between messages, and it
puts nothing in the text — which is why reading the text never revealed it.

The wait arrow animates during the pause, and a button press alone does not
resume: the state-3 button handler (`0x020442a0`) does not advance the cursor.
Only the next message does.

### `<N_TURN>` `0xFF2B` — "no turn"

208 uses through NPC dialogue, and **its compiled code has no consumer
anywhere** in the ARM9 or the overlays. It is handled in the leading-tag pass
instead, and against that pass's face-the-player default it means *no* turn:

```
0206a498  ldr  r2, [r0, #0x83c]   ; the facing saved when the talk opened
0206a4a0  str  r2, [r0, #0x844]
0206a4a4  strb r1, [r0, #0x9b6]   ; r1 = 0 - the pending-turn flag is CLEARED
```

**INFERRED:** that "N" is "no". The mechanism is confirmed; the expansion of
the abbreviation is not.

### The rest of the turn family

The window keeps the actor's handle at `+0x1838`, the facing it had when the
conversation opened at `+0x183c`, a pending target angle at `+0x1844`, and a
"turning" flag at `+0x19b6`. The stepper is `0x020656e4`.

| tag | code | what it does |
|---|---|---|
| `<TURN_P>` | `0xFF2D` | face the party leader, by `atan2(leader − npc)` |
| `<R_TURN>` | `0xFF2C` | return to the facing at `+0x183c`, and wait for the rotation |
| `<END_R_TURN>` | `0xFF02` | end the message as `<END>` does, **and** restore the facing without waiting |
| `<TURN=n>` | `0xFF2A` | an absolute angle: `n` multiplied by `4096.0f` and truncated |

`<TURN=n>`'s `4096` and the wrap in `fix32ReduceAngle0To2Pi` (`0x02030f30`,
which wraps modulo `0x6488` = 2π × 4096) agree that **engine angles here are
fx32 radians**, not degrees.

### `<EXC>` and `<QES>` — the balloons

Both write `60` to `+0x959` and `1` to `+0x9b7`, and differ only in a kind
byte at `+0x95c` — `0` and `1` — and the sound asked for, `6` and `28`. Sixty
frames is a second. **INFERRED**, from the names and the pairing, that these
are the `!` and `?` balloons over a character's head.

### `<SHAKE>` `0xFF0E` — the message window, not the screen

The arm sets `+0x19c0 = 1` and `+0x195d = 30` frames. The offset comes from
two four-byte signed tables stepped on `timer & 3`:

| table | address | bytes |
|---|---|---|
| x | `0x020e7e10` | `{-2, 0, 0, 0}` |
| y | `0x020e7e1c` | `{0, 0, -3, 0}` |

Applied to the window rect at `0x02043b6c`, so frame and text move together.
Amplitude and duration are hardcoded; the tag takes no argument.

### `<TIME=n>` `0xFF1A` — a pause

The stored count is decremented once per interpreter tick and the cursor holds
on the code until it reaches zero. It is **not** a typing speed: that is
`<AUTO=n>` `0xFF0B` (`win+0x95e`) and `<PAGE_T=n>` `0xFF0C` (`win+0x960`).

### The quest family

`<QUEST=n>` `0xFF10` binds a quest to the window. The compiler turns the
number into the index of its slot via `QuestNumberToSlot` (`0x020965c0`, a
linear scan of a 204-entry byte array returning `0xFF` when absent) and
stashes it; the interpreter copies it onto the window at `0x020668e8`. The
rest act on whatever is bound:

| tag | code | what it does |
|---|---|---|
| `<QUEST_HAN>` | `0xFF11` | opens a banner; sets bit `0x200` in `win+0xda`, sound id `0x33` |
| `<QUEST_FAILED>` | `0xFF13` | the same code path, plus bit `0x100`, sound id `0x44` |
| `</QUEST>` | `0xFF12` | closes it |
| `<QUEST_SE>` | `0xFF0F` | writes a packed word at `quests + 0x178 + 4×number` and asks for a fanfare, sound id `0x32` |

**What `HAN` abbreviates is not established.** It is symmetric with
`QUEST_FAILED` and differs by one bit and a sound id, which is suggestive and
no more.

### `<ALL_RECOVER=a,b,c>` `0xFF1B` — not a text tag at all

The compiler stores `a != 0` at `+0x19c6`, `b != 0` at `+0x19c7` and `c` at
`+0x187e`; the interpreter packs all three and calls into an overlay. It is a
**gameplay action written where a line of dialogue would go** — one event's
entire English message is the single string `<ALL_RECOVER=0,0,999>`. What the
two flags select is **not established**.

### `<ME_n>` and `<SE_n>` — sound in the text

`<ME_n>` compiles to `0xFF34 + n`, the number parsed as decimal:

```
0206a25c  add r0, r0, #0x334
0206a260  add r3, r0, #0xfc00    ; 0xFF34 + n
```

`<SE_n>` compiles to `0xFF4B`, its number looked up in a `0xFFFF`-terminated
list at `0x020e7e04+0x24`. **That list has exactly one entry, `14`** — and
`<SE_014>` is the only effect the cartridge's English text uses. The compiler
and the content agree.

### The window tags in the leading pass

| tag | what it writes |
|---|---|
| `<WIN>` | `win+0x19b1 = 0` — the same byte [engine function](Engine-Functions) `410` writes |
| `<CEN>` | `win+0x19b8 = 1` — centres the box; the game's narration card |
| `<GYOU=n>` | `win+0x9a4 = max(n, 1)` — 行, *line*: how many lines the box has |
| `<MOJI=w,h>` | `win+0x1860 = w`, `win+0x1864 = h`, **defaulting to 12 and 16** when either is zero or less — 文字, *character*: the font cell |
| `<COLOR=…>` | each component parsed as decimal and clamped to `0`–`255` |

The Japanese names here are a useful reminder that the vocabulary is the
authors' and not the localisers'.

### Prompts, settled

[Event text](Event-Text) reads `<UKE>` and `<YAME>` as *accept* and *decline*
and marks it INFERRED. **The codes settle it without reference to the text**:
`<YES>` `0xFF14`, `<NO>` `0xFF15`, `<UKE>` `0xFF16`, `<YAME>` `0xFF17` are
four consecutive values in the order their two prompts introduce them —
`<YESNO>` `0xFF04` and `<UKEYAME>` `0xFF08`. The pairing is the compiler's.

## The line-count scan

`MessageCountLines` (`0x0206b6b8`) loads `0xFF01` and forms its other
comparands by addition — `+0xB`, `+0xC`, `+0x17`. It **stops** on `0xFF01`
(`<END>`), `0xFF0C` (`<PAGE_T=>`) and `0xFF0D` (`<PAGE>`), and **counts**
`0xFF18`, the newline. It then multiplies `lines − 1` by the `<MOJI=>` line
height to centre the window vertically.

## Evidence

| what | where |
|---|---|
| tag table | USA ARM9 `0x020e7f84`, 40 entries, `{NULL, NULL}` at `0x020e80c4` |
| dropped-tag list | USA ARM9 `0x020e7e74`, 5 entries |
| shake offsets | USA ARM9 `0x020e7e10` (x), `0x020e7e1c` (y), 4 signed bytes each |
| the codes | each read from its own handler's literal pool, not from a table of names |
| the interpreter | USA ARM9 `0x02065990`–`0x02066a60`, comparands derived from `0xFF4B` at `0x02066958` |
| the compiler | USA ARM9 `0x0206a020`; the leading pass `0x0206a3c0` |
| tag counts | 5,157 English event texts across 687 events, counted by running every one through a reimplementation |

## Not established

- **What emits `0xFF20`–`0xFF25`.** Nothing in the ARM9 or any overlay does.
  They are the only codes that carry inline operands — one halfword for
  `0xFF20`, `0xFF21`, `0xFF23`, `0xFF24` and two for `0xFF22`, `0xFF25` — and
  only two have consumers: `0xFF20` raises the running x to at least its
  operand, and `0xFF23` advances x by it. An authoring path not present in
  this build is the obvious guess and stays a guess.
- **`0xFF09`**, which no tag emits.
- What `HAN` in `<QUEST_HAN>` abbreviates, and what the quest banner draws.
- What the two flags of `<ALL_RECOVER=>` select.
- The direction of `<WIN_ON>` / `<WIN_OFF>` and `<CEN_ON>` / `<CEN_OFF>`.
  `<WIN>` writes `0` to the frame byte and `<CEN>` writes `1` to the centring
  byte, and the pairs plainly toggle those, but the consumers have not been
  read.
- `<.|>` and `<.|.|>`, which the English text uses twelve times and **the tag
  table has no entry for**. They belong to a pass not yet found.

## A caution

The table at **`0x020e7efc`**, immediately before the tag table, holds
`{name, value}` pairs — `DEF_`, `INDEF_`, `ART_`, `SGL_`, `PLR_`, `NOM_`,
`GEN_`, `DAT_`, `ACC_`, `I_NAME`, `M_NAME`, `ACTOR`, `TARGET`, `ACTION`,
`REFLEX`. It is **not** part of the tag table and not a sub-table of it,
despite the adjacency; it is walked from `0x02069234` as a separate
ASCII-to-ASCII substitution pass. Its `0xFF04`–`0xFF09` values look like they
collide with `<YESNO>`…`<UKEYAME>` and do not, because they are never stream
codes. See [Articles](Articles).

## See also

- [Event text](Event-Text) — the files this markup is authored in
- [Character dialogue](Character-Dialogue) — the talk files, same vocabulary
- [Item descriptions](Item-Descriptions), [Battle text](Battle-Text) — likewise
- [Articles](Articles) — the grammar substitution pass
- [Bitmap font](Bitmap-Font) — what the compiled codes are eventually drawn with
- [Engine functions](Engine-Functions) — the event VM, which reaches some of
  the same window fields by opcode rather than by tag
