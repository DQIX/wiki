# Engine functions — what a script's numbers do

An [event script](Event-Scripts) calls the engine by number: the `0x15` invoke takes a function number off the stack and then its arguments. This page is about **the code those numbers reach**, where [Event-Scripts](Event-Scripts) is about the file and the machine.

Everything here was read from the disassembled binaries of the **USA release**, with the symbol names of the DQIX decompilation project. Readings marked INFERRED come from the arguments a function is handed and where its calls stand, not from its code.

## How a number becomes code

**A direct index, and no searching.** The VM's invoke (overlay 17, `0x021d4bc8`) is:

```
if (number < 0 || number >= vm->count) return;   // count is 1000
fn = vm->fnTable[number];
if (fn == NULL) return;                          // an unregistered number does nothing
fn(&args[1], argc - 1);
```

So an engine function is `int fn(Value* args, int argc)`, and a number nothing has registered is silently a no-op.

**A `Value` is 8 bytes**: a tag at `+0x00` — 0 an integer, 1 a float, 3 a reference — and the value at `+0x04`. The accessors are `ToInt` (`0x021d60f4`), `ToFloat` (`0x021d6110`), the raw/string reader (`0x021d612c`) and the store-through-a-reference (`0x021d6134`, and `0x021d6148` beside it). A store writes the payload word only where the tag is 3, and **does not change the destination's type** — so a script's variable must already be of the type the function hands back.

**Overlay 1 fills the table** from a static array of `{function, number}` pairs at `0x02164d6c`, **304 entries**, ending `{0, -1}` at `0x021656ec`. The numbers registered are 0–9, 100–122, 200–240, 300–328, 400–421, 500–522, 530–603, 700–738 and 800–845. Two other modules register their own tables into the same VM for other kinds of script: the ARM9 at `0x0209dcbc` and overlay 23 at `0x021eb070`. **504 and 505 are not registered at all**, and the "append" twin of 506 at `0x0215ed74` is in the binary but unreachable.

## A character's commands

A character in a scene is an **actor**: `GetEventActor` (`0x0215ab20`) bounds an index to 24 and returns `base + index × 0x588`.

**The 200-group does not act at once.** Each handler queues a record on one of the actor's **eight command channels** (head and tail pairs at `+0x08` through `+0x44`); a per-actor tick (`0x0215a134`) walks the channels and dispatches each record's type through a table at `0x02164ca4`, and a handler that returns nonzero holds its channel for the frame. After the commands run, the tick copies the actor's position (`+0x74`) into `Object3D::position_` and its rotation (`+0x80`) into `Object3D::rotation_`.

**The engine's angles are fixed-point radians.** `fix32ReduceAngle0To2Pi` (`0x02030f30`) wraps one modulo **`0x6488`**, which is 25,736 — 2π × 4096 — and the camera's own yaw is wrapped by the same constant inline (`0x02158120`). `532`, the field of view, is the exception: it takes **degrees** and converts them, multiplying by `0x47 / 4096` before any sine is taken (`Camera_SetFov`, `0x0202e9a4`). That constant is 0.0173340, against π/180 = 0.0174533 — the game's degree is 0.68% short of a real one.

*(An earlier revision of this page said the engine's angles were degrees, on the strength of `532` alone. `532` is the one function that isn't.)*

## The waypoint path — 214, 215, 216, 217

One feature: a spline walk, the many-point counterpart of `207`. They share a channel with `206` and `207` and work on an object at the actor's `+0x11C` holding sixteen points, a speed and a curve.

| fn | handed | what it does |
|---|---|---|
| 214 | character | **resets** the path: the sixteen points, the speed, the curve and its flags (`0x02157908`) |
| 216 | character, x, y, z | **appends a point**, each float × 4,096 into fixed point. **The fourth and fifth arguments are read by nothing.** Past sixteen points it drops them silently (`0x02157964`) |
| 215 | character, speed | **sets the speed**; the path's length over it is how long the walk takes (`0x021579ac`) |
| 217 | character | **runs it, and waits**: builds the curve, then each frame samples it into the character's position and facing until it ends (`0x0215944c`) |

