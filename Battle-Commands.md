# The battle's other commands

Examine, Misc.'s Equipment and Line-Up, and the Coup de Grâce: what each does,
the files it reads and the rules it follows. For the draws an action makes,
see [Battle resolution](Battle-Resolution).

> **USA only** for the code (overlay 0, the battle's command UI; overlay 24,
> the resolver), read through the [dqix-decomp](https://github.com/DQIX/dqix-decomp).
> **EU only** for the files and text. The code's constant tables were read from
> the USA images and agree with the strategy guide (pp. 14, 434–435).

## Examine

`func_ov000_0217df08`, the party menu's second row. **It costs nothing**: no
member's command is touched, and the party menu comes back.

**File**: `/data/bin/menu/str_ex2.gp2` › `str_ex2_<lang>.nat`.

1. **One page per monster with something worth telling**, in the order a
   target choice walks them (group by group, the living only). Pages are
   joined by `str_btl` 6, `<PAGE>`.
2. **No monster has a line**: one general line naming **the highest-level
   monster** (`mon_data +0x0A & 0x7F`, the first of the highest):
   - line `W(100) & 1`, from the **world's** generator: 0 "…is sizing up the
     party", 1 "…is preparing to attack";
   - **+2 when several monsters stand**: lines 2 and 3, "The enemy are …";
   - on the round the party has the jump, 60 + a flag instead: "…hasn't
     noticed the party's presence yet" or "…frozen stock-still with surprise"
     (62, 63 for several). Who writes the flag was not read.

Examine draws only from the world's generator, so it moves nothing in a
battle's replay.

**Which line a monster gets** (`func_ov000_0217ff34`): the first test that
holds, on the monster's status `s`:

| order | holds when | line |
|---|---|---|
| 1 | fixed on a target (`s+0x18` bit `0x1000`) | 4 or 5, by `W(2)`: "…glaring furiously at `<TARGET>`!", "…sights set squarely on…" |
| 2 | tension level ≠ 0 | 59 slightly raised, 58 considerably, 57 high, 56 super-high (levels 1 to 4) |
| 3–5 | attack, defence, agility changed | +2, +1, −1, −2: 31–34, 35–38, 39–42 |
| 6–8 | a barrier, the Burn, a mist | 21, 24, 25 |
| 9 | spell resistance changed | 48–51 |
| 10 | dodging raised two | 55 |
| 11–12 | magical might, mending | 45/44, 47/46 |
| 13–15 | paralysed, asleep, confused | 6, 7, 8 |
| 16 | fallen over, laughing, dancing, petrified, trembling, tied up | 9, 11, 12, 10, 14, 15 |
| 17 | hallucinating, dazzled, dust, ink | 16, 18, 17, 19 |
| 18 | spells sealed | 20 |
| 19 | poisoned, envenomated | 23, 22 |
| 20 | charm raised one | 43 |
| 21 | breath resistance: 1 → 52 "seriously", 2 → 53 "slightly" — the reverse of rows 11–12, as the code has it | |

Lines 26–30 and 54 are never produced by this function.

## Equipment (Misc. row 1)

`func_ov000_0217ce24`, states 5, 6, 7 and 32. **Weapons only, and free.**

1. **Whom**: no choice for a party of one; otherwise a list in panel order.
2. **Kinds** (a 12-bit mask, `func_020dd3cc`, then `func_ov000_0217c514`):
   - a kind the member may wield — one of the vocation's four weapon trees, or
     the tree's "may wield" panel;
   - and of which the party's bag holds a weapon (`id − id % 100` against
     20000, 20500, 19000, 20400, 20300, 20600, 20800, 20100, 20200, 19100,
     20700, 20900);
   - **plus the kind in hand**, so that it can be taken off.

   None: `str_btl` 35, "…isn't carrying any equipment." Each kind's row is
   `str_btl` 7 + kind (Swords … Bows).
3. **Weapons** of the kind, four rows a page. The may-equip test's result is
   not looked at.
4. **The change** (state 32):

   | case | message (`str_btl`) |
   |---|---|
   | the weapon in hand chosen | taken off into the bag: 22 (23 of a fallen member) |
   | the weapon in hand is cursed | 37, nothing changes, sound 61 |
   | another | the old one into the bag, the new one on: 20 (21 fallen) |
   | …and the new one is cursed | 36 as well |

   Then Misc. comes back, with the member's figure rebuilt.

## Line-Up (Misc. row 2)

`func_ov000_0217dcf0`. One row a member: the name, then at x = 70 `str_btl`
30033 "Front Line" or 30034 "Back Line", by **bit 30 of the member's
`base+0x3c`**. A toggles it, **free**. The bit lasts from battle to battle;
the field menu (overlay 2) toggles the same bit.

**The one thing in the battle that reads it is the monsters' weighted pick**
(`func_ov000_02154f30`, `0x02155024`–`0x02155040`):

