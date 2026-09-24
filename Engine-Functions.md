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

**The engine's angles are fixed-point radians.** `fix32ReduceAngle0To2Pi` (`0x02030f30`) wraps one modulo **`0x6488`**, which is 25,736 — 2π × 4096 — and the camera's own yaw is wrapped by the same constant inline (`0x02158120`). **Two** functions take degrees and convert: `532`, the field of view (`Camera_SetFov`, `0x0202e9a4`), and `327`, the camera's roll (`0x0215e108`). Both multiply by `0x47 / 4096` — 0.0173340, against π/180 = 0.0174533, so **the game's degree is 0.68% short of a real one**.

*(An earlier revision of this page said the engine's angles were degrees, on the strength of `532` alone. `532` is the one function that isn't.)*

*(A later one still had `544` handing back degrees, which contradicted the paragraph above it. Its handler, ov001 `0x0215ffc0`, reads the three components of the rotation, converts each with `_fflt` and divides by `0x45800000` — `4096.0f` — and does nothing else. That is the plain fixed-point-to-float conversion; no `0x47` appears in it. **`544` hands back radians.** The pairing is the giveaway: `208` sets a facing in radians, so a script that read one back with `544` and set it again would have turned the character through 57 times the angle it asked for.)*

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
| 544 | character, 3 references | **which way it faces** — the vector that goes to `Object3D::rotation_`, in **radians** (`0x0215ffc0`) |
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

## What every scene declares — 568

**568 is called 309 times across 476 of the 687 event scripts**, more than any number but the talking blip 554 — and at the moment it is called it does nothing observable.

```
02161380  bl   #0x218b5b0        ; GameResources*
02161388  ldr  r4, [r0, #0x3734] ; the scene context
02161398  bl   #0x21d60f4        ; ScriptValueToInt(args[i])
0216139c  ldr  r2, [r4, #0xf8]
021613a4  lsl  r1, r2, #5
021613a8  orr  r0, r0, r1, lsr #5
021613ac  and  r1, r2, #0xf8000000
021613b0  bic  r0, r0, #0xf8000000
021613b4  orr  r0, r1, r0
021613b8  str  r0, [r4, #0xf8]
```

i.e. `flags27 |= (arg & 0x07FFFFFF)`, top five bits preserved. It is **variadic** — one `ScriptValueToInt` per argument, in order, no arity check, `argc == 0` legal — it never clears a bit, and it never fails.

The top five bits are **a count of the characters `566` has spawned** (`566` increments them at `0x02161138` and reads them back as GameState object slot `0xA0 + n`), so 568 preserving them is load-bearing, not incidental.

The effect is all later. The scene's **setup** (tail of `func_ov001_02154974`) reads the field and turns each bit's subsystem *off*; the scene's **teardown** (`func_ov001_021539d8`) reads it again and turns them back *on*:

| bit | setup | teardown |
|---|---|---|
| `0x01` | `GameResources+0x04 &= ~0x008` | `\|= 0x008` — the same bit **536** kind 0 switches |
| `0x02` | `&= ~0x010` | `\|= 0x010` |
| `0x04` | for objects 0–3, `Object3D::DisableFlag(obj, 1)` | re-enables it on the ones the scene's cast does not hold |
| `0x08` | `&= ~0x400` | `\|= 0x400` — **536** kind 1 |
| `0x20` | placement manager `+0x98 &= ~2` | `\|= 2` — **581** |

**Bits 6 to 26 have no reader anywhere in the cartridge.** So what nearly every scene is doing when it calls 568 is declaring which subsystems to suppress while it plays.

### The three flag words are not "brightness flags"

`GameResources + 0x00`, `+0x04` and `+0x08` each have a full get/set/clear/test accessor quartet (`0x0203b498`–`0x0203b52c`). `test_f4` has ~36 call sites, almost all of the shape `bl test_f4; cmp r0,#0; bne <skip>` — **a set bit suppresses a subsystem update**. The decomp's provisional name `brightnessFlags_4` is misleading; the only `src/` use is `InitializeBrightnessState` zeroing all three together.

Script access to that word: **512** pokes a raw 32-bit mask, **536** bits `0x8` and `0x400`, **833** bit `0x800`. In 536, 833 and 581 alike, **a 0 sets the bit and anything else clears it** — a 0 means "hold this still".

## The caption — 409 to 414

Six numbers that always travel together, and the code says why: each writes a field of **the one message window** (`*(u32*)(0x02107800 + 0x1c)`, returned by `func_020421a0`), and every field they write is one `400`'s show routine `func_0204500c` has just reset. They are a scene's word about the message `400` started, and the next `400` undoes them.

| fn | handler | writes | effect |
|---|---|---|---|
| 409 | `0x0215e4b4` | `+0x9a8 = n`, flags `\|= 0x04` | **time it**: a second of hardware alpha in, `n` frames of hold, a second out, message tick frozen throughout |
| 410 | `0x0215e4f0` | `+0x19b1 = 0` | **no window box** — and the per-frame reset of the box's geometry stops with it |
| 411 | `0x0215e514` | flags `\|= 0x40` | **centre the text**: counts the lines each frame and puts the block at `(192 − (lines−1)×20 − 8) ÷ 2 − 16` instead of the box's own 116 |
| 412 | `0x0215e53c` | flags `\|= 0x02` | **shadow the glyphs** — 414's alternative, not its companion |
| 413 | `0x0215e564` | `+0x19b2 = 0` | **silent**: no sound as the text types |
| 414 | `0x0215e588` | flags `\|= 0x80` | **outline the glyphs** |

Together: *show this message as a caption over the scene rather than in a box.*

