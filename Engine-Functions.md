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

## What is still only inferred

The readings in [Event-Scripts](Event-Scripts) taken from arguments alone still stand for everything not read here — the camera's 302, 303, 304, 310, 321, the model and motion packs of 566 and 567, and the second folder's wait through 840. **51** numbers are invoked by the cartridge's scripts and answered by nothing in the reimplementation that measures them, down from about 150; the most wanted of the rest are 538, 238, 230, 589, 226, 236 and 228.

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
- What distinguishes event-placement kind 2 from kind 6, and what kinds 0, 4, 5 are.

## See also

- [Event-Scripts](Event-Scripts) — the file, the machine and its instructions
- [Event-Text](Event-Text) — the messages a script names
- [Triggers](Triggers) — which event runs when
- [Battle-Resolution](Battle-Resolution) — the same kind of reading, for battle
