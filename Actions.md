# Actions

What a fighter or an item does, in two halves. `/data/prm/actdt_a.gp2` holds `actdt_a_<lang>.nat`, 63 actions — the spells and the healing items — and `actdamage_a.nat`. `/data/prm/actdt_b.gp2` holds `actdt_b_<lang>.nat`, 618 actions — the attack, defending, fleeing, the monsters' moves — and `actdamage_b.nat`. `actname.nat` names the actions by number, in the [system strings](System-Strings) layout. The name, plural, action number and range index are confirmed; MP cost, messages, reach, damage flag and the range table's amounts are INFERRED; most of each record is not established.

All observations were made on the European release (game code `YDQP`). Both archives' members are stored whole; see [GPC2](GPC2).

"The reference" below is DQIX/BattleEmulator (MIT, © 2024 DaisukeDaisuke), which reproduces the game's arithmetic.

## Layout

### Action table — `actdt_a_<lang>.nat`, `actdt_b_<lang>.nat`

The file opens with the head word the system strings share (low 12 bits the record count, upper 20 the string section's size) — 618 records and 3,969 bytes of strings in English for `_b`, which leaves exactly 60 bytes a record — then the records, then the strings.

| offset | reading | evidence |
|---|---|---|
| `+0x00` | the name's offset | a string's start on every record |
| `+0x04`, bits 0–9 | the action's number | `actname`'s: Heal 30, Midheal 31, the medicinal herb 255, strong medicine 256; no two alike in a table |
| `+0x08`, the low byte | its cost in MP, INFERRED | Heal 2, Midheal 4, Moreheal 8, Frizz 2, Crack 3, Zam 4, Kamikazee 1; 0 on the 488 actions that are no spell — the attack, the items, the monsters' moves — and 255 on four, Magic Burst and Kerplunk among them, the spells that spend all a caster has. 128 on two, not established |
| `+0x08`, bits 14–21 | its range: an index into the range table beside it, 0 for none | **every one is there** — 37 in `_a`, 117 in `_b` — and every range is some action's, 17 of 17 and 107 of 107; the word is the same in all five languages |
| `+0x17`, high nibble | whom it reaches, INFERRED — below | |
| `+0x20`, bits 10–19 | how it opens, INFERRED: a message in `actmsg` said first, 0 for none | 1 `attacks` on the attack; 45 `flees` on fleeing; 46 `casts <ACTION>` on 83 spells; 70 `uses <INDEF_ART_SGL_I_NAME>` on the herbs and 46 named items; 15 `does the <ACTION>!` on the dances; and on the monsters' unnamed moves their own lines — 394 `sends rubble raining down` on the hexagoon's 546, seen in a let's play video, 286 `spews forth a cloud of sand`, 350 `is just fluffing around`, 55 `calls for backup`. 669 of the 681 index one of the 591 messages |
| `+0x20`, bits 20–31 | what it says, INFERRED: a message in `actmsg`, 0 for none | 22 `wounds are healed` on Heal, Midheal and the herb; 84 `no longer poisoned` on the antidotal herb and Squelch; 32 `returns to life` on the leaf and Zing; 106 `MP are replenished` on magic water; 2 `takes <val_1> points of damage` on the attack spells; and **157 to 166 on the nine seeds and the pretty betsy**, each message naming the number it raises — `maximum HP` on the seed of life, `charm` on the pretty betsy, `skill points` on the seed of skill |
| `+0x24` | a byte; `0x05` deals damage, INFERRED — below | |
| `+0x34` | the plural's offset | `medicinal herbs`; a string's start on every record |

The rest of the record is not established. For the messages, see [Battle-Text](Battle-Text).

### Fields read from the battle's code

These were not read from their values. Each is what a function of the battle tests before it acts — see [Battle resolution](Battle-Resolution), which names the functions. The counts are over the 681 actions of both halves.

| where | reading | the cartridge's witness |
|---|---|---|
| `+0x04`, bits 0–11 | the action's number, as the code masks it — twelve bits, not ten | no action is numbered past 1,023 |
| `+0x04`, bits 12–21 and 22–31 | the user's number at which a scaling amount (or accuracy) leaves its least, and at which it reaches its most | Frizz 50 and 999; Crackle 100 and 999; Heal 50 and 999 |
| `+0x08`, bits 22–26 | **the element of what it deals**: the damage is multiplied by the target's resistance to it | the plain Attack 8; Frizz 1, Crack 2, Woosh 3, Bang 4, Zam 6; Fire Breath 1, Cool Breath 2 |
| `+0x08`, bit 29 | **always a critical**: the critical roll returns 1 without a draw | 18 actions; one is named Critical Claim, fifteen are a second copy of each attacking spell |
| `+0x10`, bit 3 | spoilt by a status on the attacker: the accuracy roll's die of eight misses on five faces. INFERRED: dazzle | 110, every one a blow that can be dodged |
| `+0x10`, bit 5 | **can be dodged** | 156; the plain Attack and the breaths, not the spells or the herb |
| `+0x10`, bit 6 | **can be blocked** | 162, 130 of them dodgeable too |
| `+0x10`, bits 14 and 15 | the number it scales by: **magical might**, **magical mending** | 14 on the attacking spells, 15 on the heals |
| `+0x10`, bit 17 | strikes several, weakening as it goes: 1.0, 0.8, 0.6, 0.4, 0.2 | |
| `+0x10`, bit 24 | **works on a metal body** | 208: the blows have it, every attacking spell lacks it |
| `+0x14`, bits 0–6 | **a monster's chance with it**, in a hundred: its accuracy where the accuracy scales — the whole of whether a change of state lands — and its rider's chance | Kasap 75, Deceleratle 75, Sweet Breath 25, which are the reference's three, found in play; Snooze 37, Kasnooze 50; action 275, the poison attack, 12 |
| `+0x14`, bits 7–13 and 14–20 | a party member's least and most accuracy with it, and bits 7–13 their rider's chance | Sap 75 to 100 |
| `+0x14`, bits 21–27 | the critical chance's multiplier, in hundredths | **100 on the plain Attack, 50 on the spells**, 0 on the items |
| `+0x14`, bits 28–31 | whom it reaches — the high nibble of `+0x17`, below. **At 3 or 4 the critical is rolled once for the whole action** rather than once a target, which bears out reading them as all and a group | |
| `+0x18`, bits 0–4 | **what rides on its blow**: a slot of 22, 0 for none | Toxic Dagger 4 (poison), Helm Splitter 8 (defence down); the plain Attack 0 |
| `+0x18`, bits 5–11 | its **kind**, which picks the handler that applies it. Only kind 1 is halved by the final-damage function | 1 deals damage, 242 actions; 2 heals; 3 attack up or down; 4 defence; 5 agility; 6 poison; 8 sleep; 0 on Defend. 93 numbers in use, most not established |
| `+0x18`, bits 16–17 | what scales: at **1 its accuracy**, at **2 its amount** | 202 at 1; Frizz, Heal and the herb at 2. The plain Attack is at 2 and has no range, so nothing reads it |
| `+0x18`, bits 18–26 | which of 67 damage handlers its damage goes through; 0 is none | 570 on 0; Dragon Slash alone on 1; Thunder Thrust and Hatchet Man sharing 45 |
| `+0x18`, bits 27–31 | **the element its landing is resisted by** | Kasap 19, Deceleratle 20, Snooze and Sweet Breath 10, Poison Breath 16; a blow with a rider has the rider's — Toxic Dagger 16 |
| `+0x1C`, bits 0–13 | the most it can deal; 0 is no limit | 211: Frizz 999, Frizzle 1999, Kafrizz 2999, and Heal's three the same |
| `+0x30`, `+0x32` | `s16` ×2: the levels it moves a stat, and its rider's; held to two either way | Buff 1, Sap −1, Oomph 2, Blunt −2 |

Actions the code singles out by number: `0x1B` Kamikazee, `0x40` Metal Slash, `0x48` Thunder Thrust, `0x70` Hatchet Man, `0x7E` Metalicker, `0xAF` Double-Edged Slash.

### Reach — `+0x17`, high nibble

INFERRED from the actions that carry each value:

| value | reach | carried by |
|---|---|---|
| 1 | the actor | Defend, Psyche Up and the like |
| 2 | one | Heal, Frizz, Crack, Zam, Buff, the herbs |
| 3 | everyone | Multiheal, Bang, Boom, Kaboom, Kathwack and the breaths |
| 4 | a group | Crackle, Woosh, Swoosh, Kaswoosh, Snooze, Thwack |
| 5 | — | the attack's alone |
| 6, 8 | not established | |
| 7 | used outside battle | Evac, Zoom, the chimaera wing and the seeds |

The Ka- spells show the order: Buff and Sap (2) become Kabuff and Kasap (4), Snooze and Thwack (4) become Kasnooze and Kathwack (3) — so 4 is between one and everyone: a group.

### Effect — `+0x24`

**`0x05` at `+0x24` deals damage**, INFERRED: the attack and every attack spell carry it, each saying `actmsg` 2.

The byte agrees with the message (`+0x20` bits 20–31) on 125 of the 389 actions that carry both and not on the rest (the attack spells' is 5), so the two are separate fields.

### The halves

`_a` holds the healing items and the spells that do not strike — Heal, Midheal, Zing, Evac — and `_b` the attack spells, Crack and Woosh among them. What decides which half a spell is in is not established.

### Range table

The range table sits beside the action table in each archive — `actdamage_a.nat` and `actdamage_b.nat`. A word holding its count, then 8-byte records:

| offset | reading | evidence |
|---|---|---|
| `+0x00` | the index | — |
| `+0x00`, bits 8–17 | **spread**: a draw between ∓ this is added last, whoever uses the action — ten bits, as the code reads it | Heal's is 5, and the reference draws Heal as 35 ± 5. No range on the cartridge sets the upper two |
| `+0x04`, bits 0–9 | **a monster's amount** | Heal 35, Midheal 85, Moreheal 185: the reference's own bases |
| `+0x04`, bits 10–19 | **a party member's least** — what it is until their number passes the action's `lo` | the reference's own party amounts: Heal `typeD(5, 35)`, Crack `(5, 30)`, Crackle `(8, 50)`, Woosh `(8, 16)` — and these are 35, 30, 50 and 16 here, where the base is 35, 17, 33 and 14. Equal to the base on 78 of 124, every heal and item among them. The base's own part beside it is not established; monsters' casting is the likeliest |
| `+0x04`, bits 20–29 | **a party member's most** — what it is from the action's `hi` | the reference's Midheal, 85 + (mending − 100) × 0.2392, and Moreheal, 185 + (mending − 200) × 0.5194, come to exactly 300 and 600 at 999, which are theirs |
| `+0x04`, bits 30–31 | 0 | on every record |

**All four were INFERRED from the reference and are now read from the game's `GetAttackBaseDamage`**, which bears them out — see [Battle resolution](Battle-Resolution), "The amount". The reference's slopes are these: Midheal's 0.2392 is (300 − 85) / (999 − 100). An action that names no number to scale by has its base *drawn* between the least and the most.

**The medicinal herb** is action 255, range `0x31`: 35 ± 5, peak 35 — it restores 30 to 40 HP whoever uses it. Strong medicine is range `0x32`, 50 ± 10. An item names its action in its item table — see [Items](Items).

## Evidence

- Action numbers: agree with `actname.nat`; no two alike in a table.
- Range indices: every one present in the range table, and every range used (17 of 17 in `_a`, 107 of 107 in `_b`); the same in all five languages.
- Opening messages: 669 of 681 index one of `actmsg`'s 591 messages; the hexagoon's move 546 and its message 394 matched against a let's play video.
- Range amounts: Heal, Midheal, Moreheal, Crack, Crackle and Woosh against the reference.
- A monster's six ways of acting are INFERRED to be these action numbers; see [Monsters](Monsters).

## Not established

- MP cost value 128 (on two actions).
- Reach 6 and 8; what 5, the attack's alone, means.
- `+0x24` beyond `0x05`.
- The rest of each action record.

## See also

- [Battle resolution](Battle-Resolution) — the code that reads these fields
- [Battle-Text](Battle-Text) — `actmsg`
- [System-Strings](System-Strings) — `actname.nat`
- [Monsters](Monsters)
- [Items](Items)
- [Spell-Table](Spell-Table)
