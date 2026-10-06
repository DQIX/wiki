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

### How a status runs down

Two counts, and two functions, both run after each action for the one who acted (`func_ov000_02157d3c`):

- **The count** — the status's byte at `+0x5c + n`, set by its setter: attack 5 (`+0x6e`), defence 6, agility 6, charm 6, might, mending and the two wards 5, Fizzle 6 (`+0x60`), 0 Zone 5 (`+0x78`), Rough 'n' Tumble 5 (`+0x79`), paralysis 3 (`+0x5c`). `func_ov000_021599f4` takes one off every status held on each of its holder's passes; at 0 it starts **the second count** at `+0x7f + n` — 4, or 1 for 0 Zone and Rough 'n' Tumble (the table at `data_ov000_02182efc`, 26 pairs). No draw.
- **The wear-off** — `func_ov000_0215858c`, just before it on the same pass: its first draw `R(100)` always (`0x021585bc`); then, in the order of its blocks (Fizzle `+0x83` … attack `+0x91`, defence, agility, charm, might, mending, spells `+0x97`, breaths, … 0 Zone `+0x9b`, Rough 'n' Tumble `+0x9c`), each status with its second count running: that count less one, **a draw of its own** `R(100) / 100`, and the status cleared, its line said, where the table by the count is above the draw — `0x02182ad4` (1.0, 0.875, 0.75, 0.625) for most, `0x02182bd4` (1.0, 0.875, 0.625, 0.375) for the ward against spells, 0 Zone and Rough 'n' Tumble.

So a level of defence holds its holder's next six passes, then wears off by 63, 75, 88 and 100 in 100 over the four after; 0 Zone holds five passes and goes on the sixth. Lines: attack `0x1ce`, defence `0x1cf`, charm `0x1d0`, might `0x1d1`, mending `0x1d2`, spells `0x1d3`, breaths `0x1d4`, agility `0x1db`, Fizzle `0x1d6`, 0 Zone `0x1c5`, Rough 'n' Tumble `0x1da`.

**Paralysis** goes otherwise: its count runs down the same way, but its second (`+0x7f`, from 4) is looked up at the start of each of its holder's turns, against `0x02182ad4` and the turn-start draw (`func_ov000_0215833c`), which frees them — action 900, "is no longer paralysed" — as the same function wakes a sleeper (`+0x80`, `0x02182bd4`, action 901).

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

## The lost turn — status bit 19

`+0x14` bit 19, its kind at `+0x22` bits 2–5 (`func_02088474`). Its holder **cannot act** (`func_ov000_02155f9c`, beside paralysis, bit 3, and sleep, bit 4): they cannot dodge, block or choose, and on their turn action 503 — nameless, with no line — takes their action's place (`func_ov000_0215767c`, `0x02157ac0`), which marks `+0x3b` bit 1; the run-down after that turn clears it first (`0x021585d4`). One turn lost.

**Rider 1** (`func_ov024_021e2bd0`) sets it: from a blow that dealt something, the target's byte `+0x4c` (element 15) not 0, a draw under the action's chance times the byte (the byte passed over for `0x239` and Roaring Tirade); from **kind 10** (`021dc0b8`) none of that. The record's `+0x32` names the kind — 2 a fall off its feet, 3 Pratfall's, 4 a dance's, 5 terror — from the table at `data_ov024_021fe820`, which knows 2 to 8; 2 is refused where `mon_data +0x0A` bit 11 is set. One may take it (`func_02088418`) who stands, is not paralysed, is not at the maximum of tension — but for the coups `0x1fc` and `0x20f` — and is not under the same kind. It takes their tension away (`0x25c`, `func_ov024_021e8cfc`). From a blow, kind 2 says `0x150`, 5 `0x5e`.

## Paralysis — rider 11

`func_ov024_021e3a34`: from a blow that dealt something, the target's byte `+0x4e` (element 17) not 0 — for action `0x52` on family 9 alone at a flat 25, for `0x58` at a flat 12.5 on a metal body — on one standing and not at the maximum of tension, a draw under the chance times the byte. `func_0208826c` takes tension, a lost turn and sleep away and sets bit 3 with a count of 3; "is paralysed!" (`0x1e`), or "is frozen even further" (`0x6e`). See "How a status runs down" for how it goes.

## The coups

Each by its kind's handler; `func_02088xxx` and `02089xxx` are the statuses' tests and setters.