**Two couplings are mechanically forced**, which is why the co-occurrence is total. `func_020439b0` rewrites the geometry to the bottom box `(2, 0x74, 0xfc, 0x4a)` every frame while `+0x19b1 != 0`, so without 410 411's centring never survives; and the outline of 414 exists so text reads over scenery, which is only wanted once the box is gone.

414's outline is five passes from the tables at `0x020e7a8c` (colour), `0x020e7aa6` (x) and `0x020e7ab0` (y): `(1,2)`, `(2,1)`, `(2,3)`, `(3,2)` in palette index 1, then `(2,2)` in index 15 — the four von-Neumann neighbours plus the glyph.

409's "second" is a second because the engine steps a level of `0x1f0000` by `0x8444` a frame (literal at `0x020658a8`), and `0x1f0000 / 0x8444 = 60.0`.

The game has the same preset written out by hand in C++ in four places, each straight after `func_0204500c`: ov026 `0x021ddd18` and `0x021db2e8`, ov025 `0x021ee338`, ov017 `0x021b8378`.

### 400 and 405, refined

**400** (`0x0215e2a4`): the number is a **key looked up linearly** in the list at `0x021658d8` (`func_02153884`), not an offset, and an **unknown key shows nothing and returns 0**. A **tag-2 raw string** is taken in its place and used as the text directly. There is an **optional second int whose bit 0 alone is read**, inverted, as the show routine's third argument.

**405** (`0x0215e374`) reads the byte `+0x19bd`, which is 1 from the moment `func_0204500c` starts building a message until the teardown `func_020430b0` runs. It is not a test of whether pixels are lit. Unlike 402/403/404 it does **not** null-check the window.

**401** (`0x0215e398`) zeroes `+0x9a0` and `+0x998` and tears the window down.

### The window's other knobs

| fn | what it does |
|---|---|
| 402 | reads the byte `+0x19b4` into a reference |
| 403 | reads the word `+0x9a0`, the message's own state |
| 404 | reads the byte at the window's current text pointer, `*(u8*)win[0x58]` |
| 417 | `+0x19c0 = 1`, `+0x195d = 0x1e` |
| 418 | writes its number to `+0x19ae` |
| 419 | `+0x19ca = 0` |
| 420 | `+0x19cb` = boolean of its number |
| 421 | `+0x19c1 = 1` |

**What those bytes mean is not established.**

## Sound: arm and go, and twelve dead numbers

**713** (`0x02163640`) hands its number to the sound manager's play routine (`func_0209c3b4`), which **loads** the sequence and bank into the sound heap (`func_0203aaf8`), starts it and registers it as the current tune — and then 713 **stops the player dead** with `FadeOutSequencePlayer(mgr, 0)`. The tune is resident and silent.

**714** (`0x021636a8`) takes **no arguments at all** and restarts whatever is registered (`func_0209c5e8`), then slams the master volume to `0x7f` with a zero ramp. `func_0209c5e8` contains **no load path** — no `func_0203aaf8`, no heap call — which is the mechanical proof it depends on 713 having run.

713 takes its number either as its only argument, or as the **second of two, the first read by `ScriptValueToInt` and thrown away**. A negative number, or any other argument count, makes it return 0.

**725** (`0x0216376c`) answers 1 while `720`'s jingle is either still latched pending (`mgr->0xc9`) or still sounding (at least one live allocation playing `mgr->0xce`).

**Twelve numbers in the sound range are empty stubs** — `mov r0,#1; bx lr` and nothing else: **703–709** (`0x021634e0`–`0x02163510`), **716–719** (`0x02163724`–`0x0216373c`) and **724** (`0x02163764`).

## The bone-driven camera — 572, 531, and 213

**572** (`0x02161650`) takes a placement index and **two bone names**. It allocates a `0x268`-byte camera subclass, stashes the current camera in the event state at `GameState + 0x5ca8`, attaches the placement's `Object3D`, `strcpy`s the two names into `+0x224` and `+0x234`, and installs itself as `GameState::unknown_3b0_`. Each frame `func_0204a170` reads the two tracked bone matrices, scales and offsets their translations by the object's own, and sets **the camera's eye from bone A and its look-at from bone B**, then calls `UpdateCameraOrbitFromEye`.

The placement must be of **kind 1** and hold a non-null object, or the call returns 0 having done nothing. The index is **not bounds-checked** against the 32-entry table. The name copies are plain `strcpy` into `0x10`-byte fields.

**531** (`0x0215f930`) takes **no arguments** — zero accessor calls — and is the **only reader** of `GameState + 0x5ca8`: it restores the stashed camera and zeroes the slot. If the slot is 0 it silently does nothing. It does not free the replaced camera.

**530** (`0x0215f854`) and **552** (`0x02160768`) are the same mechanism over a monster slot and over three bones; all three write the same stash word.

**213** (`0x0215c3e8`) is the synchronisation. It queues a type-`0x0c` record on the actor's **third** command channel (`+0x18`/`+0x1c`, via `func_ov001_02159f94`); the dispatched handler `0x02159b04` asks `func_ov001_02164624` whether the actor's placed object reports its animation stopped, and **holds the channel while it has not**. Kinds 0/1/4/5 read the object directly, kind 6 reads `obj->+0x18`, kinds 2/3 and >6 return 0.

A hazard in the game worth recording: the decomp documents `HasAnimationStopped` as a one-frame edge — set on the frame an animation goes from playing to stopped, cleared after — so a wait begun *after* the animation ended never ends.

## The camera's roll — 327

