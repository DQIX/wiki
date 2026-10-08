# Battle AI

How a monster chooses among its ways and whom it aims at, and how the party's tactics choose. Read 6 October 2026; the tactics read again and built 8 October 2026.

> **USA only** for the code (the ARM9 and overlays 0 and 24), read through the [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the counts of monsters and actions, from `mon_btldata.nat` and the action tables.

## A monster's way rules

Each monster has six ways (see [Monsters](Monsters)). `func_0208a91c` reads bits 5–7 of the battle record's word `+0x10` and calls one of eight functions through the table at `0x020f10b0`:

| rule | function | how it chooses | monsters (EU) |
|---|---|---|---|
| 0, 1, 2, 4 | `func_0208a4ac`, `4cc`, `4ec`, `50c` → `func_0208a370` | by [weight table](Battle-Weight-Tables) 0, 1, 2, 3: `NextRandomMax(256) + 1` walked down the six weights | 96, 281, 2, 25 |
| 3 | `func_0208a52c` | **in turn**: the way its count names, the count then `(count + 1) mod 6`; six tries | 9 |
| 5 | `func_0208a5d8` | **a pair in turn, a coin within it**: the count taken mod 3; three times, `NextRandom`'s low bit `b`, ways `2c + b` then `2c + (b xor 1)`, the count on by one mod 3 | 22 |
| 6 | `func_0208a700` | **its first way, then the rest**: the count's low bit; twice, at 0 way 0 alone, at 1 a start drawn by `NextRandomMax(5)` among ways 1–5 and on round them; the count flips | 3 |
| 7 | `func_0208a840` | in turn as 3, by a count its **group** keeps | 0 |

Every rule tries a way with the usable test `func_0208a03c` — a way its group may use once and has, too little MP in AI mode 2, or its targeting handler refusing — and, when none is usable, falls to the Attack through the first handler with action 2.

The counts: rules 3, 5 and 6 keep theirs in the byte at `+0x38` of the fighter's status (`+0x138`), rule 7 in the first byte past `+0x10` of the group's record at `battle + 0x81b0 + 0x18 × group`. Nothing but these functions writes them; **what they start at is not read** (presumably 0, cleared with the rest).

The weighted rules try the drawn way, then the ways before it down to the first, then those after.

## Targeting handlers

The dispatcher `func_ov024_021f66cc` takes the action record's `+0x0c` in AI mode 1 and `+0x0e` in mode 2 (see [Actions](Actions)); 0, or `0xa1` and above, is the first handler. Otherwise the pointer-to-member at `0x021ff790 + 8n` — 161 of them, all distinct but 3 and 4, and six that only refuse (109–111, 118, 133, 143). An odd-numbered handler is usually its even neighbour's mode-2 form, with a further test on status `+0x14` bit 9.

Shared helpers:

- `func_ov000_0215e9fc` — the party standing, in the party's order; `0215eb1c` the monsters; `0215ec80` one group;
- `func_ov024_021ed890` — one of a list by `NextRandomMax(n)`;
- `func_ov024_021ed8c0` — weighted picks (`func_ov000_02154f30`) by the action's hit code (`+0x1c` bits 14–18): 3 → `NextRandomBetween(3, 4)`, 4 → 2, 5 → 4, 7 → 7, 8 → 3, any other → 1;
- `func_ov024_021edf00` — a monster made to aim at one member (status `+0x2e`) aims there alone;
- `func_ov024_021ede2c` — refuses when a third or more of the party standing have status `+0x14` bit 26.

The fighter's status as the handlers read it: `+0x00` HP, `+0x02` MP, `+0x04` maximum HP, `+0x08` attack, `+0x0a` defence, `+0x0c` agility, `+0x58` bits 3–5 the defence's buff level and 6–8 the agility's (signed). The attack/defence/agility reading is inferred from how they are used — Kabuff refuses at a defence of `0xffff`, Accelerate at an agility of 999, and the party's AI forms `(attack − defence ÷ 2) ÷ 2` from `+0x08` and `+0x0a`.

Read so far:

| # | function | rule |
|---|---|---|
| 1 | `021edfa0` | mode 2's Attack: the weighted pick among those whose defence is under twice their attack |
| 2, 7 | | the weighted pick among the party |
| 3, 4 | `021ee20c` | all of the party; refused when a third or more have status `+0x14` bit 9 |
| 5, 6 | `021ee2fc`, `021ee33c` | Body Slam, Kamikazee: only at a third of its HP or less (5), half or less (6) |
| 11, 12 | | Heal: a draw among its own below half; Fullheal: two thirds of its own below half |
| 18, 19 | | Buff: a draw among its own below two steps |
| 20 | `021ef074` | Kabuff: a draw among its side's groups with one below two steps; that group |
| 22 | `021ef388` | Sap: those with a defence above two steps down, by the hit code's picks |
| 23 | `021ef4ac` | Sap, mode 2: as 22, and not status `+0x14` bit 9, and status byte `+0x50` above 0 |
| 24, 25 | | Kasap: those above two steps down |
| 26 | `021ef7b8` | Accelerate: a draw among its own under 999 agility and below two steps |
| 32 | `021eff3c` | Deceleratle: all of the party while one is above two steps down |
| 42–45, 113, 158 | | sleep: those awake |
| 61 | `021f1844` | the single abilities: the hit code's weighted picks among the party |
| 62 | `021f18a0` | all of the party |
| 96 | | Psyche Up: refused at the most tension |
| 112 | `021f418c` | Flee: refused unless the party's mean attack and defence is three times its own |
| 114 | `021f43b0` | Poison Breath: all of the party, gated as 157, refused when none is unpoisoned |
| 157 | `021f639c` | the breaths: all of the party, refused when a third have status `+0x14` bit 26 |

All 161, with the actions that name each on the EU cartridge:

| # | function | used by (EU cartridge, modes 1 and 2) | |
|---|---|---|---|
| 0 | `0x021edf6c` | mode 0, and every way whose number is 0 | read, built |
| 1 | `0x021edfa0` | Attack | read, built |
| 2 | `0x021ee0f0` | Whack, Zam, Zammle, Crack, Frizzle, Kafrizz and 1 more | read, built |
| 3 | `0x021ee20c` | Swoosh, Thwack, Woosh, Kaswoosh | read, built |
| 4 | `0x021ee20c` | Bang, Kacrack, Kaboom | read, built |
| 5 | `0x021ee2fc` | Body Slam, Kamikazee | read, built 6 Oct |
| 6 | `0x021ee33c` | Body Slam | read, built 6 Oct |
| 7 | `0x021ee378` | Zam, Crack, Frizz, Zammle, Frizzle, Whack and 4 more | read, built |
| 8 | `0x021ee3e8` | Swoosh, Crackle, Woosh, Kaswoosh, Thwack | read, built |
| 9 | `0x021ee454` | — | not read |
| 10 | `0x021ee574` | — | not read |
| 11 | `0x021ee6a8` | Heal, Midheal, Moreheal, Fullheal | read, built |
| 12 | `0x021ee7a4` | Multiheal, Omniheal | read, built |
| 13 | `0x021ee8b4` | — | not read |
| 14 | `0x021ee9b4` | — | not read |
| 15 | `0x021eeab8` | — | not read |
| 16 | `0x021eebbc` | Zing, Yggdrasil leaf, Kazing | not read |
| 17 | `0x021eecc8` | Kerplunk Dance, Kerplunk | not read |
| 18 | `0x021eee68` | Buff | read, built |
| 19 | `0x021eef68` | Buff | read, built |
| 20 | `0x021ef074` | Kabuff | read, built 6 Oct |
| 21 | `0x021ef1f8` | Kabuff | not read |
| 22 | `0x021ef388` | Sap | read, built 6 Oct |
| 23 | `0x021ef4ac` | — | read; not built |
| 24 | `0x021ef5ec` | Kasap | read, built |
| 25 | `0x021ef6c4` | Kasap | read, built |
| 26 | `0x021ef7b8` | Accelerate | read, built 6 Oct |
| 27 | `0x021ef8b8` | — | not read |
| 28 | `0x021ef9c4` | Acceleratle | not read |
| 29 | `0x021efb48` | — | not read |
| 30 | `0x021efcd8` | #324 | not read |
| 31 | `0x021efdfc` | — | not read |
| 32 | `0x021eff3c` | Deceleratle, Snot Shot | read, built 6 Oct |
| 33 | `0x021f0014` | Deceleratle | not read |
| 34 | `0x021f0108` | Oomph | not read |
| 35 | `0x021f0208` | Oomph | not read |
| 36 | `0x021f0314` | Blunt | not read |
| 37 | `0x021f0438` | Blunt | not read |
| 38 | `0x021f0578` | — | not read |
| 39 | `0x021f063c` | — | not read |
| 40 | `0x021f0720` | Fuddle Dance, Kafuddle | not read |
| 41 | `0x021f0734` | — | not read |
| 42 | `0x021f0748` | Snooze | read, built |
| 43 | `0x021f0810` | Snooze | read, built |
| 44 | `0x021f08f8` | Kasnooze | read, built |
| 45 | `0x021f090c` | Kasnooze | read, built |
| 46 | `0x021f0920` | Bounce | not read |
| 47 | `0x021f094c` | Bounce | not read |
| 48 | `0x021f0a20` | — | not read |
| 49 | `0x021f0b84` | Magic Barrier | not read |
| 50 | `0x021f0d28` | Magic Barrier | not read |
| 51 | `0x021f0e90` | — | not read |
| 52 | `0x021f101c` | Fizzle | not read |
| 53 | `0x021f10e0` | — | not read |
| 54 | `0x021f1198` | Dazzle, #323, Dazzleflash, Flashbang Wallop | not read |
| 55 | `0x021f125c` | — | not read |
| 56 | `0x021f1330` | — | not read |
| 57 | `0x021f145c` | — | not read |
| 58 | `0x021f1578` | — | not read |
| 59 | `0x021f166c` | — | not read |
| 60 | `0x021f1768` | Divine Intervention | not read |
| 61 | `0x021f1844` | #273, #231, #244, Paralaser, Blockenspiel, #281 and 38 more | read, built 6 Oct |
| 62 | `0x021f18a0` | Wind Sickles, Stone’s Throw, #332, Party Pooper, Gigagash | read, built 6 Oct |
| 63 | `0x021f18fc` | — | not read |
| 64 | `0x021f1a0c` | Victimiser | not read |
| 65 | `0x021f1b40` | — | not read |
| 66 | `0x021f1c64` | medicinal herb, Caduceus | not read |
| 67 | `0x021f1d4c` | — | not read |
| 68 | `0x021f1e58` | — | not read |
| 69 | `0x021f1f64` | — | not read |
| 70 | `0x021f2064` | — | not read |
| 71 | `0x021f20b8` | Hustle Dance | not read |
| 72 | `0x021f21b4` | Helm Splitter | not read |
| 73 | `0x021f22d8` | — | not read |
| 74 | `0x021f23e0` | — | not read |
| 75 | `0x021f24fc` | — | not read |
| 76 | `0x021f2548` | Mist Me | not read |
| 77 | `0x021f259c` | Heart Breaker, #238, Sultry Dance, #331, #333, #250 and 1 more | not read |
| 78 | `0x021f26a8` | Back Atcha, #329 | not read |
| 79 | `0x021f26fc` | — | not read |
| 80 | `0x021f2754` | Whipping Boy | not read |
| 81 | `0x021f286c` | — | not read |
| 82 | `0x021f2998` | — | not read |
| 83 | `0x021f2ab4` | Morale Masher | not read |
| 84 | `0x021f2c30` | Attack Attacker | not read |
| 85 | `0x021f2d4c` | — | not read |
| 86 | `0x021f2d98` | — | not read |
| 87 | `0x021f2e88` | — | not read |
| 88 | `0x021f2f78` | — | not read |
| 89 | `0x021f304c` | Spooky Aura | not read |
| 90 | `0x021f3168` | Wizard Ward | not read |
| 91 | `0x021f3248` | — | not read |
| 92 | `0x021f32b4` | — | not read |
| 93 | `0x021f331c` | Channel Anger | not read |
| 94 | `0x021f3368` | — | not read |
| 95 | `0x021f3440` | Weakening Wave | not read |
| 96 | `0x021f3524` | Psyche Up | read, built |
| 97 | `0x021f3564` | — | not read |
| 98 | `0x021f3688` | Meditation | not read |
| 99 | `0x021f36cc` | Egg On, #330 | not read |
| 100 | `0x021f37fc` | — | not read |
| 101 | `0x021f38f0` | Forbearance | not read |
| 102 | `0x021f3a04` | — | not read |
| 103 | `0x021f3b20` | — | not read |
| 104 | `0x021f3c3c` | M-Pathy | not read |
| 105 | `0x021f3d78` | Selflessness | not read |
| 106 | `0x021f3e64` | Disruptive Wave | not read |
| 107 | `0x021f40c8` | — | not read |
| 108 | `0x021f4120` | — | not read |
| 109 | `0x021f4174` | — | not read |
| 110 | `0x021f417c` | — | not read |
| 111 | `0x021f4184` | — | not read |
| 112 | `0x021f418c` | Flee | read, built |
| 113 | `0x021f4294` | — | read, built |
| 114 | `0x021f43b0` | Poison Breath | read, built 6 Oct |
| 115 | `0x021f44ac` | — | not read |
| 116 | `0x021f45c8` | #242, #344, #345, #347, #470, #349 | not read |
| 117 | `0x021f4768` | Weird Dance | not read |
| 118 | `0x021f4878` | — | not read |
| 119 | `0x021f4880` | — | not read |
| 120 | `0x021f4974` | — | not read |
| 121 | `0x021f4a54` | Venom Mist | not read |
| 122 | `0x021f4b60` | — | not read |
| 123 | `0x021f4c8c` | Burning Breath | not read |
| 124 | `0x021f4d6c` | — | not read |
| 125 | `0x021f4e84` | #287, #288 | not read |
| 126 | `0x021f4ed4` | Dazzleflash | not read |
| 127 | `0x021f4fd8` | — | not read |
| 128 | `0x021f50cc` | — | not read |
| 129 | `0x021f51d4` | #326 | not read |
| 130 | `0x021f5220` | #327 | not read |
| 131 | `0x021f5300` | #337 | not read |
| 132 | `0x021f5344` | #339 | not read |
| 133 | `0x021f5420` | — | not read |
| 134 | `0x021f5428` | — | not read |
| 135 | `0x021f5478` | — | not read |
| 136 | `0x021f5558` | — | not read |
| 137 | `0x021f559c` | Drain Magic | not read |
| 138 | `0x021f567c` | Drain Magic | not read |
| 139 | `0x021f5768` | Feel the Burn | not read |
| 140 | `0x021f57a8` | #232 | not read |
| 141 | `0x021f5888` | #281 | not read |
| 142 | `0x021f58dc` | #474 | not read |
| 143 | `0x021f59bc` | — | not read |
| 144 | `0x021f59c4` | — | not read |
| 145 | `0x021f5a08` | Air Pollution | not read |
| 146 | `0x021f5ae0` | Wave of Panic | not read |
| 147 | `0x021f5bb8` | Eerie Light | not read |
| 148 | `0x021f5c80` | — | not read |
| 149 | `0x021f5ce4` | #567 | not read |
| 150 | `0x021f5db0` | #794 | not read |
| 151 | `0x021f5e8c` | Fuddle | not read |
| 152 | `0x021f5f6c` | Fuddle | not read |
| 153 | `0x021f606c` | Lullab-Eye | not read |
| 154 | `0x021f6150` | Antimagic | not read |
| 155 | `0x021f6230` | Double Up | not read |
| 156 | `0x021f6298` | Gritty Ditty | not read |
| 157 | `0x021f639c` | #268, Cool Breath, Fire Breath, #227, Inferno, #269 and 6 more | read, built 6 Oct |
| 158 | `0x021f6424` | Sweet Breath | read, built |
| 159 | `0x021f6500` | #929 | not read |
| 160 | `0x021f65fc` | #472 | not read |

## The party's tactics

Read whole, frame and scoring (6 October 2026); built in minstrel 8 October 2026, function by function, with the corrections below.

The AI runs in two places: in the command phase (`ProcessCombatTurn` → `func_ov024_021f9030`) and at a member's turn (`func_ov000_0215767c` → `func_ov024_021f8f20`). Both read the tactic, the signed byte at the character record's `+0x94c` — 0 Show No Mercy, 1 Fight Wisely, 2 Mix It Up, 3 Focus On Healing, 4 Don't Use MP, 5 Follow Orders — and act **only when the action handed in is 1, the Attack**.

**The command phase** looks for ten actions that must be settled before anyone acts (the list at `0x021fefc2`): Knight Watch, Mercurial Thrust, `0x86`, Counter Wait, Back Atcha, Defending Champion, Whipping Boy, Forbearance, Selflessness, Pincushion — each the member holds and can pay for (none that costs MP under Don't Use MP). Only six are ever chosen, in this order, with no draw:

1. **Knight Watch**, unless anyone has `+0x18` bit 11 or has chosen it already, not under Show No Mercy, under Fight Wisely or Don't Use MP only with more than two turns needed; and then if the member has no heal at hand that costs no item, or is the weakest, or the weakest is not under the threshold.
2. **Mercurial Thrust** with one monster standing, under any tactic but Focus On Healing, when the forecast's least of the member's own blow is above its HP.
3. Under **Focus On Healing** at a quarter of the member's HP or less, with no heal at hand that costs no item and nobody on Knight Watch: **Defending Champion**, else **Defend**.
4. Under **Focus On Healing** only, with one at 0.08 or less, nobody covering already and no free heal, the member at half HP or more and their HP at least twice the weakest's: **Forbearance** when two are at 0.08 or less, else **Selflessness**, **Whipping Boy**, **Forbearance** — Forbearance on oneself, the others on the weakest.

The threshold there is 0.4, or 0.25 when the AI object's tactic byte says Mix It Up — read **before** it is written: the object is `ProcessCombatTurn`'s one stack slot, so it is the previous member's tactic.

**At the turn**, by the table at `0x021ff054`:

| tactic | function | threshold `+0x124` | lists, in order |
|---|---|---|---|
| Show No Mercy | `021f8144` | 0.08 | 6, 2 |
| Fight Wisely | `021f81dc` | 0.4 | 6, 5, (`+0x0c` ≥ 4: 8), then `+0x0c` ≥ 4: 0, 2 — else 3 |
| Mix It Up | `021f84f0` | 0.25 | 6, 5, (≥ 4: 8), then ≥ 2: 0, 2 — else 1, 3 |
| Focus On Healing | `021f83f8` | 0.6 | 6, 5, (≥ 2: 8, 1), 3 |
| Don't Use MP | `021f8300` | 0.4 | 6, 5, (≥ 4: 8), 0, 3 |

Each list keeps the best four choices by a float score (`func_ov024_021f6830`), 12 bytes each: the action, an item's bag place, the score, the target group and target. The first list whose best score is above 0 is taken (`021f691c`); with none, **the Attack on the monster lowest in HP fraction** (`021f8628`). `+0x0c` is the setting up's estimate of the turns the party needs: over the monsters, `⌈size ÷ (0.9375 × blow + 0.5)⌉ + 1`, the blow `(attack − defence ÷ 2) ÷ 2`.

The setting up (`func_ov024_021f7478`) also gathers the candidates — the Attack, the coup de grâce when ready, the spells and abilities usable in battle, the bag's usable items, up to 128 — and **at the turn only** draws from the battle's generator: one `NextRandomFloat01`; for each of 21 behaviours a `NextRandomMax(100)` against the tactic's chance and a `NextRandomBetween(lo, hi)`; and a `NextRandomFloatBetween(0, 0.9)`. The tables of 21 × (chance, gate, lo, hi) are at `0x021ff084` (Show No Mercy), `0x021ff0d8` (Fight Wisely, Don't Use MP), `0x021ff12c` (Mix It Up) and `0x021ff180` (Focus On Healing).

Each candidate is scored by an evaluator chosen by the action's kind (`+0x18` bits 5–11) from the table at `0x021ffeac`: 79 pointers, 22 null and 21 empty functions.

### The 21 behaviours

Per behaviour *i*, the tactic's four bytes are (*chance*, *gate*, *lo*, *hi*). The flag at `ai+0x10+i` is set on `NextRandomMax(100) < chance`, and cleared when the party's turns needed (`ai+0x0c`) are fewer than `gate × ai+0x78 ÷ 10` — the second byte is a gate on the turns needed, not an MP need. Then a weight `ai+0x54+i = NextRandomBetween(lo, hi)` for each, and `ai+0x30 = NextRandomFloatBetween(0, 0.9)`. An evaluator asks a behaviour (`func_ov024_021fe698`) before it scores anything; the scorer weighs its state entries by `0.01 ×` the weight drawn.

| behaviour | what asks it |
|---|---|
| 0 | always set |
| 1 | a state on the monsters: sleep (kind 8), kinds 10, 16, 19, 21, 49 |
| 2 | raising an ally's levels (kinds 3–5), kinds 15 and 46 |
| 3 | lowering a monster's levels (kinds 3–5) |
| 4 | Whack and its like (kind 17); and the scorer's pass over sure kills |
| 5, 6, 7 | an ally's attack, defence, agility |
| 10, 11, 12 | an ally's protections (kinds 22; 23, 32, 61, 62; 39) |
| 13, 14, 15 | a monster's attack, defence, agility |
| 16 | a monster's kind 22 |
| 18 | the coups de grâce |
| 8, 9, 17, 19, 20 | asked by no evaluator |

Show No Mercy's table sets only 0 and 4.

### The scorer

Each evaluator fills a target set — up to 16 entries of 12 bytes: a float, an effect, whether it lands on a monster, the target, a chance in 100, a category, the hits — and hands it to `func_ov024_021f9874`, which, in order:

1. sums each monster's forecast damage (× 1.2 on the combo chain's target), marking those it would kill;
2. with behaviour 4, adds a sure kill's chance as `(HP − dealt) × min(p², 0.9)`, `p` lowered by `0.005 × MP` (as doubles) unless Show No Mercy;
3. sums the HP given to each of the party;
4. scores **harm** as Σ `100 × min(dealt, HP) ÷ max HP` (none for an item that is used up, but under Show No Mercy; such an item costs 30 more) and **heal** as Σ `100 × given ÷ max HP`, doubled for the weakest member;
5. weighs the state changes by three tables (`0x021ffc98`, `0x021ffca4`, `0x021ffcc5`) into four slots;
6. puts the candidate into its lists, each score less its cost × 0.01 or 0.1: list 2 harm (and list 3 when free), 5 category 5, 6 heal, 8 cures, 9–11 the slots, 0 everything, 1 the same when it does no harm or costs nothing. Mix It Up multiplies harm by 0.3 there unless the action is Critical Claim.