| coup | kind | what it does |
|---|---|---|
| 0 Zone | 68, `021e1580` | `+0x18` bit 9, count 5: its holder's MP is neither asked (`func_ov024_021eaa50`, `0x021eabd8`) nor spent |
| Rough 'n' Tumble | 70, `021e1824` | `+0x18` bit 10, count 5: a dodge on the pass's die under 50 with no draw of its own (`func_ov000_02156f98`); evasion 50.0; a counter on the die 50 to 74 |
| Brownie Boost | 74, `021e1ed4` | defence, the ward against breaths and attack a level up each, no test of its landing |
| Spelly Breath | 26, `021ddf5c` | MP back: damage handler 48 (`021d974c`), the most MP times `NextRandomFloatBetween(0.2, 0.5)` |
| Itemised Kill | 69, `021e16a4` | the group's `+0x16`: the ordinary drop's chance one in 1 in the drop roll's first pass (`func_ov023_021f454c`, `0x021f4ab0`); fails on a group already marked or an ordinary drop of step 7; a draw under 100 (50 in a grotto's or legacy boss's battle) |
| Voice of Experience | 72, `021e1cbc` | the resolver draws `NextRandomFloatScaled(1.1, min(2.0, 1 + (level + 11) × 0.01), 1)` (`0x021eba20`) into `battle + 0x8e3c`, which the victory multiplies the experience by |
| Knight Watch | 73, `021e1de8` | each monster, a count `NextRandomBetween(record +0x28, +0x29)`: `+0x18` bit 12 and the Paladin at `+0x2e`; its weighted pick takes the Paladin with no draw while they stand (`func_ov000_02154f30`); it goes as the count runs out on its own passes, or when the Paladin is down; line `0x164` |
| Roaring Tirade, Disco Tech | 10 | a lost turn of kind 5 and 4 on every monster — see above |
| Choir of Angels, Tension Boost | 67, 71 | as above |

## The round's end

`func_ov000_0215e6e8` clears each one's guard, then calls `func_ov000_0215a23c` — what is given back and tolled — and then, unless `battle + 0x8e14` is set, `func_ov000_02157e1c`, the count-down.