**327** (`0x0215e0dc`) takes one number in **degrees**, multiplies by `0x47/4096` (the identical sequence to `SetCameraFovDegrees`), wraps it with `fix32ReduceAngle0To2Pi`, and writes it to the camera's `+0x7c` — also zeroing `+0x1ec` and `+0x1ee`, the per-frame roll increment and its remaining-frames counter, so a roll under way is stopped dead.

That it is a **roll, a bank, not a turn** is settled by the view-matrix builder `func_0202e0a4`: at `0x0202e13c` it reads `+0x7c`, and when it is zero takes the world up `(0, 0x1000, 0)` literally, and when it is not, rotates that vector by `RotationMatrixZ(roll)` before applying the heading rotation about Y.

**Camera field map**, pinned while reading this: `+0x04` eye, `+0x10` look-at, `+0x58` fov, `+0x5c` sin fov, `+0x60` cos fov, `+0x70/74/78` yaw/height/distance, `+0x7c` roll, `+0x144` rotation matrix, `+0x1ec/+0x1ee` roll animation, `+0x1f0/+0x1f4` fov tween, `+0x20e…+0x216` shake.

## Map placements — 574 to 577, 581, 582, 587

**574**–**577** all find a record the same way, by group key and `u16` id, through `GetCurrentZone` and `FindMapPlacement`: 574 clears bit 2 of the record's `+0x02` flags when its third number is nonzero and sets it when zero (bit 2 being what the draw path skips on), 575 writes a fixed-point position at `+0x08`, 576 a halfword at `+0x06`, 577 a second vector at `+0x14`. Only the position's meaning is settled.

**581** sets bit 2 of the placement manager's `+0x98` when its number is 0 and clears it otherwise; **582** clears that bit and additionally clears `0x10000` on every one of the manager's `0x20`-byte sub-objects.

**587** (`0x02161900`) indexes the 8-entry allocator array `0x021658b8` and calls `HMRFAllocator::Free(1)` = `FreeFront`, which rewinds the block's bump pointer to `allocBegin` and drops the saved-state chain. **Neither the index nor the allocator's signature is checked**, and heap 0 is the one holding the event system's own actor array (24 × `0x588`) and placement array (32 × 16).

**569** (`0x021613d0`) is one line: `sprintf(context + 0xD8, "data/%s", <string>)`.

## Two globals of overlay 1 worth naming

- `0x021658b8` — an array of `SafeAllocator*`, count at `+0x88`, a flag at `+0x8c`. Element 0 is the default allocator; `233`'s third argument indexes it.
- `0x02165884` — points at an array of **32** 16-byte **event placement** entries, `{s32 kind; s32 slot; u32; Object3D* obj}`. Reset writes `kind = -1`, `slot = -1`, `[8] = 1`, `obj = 0`. Kinds 0, 1, 2, 4, 5 and 6 are observed in overlay 1, which assigns none of them. `547`, `573` and their neighbours index it, and **none of them checks the index against 32**.

## Script chaining — 538, 810, 834

**`538`** (`0x0215f9dc`) writes one halfword of the scene context, `+0x11a`, through `func_ov017_021bbbec` (`add r0,r0,#0x100; strh r1,[r0,#0x1a]`). The VM's step, at the point a script runs out, consumes it (`0x021bca68`):

```
021bca68  add   r0, sl, #0x100
021bca6c  ldrh  r1, [r0, #0x1a]
021bca70  cmp   r1, #0
021bca74  beq   #0x21bca94
021bca7c  strh  r1, [sl, #8]      ; SceneContext->eventId = nextEventId
021bca84  strb  r1, [sl, #0xfd]
021bca88  bl    #0x21bb0c4        ; re-arm the VM for the new script
021bca8c  mov   r0, #0            ; -> "not finished"
```

So **a scene runs on into another script, keeping its context** — its cast, its camera, its shot. That is how a long cutscene is cut into pieces, and it is why 538 is called by 95 of the 687 scripts. The halfword is cleared at scene begin (`0x021baf04`) and by the re-arm, so **0 means no chain**; nothing validates the id.

**`+0x11c` is a second script id the trigger carried.** A trigger record holds two (`+8` primary, `+0xa` secondary); `func_ov017_021d1e50` runs the first and parks the second at `+0x11c`. **`834`** (`0x02163164`) answers whether one is parked — **1 or 0, not the id** — and **`810`** (`0x02162210`) moves it into `+0x11a` and clears it.

## Sprite placements — 521 and 522

A create-and-destroy pair over the 32 slots of the sprite manager at **`0x021075f4`** (returned by `func_0203cf4c`).

**`521`** (`0x0215f3fc`) `(name, &slot [, allocIdx [, vramIdx]])`:
- `func_0203e03c` finds **the first free of 32 slots** and 521 **stores it through its reference** (`0x0215f470`) — before the bounds check and before every failure return, so a failed call still leaves an index behind.
- The path is `data/ani/%s.spr`, or `data/ani/%s` when the name already ends `.spr` (`strstr`, format strings at `0x021657b2` / `0x021657be`).
- Four allocations from `allocTable[arg2]` (default 0, **not bounds-checked**): `0x20` the placement record, `0x78`, `0x14` the name record, `0x9c` the sprite instance.
- The name record keeps the **bare five characters**, or seven when the name holds `_s` — which also sets bit 3 of the sprite's flags at `+0x50`.
- The texture is staged into `GameResources + 0x2cc + vramIdx*0x70`, **default 27**, which is the same partition handler 503 hardcodes (`+0xbd0 / 0x70 == 27`).
- Scale `0x8f` on all three axes.

**`522`** (`0x0215f740`) takes that slot back: releases the cached resource by name (`"%s.spr"` rebuilt from the name record) or destroys the `Object3D`, re-runs the record constructor, empties the manager slot, and **clears any event-placement entry of kind 2 or 6 whose `slot` field matches**. It does not free what 521 allocated.

