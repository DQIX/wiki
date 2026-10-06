# Battle presentation

How a battle is staged on top of its rules: the camera while commands are chosen, the chase shot, when an action's line goes up, the rates the battle runs at, and the party's panels. Read 6 October 2026.

> **USA only** for the code (the ARM9 and overlays 0, 17, 23, 25 and 26), read through the [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the files' values. See also [Battle stages](Battle-Stages) and [Battle action scripts](Battle-Action-Scripts).

## The command phase's fixed shots

While commands are chosen, the camera holds the opening's wide shot on the monsters, cut to each round. For some fights overlay 26 replaces its eye and look-at with fixed ones.

**The table**, `data_ov026_021de87c`: 47 records of 28 bytes, ended by a key of −1.

| offset | type | meaning |
|---|---|---|
| `+0x00` | `s32` | the key: a monster's **kind**, `mon_data` `+0x10` ([Monsters](Monsters)) — or 0 |
| `+0x04` | `fx32` ×3 | the eye |
| `+0x10` | `fx32` ×3 | the look-at |

**The choice**, `func_ov026_021d8aac`, every frame of overlay 26: the first record in the table's order that holds.

- A key of 0 holds only when `func_ov000_0215fc60` gives 2: the battle's first group is monster 801, the story's first Corvus.
- Any other key holds when a monster of that kind is among the battle's eight monster objects (`func_ov000_0215fc8c`, comparing each object's `mon_data` record's `+0x10`).
- Key `0x115`, Corvus's last form, has three records: the round counter (`battle+0x8e20`) mod 3 picks one.

**EU only:** the keys are the bosses' kinds `0x101`–`0x133`, a few sharing a shot, and two whales' (`0xd5`, `0xff`). The hexagoon's eye stands at (0, 1.06, 2.27) looking at (0, 1.08, 0) — 4.8 from the monsters' row at z −2.5.

**Where it applies**: the side shot `func_ov000_0216d600` takes the fixed eye and look-at when its last argument is set — which only the opening's shot does (`func_ov000_0216118c`, called for the opening and for each round's cut). The wide view (a 22° half-angle) stays. A camera command in an action script that frames a side passes 0.

## The chase shot

Taken whenever an action's script does not open on a camera of its own — see [Battle stages](Battle-Stages) for its pose.

**Its start**, `func_ov000_0216e678`, draws in this order: a number below 100; when 1 to 4 actions have passed without a forced start, one below 5 less those passed, forced on 0 (on the 5th, forced without a draw; and on a round's first action); when forced, one of four start poses (`data_ov000_021832c4`: yaw ±162° or ±18°, height 0.5, distance 5 or 10).

**A target taller than 2.5**, forced: the orbit's height is drawn, −1.2 − 0.8 × a float draw, and — unless the action is 9, 10 or 11 (Frizz, Frizzle, Kafrizz; `func_ov000_0216f728`) — a **yaw offset**, π × (0.35 − 0.7 × a float draw), up to ±63°. Both are kept in `data_ov000_02184270` (`+8`, `+0xc`) **between chases**: the follow (`func_ov000_0216ea38`) takes them for every tall target, so a chase that was not forced uses the last forced one's.

**Settling**: a forced start sets a count of 5, otherwise 0. Each follow takes one off; once it is 0, the chase is marked settled (`+0x261`) when its look-at is within 5 of where it wants to be.

## When an action's line goes up — state 6

Overlay 25's action loop keeps a state at `+0xeac`. As an action begins, `func_ov025_021dc220` sets **state 6** when `func_ov000_021627fc` holds, else state 3. It holds when the turn's action's record has **`+0x14` bits 28–31 — whom it reaches — equal to 2 or 5** ([Actions](Actions)).

**EU only:** 5 is on the Attack's two records alone; 2 is on 189 — the heals, Zing and the herbs that take one ally.

State 6 (`func_ov025_021dc324`) waits, while the chase runs, for it to settle (`func_ov000_0216f0bc`); then puts the line up (`func_ov025_021ea474`). A camera command in the script stops the chase, so the line goes up at once. Any other action goes to state 3, and its line goes up with its script's first camera.

## The rates

- **The field's loop waits for two vblanks a pass** (overlay 17 `0x0218c78c`–`0x0218c7b4`): `WaitForInterrupt(true, 1)` until `GameState+0x3c8`, the vblanks since the last pass, is at least 2. `func_02012bd8`, the vblank handler, counts them. So a pass is 30 a second.
- `GameState::CalculateDeltaTime` takes the pass's microseconds, capped at 50 ms, in whole milliseconds — 33 for two vblanks — and an animation frame is 17 ms of it.
- **The battle's update** runs once a pass (taken so: the battle is a field task). The action dispatcher, the camera's ticks and **the rising numbers** (`func_02039fec`, no count) step once an update; a rising number's 37 steps last 74 vblanks.
- **The results windows** count vblanks: `GetTickCount` takes their row counter down (`func_ov023_021d8f2c`). The menus take it too.
- **The swirl** into a battle (`func_0204700c`) counts vblanks to its 35, but turns the camera 8° and narrows it 0.4333° once a pass.
- **Brightness fades** are timed: a count × 16.667 ms (`SetMainBrightness`).

## The party's panels

- **The acting member's pulse**, `func_ov000_02170b0c`: while the member record's `+0x43c` bit 0 is set, a phase grows 0.2 a vblank and goes round at π; with t = 1 − sin(phase), red and green are 10 + ⌊21t⌋ and blue 10 + ⌊−10t⌋ — grey to yellow — written to **colour 15 of the member's panel palette**. Bit 1 stops it: white again. `func_ov000_021754e0` stops it as an action ends. **What sets bit 0 was not found.**
- **The level**, `func_ov000_02174738`: `%d` of the member's level in their vocation, measured in font 0 and drawn right-aligned in a 16-pixel sprite, colour 15; placed at (44, 22) of the panel, large or small (`func_ov000_021811f4`), where no status icon is.
- **A hit's flash and shake**: not found.

## The way in

- The swirl's model, `data/effect/ev999991500.chr`, is loaded with polygon ID `0x3d`, placed at (0, −10, 1) and drawn by `Object3D::Draw(true)` while the transition's state is 3 (`func_ov017_021b65bc`). Under which view: not read.
- The transition (`func_ov017_021b6290`) starts the battle's track, then swirls — unless a value from `func_020709ac` is over 30, or the main screen is already black, when both screens go black at once and there is no swirl.

## Open

- What turns the acting member's pulse on; what flashes and shakes a hit member's panel.
- The view the swirl's model is drawn under; what `func_020709ac` gives.
- That the battle holds 30 updates a second — a rising number should last about 1.24 s.
