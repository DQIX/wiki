# Event Scripts (`.stb`, magic `SB2`)

`.stb` files are compiled scripts for a stack machine. Each event has one, next to its text (see [Event-Text](Event-Text)). A file has a header, a table of sections, and a shared library block. Every section is a routine of three-word instructions. The container, the routine header and every opcode used by the event scripts have been read, and each opcode's evidence is given below. The engine functions scripts call are mostly **not established**; a few readings are **INFERRED**.

Nothing about this format is published. Everything here was read from the scripts themselves. All counts are from the European release (game code YDQP).

## Where the files are

There are 736 `.stb` files:

| folder | count | notes |
|---|---|---|
| `/data/event` | 523 | one per event |
| `/data/evspt_lv5` | 165 | these carry cutscene staging: model files, motions, cameras. 164 of them are events of their own (see [Event-Text](Event-Text)) |
| `/data/scenario` | 33 | not described here |
| `/data/menu` | 13 | not described here |
| `/data/event_lv5` | 2 | not described here |

The scripts in both event folders were read whole: container, routines and code. Unless stated otherwise, the numbers below are over the 523 event scripts in `/data/event`.

## Layout

| offset | type | meaning |
|---|---|---|
| `+0x00` | `char[4]` | `SB2\0` |
| `+0x04` | `u32` | size of the shared block (below). `0x1500` on 522 of the 523 event scripts |
| `+0x08` | `u32` | end of the section table: its start plus 8 × the count, on 523 of 523 |
| `+0x0C` | `u32` | start of the section table: `0x40` on all 736 |
| `+0x10` | `u32` | number of sections |
| `+0x14` | | zero, except `+0x18` |
| `+0x18` | | 0 to 5 on 122 files. Meaning not established |
| `+0x40` | `u32[2]` × n | the sections: a number, then an offset into the file |

