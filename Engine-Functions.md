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

**The engine's angles are fixed-point degrees** — `fx32 / 4096 = degrees` — which `532` shows plainly.

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

## What is still only inferred

The readings in [Event-Scripts](Event-Scripts) taken from arguments alone still stand for everything not read here — the camera's 302, 303, 304, 310, 321, the messages' 400 and 405, the model and motion packs of 566 and 567, and the second folder's wait through 840. About 126 numbers are invoked by the cartridge's scripts and answered by nothing in the reimplementation that measures them.

## Not established

- What the flag at `GameState+0x5CAC` is for.
- What the waypoint path's duration is counted in.
- The display table's type codes, 0 to 6.
- `503`'s optional second argument: the code it enables computes two sums and discards both.
- Which of the 33 VRAM partitions means what, and why a negative index picks 27.

## See also

- [Event-Scripts](Event-Scripts) — the file, the machine and its instructions
- [Event-Text](Event-Text) — the messages a script names
- [Triggers](Triggers) — which event runs when
- [Battle-Resolution](Battle-Resolution) — the same kind of reading, for battle