1. a monster fixed on a target takes it, with no draw;
2. otherwise each party member standing weighs **2 in the Front Line, 1 in
   the Back Line**, +2 if they struck the monster last and +1 the time before,
   where its record says it remembers;
3. the total is summed, then a candidate under status `0x8000000` has their
   own weight halved;
4. a draw of `R(total) + 1` walks the weights; if the halving leaves it
   unspent, a second draw `R(count)` picks evenly.

**No damage change by row was found.** The guide says the Back Line takes less
damage and the Front deals more in melee. Every reader of the bit in the
ARM9 and all overlays was searched, and none supports that.

## The coup de grâce

### Who may come ready

`func_ov024_021eb1ec`: a character of the party, **at level 10 or more in
their current vocation**, not Inactive, paralysed, confused, asleep or dead,
and not ready already. A flag a revival sets (`status+0x3a`) skips one draw
and is cleared.

### The two draws

Both are `NextRandomMax(100)` on the battle's generator, in the resolver
(`func_ov024_021eb5d0`), and both are made whenever the member is eligible,
however small the chance.

| | where | term |
|---|---|---|
| **at a pass** | each target's pass, after its results (`0x021ecf6c`–`0x021ed078`): any action that reaches the member — a monster's blow, an ally's heal, their own Defend | what an action of kind 1 or 35 dealt them as a share of their maximum HP, below |
| **after acting** | once, after every target (`0x021ed298`–`0x021ed3c8`), while a monster stands | their vocation's term + what they wear |

**The share of HP** (`func_ov024_021eb344`, table `0x021fe970`): `(float)dealt
/ (float)maxHp` against `0.9f` … `0.1f`, the first it reaches:

| ≥ | 0.9 | 0.8 | 0.7 | 0.6 | 0.5 | 0.4 | 0.3 | 0.2 | 0.1 | else |
|---|---|---|---|---|---|---|---|---|---|---|
| term | 90 | 90 | 64 | 32 | 16 | 8 | 4 | 2 | 1 | 0 |

**The vocation's term** (`func_ov000_02159d24`): Martial Artist, Luminary and
Ranger 2, the other nine 1. **What they wear**: bits 20–26 of each worn
item's stats word 4 (`func_02085038`; see [Items](Items)). On the European
tables this is 3 on the combat action medal and 6, 7, 8 and 10 on the
critical, overcritical, hypercritical and dire critical fans, and 0 on
everything else. An action's own term (`+0x2c` bits 20–26) is 0 on every
action.

**The chance** is `(int)(multiplier × term)`, the multiplier 1.0, 2.0, 3.0
or 4.0 by how many of the living party are **already ready**
(`data_ov024_021fe738`). The member comes ready when the hundred drawn is
under it.

### Ready, and after

- **Coming ready** sets `status+0x3b` bit 3 and a count in bits 4–7 by level:
  **7 below 25, 8 below 50, 9 below 75, else 10**. Action 922 plays with
  actmsg 531, "`<ACTOR>` is primed to perform a coup de grâce!".
- **Each round's end** takes one off (`func_ov000_02157e1c`), with no draw.
  At 0 it passes, with actmsg 603 "The moment for `<TARGET>`'s coup de grâce
  has passed." in action 936. So **it is offered in the next 6, 7, 8 or 9
  command phases**, as the guide's table says.
- **Using it** clears it: an action of 505–514, 527 or 516, after the after-acting
  draw, which finds them still ready and so does not draw. A co-op (517,
  522–525, 530) clears it for each who took part. Death clears it too.
- **The command** is greyed (colour 3) until ready. Ready, its label pulses
  from (6, 6, 6) to blue (0, 16, 31), and **on its last phase it blinks
  orange, (28, 12, 3)**. A small panel shows a blue burst while ready.

### Each vocation's coup

`data_ov000_02183658`, by vocation; a Guardian's is the Warrior's.

| vocation | action | coup | kind |
|---|---|---|---|
| Warrior | 505 | Critical Claim | 1, a blow, always critical |
| Priest | 506 | Choir of Angels | 67 |
| Mage | 507 | 0 Zone | 68 |
| Martial Artist | 508 | Roaring Tirade | 10 |
| Thief | 509 | Itemised Kill | 69 |
| Minstrel | 510 | Rough 'n' Tumble | 70 |
| Gladiator | 511 | Tension Boost | 71 |
| Armamentalist | 512 | Voice of Experience | 72 |
| Paladin | 513 | Knight Watch | 73 |
| Sage | 514 | Spelly Breath | 26 |
| Luminary | 527 | Disco Tech | 10 |
| Ranger | 516 | Brownie Boost | 74 |

There is no action 515 in the English table.

## Not established

- Who writes Examine's surprise-round flags (`ui+0x950`, `0x954`).
- `func_0207c984`, which builds a kind's weapon list.
- Status `0x8000000` in the weighted pick.
- The coups' handlers (kinds 10, 26, 67–77), and how the co-ops pair.
- Whether a guest counts as a character for the coup.