**`573`** does the same teardown but is **indexed through the event placement table** — it reads an entry of kind 2 or 6 and uses that entry's `slot`. So 522 is 521's direct inverse and 573 is the same destructor reached the other way. Both go through `func_0203cf4c`.

That kind-6 case is confirmed by the dispatchers `0x02164624`, `func_ov001_02164578` and `func_ov001_021646b8`: for kind 6, `entry[0xc]` is **not** an `Object3D*` but a `0x20`-byte placement record of 521's shape, with the `Object3D*` at `+0x18`.

## The rest of the event VM

| fn | handler | what it does |
|---|---|---|
| 228 | `0x0215ba64` | shallow-copy a game object into another slot, scaled **`0x10a`** — about a fifteenth of size, and why is not established. Its optional third argument (the allocator) is passed by **no script on the cartridge** |
| 230 | `0x0215bcc0` | unload every animation package with the given id (**3 by default, which is every call**) and set the same animation again by name, **falling back to `"stand"`** when the name no longer resolves. It reads the flags and the name *before* the unload, which clears them |
| 236 | `0x0215cdf8` | `Object3D::Detach` on a placement's model — clears the two child links and the attach bone, and walks the whole child list when it is itself the anchor |
| 238 | `0x0215cf98` | **a palette recolour, not a move.** Packs three numbers as `r \| g<<5 \| b<<10` into BGR555 and rebuilds the model's texture palette into a staging buffer bound for VRAM. An optional fifth number is the mode: **0 add** (held at 31), **1 fill**, **2 multiply** over 31. On one of the first four game objects it recolours the whole party member — the model plus twelve slots at `id × 12 + 0x13` |
| 509 | `0x0215eeb0` | switch a **raw 32-bit mask** on `Object3D+0x6C`, the same word visibility and `SetFlag16` use |
| 550 | `0x021605d4` | show or hide a character's objects at `12n + 0x1C` and `+0x1D`, skipping either whose model id is negative |
| 556 | `0x02160938` | re-mount the weapon from **`data/bin/wpnpos.bin`** — `0x150 / 0x1C` = exactly **12 rows**, one a weapon class, each holding **two 14-byte placements** of a bone, a position and a rotation. Which of the two is picked by its second argument; **stowed-versus-drawn is INFERRED**, the halves being structurally identical |
| 559 | `0x021609e4` | writes one byte at `0x02108844 + 0x490` — **two writers in the whole cartridge and no reader** |
| 578 | `0x02164004` | `LightingManager::BeginFade`: a multiplier over the scene's two light colours and the horizon's, over a count of frames converted to milliseconds. 0 sets it outright |
| 579 | `0x02164080` | `GameState::SetDayTimerRunning` — **inverted**: a 0 starts the clock |
| 580 | `0x021640b4` | the field of view over a count: `cam+0x1F0` target, `cam+0x1F4` remaining, the count multiplied by **33**, which is what the frame length is initialised to. 0 calls `532`'s setter directly |
| 588, 589 | `0x021603d8`, `0x02160504` | pin the lighting to a phase and re-tint the zone. The phase-start table is `{0, 180, 210, 390}` of a 420-second day, built at startup as running sums of `{180, 30, 180, 30}`. **`589` runs once a zone** — a byte at `Zone3D+0x834` makes a second call do nothing at all |
| 548, 549 | `0x02160338`, `0x021603b0` | set and clear `LightingManager::lightingIndexOverride_`. **`549` reads its one argument and immediately overwrites it** |
| 598 | `0x02161d08` | the first entry of the byte array of party object indices at `GameState+0x397C`, whose count sits at `+0x3980` |
| 600 | `0x021632e4` | read a story flag **by its raw bit**, calling `GetBitInBitfield` directly and **bypassing** `GetStoryFlag`'s `+1786` displacement. So 600 and 603 agree below `0x400` and part above it, and **raw bits 1024–2809 are reachable only through 600** — which the game uses: other code reads raw `0xC02`–`0xC11` as a mask and sets raw `0x1142` and `0x113A` |
| 226, 227 | `0x0215c858`, `0x0215c8a4` | set and interpolate `Object3D::radius_` via actor commands `0x15` and `0x16` — the exact fx32 analogue of 219/220 on alpha. **A duration of 0 writes nothing at all** |
| 738 | `0x021637d4` | `func_0209c20c`: stop the track, fade over no frames, free the player's heap, set both sequence numbers to −1, master volume back to 127 |
| 838 | `0x02163228` | overlay 28's stopwatch as **milliseconds** — `(ticks << 6) / 33514`, the DS's own tick conversion. Overlay 28's only string is `data/evspt_lv5/staffroll.bin` |

## The lowest ten numbers are the player's input

| fn | what it does |
|---|---|
| 0 | **how many of four buttons are held**, 0 to 4 — it tests `0x0001`, `0x0002`, `0x0400` and `0x0800` separately and adds the answers |
| 1 | whether the buttons in a mask were **newly pressed**: `(held & mask) && !(prev & mask)` |
| 2 | a flag of the input object ANDed with a count of its below ten |
| 3 | switches something of the loader's, by two calls differing only in which |
| 4, 5, 6 | one and two numbers of maths, answered through the **float** store accessor. **INFERRED** sine, cosine and arc tangent, from the shape alone |
| 7 | **a random number from low to high, both ends included** — `NextRandomBetween(Random*, lo, hi)`, whose body is `lo + below(hi − lo + 1)` |
| 8, 9 | set and clear the zone-mask flag |

A consequence worth recording: **a script that polls `0` or `2` and never gets a press will run for ever.** One scene on the cartridge does exactly that, and it is the game working as intended, not a broken script.