**Sections.** On all 523 event scripts, the sections are in rising offset order and start after the table and the shared block. On 522 scripts they are numbered 200, 300 and 100, in that order. The other script has 200, 201, 300, 301, 100 and 101. Section 100 is the largest, with a median size of 3,632 bytes. Each section is a routine whose first word is its entry address (see [The code](#the-code)).

**The shared block is byte-identical on 522 of the 523 scripts.** It is common to every event, not part of any one event.

## What a script names

**A script names its own messages.** An event's text carries 3,649 message numbers, and 3,522 of them occur as a word in the event's own script, mostly in section 100. For comparison, only 43 of 3,649 control numbers that the text does not carry occur this way.

The words around a message number are regular. In 7,692 of 8,963 occurrences, the two words before it are `3, 1`. This reads as a typed operand. What the types are is not established.

**A script does not name maps or other events.**

- Event numbers occur as words in scripts no more often than control numbers do: 1,655 against 1,514.
- No village event names an Angel Falls map id.

What a script does carry as strings:

- its cast, by model file (`chara_sub/s016.chr`)
- motions (`stand`, `walk`)
- fades (`EFADE`)
- in some scripts, its own name in brackets

Which event runs when is decided elsewhere. See [Triggers](Triggers).

## The code

**Code addresses count from `+0x08`**, the end of the section table. Jump targets and routine call targets are offsets from there. This page calls that point the *code base*.

### Routines

**A routine is 14 header words followed by instructions, ending in a return.** Sections are routines. So is everything in the shared block, and everything after each section.

| offset | meaning |
|---|---|
| `+0x00` | entry address: the routine's own offset minus the code base, plus `0x38` |
| `+0x04` | zero wherever seen |
| `+0x08` | how many locals it has, parameters included |
| `+0x0C` | how many parameters it takes |
| `+0x10` .. `+0x37` | a 1 per parameter, where there are any. Meaning not established |

**The entry address is what identifies a routine.** With the usual three sections, the code base is `0x58`, so the entry word first read as "own offset minus `0x20`". But `ev03130`, the one event with six sections, has its code base at `0x70`. It would not parse until the rule was taken to be the entry address.

**The parameter count is confirmed by the shared routines' bodies.** Each one reads exactly its first *parameters* locals as inputs. The message routine at `+0xDE4` reads 2 of its 3 locals as inputs. The wait routine at `+0x0` reads 1 of 1.

### Instructions

**An instruction is three `u32`s**: an opcode and two arguments. Walking every section, and every routine it calls, down to its return finds only the opcodes below. No opcode is left unread, on all 523 scripts.

In the table, the letters after an opcode name its argument words. The first argument of `0x13` is written `_`: its meaning is not established.

| op | reads as | evidence |
|---|---|---|
| `0x03 t v` | push a constant. `t` is the type: 1 an integer, 2 a float's bits, 3 a string's offset **counted from the code base** | these are the only types, over 153,272 pushes. Floats read as coordinates and strings as names (see [Strings](#strings)) |
| `0x01 i s` | push variable `i` of scope `s` | |
| `0x02 i s` | push a reference to variable `i` of scope `s` | taken by stores, and by engine functions that answer through an argument |
| `0x05` | store: pop the value and the reference, then push the value back | `&0 0 store pop` |
| `0x04` | drop the top value | follows every routine call whose answer is not used |
| `0x06` | add | `&0 L0 1 add store` counts up; `4 1 add 2 add` builds 7 |
| `0x07` | subtract | the wait routine counts down with it |
| `0x08` | multiply | found only in `/data/evspt_lv5`'s 164 scripts, where it is common: 4,777 uses, in 127 scripts. **4,761 follow `1 negate`**, so they multiply a value by −1. The rest are `3.14 1.5` (a three-quarter turn in radians), `2.0 3.14` (a whole turn), and `30 0.2` |
| `0x09` | divide: the second value by the top | also only in `/data/evspt_lv5`, 9 times. `4.5 180 divide 3.14 multiply` turns 4.5° into radians; another is `0.95 L6 divide`. Every use divides a float, so what integer division does is not seen |
| `0x0B` | negate the top value | follows coordinates, which are stored positive |
| `0x0E c` | compare. `c` is 40 for `==`, 41 for `!=`, and 42–45 for the ordered comparisons | `==` is known from its use in "wait while busy is 1". The ordered ones are **INFERRED** to follow C's order |
| `0x0F` | return, with the top value | ends every routine |
| `0x10 t` | jump | every target is inside its own routine |
| `0x11 t w` | pop, and jump when the value's truth is `w` | loop exits |
| `0x12 t w` | short-circuit: when the value's truth is `w`, jump and keep the value; otherwise drop it | `a == 1 ‖ a == 2`. **INFERRED** |
| `0x13 _ t` | call the routine at `t` | 11,515 calls, **every one lands on a routine header** |
| `0x14 1` | drop a string: the developers' notes, in Shift-JIS | |
| `0x15 n` | invoke an engine function with `n` values; the first value is the function's number | see [Engine functions](#engine-functions) |
| `0x16 n` | nothing: a label | always at a jump's target |
| `0x17` | wait for the next frame | inside every waiting loop |
| `0x19` | or | only ever used on flags, as in `4 \| 16` and `1 \| 16`. **INFERRED** |
| `0x1A` | not | appears before a jump on an engine function's answer |

**Opcodes found only in the second folder.** `0x08` and `0x09` belong to `/data/evspt_lv5`. In the 523 scripts of `/data/event`, `0x08` appears only in one shared routine that no event calls.

The second folder also has `0x1D` and `0x1E`, twice each, and only in `ev29350`:

- `r θ 0x1E multiply cx add`
- the same with `0x1D` and `cz`

These look like the two coordinates of a point on a circle: one a cosine and the other a sine. Which is which is not settled, and neither opcode has been read.

### Strings

**A string's offset counts from the code base**, just like jumps and routine calls. The 523 event scripts contain 9,273 string pushes:

- 3,305 go straight to a note (`0x14`), in Shift-JIS.
- **Every one of the other 5,968 lands on the start of a string** when counted from the code base. Examples: `stand` 2,540 times, `walk` 685 times, `chara_sub/s011.chr`, `event_lv5/ev02010s016.chr`.

### Scopes

| scope | meaning |
|---|---|
| 1 | the routine's own locals |
| 8 | the event's variables, shared by its sections. One section writes a character's position into them and another reads it back. **INFERRED** |
| 64 | the game's variables. `L0@64 == 0` appears beside a note about death and revival. **INFERRED** |

### Engine functions

**Engine functions are numbered in hundreds, and scripts write the number as a sum.** For example, `200 9 add` is function 209. With `add` read as a real add, **every invoke finds its `n` values**.

**What the numbers reach has since been read from the code** — the table they index, and about twenty of the functions themselves. That is [Engine functions](Engine-Functions); the readings below are the older ones, taken from the arguments each function is handed, and are **INFERRED** where that page does not say otherwise.

The hundreds group what the functions work on:

| group | area | readings |
|---|---|---|
| 200s | the cast | 206 places a character; 207 walks one somewhere over a number of frames; 209 turns one; 210 plays a motion by name. 203, 205, 212, 214–218 and 543/544 are read — see [Engine functions](Engine-Functions) |
| 300s | the camera | 303 sets where the camera looks; 310 takes a yaw, a rise and a straight-line distance to look from |
| 400s | messages | 400 shows a message; 405 answers through its argument whether a message is still up |
| 500s | the event and the screen | 566 and 567 set a character's model pack and motion pack. 502, 503, 506, 507, 508, 532, 540, 563 and 597 are read — see [Engine functions](Engine-Functions) |
| 700s | sound | |

**The camera, read further (INFERRED).** These readings come from how the calls agree with each other across every script run.

- **302 is where the camera is.** Within a shot, 302 and 303 give the same yaw, rise and distance that 310 does. They agree on **1,024 of 1,032** shots in the second folder, and on 9 of 14 in the first. This holds **when the distance is the straight line from target to eye**.
- **304 moves both the camera and the target.** Its arguments are the camera, then the target, then the frame count. Its camera and target agree with the 311 call beside it (yaw, rise, distance, frames) on 506 of 511.
- **321 moves where the camera looks over a number of frames.** This is read from its shape alone: a point and a count, like 304's. There is no other call for it to agree with.

**The second event folder waits its own way (INFERRED).** Each of its 164 scripts has one wait routine of 27 instructions. The routine doubles the frames asked for. Then, each frame, it calls function 840 with a reference, and takes what 840 wrote off the count. The first folder's wait takes 1 off instead. Function 840 is called nowhere else, in either folder.

The two folders ask for waits of the same sizes. The commonest are 1, 10, 5, 30, 20 and 15 in both. The medians are 10 and 12, over 7,714 and 5,182 waits. So 840 reads as the frame's length in half-frames, and the game answers 2.

### The shared block

**The shared block is a library of 18 routines**, with the same bytes in 522 of the 523 events.

| routine | what it does | calls |
|---|---|---|
| `+0x0` | wait a number of frames | 6,982 |
| `+0xDE4` | show a message and wait for it to be read, handing a second value to function 554 | 2,352 |
| `+0xC68` | the same, without the second value | 898 |
| `+0x9FC` | choose between two messages by what function 560 answers | 26 |

The rest wait for a fade, a sound or a character's walk to finish, and a few handle motions.

### Section order

**Which section runs when is not established.** One working order is 200, then 100, then 300. Under that reading:

- 200 loads the cast and sets the event's options.
- 100 is the scene.
- 300 hands control back.

The scripts were run in that order against a stand-in engine that answers every function with 0. **504 of the 523 events run to their end.** The other 19 are still waiting after 20,000 frames, for answers that stand-in never gives.

## Earlier readings

- **String offsets counted from the file's start.** Counted this way, only 283 string pushes land on a string at all, and those by chance (`walk` where `stand` belongs, `head` for `kiki`). The rest read as the tail of a name (`tand`, `ara_sub/s011.chr`) or as nothing. Counting from the code base fixed this.
- **Entry address as "own offset minus `0x20`".** This works only when the code base is `0x58`, and fails on `ev03130` (see [Routines](#routines)).
- **`add` as a "begin call" marker.** The `add` that builds an engine function's number was first taken for a marker. 98% of invokes fitted that reading. Read as a real add, all of them fit.
- **Camera distance across the ground.** Read as the distance across the ground, 302/303 and 310 agree on only 539 shots. Read as the straight-line distance, they agree on 1,024 of 1,032.

## Not established

- `+0x18` in the header (0 to 5 on 122 files).
- Header words `+0x10` .. `+0x37` of a routine, beyond there being a 1 per parameter.
- What the operand types are in the `3, 1` pattern before message numbers.
- The meaning of `0x1D` and `0x1E`, including which is the cosine and which the sine.
- What integer division does.
- The ordered comparisons 42–45, beyond the **INFERRED** C order.
- Most engine functions: about 126 numbers the scripts call are still unread. Twenty or so are read from the code — see [Engine functions](Engine-Functions) — and the rest of the readings above are **INFERRED**.
- Which section runs when.
- The `.stb` files in `/data/scenario`, `/data/menu` and `/data/event_lv5`.

## See also

- [Engine functions](Engine-Functions): what the numbers a script invokes actually do
- [Event-Text](Event-Text): the messages a script names
- [Triggers](Triggers): which event runs when
- [Character-Dialogue](Character-Dialogue)
- [GPC2](GPC2): the archives events unpack from
- [NSBMD](NSBMD)
- [Motion-Tables](Motion-Tables)