The curve duplicates its first and last control points, which is Catmull-Rom's shape. On the cartridge: 1,153 calls across 65 events, with 214, 215 and 217 called about 129 times each — once a path — and 216 767 times, six or so points apiece. A path's first point is nearly always where `206` has just put the character. Six paths hand it more than sixteen points, one of them 22, so the drop is not theoretical.

**Not read**: what the duration is counted in — the game divides the length by the speed and hands the answer to the curve, whose time base was not followed.

## Staging a scene's cast — 502, 503, 506, 507, 508, and 203, 205, 212

Eight numbers that stand together in the same 118 events. They load the models a scene needs and bind them to its characters.

| fn | handed | what it does |
|---|---|---|
| 502 | partition, reset? | makes one of `GameResources`' **33 VRAM partitions** current, emptying it first unless told not to (`0x0215eab0`) |
| 506 | 1–3 names | **queues files on the background loader**: `chara/p_…` out of `chara_pc.gp2`, a `.mon` out of `enemy.gp2`, anything else as `data/<name>` (`0x0215ed2c`) |
| 507 | reference | **1 while any queued file is still loading, 0 once all are done or failed** — the script spins on it (`0x0215edb8`) |
| 503 | partition | writes the partition's use back, closing the bracket (`0x0215eb3c`) |
| 508 | — | removes every queued task and empties the list (`0x0215ef44`) |
| 203 | character | **unbinds** a character from its display entry (`−1`) and zeroes its movement state (`0x0215bf34`) |
| 205 | character, entry | **points a character at a display entry** (`0x0215bf94`) |
| 212 | slot | **destroys** the model object in a slot, nulls it, and clears every display entry pointing at it (`0x0215b9c4`) |

The order is `502` → `506` → spin on `507` → `200` builds an `Object3D` from the loaded bytes → `202` gives a display entry that object → `205` points a character at the entry → `503` → `508`; and on the way out `212` and `203`.

**The script's model slots are `GameState::objects_[0xA0..0xBF]`** — 32 of them, matching the 32-entry display table. A negative script argument maps as `−n + 0x9F`, so `-1` is `0xA0`; `200` rejects anything outside that range.

**A character and its display entry are always the same number**: all 1,324 calls of `205` pass the same value twice.

## The camera's field of view — 532

`532` sets the active camera's field of view and takes an integer or a float. **Its number is the half-angle, in degrees.** The engine takes the sine and cosine of the number as it stands (`Camera_SetFov`, `0x0202e9a4`, whose `71/4096` is a degree in radians), keeps both, and hands them to the DS's perspective call — which divides the cosine by the sine, putting `cot(angle)` in the matrix slot that holds `cot(fov / 2)`. So the **15** that 1,668 of its 2,477 calls pass is a vertical field of **30°**; the scenes range from 4 to 35, which is 8° to 70°.

`530` and `531` (`0x0215f854`, `0x0215f930`) make a camera and put the old one back, so a scene's field of view lasts as long as its camera does.

## Waiting, reading a character, doors, and the rest

| fn | handed | what it does |
|---|---|---|
| 8, 9 | — | **set and clear one global flag** at `GameState+0x5CAC` (`0x0215b040`, `0x0215b058`). Clearing it lets entering a zone apply its masks of already-opened chests and doors. Every event's section 200 clears it; what the flag is *for* is **not established** |
| 218 | character, ticks | **waits**, on the same channel the character's motions run on, counting in the actor's `+0x50` (`0x0215c544`) |
| 543 | character, 3 references | **where the character is** — the vector that goes to `Object3D::position_` (`0x0215ff10`) |
| 544 | character, 3 references | **which way it faces** — the vector that goes to `Object3D::rotation_`, in degrees (`0x0215ffc0`) |
| 540 | group, object | **opens a door placement** in the zone's list: swings it ±35° or ±28°, or slides it along its facing where a flag says so, and plays a sound the door's material picks (`0x0215fa40`). 584, 585 and 586 are the same function with another swing |
| 563 | group, object | **closes it again** (`0x02160b08`). Its third argument is read and discarded |
| 597 | reference | the **lighting's time of day**, `LightingManager::timeOfDayIndex_` — a slot of 0 to 6 (`0x02161ce8`) |
| 800 | reference | **1 where the Hero is a man**, 0 where a woman, from a bit of the protagonist's record (`0x02161d54`). The paired `sg00m.chr` and `sg00w.chr` in `data/chara` are the same distinction. `827` is the identical function over party member 0 |