## Walking a character over the ground — 207, 231, 232

Three handlers, **one command**. `func_ov001_0215a364` has exactly two callers — `0x0215c124` inside **207** and `0x0215ca38` inside **232** — and both produce the same opcode-2 record on actor channel 0, differing only in a mode word. **231** is the instant form, enqueuing opcode 1.

| fn | takes | mode | what the handler does |
|---|---|---|---|
| 207 | character, x, y, z, frames [, name] | 0 | glide to exactly (x, y, z) |
| 232 | character, **x, z**, frames [, name] | 1 | glide x and z, then **`GetCurrentZone()` and `func_02018fbc(zone, actor+0x74)` each frame, writing the result to `actor+0x78`** |
| 231 | character, x, z [, name] | — | the same ground query, at once |

**There is no y argument on 231 or 232.** The y the record carries is the constant `0xa000` — fx32 10.0 — and it is only where the probe starts. `func_02018fbc` builds an AABB of `x±0x800`, `z±0x800`, `y+0x1000` down to `y-0xa000`, so a probe at 10.0 spans 0.0 to 11.0.

The optional name is played when the move ends, through `func_ov001_02164578`, which is called **whether or not one was given** — with the record's `""`, which `Object3D::MaybeSetRegularAnimation` early-outs on (`0x02036e60`).

The record allocator's free path re-initialises, including `strcpy(rec+0x1c, "")` from the empty string at `0x02164d10`, which is why the name field is `""` rather than stale.

## 317 and 326 are twins

`func_ov001_0215d8f4` (317) and `func_ov001_0215d984` (326) are **the same instructions** — same three `ToFloat`×4096, same `ToInt`, same `*(0x021658a4)` — differing only in the enqueuer:

| fn | enqueuer | channel | node | what it moves |
|---|---|---|---|---|
| 317 | `func_ov001_021591d0` | 2 | `0x10` = `func_ov001_02158494` | **eye and look-at together** — the view slides without turning |
| 326 | `func_ov001_02159210` | 3 | `0x11` = `func_ov001_02158654` | **look-at alone** — the view turns about a fixed eye |

Both run the identical `t % 4` square wave (`+A` at `t≡0`, baseline at `t≡2`) and the identical `+0x134`/`+0x150` save-and-restore protocol, and both have **the same dead decay**: the amplitude actually applied is `controller+0x138`, written once on the first frame and never again. The three-call decay block writes only `record+0x04`, which nothing that touches the camera reads.

A count below zero shakes for ever.

Note also a **third, unrelated shake**: **803** (`0x02161e00`) is a *continuous sine*, not a queued square wave. It sets `camera+0x1F8` (enable), `+0x200` (speed, a **raw float, no fixed-point conversion**) and `+0x204` (amplitude, fx32). `BuildCameraViewMatrix` at `0x0202e3c4` advances a phase at `camera+0x1FA` by `delta × 182 × speed`, indexes the sine table at **`0x020e9450`**, scales by the amplitude and adds the result to **the eye's and the look-at's Y only**. `803(0)` clears the enable byte. It reads all three arguments unconditionally, so a one-argument call reads past its own argument list.

## The camera follows a character — 324 and 325

**324** (`0x0215dfc4`) writes `controller+0xa20 = EventActor*` and queues node `0x12` (`func_ov001_021587c4`) on camera channel 0. That node copies the actor's position from `actor+0x74` into `controller+0x58` (the look-at), adds the record's offset, and **returns 1 every frame — it never finishes**. The eye at `controller+0x4c` is untouched.

**325** (`0x0215e0c0`) is three instructions of work: `controller[0xa20] = 0`. That makes the node return 0 on its next tick and free its record. It is the only thing that ends 324.

## The 800 block is the ending

`804` co-occurs at 100% with `820`, `821`, `822`, `826`, `811`, `734` and `845`. It is **the staff roll and the credit cards**, and the scripts name the files:

```
ev29350  821(0) 820("chara_sub/toriyama.pac") 820("chara_sub/sugiyama.pac")
         820("chara_sub/hino.pac") 820("chara_sub/fujisawa.pac") 822(0) 826(0)
         811() 804(0) 734(0) 820("chara_sub/horii.pac") 734(1)
ev29373  838 804(0) 821(0) 838 812() 820("chara_sub/ichimura.pac") 822(0) 826(0)
ev29306  821(0) 820("chara_sub/tobe_<LG>.pac") 822(0) 826(0) 804(0)
```

All of those exist on the cartridge — `horii.pac`, `toriyama.pac`, `sugiyama.pac`, `hino.pac`, `fujisawa.pac`, `ichimura.pac`, `company.pac`, and `tobe_de/en/es/fr/it.pac`. `horii.pac`'s members are `horii_san.bncg` (payload magic `CHAR`, 0x40×0x20 tiles, 8bpp), `.bncl` (`PALT`, 256 colours) and `.bnsc` (`SCRN`, 32×24×2) — one full-screen 256-colour picture. The `<LG>` is resolved by `StringReplaceLanguageTag` (`0x020757b4`).