The forecast (`func_ov024_021fa7ec`) multiplies a blow's mean and least by tension, the weapon's killer bonus for the target's family or its element (see [Equipment battle parameters](Equipment-Battle-Parameters)), the target's resistances and levels, the combo chain (1.0, 1.2, 1.5, 2.0 at `0x021fefa0`), a metal body and the record's cap, then mixes them as `mean × 0.4 + least × 0.6` (`ai+0x170`; under Show No Mercy it is 0, so the least alone).

The coups score a fixed 1,000 under their own condition, so a tactic that reaches list 0 with a coup ready plays it.

### What reading it again corrected (8 October 2026)

- `func_ov000_0215e9fc`'s count, `ai+0x78`, is the party **standing**. The character's `+0x134 +0x34` and `+0x36` are the base attack and defence (`UpdateCombatantAttack`, `…Defense`). The bag entry's `+0x08` bit 19 is the item's "used up". `+0x2F4` is the weapon's `itembtlprm.nat` record: its flags' bits 0–1 widen a reach of 5, bits 4 and 10 are what the metal arithmetic asks.
- A state change with a negative value weighs **−3** times its weight, not −1.5: the constant is `0 − 0x3fc00000` as a whole number, which is the float −3.0.
- The heal's factors for `0x310` and `0x21` apply only when the action costs MP.
- The wand's bonus (weapon kind 3) is by the **member's own** MP over their most, and its steps add: 50 at a tenth, 30 more at three tenths, 10 more at a half.
- The forecast: action `0x79` is `0.8 + 0.125 ×` the monsters' count on the first and 0.8 after; the levels it reads are the target's against spells and breaths; Critical Claim's mean is the greater of the base attack and 1.2 × the mean. **Tension's bonus is thrown away**: `CalculateTensionBonus` is called, its result dropped, and the member's level added instead.
- Kind 4 on a foe asks behaviours 2 and 14; kind 26 goes by the member's MP; the state evaluator's floors are 33.3, 35 (effects 4, 5, 7) and 50 (effect 8).
- A list's insertion copies one entry down and leaves the rest; and the scorer's behaviour-4 pass walks the set's entries (16) over arrays of the monsters (8), so past the eighth it reads the member's own blows as sizes and writes into the kills' flags.

The full reading, every evaluator by kind with its address, is in minstrel's `docs/readings/T17-ai.md` §2b and §2c; the port is `packages/sim/src/battle/tactics.ts`.
