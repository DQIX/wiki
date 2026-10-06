# Ability handlers

What an ability or a spell does once it has landed, by its **kind** and the **rider** on its blow, and the lines its record carries. Read 6 October 2026.

> **USA only** for the code (overlays 0 and 24 and the ARM9), read through the [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the action counts and lines, from the action tables (see [Actions](Actions)).

## The kind table

The resolver (`func_ov024_021eb5d0`, see [Battle resolution](Battle-Resolution)) calls one handler per target through 81 pointers-to-member at `data_ov024_021ff508`, indexed by the action's kind (`+0x18` bits 5–11). Each is handed **whether the action landed** — the accuracy roll's answer — and none makes a draw of its own: the chance of a change of state is its accuracy.

| kind | handler | what it does | for instance |
|---|---|---|---|
| 1 | `021da9e0` | a blow or an attacking spell: the damage handlers (`0x021ff1e0`) and the rider | Attack, Frizz, Dragon Slash |
| 2 | `021db3a4` | a heal | Heal, Meditation |
| 3, 4, 5 | `021db5ec`, `021db7c0`, `021db994` | attack, defence, agility moved by `+0x30` (held to ±2), the rider first | Oomph, Blunt; Buff, Sap, Kasap; Accelerate |
| 6 | `021dbaf4` | poison, or envenomation where `+0x30` is above 0 | Poison Breath; Venom Mist |
| 7 | `021dbc64` | both poisons cured | Squelch |
| 8 | `021dbd84` | sleep, which takes tension away | Snooze |
| 9 | `021dbf18` | a sleeper woken | Cock-a-doodle-doo, Sobering Slap |
| 15 | `021dc93c` | tension up `+0x30` steps, a coin from 3 | Psyche Up, Egg On |
| 17 | `021dd028` | all HP taken, unless heavenly protection spares one on 1 HP | Whack, Thwack, Kathwack |
| 18 | `021dd278` | the fallen raised with a share of their most HP | Zing, Kazing, the Zing stick |
| 67 | `021e13e0` | the party healed 0.4 of their most HP (rounded half up, at least 75) and every misfortune cleared | Choir of Angels |
| 71 | `021e191c` | tension straight to 4, each level told | Tension Boost |

The rest of the 81, with the actions on each, are listed in minstrel's [`docs/readings/T18-handlers.md`](https://github.com/Moss255/minstrel/blob/main/docs/readings/T18-handlers.md) §7. Slots 30, 34, 59 and 60 are empty.

### The levels

Status `+0x58` holds three signed levels: **attack bits 0–2, defence 3–5, agility 6–8**. Setting one stores a count — attack 5 at `+0x6e`, defence and agility 6 at `+0x6f`, `+0x70` — and a flag in `+0x14` (`0x400`, `0x800`, `0x1000`). A raise may move a level below 2, a fall one above −2; a sum of 0 clears it.

**Attack moves a quarter a level** — `CalculateAttackBuffMultiplier` is `1 + 0.25 × level` — where defence and agility move a half (a quarter and a half down). `UpdateCombatantAttack` truncates the product, at most 999 for one of the party.

A level's line comes from the level it reaches (`func_ov024_021e94c4`): to ±2 "a lot", to 0 "returns to normal", else "a little" — attack `actmsg` `0x47`–`0x4b`, defence `0x3a`–`0x3e`, agility `0x4c`–`0x50`.

### More levels: might, mending, and the resistances to spells and breaths

Four more handlers have the same shape over their own bits of `+0x58`, each with a count of 5 and a flag in `+0x14`:

| kind | handler | actions | bits | count, flag |
|---|---|---|---|---|
| 42 | `func_ov024_021df284` | Channel Anger, Caster Sugar | 12–14, magical might | `+0x72`, bit 14 |
| 38 | `func_ov024_021dee84` | Care Prayer | 15–17, magical mending | `+0x73`, bit 15 |
| 22 | `func_ov024_021dd968` | Wizard Ward, Spooky Aura | 18–20, resistance to spells | `+0x74`, bit 16 |
| 23 | `func_ov024_021ddaa0` | Insulate, Insulatle, Mind Over Matter | 21–23, resistance to breaths | `+0x75`, bit 17 |

Might and mending are worked out again at `1 + 0.5 × level`, truncated, at most 999 for anyone (`UpdateCombatantMagicalMight`, `…Mending`). The resistances act in the final damage (`func_ov024_021e6a90`): a **spell** — an action with `+0x10` bit 0 — not of kind 2, against one with `+0x14` bit 16, is multiplied by `1 + (−0.25 × level)` (`func_020748d0`, `0x021e7534`); then a **breath** — `+0x10` bit 2 — against bit 17, by the same of the breaths level (`func_020748a8`, `0x021e7588`). Both come after the element's resistance and before the guard. `+0x10` bit 1 marks a dance.

The lines: might `0xd0`/`0xd1` up, `0x1b5`/`0x1b6` down, `0x1b7` normal (`func_ov024_021e9904`); mending `0xc4`/`0xc5` up, **nothing for a fall** (`021e9990`); spells `0xab`–`0xaf` (`021e97f4`), and "But nothing happens" (`0x1f`) for a fall that landed on one already at −2; breaths `0x1b0`/`0x1b1` up, `0x1ae` down — **no "a lot" for a fall** — `0x1af` normal (kind 23's own).

### How a level runs down

`func_ov000_0215858c`, for each status with its flag set and its count not 0: the count less one, then a draw `R(100) / 100` against the table at `0x02182ad4` by the count — 1.0, 0.875, 0.75, 0.625, and at 4 a denormal only a draw of 0 is under. Under it the status clears and its line is said: attack `0x1ce`, defence `0x1cf`, charm `0x1d0`, might `0x1d1`, mending `0x1d2`, spells `0x1d3`, breaths `0x1d4`, agility `0x1db`, Fizzle `0x1d6`. A count of 5 wears off by 1 in 100 after its first round, then 63, 75, 88 and 100.

### Wave of Relief, Antimagic, Tingle

- **Wave of Relief** (kind 41, `func_ov024_021df1e8`): the cure-all (`func_ov024_021eae14`) on each one reached, no landing test. The cure-all clears sleep, the poisons, paralysis, Fizzle, many statuses, and every level below 0.
- **Antimagic** (kind 16, `func_ov024_021dced0`): Fizzle, `+0x14` bit 8, a count of 6 at `+0x60`; on one already fizzled, "further prevented" (`0x19`, `0x1a`). A fizzled caster's spell is put out as **action 914** — "tries to cast … but can't cast spells at the moment" — after the MP is asked (`func_ov024_021eaa50`, `0x021eacc4`).
- **Tingle** (kind 20, `func_ov024_021dd6f0`): frees one paralysed, `+0x14` bit 3.

### Raising the fallen

The share of the most HP, by the action (`0x021dd2fc`–`0x021dd3d0`):

- **Zing and the Zing stick**, cast by one of the party: a quarter at or under the record's `lo` (`+0x04` bits 12–21), a half at or over its `hi` (bits 22–31), and between `((int)((25 / (hi − lo)) × (mending − lo)) + 25) / 100`, in floats. Zing's own are 180 and 849. Cast by a monster, a half.
- **Kazing**: a half.
- Anything else: whole.

## The rider table

22 pointers-to-member at `data_ov024_021ff450`, by `+0x18` bits 0–4, dispatched by `func_ov024_021e4b14` — from the blow's handler on each pass that dealt something, and from the kind handlers (3, 4, 5, 9) with "dealt" 1.

| rider | handler | shape |
|---|---|---|
| 2, 8 | `021e2ebc`, `021e3594` | a draw below 100 **first**; a fall lands under the target's own byte (`+0x4f`, `+0x50`) or on a critical — **the action's chance is not read**; a raise always. Double Up (`0xad`) skips the test |
| 4 | `021e303c` | poison, or envenomation where `+0x32` is above 0: nothing and no draw for a target whose byte `+0x4d` is 0 or who cannot take it; then a draw under the action's chance (one of the party's `+0x14` bits 7–13, a monster's bits 0–6) times the byte over 100, or 100 on a critical |
| 7 | `021e33a4` | sleep, the same with byte `+0x47` |
| 20 | `021e4604` | death: **not the action's chance** but a flat 12.5 (`0x021e47d0`) times byte `+0x48` over 100, or 100 on a critical. On a metal body (`func_ov000_02156068(…, 0, 1)`) the byte is passed over — a 0 does not refuse it — so the 12.5 stands |

**The bytes are resistances.** Status `+0x3E + element − 1` is the target's resistance to an element, and each rider's byte is the one for the element its change lands with: `+0x47` sleep (10), `+0x48` death (11), `+0x4d` poison (16), `+0x4f` attack down (18), `+0x50` defence down (19) — the landing elements of Snooze, Whack, Toxic Dagger, Blunt and Sap. A monster's come from its record, as its other resistances do.

## Poison and envenomation

Status `+0x14` bit 1 is poisoned; `+0x22`'s low two bits say which — **1 poison, 2 envenomation**. Nobody at the maximum of tension takes either, and plain poison does not take on the envenomated; the poisoned are poisoned again ("even more powerfully"). Squelch, the cure-all and reaching the maximum of tension clear both.

**Only envenomation is tolled in a battle**: at a round's end (`func_ov000_0215a23c`), a sixteenth of the most HP, at most 999 and at least 1. Nothing in the battle tests plain poison but to cure it, the AI and Victimiser's blow. The poison attack 275 envenomates.

## The record's lines

Three words of an action's record hold ten-bit `actmsg` numbers, the first of each pair for a target of the party (`func_ov024_021da644`):

| word | bits 0–9 | 10–19 | 20–29 |
|---|---|---|---|
| `+0x20` | opening | opening | done, at one of the party |
| `+0x24` | done, at a monster | failed, at one of the party | failed, at a monster |
| `+0x28` | killed, at one of the party | killed, at a monster | its critical |

The Attack's: 1, 1, 2 / 5, 4, 7 / 8, 9, 140. Whack's fail lines are 621 and 27, its kill lines 8 and 69. What [Actions](Actions) had as the effect byte at `+0x24` is the low byte of the done line at a monster.

## The skills that scale by the game's own table

`GetAttackBaseDamage` (`0x021e7bc0`), for one of the party whose action's amount scales (`+0x18` bits 16–17 at 2), takes the number the record names (`+0x10` bit 14 magical might, bit 15 mending) and the record's `lo` and `hi` (`+0x04` bits 12–21, 22–31) — and then looks the action up in a table of its own at `data_ov024_021fe8b6`: seven quads of `u16`, action, number, `lo`, `hi`, ending `−1`. A match takes the table's in place of the record's and goes through the same three arms: the least at or under `lo`, the most at or over `hi`, between them in proportion.

| action | number | `lo` – `hi` |
|---|---|---|
| 67 Gigaslash, 68 Gigagash, 74 Lightning Storm | record word 0 bits 0–9 + magical might | 500 – 1,998 |
| 102 Hand of God | record word 0 bits 0–9 | 300 – 999 |
| 114 Whopper Chop | record word 0 bits 0–9 | 250 – 600 |
| 144 Boulder Toss | record word 0 bits 0–9 + deftness | 500 – 1,998 |

The record is the character's at `[obj+0x150]`; its word 1 bits 0–9 is deftness (`RollCritical`). That word 0 bits 0–9 is strength is inferred from the level tables' order; magical might is the fighter's now (`[obj+0x138]+0x10` bits 10–19). Each sum is kept in sixteen bits, signed.

## Propeller Blade, Crosscutter Throw, Gold Rush

Kind 1 and damage handler 0, made theirs elsewhere:

- **Propeller Blade** (`0x61`): the resolver lists its one target twice (`0x021eb954`). On the second pass the result's critical, dodged and blocked bits are cleared — their draws spent — and the accuracy roll is handed a flag that lands it with no draw (`func_ov000_02156648`, `0x0215678c`). The kind-1 handler says line `0x1f0` on that pass.
- **Crosscutter Throw** (`0x79`): one more target, `func_ov000_0215cda0`'s — the standing monster whose place on the stage has the least first coordinate (`0x021eb974`).
- **Gold Rush** (479): post-step 6 (`func_ov024_021e5be4`) takes the record's `+0x32` — 1,000 — from the party's gold (`func_02010828()+0xf6c`) after the action, or from a monster's own. Before it, `func_ov024_021eaa50` puts action 935 (its opening, actmsg 580) in its place when there is not enough.

## A metal body

The tail of `func_ov024_021e6a90` zeroes a non-critical blow on a metal body when the action carries `+0x10` bit 24 and is aimed at the monsters (`+0x08` bits 8–9 at 1) — not `0x205`, not Needle Shot (`0x82`); the 0-or-1 coin follows.

## Not yet read

- The handlers of the kinds above not in the table, and the riders 1, 5, 6, 9–14, 19 and 21.
- Bounce and Magic Mirror's reflection past what is above (`func_ov024_021e9f68`), and its lines 169 and 170.