| fn | handler | what it does |
|---|---|---|
| 734 | `0x02163a5c` | re-size the two sound heaps. **Non-zero**: destroy heap A and re-create heap B at `0x02200180` size `0xA2000`. **Zero**: heap B at `0x02200180` size `0x57000`, heap A at `0x02257180` size `0x4B000`. The arithmetic is the point — `0x02200180 + 0x57000 = 0x02257180`, and `+ 0xA2000` = `0x02257180 + 0x4B000` |
| 811 | `0x0216224c` | push overlay group 5, set bit `0x1000` of `GameResources+0x00`, then `func_ov028_021d96bc(eventAllocators[0])` — which takes `0xA000` + `0x5000` from that allocator, records a 64-bit timestamp at `ctx+0xa0`, and registers a per-frame task at priority `0xd7` |
| 812 | `0x0216227c` | clear that bit, `func_ov028_021d9714()`, pop the overlay group |
| 838 | `0x02163228` | `(ctx[0xa8..0xac] << 6) / 0x82EA` — ticks × 64 / 33514, i.e. **milliseconds** |
| 821 | `0x0216297c` | save the display state. **0 = main, 1 = sub, anything else nothing.** `GetMainBGVRAMBanks()` → `eventAllocators+0x494`; BG0–BG3CNT (`0x04000008`–`0x0400000E`) → `0x02165cb8+0x98..0x9e`; `(DISPCNT & 0x1f00) >> 8` → `+0x4a0`. Sub uses `+0x4a4`, `+0xa8..0xae`, `+0x4b0` |
| 820 | `0x021624cc` | `sprintf("data/%s")`, load, then **BG3 only**: `DISPCNT &= ~0x1f00; \|= 0x800`, BG3CNT set 256-colour, and the chunks dispatched by magic to `LoadToMainBG3CharacterData` (`0x020c6018`), `LoadToMainBG3ScreenData` (`0x020c5d18`), `LoadToMainBGStandardPalette` (`0x020c5820`) |
| 826 | `0x02162900` | zero `0x20` bytes of BG3 tile 0 and `0x600` bytes of its screen map. **0 = main, non-zero = sub** |
| 822 | `0x02162a90` | the exact inverse of 821 |
| 804 | `0x02161e8c` | **fog.** `LightingManager+0x85 = 0 or 1`, then `func_020c54a4(enable, fogInfo_.type, .depthShift, .offset)` — `FOG_OFFSET` at `0x0400035C` and the fog bits of `DISP3DCNT` at `0x04000060` |

**804 is not inferred.** `src/Graphics/LightingManager.cpp:818` in the decomp's own hand-written C++ contains the identical call.

**845 is not part of it.** It is the middle of a different set: **506** opens a preload batch (resetting the count at `eventAllocators+0x88`), **845** tops it up, **507** polls until every queued task is done. It shares 804 for the same reason 124 other scripts share 506.

### 845 has a slip

```
0215ed84  ldr r4, [r2, #0x88]   ; loop counter starts at the RUNNING COUNT
0215ed8c  mov r0, r6            ; but the argument cursor starts at args[0]
0215ed90  bl  #0x21d612c
0215ed98  add r6, r6, #8
0215eda4  cmp r4, r5            ; bounded by ARGC
```

So it queues `argc − count` files, reading the **first** `argc − count` arguments and leaving the last `count` read by nothing; where `count >= argc` it is a complete no-op. `506`, its sibling, stores 0 to `[+0x88]` first and so never trips over this.

## 815 is an anti-tamper check

```
02162348  bl #0x21d6134         ; *** store 1 into args[0] FIRST ***
02162354  bl #0x20a1940         ; load overlay 29 (0x1D)
02162388  bl #0x21d8e94  ; cmp against 0x001BF27F
021623b0  bl #0x21d8f84  ; cmp against 0x001BEFCB
021623d8  bl #0x21d9074  ; cmp against 0x001BEB10
021623fc  cmp r0, #6            ; and the counter must reach 6
0216240c  bl #0x21d6134         ; *** only then store 0 ***
```

The three stubs at `0x0215A6FC`, `0x0215A718`, `0x0215A734` each call the callback they are handed and return their own magic constant; the three callbacks bump one counter by **1, 2 and 3** — summing to exactly the threshold. So it verifies both that overlay 29's entry points answer correctly *and* that each genuinely invoked its callback.

**0 is the good answer.** 1 means tampered-with or not checked, and the 1 is written first so a check cut short leaves it. The second argument is the "really check" switch and must be exactly `1`; without it the answer is 0.

Overlay 29 is obfuscated — the decomp marks every symbol in it `kind:data(any)` and it disassembles to nonsense. Its six entry points at `0x021D8E1C` + `n×0x78` are byte-identical apart from two branch offsets.

## Two handlers that write nothing on the common path

Worth calling out together, because a reimplementation that writes 0 instead is wrong:

- **234** (`0x0215ccdc`): where the cast entry's kind is in `{0,1,4,5,6}` but `cast[i].obj == NULL`, it jumps to the return and **writes nothing at all**. The script's variable keeps its previous value. (Kinds 2, 3 and >6 do write, always 1.)
- **823** (`0x021626a4`): where bit 0 of the byte at `GameState + 0x63DC` is **clear**, it returns without writing. Only where it is set does it store, and what it stores is always 1. **819** (`0x021624a8`) is the other half — same bit, and it acts where 823 asks, queueing a work item carrying `data/scenario/chur_messet.bin`.

## The equipment pair — 828 and 829

Proved three ways, none circumstantial:

1. **The same flag bit.** 828 ends with `func_0203b4b0(GameResources, 0x10)` — **clear** bit `0x10` of `GameResources+0x00`; 829 opens by **testing** it and can **set** it. No other handler touches that bit.
2. **That bit gates the queue 829 reads.** ov017's frame update at `0x0218cf78` tests it and *skips* the queue update when set. 828 clearing it is "let the queue run".
3. **The node type matches.** 828's `func_ov017_0218f5a4` obtains its node through `func_ov017_021a4658`, whose initialiser writes `0x13` — the exact constant 829 compares against.

