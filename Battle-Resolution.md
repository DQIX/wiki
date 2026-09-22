# Battle resolution

How the game resolves one action in a battle: which random numbers it draws, in what order, and what it does with them. This page is about **code**, where the rest of this wiki is about files — it is here because it is what gives a meaning to fields of the [action table](Actions), the [monster data](Monsters) and the [item stats](Items) that could not be read from their values alone.

Everything on this page was read from the disassembled ARM9 binary and overlays 0 and 24, with the symbol names of the DQIX decompilation project. **Addresses are the USA release's.** Overlays 0 and 24 were found at the same addresses in the European release; the ARM9 binary was not compared throughout, and at least one region of it sits `0x10` higher there. Functions with a name are the decomp's; `func_…` are unnamed there, and the name given in brackets is the one proposed to it.

Where something is marked INFERRED it was not read from code that names it but from what carries it.

## The two random generators

Both are the same 64-bit linear congruential generator (`src/Util/Random.cpp` in the decomp): `state = state × 0x5D588B656C078965 + 0x269EC3`, the draw its top 32 bits. The generator **steps and then draws**.

| | where | seeded | what draws from it |
|---|---|---|---|
| the battle's | the head of the battle object; every roll below is handed the object itself as its `Random*` | when the battle is made, from `GetCurrentTimestamp()` — `InitRandom` at overlay 0 `0x0215d070`. A thunk at `0x0215faa4` re-seeds it from two words, and `0x02160600` reads its state out | every roll on this page but one |
| the world's | a global at `0x02108ddc`, which `GetBTRandom()` returns | once, when the game state is made (`0x0200f540`) | the field (overlay 17), thirty callers in all — **and a monster's HP** |

The helpers, all in 32-bit floats:

- `NextRandomFloat01` — `(float)(next / (double)0xFFFFFFFF)`.
- `NextRandomMax(n)` — `(int)(n × float01)`, held below `n`.
- `NextRandomFloatBetween(a, b)` — `(b − a) × float01 + a`.

**The battle's arithmetic is in `float`, and the rounding is part of the answer.** `0.01f` is not a hundredth: a critical threshold computed in doubles or integers is off by one at 151 of the 850 deftness values past 150.

## A monster's HP

`func_02089630` [`InitMonsterBattleStatus`] builds a monster's battle status from its record in `mon_btldata.nat` (see [Monsters](Monsters)). Its HP is

```
(int)(0.5f + (float)HP × NextRandomFloatBetween(0.8f, 1.0f))
```

one draw **from the world's generator**, and the result is both its HP and its maximum. The table's HP is a ceiling: a slime's 8 comes to 6, 7 or 8. The draw is skipped, and the table's HP used, when the battle's setup holds a number other than −1 at `+0x0C` (`func_020a3694`) — INFERRED: a scripted battle's number.

## The order of draws for one action — `func_ov024_021eb5d0` [`ResolveAction`]

One function resolves every action — a blow, a spell, an item, a change of state. It loops over the targets itself.