That a placement 540 opens is a **door** is INFERRED — from the swing, the material-indexed sound, and the mask of doors applied beside the mask of opened chests when a zone is entered.

## The brightness family — 100 to 122

Eighteen numbers, one block. The handlers from `109` up are all the same three-instruction stub — `mov r0,#<type>` into one dispatcher at `0x0215b074` — and the type picks one of nine setters: three screens times three locking kinds.

| | both screens | top | bottom |
|---|---|---|---|
| set | `100` (to normal), `101` (to black) | | `105` (to black) |
| set and lock | | | |
| unlock and set | | `121` (to normal) | `120` (to black) |

Every one is `fn(frames [, level])`. The level defaults to **−16, black** (`mvn r5, #0xf` in all nine), and the frame count is turned into **milliseconds** inside the setter — `frames × 16.6667f`, the literal `0x41855604` = 1000/60. With `frames == 0` the setter writes the level and a flag that applies it this frame.

The pairs alternate: the **even** type of each pair passes a level of 0 whatever the script gave it, the **odd** type passes the argument. So `120` honours a second argument and `121` cannot.

So `120` is the **bottom** screen — the pair of `121`, not its opposite.

## The worklist head, and the towns' shared set

| fn | handed | what it does |
|---|---|---|
| 211 | character, x, y, z [, frames] | **moves a character to a point without turning it**, which is what tells it from `207`. It queues opcode `0x10` (set the position outright) with no count or one not above zero, and opcode `0x11` (work out `(there − here) ÷ frames` on the first tick, add it each frame after) with one above zero (`0x0215c330`) |
| 233 | name, slot [, allocator] | loads a monster model out of `data/pack_lv5/enemy.gp2` — the first `.cchr` of the archive it finds — and installs it as a **GameState game object**. A negative slot maps by `-x + 0x9f` onto `0xa0`–`0xbf`, which is the range every scene uses. Scale `0x10a` on all three axes, animation 0; **whatever was in the slot is overwritten, not freed** (`0x0215ca4c`) |
| 322 | x, y, z, yaw, height, distance, frames [, direction] | **moves the look-at point and the orbit together**, on two of the camera's queues. Not two points: the eye it hands the first command is a zero vector, and the command sets the flag that makes the camera recompute the eye from point and orbit at the end of the frame. `direction` is **−1, the short way round**, by default; 0 forces negative, anything else positive (`0x0215dd58`) |
| 328 | frames | moves the camera back to the eye and look-at point its **idle placement** would have, computed by `0x020a2b38` without disturbing the camera, over a count. The default orbit triple it computes alongside is **discarded** (`0x0215e14c`) |
| 547 | placement [, battle] | **begins the scripted battle.** The placement's entry must be of kind 1 and hold an `Object3D`, or the call does nothing at all; that model is made visible, flagged `0x40000000` and becomes the transition's foreground. `battle` is a record index into `data/event/eventbattle.bin`, which picks the battle and, from `+0x0e` of its record, the music — **−1** when the scene gives one argument, which skips the lookup and plays sequence `0x17`. The transition blacks both screens and snaps the volume to `0x7f` (`0x02163ccc`, task type `0x16` at `0x021b6290`) |
| 558 | reference | **which of a message's choices is highlighted**, 0-based. The field is walked by the d-pad handler (`0x02045740`), wrapping against the option count beside it, and set to a default when a two-option prompt is built. No bounds check (`0x021609c0`) |
| 573 | placement [, ignored] | **takes a placed `.spr` away** — the exact inverse of `521`, which loads `data/ani/<name>.spr` and registers it. Releases the cached resource if one is held, else destroys the `Object3D`, then empties the manager slot. **Its second argument is read by nothing**: there is exactly one `ToInt` in the function (`0x02161754`) |
| 574 | group, object, visible | **shows or hides a thing the map placed.** The group is a key on a linked list of placements, the object a `u16` id within the group's array of `0x70`-byte records. A nonzero third argument **clears** bit 2 of the record's flags and a zero sets it — bit 2 being what the draw path tests to skip a record (`0x02163dec` → `0x02013380`). Its neighbours settle the record: `575` writes a position at `+0x08`, `577` a vector at `+0x14`, `576` a halfword at `+0x06` |
| 603 | flag, reference | **reads one of the game's story flags** into a reference, 1 or 0. The bank is the bitfield at `0x02108844 + 0x8c`; ids from `0x400` up are displaced by **1,786 bits** (`id + 0x6fa`). Nothing is bounds-checked (`0x021633ec` → `0x0206eb98`) |
| 715 | volume [, ticks] | the sound's **master volume, clamped to 0..127**, ramped linearly over a tick count (0 is immediate). The manager keeps it as the script's own level and scales it by the player's 1-to-5 sound setting — table `{0.0, 0.37795, 0.66929, 0.85039, 1.0}` at `0x020e8ec4` — before it reaches the mixer, halving it again if a flag is set (`0x021636d0` → `0x0209c2e0`) |
| 721 | [frames] | **fades the live sequence player to silence** over a count, **30 by default**, and marks it stopping; 0 stops it outright. A no-op while bit 2 of the manager's `+0xc8` is set (`0x0216393c` → `0x0209c678`) |