**828(who, slot [, back])** stashes `equip[slot]` into `sceneCtx+0x182` and sets the slot to −1; with a non-zero third argument it puts the stash back, but **only if the slot is still empty and the marker at `sceneCtx+0x180` is not 6**. `func_02052d7c` also sets raw story-flag bit `0x113F` unless the slot is 7 or 8.

**829** answers **1 while the request is still at the head of the queue**, and latches itself off (setting bit `0x10`) once it is not. It is a while-loop condition, not a done flag.

## The time of day is a four-phase enum

`include/GameState/TimeOfDay.h`: **Invalid −1, Night 0, Morning 1, Day 2, Evening 3.**

- **808** (`0x02162148`) → `GameState::SetTimeOfDay` (`0x02010364`), which writes `GameState+0x3DC`. **A value of 4 or more does nothing at all** — and the guard is a signed `bge #4`, so **−1 is not rejected** and would index a table short.
- **588** and **589** pin `LightingManager::timeOfDayIndex_` (`+0x98`) and its day clock (`+0x94`) to that phase's start. The phase-start table is `{0, 180, 210, 390}` of a 420-second day, built at startup as running sums of `{180, 30, 180, 30}`.
- **597** answers the same index.

All three speak these numbers.

## The rest

| fn | handler | what it does |
|---|---|---|
| 223 | `0x0215c730` | show or hide a map placement — **only when `cast[i].kind == 2`**; any other kind returns success having done nothing |
| 239, 240 | `0x0215d08c`, `0x0215d0f4` | set and clear `placement+0x10`, an extra `Object3D*` that `func_02040910` draws **before** the placement's own model. 239 reads its first entry for its `.slot` and its second for its `.obj` |
| 552 | `0x02160768` | the three-bone camera. Two bones drive the eye and look-at as 572's do; **the third drags a second object**, whose index is the fifth argument, setting its position from the bone and its facing from `fix32_Atan2` of the movement |
| 557 | `0x021609a0` | clear bit 0 of the Hero's flag word, push their action state back, reset the object `GameState+0x397C` names. **INFERRED**: getting off a mount |
| 583 | `0x021618d0` | one byte at `GameState+0x63D6`, `&0xff`. Fifteen readers treat it as a gate on entering a map; **ov017 `0x0218b6c0` tells 4, 8 and `0x0c` apart** |
| 591 | `0x02161988` | bit 0 of `zone+0x105`, **set when the argument is 0**. Six write sites in the cartridge and **no reader found** |
| 599, 805 | `0x02161d2c`, `0x02161f3c` | a **whole word** at `zone+0x274C` and `zone+0x2750`; each is the first thing its render pass tests, and a zero skips the pass entire |
| 601, 602 | `0x02163334`, `0x02163390` | bits of the **progress record in hand**. The bank at `0x02108844` opens with five `0x1C`-byte records (`0x8c = 5 × 0x1C`), `byte[base+0x332]` selects one, 601 reads its bitfield at `+0x03` and 602 its second at `+0x10` |
| 735 | `0x02163ab4` | bit `0x04` of the sound manager's `+0xC8`, **set when the argument is 0** — and that bit makes both `PlayBGM` and `FadeOutSequencePlayer` return immediately |
| 736 | `0x02163aec` | play the zone's own tune: its id through a table of 47 at `0x020E8ED8`, substitutions that follow the time of day, and an override list whose entries each carry **a story flag to test** |
| 737 | `0x021637a8` | the same teardown as 738, then `func_0209c6d8` starts a track on the manager's **second** player (`+0xC4`, id at `+0xCE`), leaving the first slot empty so a later `PlayBGM` proceeds |
| 802 | `0x02161db0` | set bit 0 of the byte at `+0x04` of the first cast node whose byte at `+0x01` matches. The cast loader reads it and **rewrites the model's palette colours in place** through `LightingManager::ColorTransformTintBrightnessContrast` |
| 806 | `0x02161f64` | `Zone3D+0x264D = 1` — a one-shot request in the embedded **`ActiveGrottoClass`**, consumed and cleared by `func_0208fc30`, which enqueues a type-`0x34` work item |
| 809 | `0x02162174` | show or hide `*(Object3D**)(GameResources+0x4334)` and `+0x4338`, slots 0 and 1 of a four-pointer array. Its **second argument is an optional mask**, and no script passes one — so in practice the first slot alone |

### A house style: a 0 means "on"

Five switches read the argument the other way up — `536`, `581`, `591`, `735` and `833`. In each, **0 sets the bit and anything else clears it**, and in each the bit *suppresses* something. Consistent enough to expect on any switch still unread.

## What is still only inferred