1. Four actions draw before any target is looked at: `0x1FF`, `0x200`, `0x20B`, `0x20C`. Not followed.
2. **The critical roll, once for the whole action**, if `func_ov024_021ea4d0` or `func_ov024_021ea500` says so: the action's reach (`+0x14`, top four bits) is 3 or 4 — all, or a group — and `+0x1C` bits 14–18 are 0; or it is the plain Attack from a party member whose weapon strikes more than one.
3. Then, **for each target**:
   1. `NextRandomMax(100)`, kept at `[battle + 0x8e6e]` (`0x021ebf28`). Made for every action. Read only by the evasion roll and by `func_ov000_02156558`, in place of a draw of their own, for a target in a state `func_ov000_02156404` tests (under 50 dodges; 50 to 74 does the other's thing). What state is not established.
   2. **The critical roll**, if it was not made for the whole action. Actions `0x48` (Thunder Thrust) and `0x70` (Hatchet Man) take `NextRandomMax(2) == 0` instead.
   3. **The evasion roll**, if the action can be dodged (`+0x10` bit 5).
   4. **The block roll**, if it can be blocked (`+0x10` bit 6) — **skipped for a blow already dodged**.
   5. **The accuracy roll** — always, dodged or not.
   6. If it landed, **the amount** — `GetAttackBaseDamage` — **even for a blow that was dodged or blocked**. The dodge and the block ride along as flags and zero the damage later.
   7. The damage handler (`func_ov024_021da55c` [`DispatchDamageHandler`]: 67 member pointers at `0x021ff1e0` [`damageHandlers`], indexed by the action's `+0x18` bits 18–26; slot 0 is none and 570 of 681 actions are on it).
   8. The handler for the action's **kind** (`+0x18` bits 5–11), from a table at `0x021ff508` [`actionKindHandlers`]. Kind 1 calls `func_ov024_021e6a90` [`CalculateFinalDamage`]; kinds 3, 4, 5, 6, 8 … apply a change of state.

So a plain blow that lands costs: the die, the critical, the dodge, the block, the accuracy, and the damage's own one or two draws. A spell at one target costs the die, the critical, the accuracy and its amount. A spell at three costs one critical and then a die, an accuracy and an amount apiece.

Two more `NextRandomMax(100)` at `0x021ecfd8` and `0x021ed324`, for a party member `func_ov024_021eb1ec` picks out, are not followed.

## The critical roll — `func_ov000_02156cc4` [`RollCritical`]

`NextRandomMax(10000) < (int)(100.0f × rate)`. An action that is always a critical (`+0x08` bit 29) returns 1 **without a draw**.

**A party member's rate** is `CalculateCritRate` (`src/Combat/Main/CritRateCalculation.cpp`):

```
(1 / hits) × skill × (2.0 + 0.01 × max(0, deftness − 150) + accessory + book)
```

`skill` is the action's `+0x14` bits 21–27 over `100.0f`: **100 on the plain Attack, 50 on the spells** (one in a hundred, going haywire), 0 on items. Deftness counts only past 150. The rate is doubled for a character with trait `0x11d` when `func_ov000_02155a04` of them is under `0.25f`; what that is, is not established.

**A monster's rate** is `func_020748f8` [`CalculateMonsterCritRate`]: `(1 / hits) × (0.0f × skill)` — a literal zero. A monster never criticals through this roll, blow or spell, and the draw is spent all the same.

## The evasion roll — `func_ov000_02156f98` [`RollEvasion`]

`NextRandomMax(100) < (int)rate` — the rate **truncated**. The rate is `func_ov000_02156270` [`GetEvasionRate`]: a party member's is `2.0` plus what they wear (`func_02084f58` [`SumEquipmentEvasion`], see [Items](Items)) and bonuses; a monster's is a grade in its record through the table **0, 2, 4, 8, 25**.

## The block roll — `func_ov000_02156e30` [`RollBlock`]

`(float)NextRandomMax(100) < rate` — the rate **not truncated**. The rate is `func_ov000_02156118` [`GetBlockRate`]: nothing for a party member with no shield; with one, `func_02084ee8` [`SumEquipmentBlockChance`] — ten bits of every worn piece's record over `10.0f`, summed (see [Items](Items)) — plus a whole-number bonus from three traits (`func_02085b88`), doubled under one status. A monster's is a second grade, bits 16–18, through the same table as its evasion.

Because the rate is not truncated, the bronze shield's 0.5 and the iron shield's 1.0 both block on a draw of 0 — once in a hundred — and the steel shield's 1.5 on 0 or 1.

## The accuracy roll — `func_ov000_02156648` [`RollAccuracy`]

Before any draw it leaves with a miss for a metal-bodied target under an action that does not work on one (`+0x10` bit 24), and for a few of the target's statuses. Then:

1. **`NextRandomMax(100)` is drawn before anything is compared.** An action whose accuracy stands at a hundred lands every time and spends the draw.
2. For a party member with a certain trait, on an action flagged `+0x10` bit 16: a die of 4 that misses on 0.
3. If the action's accuracy **scales** (`+0x18` bits 16–17 at 1):
   - **a monster's** accuracy is `+0x14` bits 0–6;
   - **a party member's** runs from bits 7–13 to bits 14–20 as their magical might (`+0x10` bit 14) or mending (bit 15) runs from `+0x04` bits 12–21 to bits 22–31 — `(int)((stat − lo) × ((max − min) / (hi − lo))) + min` — or, where the action names neither, is *drawn* between the two and truncated: one more draw;
   - if the target's resistance to the action's landing element (`+0x18` bits 27–31) is above 0 and the cast was a critical, **it lands outright**;
   - otherwise `accuracy = accuracy × resistance + 0.5f`.
4. For an action spoilt by a status on the attacker (`+0x10` bit 3 — INFERRED: dazzle) while they are under it: a die of 8 that misses on 0 to 4.
5. It lands when the draw is under `(int)accuracy`.

**This is the whole of whether a change of state lands.** The kind handlers for Sap, Snooze and their like (`func_ov024_021db7c0` for defence) make no draw: they are handed the answer. So Kasap's 75 in 100 and Sweet Breath's 25 are those actions' `+0x14` bits 0–6 — and what *raises* a stat does not scale, so it always lands.

## The amount — `GetAttackBaseDamage` (overlay 24, `0x021e7bc0`)

**With no range** (a blow): the attacker's attack power, times a multiplier, through `RoundUp` (`0.5f + x`), into `CalculatePhysicalDamage(attack, defence)`:

```
d = (attack − defence / 2) / 2                      nothing if not above 0
if d > attack / 16:  d += between(−d/16, d/16);  d += between(−1, 1)     two draws
else:                d  = between(0, attack/16)                           one draw
```

**With a range** (see [Actions](Actions), the range table):

| who | the amount | draws |
|---|---|---|
| a monster | word 1 bits 0–9, plus `between(−spread, spread)` | 1 |
| a party member, the action's amount scaling (`+0x18` bits 16–17 at **2**) by a number it names (`+0x10` bit 14 might, bit 15 mending) | bits 10–19 at or under `lo`, bits 20–29 at or over `hi`, `(int)((stat − lo) × ((max − min) / (hi − lo))) + min` between; plus the spread's draw | 1 |
| a party member otherwise | **drawn** between bits 10–19 and bits 20–29, *then* the spread's draw | 2 |

Every arm returns through a truncation. `lo` and `hi` are the action's `+0x04` bits 12–21 and 22–31: Frizz is 14 to 99 as might goes from 50 to 999. The medicinal herb names no number, so it costs two draws, the first between 35 and 35.

Six skills scale by a number made from the user's and what they hold, by a table at `0x021fe8b6` [`skillAmountScaling`]: Gigaslash, Gigagash, Lightning Storm and Boulder Toss 500 to 1,998; Hand of God 300 to 999; Whopper Chop 250 to 600. Not followed.

## The final damage — `func_ov024_021e6a90` [`CalculateFinalDamage`]

A float to the end. In order:

1. **A critical**: the greatest of `1.2 × damage`, `func_02074838` [`CalculateCriticalDamage`], and a floor. For the plain Attack (and actions `0xDB`, `0x1F9`) that is the *attacker's attack power* × `between(0.95, 1.05)` with the damage itself as the floor; for anything else it is the damage × `between(1.5, 2.0)` with no floor.
2. **× the target's resistance** to the action's element (`+0x08` bits 22–26) — `0x021e6e8c`.
3. For a party attacker with an elemental weapon, on an action with `+0x10` bit 18, a second product by the weapon's element. Not followed.
4. **Blocked, then dodged, each zero it** (`0x021e777c`, `0x021e77a0`).
5. **A metal body zeroes it** (`0x021e77a4`): a target whose record's `+0x0A` bit 12 is set — `func_ov000_02156068(battle, target, 0, 1)`, and never a party member — under an action that **carries** `+0x10` bit 24 and is of kind 1 (or is action `0xDB`), where the blow is not a critical and the action is not `0x205` or `0x82`. The damage becomes exactly 0. Note the polarity: the flag must be *set* for the zeroing, so it reads less like "works on metal" than like "deals damage at all".
6. **The coin**: if the damage is not above 0, and it was not blocked or dodged, the action is not `0x70`, `0x48` or `0x1B` (Kamikazee), the target's resistance is above 0, and the target is not a metal body under an action that does not work on one — `(float)NextRandomMax(2)`. **Whoever struck it**: no test of the attacker's side.
7. Metal Slash (`0x40`) and Metalicker (`0x7E`) on a metal body, not critical: `1.0f + NextRandomMax(2)`.
8. `× 0.5f` for an action of kind 1 whose target carries status bit `0x1000000`. This page once read that as defending; **it is maximum tension** — see below. Defending is a guard level, and is applied earlier, at step 6 of the tail.
9. **The combo table** at `0x021fe778` — `1.0, 1.2, 1.5, 2.0` — for an action with `+0x2C` bit 27 and damage of at least 1, indexed by a counter byte at `[battle + 0x8e83]` held to 3. Anything else resets that counter (`func_ov000_0215cd80`). What increments it was not followed.
10. Truncated, and held to the action's cap (`+0x1C` low 14 bits, where not 0).
11. Action `0xAF` (Double-Edged Slash) has a quarter of the number kept — INFERRED: its recoil.

Between the resistance and the guard sit the wards and the slayer multipliers: `× 0.75` of fire or of ice for a target under status `+0x18` bit 1 or bit 2 (five turns each); `× 0.5` under status `+0x14` bit `0x20000000` (four turns) when the **attacker** is a monster of one family; and twelve family-slayer products for a party attacker, gated by `func_ov000_02156068(battle, target, N, 0)` for N of 1 to 12 against what they hold. A party member with a certain skill adds **1** to the damage against a metal body (`+0x10` bit 18).

A blow that strikes several weakens as it goes, by `func_02074948` [`GetMultiTargetFalloff`]: **1.0, 0.8, 0.6, 0.4, 0.2**, for actions with `+0x10` bit 17; and action `0x79` deals four fifths.

## Defending — the guard level

A byte on the combatant's battle status, **`[combatant + 0x138] + 0x21`**, from 0 to 3. `func_ov024_021e57c0` sets it to **1**, and is reached only through the action's sub-effect table at `0x021ff3f8` (entry 2); the round's end clears it for everyone (`func_ov000_0215e6e8` at `0x0215e7c8`), and the statuses that wake a combatant clear it too.

`CalculateFinalDamage` reads it at step 6 of the tail, where the action carries **`+0x10` bit 4** and a battle flag at `[battle + 0x8e94]` is 0:

```
damage × {1.0f, 0.5f, 0.1f, 0.0f}[guardLevel]      ; the table at 0x020e88c0
```

So **defending is an exact half**. Three things follow, each of which had been guessed at:

- it is applied **before** the 0-or-1 coin at step 6 of the list above, so a defended blow that comes to nothing still deals 0 or 1;
- the code never asks whose blow it is: a **guarding monster halves the party's blow** as well;
- **243 of the 681 actions carry `+0x10` bit 4** — the plain Attack, Frizz and Crack among them; Heal, the medicinal herb and Kasap do not, so defending does nothing against them.

Nothing was found that sets levels 2 or 3, whose multipliers are a tenth and nothing.

## Tension — status bits `0x800000` and `0x1000000`

The byte at **`[status + 0x24]`** is the tension level, 0 to 4. `func_02088220` sets `0x800000` and stores levels 1 to 3; `func_02088150` sets `0x1000000` and stores **4**. Every caller of the second is the psyche-up ladder (`func_0208767c`, and `func_ov024_021dc93c`, which emits messages `0x31`, `0x32`, `0x33` for the first three levels and `0x34` for the fourth). Both bits are cleared once their carrier acts (`ResolveAction` at `0x021ed55c`), and the level decays a step at a time (`func_02087704`), swapping `0x1000000` for `0x800000` at 3.

The level indexes ten floats at `0x020e88f8` through `func_02074738(level, isMonster)` — **1.0, 1.5, 2.5, 4.0, 6.0** for the party and **1.0, 1.3, 2.0, 3.0, 4.5** for a monster, held at 1.0 — which multiplies the damage at step 17 of the tail. The symbol immediately after that function in the ARM9 is `CalculateTensionBonus`.

That also explains the bit on the **attacker**: at the head of `CalculateFinalDamage` it writes a message code for tension spent on a blow that did nothing (1 psyched up, 2 at maximum).

## A monster's drops — `func_ov023_021f454c`

In **overlay 23**, called from the victory routine `func_ov023_021edf54` at `0x021ee2ec`, once the experience and gold are settled.

It walks **the kinds of monster beaten** — a list of up to 12 at `[battle + 0x8d66]`, built by `func_ov000_02155184` as each monster leaves the field, which counts how many of the kind were registered and how many got away. An entry whose monsters all fled is skipped. For each kind:

1. the **rare** drop is rolled first — the item at the record's `+0x06`, its chance the step byte at `+0x03`;
2. the **ordinary** drop only if the rare did not land — the item at `+0x04`, its chance the byte at `+0x02`.

Each roll is `func_02032370(oneIn) == 0`, where `oneIn` is the table of eight words at `0x021fd888`:

| step | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| one in | 1 (always) | 8 | 16 | 32 | 64 | 128 | 256 | 0 (never) |

**The generator is the C library's `rand`** (`0x02003d14`, `seed × 0x41C64E6D + 0x3039`, the draw its bits 16 to 30), not the battle's and not the world's: a drop spends none of the battle's own numbers. `GetBTRandom()` is called in the same function, but only for a grotto or legacy boss's drop. The collected list is capped at 8, and four further passes follow the first — one for each standing party member above half its HP, at a rescaled chance — which are the series' item-finding abilities.

Nothing in the battle seeds `rand`; twelve places elsewhere do, two from a clock and the rest deterministically for generating grottoes, floors and treasure maps.

## The party fleeing — `func_ov000_0215f7a8`

The player's Flee **never becomes an action**: the command short-circuits in the command overlay (`func_ov026_021dd3dc`, where the chosen command id 6 is Flee), which is why the action tables are the wrong place to look for it. That function calls this one once, for the members who chose it. In order:

1. the battle's setup forbids it — `[battle + 0xe18] + 0x0C` not negative — and it never lets go;
2. a member of the party is one of Cock-a-doodle-doo, Zing or Kazing: no escape;
3. `[battle + 0xe20] == 0 && [battle + 0xe49] == 1` — **the party surprised the monsters on the first round**: away, with no draw;
4. every monster is dead or cannot act: away, with no draw;
5. **three times the monsters' mean of attack-and-defence not above the party's**: away, with no draw. The stats are the unbuffed ones at `[obj + 0x134] + 0x34` and `+0x36`;
6. otherwise a percentage: `(int)(deftness × 0.05f) + 10`, the greatest over the members fleeing, held up to the floor its attempt gives — the table at `0x02182c04`, **25, 50, 75, 100**, indexed by a counter at `[battle + 0xe1c]` that this call then increments — and `NextRandomMax(100) < it`.

**The draw is the world's generator**, `GetBTRandom()`. The table's fifth entry is 65535, which any draw passes, so a fifth attempt always gets away.

## How a fight opens — `func_ov017_021970a0`

`[battle + 0xe49]` is carried in from the encounter's own record: `func_ov000_0215d414` copies it from the setup's `+0x35`, and a scripted battle holds its value as a byte in its data. For a **wandering monster** it is decided as the two of them meet, in the encounter check `func_ov017_02196430`.

**Who was facing whom decides which way it can go.** The check measures each one's facing against the bearing to the other (`func_ov017_021a4754`) and calls it a turned back past **9007.6 of a turn of `0x10000` — 49.48°**:

| how they met | the party may surprise | the party may be surprised |
|---|---|---|
| face to face | `(int)(2 + 0.05 × deftness)` in a hundred | 2 in a hundred |
| the monster's back was turned | `(int)(12 + 0.05 × deftness)` | never |
| it reached the party from behind | never | 12 in a hundred |

The deftness is the highest among the party who can act — the same ten bits of the character record (`[obj + 0x150] + 0x04`, bits 0–9) that `RollCritical` hands `CalculateCritRate`. The draws are the **C library generator's**, as a drop's are: the battle has none of its own yet.

`[battle + 0xe20]`, which bypasses the whole of it in `ProcessCombatTurn`, is **the round counter** — so the surprise round is the first round and nothing more.

## Initiative, and the order of a round — `ProcessCombatTurn`

Inlined at `0x0215d800`. Every combatant that is not sitting the round out is scored

```
(float)agility × NextRandomFloatBetween(0.51f, 1.0f)
```

on the **buffed** agility (`[status + 0x0c]`, which `UpdateCombatantAgility` has just recomputed and held to 999), and the scores are sorted highest first by a quicksort over floats (`func_020749ac`) — so ties break arbitrarily. `0.51f` appears once in the whole build. One whom the opening leaves out is **not scored at all**, so a surprised round makes fewer draws than an even one.

## A stat after its multiplier — `RoundUp`

`RoundUp` (`0x020744a8`) is `(int)(0.5f + x)` — round half up, despite the name. The game applies it to a stat **after** its buff multiplier and before the blow is worked out, so a defence of 41 under Kasap is 21 and not 20. The multipliers themselves (`BasicAttackCalculation.cpp`): a quarter a level on attack; half again a level up on defence, agility and the magics, and going down a half at −1 and a quarter at −2; charm never falls below whole.

## What rides on a blow — `func_ov024_021e4b14` [`DispatchRiderEffect`]

A second effect on top of a damaging action — Toxic Dagger's poison, Helm Splitter's fall in defence. The action's `+0x18` bits 0–4 index 22 member pointers at `0x021ff450` [`riderEffectHandlers`]; 0 is none. It is called from the kind's handler once the blow has landed. Every handler has one shape:

- nothing, **and no draw**, for a blow that dealt nothing, for a target whose resistance byte for it is 0, or for one who cannot take it now;
- then `(float)NextRandomMax(100) < chance × (byte / 100.0f)` — a monster's chance `+0x14` bits 0–6, a party member's bits 7–13 — or under `100.0f` for a critical;
- the levels, where it moves a stat, at `+0x32`.

| slot | what | evidence |
|---|---|---|
| 2 | attack down | its handler calls `UpdateCombatantAttack`; reads resistance byte 18 |
| 8 | defence down | its handler calls `UpdateCombatantDefense`; byte 19. Helm Splitter, at 75 |
| 4 | poison, INFERRED | Toxic Dagger at 50, Venomissile at 12; byte 16. **Action 275, the unnamed poison attack, is slot 4 at 12** |
| 7 | sleep, INFERRED | Hit the Hay; byte 10 |
| 10 | confusion, INFERRED | Hypnowhip |
| 11 | paralysis, INFERRED | Trammel Lash, Paralaser |
| 20 | death, INFERRED | Assassin's Stab, Pressure Pointer |

## Resistances — `func_ov000_02156b38` [`GetResistance`]

`GetResistance(target, element)`: the byte at the target's status `+0x3E + element − 1`, plus a modifier, held at 0 or above, over `100.0f`. 1.0 for an element outside 1 to 21.

Everyone's 22 bytes start at 100 (`func_020891cc` [`ResetBattleStatus`]). A monster's are then copied from its record (`func_02082d38` [`CopyResistances`]) — see [Monsters](Monsters). **A party member's are summed from what they wear**: overlay 17's `func_ov017_021b3780` looks each worn thing up in `itembtlprm.nat` and copies its record onto the character, and `func_02083e28` sums the twenty signed bytes at each record's `+0x14` onto a hundred, held at nothing below — see [Equipment battle parameters](Equipment-Battle-Parameters). Nothing else writes them: no vocation, no skill, no spell.

The modifier: −50 under a ward, for each of elements 1 to 7 (five wards: 1, 2, 3 and 4, 5 and 6, 7); nothing for 8; for 9 to 21, −25 under bit 3 of the status word at `+0x18`, else +25 under bit 4.

**The elements**, from the actions that carry them:

| element | | element | |
|---|---|---|---|
| 1 | fire — Frizz, Fire Breath | 10 | sleep — Snooze, Sweet Breath |
| 2 | ice — Crack, Cool Breath | 13 | confusion — Fuddle |
| 3 | wind — Woosh | 16 | poison — Poison Breath |
| 4 | blast — Bang | 18 | attack down |
| 6 | dark — Zam | 19 | defence down — Sap, Kasap |
| 8 | **the plain Attack** | 20 | agility down — Decelerate |
| 9 | Dazzle | | |

5, 7, 11, 12, 14, 15, 17 and 21 are not established.

## Other things read

- **The surprise round** (`ProcessCombatTurn`): at `[battle + 0xe49]` of 1 the monsters sit the first round out; at 2 the party does, the first monster always acts, and each after it acts on `NextRandomMax(100) < 67`. What sets it is above.
- **A monster fleeing**: action `0xE1` on oneself removes the combatant with no draw (`func_ov024_021da670`). A monster that chooses to flee, flees.
- **A heal that goes critical** multiplies by `between(1.5, 2.0)`: it takes the same `CalculateFinalDamage` path a blow does, and `CalculateCriticalDamage`'s flag is set only for actions 1, `0xDB` and `0x1F9`, which take `between(0.95, 1.05)` instead.
- **Action kind `0x22` is a metamorphosis**: the combatant's battle record is swapped for the monster named at the action's `+0x30` (`func_0204887c`, which carries the old record's name over), and the turn is then drawn again. Its handler slot is null, and the usable-action mask excludes it.

## Not established

- What the four ways of choosing an action that do not draw by weights do in detail — see [Battle weight tables](Battle-Weight-Tables).
- What trait `0x11d` is, and what `func_ov000_02155a04`'s quarter is a quarter of, which together double a critical rate.
- What the drop roll's four further passes scale their chance by.
- What increments the combo counter at `[battle + 0x8e83]`.
- What `func_ov000_0215f57c` is: it returns 0, 1 or 2 for a party member, by a three-bit field of the monster's record and one coin flip. It is **not** the action picker, which this page once supposed.

## See also

- [Actions](Actions) — the fields these functions read
- [Monsters](Monsters) — resistances, and the five numbers
- [Items](Items) — a shield's chance of blocking, and evasion
- [Battle weight tables](Battle-Weight-Tables)