**703 to 709 are empty.** All seven are the same two instructions — `mov r0,#1; bx lr` — in a run at `0x021634e0` through `0x02163510`: no arguments, no reads, no writes, the success code every other handler returns. Whatever they were for was taken out before this build, and there is nothing in this one to find.

**The store through a reference**, which `558` and `603` both use: `func_ov017_021d6134` writes **only the four-byte value** of the thing referred to, and only when its tag is 3. It leaves the tag alone.

## Two globals of overlay 1 worth naming

- `0x021658b8` — an array of `SafeAllocator*`, count at `+0x88`, a flag at `+0x8c`. Element 0 is the default allocator; `233`'s third argument indexes it.
- `0x02165884` — points at an array of **32** 16-byte **event placement** entries, `{s32 kind; s32 slot; u32; Object3D* obj}`. Reset writes `kind = -1`, `slot = -1`, `[8] = 1`, `obj = 0`. Kinds 0, 1, 2, 4, 5 and 6 are observed in overlay 1, which assigns none of them. `547`, `573` and their neighbours index it, and **none of them checks the index against 32**.

## What is still only inferred

The readings in [Event-Scripts](Event-Scripts) taken from arguments alone still stand for everything not read here — the camera's 302, 303, 304, 310, 321, the messages' 400 and 405, the model and motion packs of 566 and 567, and the second folder's wait through 840. **90** numbers are invoked by the cartridge's scripts and answered by nothing in the reimplementation that measures them, down from about 150; the most wanted of the rest are 568, 107, 117, 714, 713, 327 and 512.

## Not established

- What the flag at `GameState+0x5CAC` is for.
- What the waypoint path's duration is counted in.
- The display table's type codes, 0 to 6.
- `503`'s optional second argument: the code it enables computes two sums and discards both.
- Which of the 33 VRAM partitions means what, and why a negative index picks 27.
- What holds the brightness lock that `120` and `121` clear, and the byte at `+0x102` poked through `func_ov017_0218b5b0` by the odd fade types.
- What bit 6 of a map placement's flags is for: `574` always sets it, and nothing was found that reads it. Bit 2 is confirmed hidden, by the draw path.
- What tells event-placement kind 2 from kind 6, or what kinds 0, 4 and 5 are — nothing in overlay 1 assigns the tag.
- The size of `603`'s flag bank, and what its two id ranges mean.
- Which mixer channels `715`'s indices 5, 6 and 7 are.
- The fixed-point base of `233`'s `0x10a` scale. It is **not** the `0x1000` the neighbouring code uses for 1.0.

## See also

- [Event-Scripts](Event-Scripts) — the file, the machine and its instructions
- [Event-Text](Event-Text) — the messages a script names
- [Triggers](Triggers) — which event runs when
- [Battle-Resolution](Battle-Resolution) — the same kind of reading, for battle