The readings in [Event-Scripts](Event-Scripts) taken from arguments alone still stand for everything not read here — the camera's 302, 303, 304, 310, 321, the model and motion packs of 566 and 567, and the second folder's wait through 840. **5** numbers are invoked by the cartridge's scripts and answered by nothing in the reimplementation that measures them, down from about 150: 807, 837, 839, 843 and 844.

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
- What the individual bits of `568`'s mask mean *in gameplay terms*. The mechanical effect of `0x01`, `0x02`, `0x04`, `0x08` and `0x20` is exact, but the subsystems gated by `GameResources+0x04` bits `0x008`/`0x010`/`0x400`, and by the placement manager's `+0x98` bit 2, are unnamed in the decomp. Bits `0x01` and `0x08` are literally what engine fn **536** kinds 0 and 1 switch, and bit `0x20` is **581**, so naming those two names three of the five for free.
- **Bit `0x10` of 568's mask.** Read at five sites (`0x02153a38`, `0x02153b90`, `0x0215584c`, `0x02155b6c`, `0x02155cbc`), each *gating* a block rather than performing a symmetric set/clear, so it does not fit the setup/teardown pattern.
- **Where 568's 27-bit field is reset to zero.** No code clears bits 0–26; presumably a bulk wipe of the enclosing `0x36c0` block, not located.
- Whether **bits 6 to 26** are ever meaningful — no reader was found for any of them.
- Which layers `409`'s alpha ramp cross-fades. The register write is exact (`*(u32*)0x04000050 = 0x0148 | ((v | ((15 − v/2) << 8)) << 16)`), but which physical BG the caption sits on at that moment was not established.
- What ends `409`'s caption after the ramp-out: once the phase bits clear, `func_020657c8` still returns 1, so the message tick stays suspended. Presumably the script issues `401`.
- What the message window's bytes `+0x19b4`, `+0x195d`, `+0x19ae`, `+0x19c0`, `+0x19c1`, `+0x19ca` and `+0x19cb` mean.
- What `801`'s subsystem is. Four circumstantial routes point at the wireless manager (a six-byte address compare, a 21-byte name defaulting to `"unknown"`, a state word whose 1/2/8/9/10 match `WMState`, a screen fade on shutdown), but no symbol, string or source file names it.
- What condition makes **714** silence instead of restarting (`func_02086b98`'s per-entry bit `*(u32*)(entity->0x130) & 1`).
- Which index scripts pass to **587**. Slot 0 would rewind the actor and placement arrays.
- What `Object3D` flag bits `1` and `0x20` are, which **572** enables.
- What distinguishes event-placement kind 2 from kind 6, and what kinds 0, 4, 5 are — though kind 6's `+0x0c` is now known to be a `0x20`-byte sprite placement record rather than an `Object3D*`.
- **Who assigns `kind` and `slot`** in the 32-entry event placement table. The array is allocated and zeroed in `func_ov001_0215a850` (`Allocate(0x200)` = 32 × 16), and every use in ov001 and ov017 only reads or clears it. No writer was found in either overlay.
- **What reads `0x02108844 + 0x490`**, the byte `559` writes. Two writers in the whole cartridge, no reader; every byte and halfword load that could reach the offset was searched for.
- **The writer of `GameState + 0x397C` / `+0x3980`**, the party index array `598` reads and its count. Three readers, no writer found.
- Whether `556`'s two `wpnpos.bin` placements are stowed and drawn. The halves are structurally identical and nothing names them.
- Which weapon category is `wpnpos` row 6 — the one that toggles `Object3D+0x18c` bit `0x20`. The table is filled at runtime from the file, so its contents are not in the binaries.
- What `12n + 0x1D` is. `12n + 0x1C` is the weapon, from `556`.
- Why `228` scales its copy to `0x10a` and `521` its placement to `0x8f`. The constants and the unit (fx16, 1.0 = `0x1000`) are certain; the reason is not.
- What engine functions `4`, `5` and `6` compute. One double in and one out, and two in and one out; sine, cosine and arc tangent fit the shape, and nothing confirms it.
- What the two fields engine function `2` reads are.
- **What reads bit 0 of `0x020FB4F5`** (`591`'s zone bit). Six write sites across arm9 and all overlays; no immediate-offset reader anywhere.
- **`583`'s values.** Fifteen readers treat the byte as a yes-or-no gate on entering a map; ov017 `0x0218b6c0` distinguishes 4, 8 and `0x0c`. What those mean is open.
- **What the models `599` and `805` draw are.** Both passes are walked structurally — a count, a list of `0x24`-byte (599) or `0x368`-byte (805) instances — but no filename was reached.
- **The id space `func_02064b98` switches on** to pick one of the five `0x1C`-byte progress records. The ranges are exact (`[0xC8,0xDB]`, `[0x6A4,0x6AA]`, `[0x1068,0x106A]`, `[0x1E14,0x1E1D]`, `[0x2328,0x2330]`, …); the namespace is not identified.
- **What the four `Object3D`s at `GameResources+0x4334..0x4340` are** (`809` reaches the first two). The fill loop is at ov017 `0x021bdef0`–`0x021bdfc8`, four `s16` file ids from a record whose owner was not chased.
- **Overlay 29's algorithm** (`815`'s probe). Obfuscated; not decrypted. Only that 815 treats a mismatch as tampered.
- **The contents of the four-word table at `0x020F33B4`** that `SetTimeOfDay` indexes. It lies past the end of `arm9.bin` and is runtime-initialised.
- **Whether `845`'s count/argc mismatch is intended.** The code is unambiguous and its sibling `506` resets the count first, so the difference is deliberate somewhere — but whether the *argument cursor* starting at `args[0]` is by design cannot be told from the binary.
- **What `func_02018fbc` does past its AABB setup** (`231`/`232`'s ground probe). The box is read — `x±0x800`, `z±0x800`, `y+0x1000` down to `y-0xa000` — but not the remaining ~0x1f0 bytes; "returns the floor height" is INFERRED from that shape and from both callers writing the result into `actor->pos.y`.
- **Whether `532`'s field of view is a half-angle or the whole field.** The first reading called it a half-angle because the projection puts `cot` in the slot a perspective matrix holds `cot(fov/2)` in; reading `580` showed that slot takes `cot × aspect`, which weakens it. Against the half-angle: the engine's own default is **60** (`0xF000`, set at `0x02155fe0`), and scenes pass 15 — read whole those are 60° and 15°, read as half-angles 120° and 30°, and 120° vertical is implausible.

## See also

- [Event-Scripts](Event-Scripts) — the file, the machine and its instructions
- [Event-Text](Event-Text) — the messages a script names
- [Triggers](Triggers) — which event runs when
- [Battle-Resolution](Battle-Resolution) — the same kind of reading, for battle