- **`0215a23c`**: for the party standing (`func_ov000_0215e9fc` with 1), HP — 25 where `func_02085230` holds of their record, plus under **Right as Rain** (`+0x14` bit 31) the larger of 10 and half their level in their vocation (`func_0202053c`, `asr #1`); then MP — under **Focus Pocus** (`+0x14` bit 30) the larger of 3 and a tenth of that level, plus trait `0x3f`'s; then envenomation's toll. Given by `func_ov000_0215a16c` and `0215a1d4`, held to the most, told by `func_ov000_0215c758` as actions 930–934 only where something was given. Then the monsters' Focus Pocus (`func_ov000_02159dbc`) and toll.
- **`02157e1c`**: **a draw `R(100) / 100` at its head, every round** (`0x02157ea8`), kept for `+0x18` bit 6's wearing off. Then for each one standing: Focus Pocus (`+0x68`, second `+0x8b`) and Right as Rain (`+0x69`, `+0x8c`) — a draw of each holder's own first, whichever count runs; with the second count running, it less one and the status cleared where `0x02182ad4` by it is above the draw (lines `0x1c8`, `0x24c`), else the first less one and at 0 the second set to 4. Then `+0x18` bit 11 (its own draw, line `0x249`) and bit 6 (the head's draw against `0x02182bd4`), and the coup de grâce counted down.

## Statuses: what each does

Each set by the simple shape — on one who may take it (`+0x14` bit 0 clear), landed, the setter and the done line; else the fail line.

| status | kind, handler | set | what it does |
|---|---|---|---|
| Right as Rain | 48, `021e01b8` | `+0x14` bit 31, 6 at `+0x69` | HP at the round's end, above |
| Focus Pocus | 78, `021e268c` | `+0x14` bit 30, 6 at `+0x68` | MP at the round's end, above |
| Vanish | 54, `021e093c` | `+0x14` bit 27, 5 at `+0x62` | in a monster's weighted pick (`func_ov000_02154f30`, `0x021550ac`–`0x021550c0`) the holder's weight is halved **after** it is added to the total, so the draw may pass every weight and fall to the even draw after; two of the party at 2, one vanished: 3 in 8 for them |
| dazzle (Flower Power, Scandal Eyes) | 19, `021dd534` | `+0x14` bit 6, 4 at `+0x5f`, the record's `+0x30` at `+0x22` bits 6–8 | the last step of the accuracy roll (`func_ov000_02156648`, `0x02156a90`–`0x02156ac8`): for an action with `+0x10` bit 3 — 110 of 681, the Attack among them — a dazzled striker throws `R(8)` and misses under 5. A miss works no damage out (`0x021ec4e8`). The sorts' lines (`func_ov024_021e9198`): 1 hallucinating `0x26`/`0x27`, 2 dazzled `0x140`/`0x141`, 3 sand `0x126`/`0x137`, 4 ink `0x13d`/`0x13f` |
| Schizofanic, Mist Me | 36 `021dec50`, 55 `021e0a50` | `+0x14` bit 20 or 21, each clearing the other, no count; may take also needs `+0x18` bit 6 clear | the head of the accuracy roll, before any draw and before the sure flag (`0x02156714`–`0x02156788`): an action a shield may block (`+0x10` bit 6) at its holder misses, flagged 8 or `0x10`, and the decoy goes |
| Rotstopper | 40, `021df0f0` | `+0x14` bit 29, 4 at `+0x64` | the final damage (`func_ov024_021e6a90`, `0x021e74f8`–`0x021e7530`): times `0.5f` where the dealer is a monster of family 8 (`func_ov000_02156068` with 8 and 0), after the resistance and the killer bonuses, before the wards |
| Alma Mater | 39, `021deff8` | `+0x14` bit 22, 6 at `+0x67` | the heavenly protection: Whack, Thwack, Kathwack and Kamikazee (`data_ov024_021fe6e0`; `func_ov024_021ea78c`) and the death rider leave its holder 1 HP, say `0xc8` "…'s heavenly protection keeps the reaper at bay for now", and clear it |
| Holy Impregnable | 64, `021e1120` | `+0x18` bit 3, 5 at `+0x6b` | the resistance (`func_ov000_02156b38`, read whole: byte plus an adjustment, held at 0, over 100, in floats): −25 for the elements 9–21; none for the Attack's 8; elements 1–7 take their own statuses' −50 in its place (`func_020886b0` to `020887d0`); `+0x18` bit 31 gives +25 |
| Feel the Burn | 47, `021e00c0` | `+0x14` bit 28, 4 at `+0x63` | after a pass of kind 1 or `0x23` that dealt something, its holder is marked (`+0x22` bit 14, `0x021ecab4`); `func_ov000_0215b5a0` draws `R(100)` against a table by their tension, and under it their tension goes a level up (action 928). Where it runs among the round's draws is not read |

**The order of the run-down after a pass** (`func_ov000_0215858c`): Knight Watch, dazzle (`+0x82`, second table, line `0x1c7`), Fizzle, Bounce (`+0x84`, first), Vanish (`+0x85`, second, `0x1c9`), Feel the Burn (`+0x86`, second, `0x1d7`), Rotstopper (`+0x87`, second, `0x1d8`), Reverse Cycle (`+0x89`, first, `0x1c4`), Alma Mater (`+0x8a`, first, `0x1cb`), `+0x8d`, …, Holy Impregnable (`+0x8e`, first, `0x25d`), …, then attack's. Second counts start at 4 (`data_ov000_02182efc`), but 0 Zone's and Rough 'n' Tumble's at 1.

## Not yet read

- What the statuses of kinds 32 (Reverse Cycle, in the redirection `func_ov024_021e9f68` at `0x021ea12c`), 37 (Immense Defence, a level at `+0x58` bits 24–26) and 63 (Twocus Pocus, `+0x18` bit 8) do — what each setter stores is in minstrel's `docs/readings/T18-handlers.md` §10; and kind 0's six stances, the Pathies, Fuddle, Tap Dance, Mens Sana, Half-Inch, Eye for Trouble, the Fources and the rest of §7's table.
- Where Mist Me's taking of a blow is told — actmsg `0x1b9`, "The mist surrounding <TARGET> absorbs the attack and disperses", by its words — and Schizofanic's.
- The riders 5, 6, 9, 10, 12–14, 19 and 21.
- Bounce and Magic Mirror's reflection past what is above (`func_ov024_021e9f68`), and its lines 169 and 170.
- What the game shows on a lost or paralysed turn.
