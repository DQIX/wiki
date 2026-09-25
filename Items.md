# Items

Item names live in `/data/prm/itemname.gp2` (`itemname_<lang>.nat`) and item records in `/data/prm/itemdt_*.gp2` (`itemdt_<c>_<lang>.nat`, one table per category). Each equipment table also carries, after its records, a table of stats. Shops are in `/data/bin/menu/shopdata1.bin`, and talk lines hand over to shops, inns and churches with service tags. The name records, the record layout's id, actions and both prices, and the stats table's shape are confirmed. The price scale, rarity, the attack, defence and other stat fields, and who may use a piece are INFERRED. Several fields are not established. Observations are from the European release (game code `YDQP`).

## Names — `itemname_<lang>.nat`

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 2 | `u16` | record count (1,178 in English) |
| `+0x02` | 2 | `u16` | a value that differs by language; not established |
| `+0x04` | 16 × count | records | see below |
| then | | strings | the record offsets count from here |

Each 16-byte record:

| field | meaning |
|---|---|
| 1 | offset of the singular name |
| 2 | offset of the plural name |
| 3 | a word that differs by language: the name's grammar — its articles, packed as a monster's are (see [Articles](Articles)) |
| 4 | the item's id |

Record 0 is `wonder helm` / `wonder helms`, id `0x2F8A`.

## Item tables — `itemdt_<c>_<lang>.nat`

**The id is the item's.** Every item table is a 32-byte head and then 32-byte records, each holding an id from the names. The tools table's first is `0x55F0`, medicinal herb, then strong medicine, special medicine, superior medicine, antidotal herb. The stride was measured by where the names' ids fall in each file: 32 on 1,007 of the combined table's gaps and on every per-category table's.

The categories, by their first records:

| `<c>` | category |
|---|---|
| `a` | gloves |
| `b` | body |
| `d` | accessories |
| `h` | helms |
| `l` | footwear |
| `s` | shields |
| `t` | tools |
| `u` | legwear |
| `w` | weapons |

### Record layout

**A record begins four bytes before its id.**

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 4 | `u16` ×2 | what using it does: two action numbers (see [Actions](Actions)), 252 for nothing |
| `+0x04` | 2 | `u16` | the item's id |
| `+0x06` | 2 | `u16` | **what a shop gives for it** — its selling price; see "The price" |
| `+0x08` | 2 | `u16` | **what a shop asks for it**: the price itself, or a code on the selling price — `0xFFFF` twice, `0xFFFE` twice and one, `0xFFFD` twice less one, `0xFFFC` ten times; 0 on some items no shop sells |
| `+0x0A` | 22 | | a sort position; at `+0x10` a `u16`; a run of numbers that count the records; and an icon (see below) |
| `+0x15`, bits 1–3 | | | **rarity**, the equipment screen's stars, 0 to 5 — INFERRED (see below) |

**`+0x10`** is **the offset, into the names block at the table's end, of the next record's item's name** — on all but the last record of the weapons (267 of 268), shields (44 of 45) and armour (182 of 183), never the record's own. This suggests a record really begins 16 bytes before where it is read here (not established).

**`+0x15` rarity**, INFERRED (16 September 2026) from the value alone:

- the copper sword and the flame shield carry 1, and two captures of the equipment screen show one star for each;
- the tools carry 0 or 1 and show no stars;
- of the 268 weapons, 120 carry 1, 59 carry 2, 34 carry 3, 42 carry 4 and 12 carry 5 — the twelve that cost 30,000 G — with a rank correlation against price of 0.67; on every equipment table the counts fall from 1 to 5;
- the rusty sword and rusty shield, the legendary bases, carry 4.

The byte's bit 0 is 1 on the armour tables and 0 on weapons and shields, and its high nibble is 5 or 10; neither is read.

### The two actions

36 of the 234 tools name an action called what they are — the medicinal herb 255 in both, holy water 259 and 260, the chimaera wing 261, sage's elixir 410. 179 name 252, which has no name, as all but a few pieces of equipment do.

**The 23 skill books name actions that are not theirs.** Their first numbers run 10, 21, 32, 54, 65, 76 … 285 in steps of eleven — Frizzle, Bang, Moreheal, the seed of magic on the Sage's Scripture — which is a count, not an action. Every other tool's field action is called what the tool is, so an item's field action applies only when it is one.

**Which is which, INFERRED: the field's first, battle's second.** The chimaera wing, the Evac-u-bell and the nine seeds, which the series uses only outside battle, have 252 second. The weapons and shields that do something when used in battle have 252 first and an action second (370, 384, 396 …).

### The price

**The price word**, INFERRED and well supported: every one of the 330 items any shop sells has one above 0, and none of the 140 items at 0 — quest pieces, the celestial suit among them — is sold anywhere.

**But the word is not what a shop asks.** Found 15 September 2026, against a let's play video of the European release, whose village shop shows the price of all 18 of its items. What the shop asks is the word **scaled by `+0x08`**:

| `+0x08` | asks | the village shop's 18 | all 330 sold items |
|---|---|---|---|
| `0xFFFF` | twice the word | 11 of 11 — the herb 8, the soldier's sword 240 | 315 |
| `0xFFFE` | twice, and one | 2 of 2 — the chimaera wing 25, the bandana 45 | 4 |
| `0xFFFD` | twice, less one | 1 of 1 — the leather whip 95 | 2 |
| `0xFFFC` | ten times | 4 of 4 — the copper sword 150, the feather fan 110 | 7 |

A check that does not lean on those 18: of the 13 sold items with one of the last three values, all 13 then ask a price ending in 0 or 5 — the paring knife 70, the oak staff 120, the softwort 95, the tangleweb 35, the leather hat 65, among ones the let's play does not show — where doubling their word gives such an ending for only 1 of them.

**The word is what a shop gives, and `+0x08` what it asks** — 22 September 2026, from the *Dragon Quest IX* Signature Series guide, whose item lists print a buying and a selling price for every item. That corrects two readings above:

- The two "other" values are prices, not scales. The **bamboo lance**, `0x55`, costs **85** and sells for **8**; the **halberd**, `0x2BC0`, costs **11,200** and sells for **6,600** — `+0x08` and `+0x06` exactly. Stornway's weapon shop prices the lance at 85 too.
- **What a shop gives is the word itself**, not half what it asks. The copper sword, a `0xFFFC` item, sells for **15** — a tenth of its 150, not 75. Where the code is `0xFFFF` the word is half what is asked, which is why halving looked right: the soldier's sword 240 and 120, the rapier 480 and 240, the iron lance 450 and 225. Items no shop sells have a selling price all the same, and it is the word: the star's suit 11,750, the stud poker 24,000.

The guide prints the copper sword's buying price as 159, against 150 on its own shop pages and in the let's play: a misprint.

Why the scale is kept this way is not known. A shop's rate (see "Shops") multiplies what is asked: 100 on all shops but one. Whether it touches what a shop gives is not established.

## The stats — the table after an equipment category's records

Found 15 September 2026. Each equipment table — weapons, shields, headgear, armour, gloves, legwear, footwear and accessories; not the tools, which do not continue so — goes on past its records:

| where | what | on all eight |
|---|---|---|
| `32 × N` | N entries of 32 bytes, N the head's record count | the first shares its 32 bytes with the last record: its first eight are that record's actions, id and price |
| then | 100 bytes, not read | 100 on all eight |
| the file's end, less the head's `u32` at `+0x08` | N names, each ending with a zero | N on all eight, every one an item's name; the `u32` is their length exactly |

The first entry's words 0 and 1 are the last record's, and the last record's own bytes 8 to 31 — its sort position, name offset and icon on any other record — are the first entry's.

**The names label the entries, in order**: entry *k* is the item named *k*-th. That order is the bag's — [Item-Kinds](Item-Kinds)' `unknown_1` — on most categories, but not on legwear, where only the names' order holds. Scanning in the weapon records' own order cannot find the table.

The names are one to an entry in all eight English tables, but not in every language. **The Spanish armour's names block holds 180 for 183 entries**, since three pairs of items share a Spanish name — "atuendo de combate", "chaqueta de esgrima", "vestido de bailarina" — and the block keeps each once; the records' name offsets (above) point both of a pair at it. Even the English shields have two records pointing at one "pot lid". So a name can be given to an entry by position only where the names are one to an entry. The numbers of entry *k* are the same in every language.

### Entry words

Words 5, 6 and 7 (bytes 20–31) are **three 10-bit fields each**: bits 30 and 31 are set on none of them. The fields were read by what the items' own descriptions ([Item-Descriptions](Item-Descriptions)) say they do, entry by entry, measured on the 936 entries whose first words are their own (the first of each table left out).

| word | bits 0–9 | bits 10–19 | bits 20–29 |
|---|---|---|---|
| 5 | **attack**, INFERRED — every weapon, and 4 accessories | **defence**, INFERRED — 570 entries | set only on the 24 wands and staff-like weapons, 10–100; not established — the one whose description names a stat, the rune staff, "steps up magical might", but magical might has a field of its own in word 7 |
| 6 | **the chance of blocking, in tenths of a hundredth** — read from the game's code, below. Set only on shields, 42 of the 45, 5–100: bronze 5, iron 10, steel 15, Erdrick's 90 | **evasion**, in tenths likewise — read from the code, which bears out what was INFERRED: all five body pieces that set it say so — the cloak of evasion "makes evading enemy attacks easier" 30, the dark robe "sends enemy attacks astray" 20; also on 55 pieces of footwear, whose descriptions do not say; 5–60 | **the chance of a critical hit**, INFERRED on one witness: the critical acclaim, which "cranks up the chance of a critical hit", 40 |
| 7 | **deftness**, INFERRED: the utility belt "does wonders for deftness" 25, the medal of freedom "upgrades deftness" 100; on 43 of the 78 gloves | **agility**, INFERRED: the agility ring "accentuates agility" 20, the meteorite bracer "insanely agile" 100, the Mercury prize 120 | **magical might**, INFERRED: the sorcerer's stone "a little" 2, the brainy bracer 8, the mager achievement "maximises magical might" 50; on 66 hats and 40 body pieces |

**Word 6's first two fields are read by the battle's code.** `func_02084ee8` (USA) walks the eleven pieces a character wears and sums bits 0–9 of each one's record, each over `10.0f`; the battle's block rate is that sum when a shield is worn and nothing otherwise. `func_02084f58` does the same with bits 10–19 for the evasion rate. The runtime record the code indexes begins at this entry's word 3, so its `+0x0C` is word 6. **The block rate is not truncated before it meets a whole draw below a hundred**, so the bronze shield's 0.5 and the iron shield's 1.0 both block once in a hundred, and the steel shield's 1.5 twice. A third function, `func_02084fc8`, sums word 5's bits 20–29 — the field set only on the wands and staves — in the same way; what for is not followed. See [Battle resolution](Battle-Resolution).

**Word 5: attack and defence**, INFERRED from what they do:

- **Within each kind of weapon, attack rises with price**: copper sword 7, soldier's sword 13, rapier 19, iron broadsword 27 … dragon slayer 88, and likewise for spears, knives, wands, whips, poles, claws, fans, axes, hammers, boomerangs and bows. The sign test over neighbours in price order within kinds scores 0.62; the next best field anywhere in the data or the code, laid out the same way, scores 0.44. Its exceptions are the weapons whose worth is not their edge: the poison needle and the falcon knife earring 1, the falcon blade 12, the golden axe 26.
- **Defence rises the same way** on shields (pot lid 1, leather shield 3, scale shield 5 … dragon shield 24), headgear (iron helmet 11, iron mask 14, steel helmet 15), armour (leather armour 6, scale 9, chain mail 11 … heavy armour 35), gloves, legwear and boots. The flame shield's is 18 — matching the defence quoted for it from a published list whose source is not recorded.
- Weapons carry no defence and armour no attack. Accessories carry either — a strength ring attack 4, a raging ruby 9, a gold ring defence 2, a dragon scale 5 — and one of the 52 carries both.
- The largest values: attack 180, defence 100. Ten bits for each is INFERRED.
- The values are the same in all five languages' tables, on every entry of all eight.

**Word 0** is set on 137 entries, whose descriptions speak of resistances — to spells, sleep, Fizzle, MP being stolen: several fields packed, perhaps; not established. Its bits 20–29 are set on 8, four of them about MP.

**Words 1 and 2** are packed, and set on every entry; not established.

**Word 3**: bit 0 is set on all 936. **Bits 7–11 are a weapon's kind plus one** — exactly [Item-Kinds](Item-Kinds)' subtype + 1 on all 267 weapons, two files agreeing — 13 on all 44 shields, and 0 on 622 of the other 625. Its top bits are not established.

**Word 4**: on the weapons, bits 12–15 are one number for each kind — swords 1, hammers 3, knives 4, wands 5, spears 6, axes 7, boomerangs 8, bows 9, whips 10, staves 11, claws 12, fans 13 — not established. Bits 0–11 are 0 on every weapon and shield, and **`0xfff` on all 51 accessories** and most armour, with other patterns on the rest — `0xebe`, `0x5e1`, `0x6a6`, and single bits `0x1`, `0x4`, `0x8`. INFERRED: who may wear it, a bit for each of the twelve vocations the equipment screen's "Used by" shows.

### Who may wear it — word 4, bits 0–11

**Which bit is which — INFERRED, 16 September 2026: bit v − 1 is vocation v in the [level tables'](Level-Tables) order** (warrior, priest, mage, martial artist, thief, minstrel, gladiator, armamentalist, paladin, sage, luminary, ranger; `str_tm` 2101 to 2112 name them so, after 2100's Guardian — see [System-Strings](System-Strings)).

The evidence is the 23 vocation presets of `charapreset.bin` (see [Character-Presets](Character-Presets)), each named for a vocation and a sex. Every armour, legwear, glove, footwear and headgear piece a preset dresses in carries one bit and no other:

| bit | pieces |
|---|---|
| 0 | the warrior's armour, trousers, gloves, boots and helm |
| 1 | the priestess's pinafore, the ascetic robe |
| 2 | the wizard's trousers |
| 3 | the tussler's top |
| 4 | the rogue's robes |
| 5 | the flamenco shirt, the loud trousers |
| 6 | the tactical vest |
| 7 | the fencing jacket |
| 8 | holy mail |
| 9 | the sage's robe |
| 10 | the star's suit |
| 11 | the nomadic deel |

The exceptions: two pieces any vocation may wear (`0xfff`, the thug's mug and the red tights), and two of another vocation's (a thief in the warrior's gloves). The skill trees named for the vocations, `str_sklc` 15 to 26 — Courage, Faith, Spellcraft, Focus, Acquisitiveness, Litheness, Guts, Force, Virtue, Enlightenment, Je Ne Sais Quoi, Ruggedness — run in the same order.

**Weapons and shields carry no bits.** Their use goes by the vocations' weapon skills — `str_gskl` 5, `"becomes able to equip <str_2> regardless of vocation"`, is the Omnivocational passives' line — and which vocation has which of the fourteen weapon and shield skill trees is in the ARM9 binary, not in a file: see [Vocation-Skill-Trees](Vocation-Skill-Trees). An item's kind (word 3, above) is the tree's number, so who wields it is whoever has that tree.

## Who may wear it

Read 24 September 2026. **`0x020dd4c4`** is the game's own "may this character
equip this?", and it is the one place the two rules above meet. It takes a
character id and a 0x20-byte in-RAM item entry and hands back a **bitmask of
refusal reasons — zero meaning yes**.

The in-RAM entry is `+0x00` a pointer to the item's record, `+0x08` a word
whose **low nibble is the category, 0 to 7**, and `+0x18` the item id as a
signed halfword. The record it points at lines up with the file entry's word 3,
so the record's `+0x04` is the file's **word 4** — the used-by word above.

| bit | refused because |
|---|---|
| `0x200` | no entry, or its id is not positive |
| `0x020` | no such character |
| `0x008` | the category is above 7, or the record is missing |
| `0x100` | the record's word 0 bit 29 is set and this is not the protagonist |
| `0x001` | **a weapon or shield whose tree the character has not got** |
| `0x002` | **armour whose vocation bit is clear** |
| `0x010` | `word0 >> 30` — two bits — exceeds `live[0x186 + vocation]`. Observed; **what it means is not established** |
| `0x080` | **sex** |

A vocation of 0 returns 0: **the Guardian may wear anything.**

### Armour: the twelve bits, categories 2 to 7 only

```
020dd5f0  lsl  r0, r0, #0x1c
020dd5f4  lsrs r0, r0, #0x1c      ; the category
020dd5f8  moveq r0, #0 / beq      ; 0, weapons: skip
020dd600  cmp  r0, #1
020dd604  moveq r0, #0 / beq      ; 1, shields: skip
020dd61c  ldr  r0, [r0, #0x950]   ; the vocation
020dd630  sub  r0, r0, #1
020dd634  ldr  r2, [r1, #4]       ; the used-by word
020dd63c  lsl  r0, r1, r0         ; 1 << (v - 1)
020dd640  lsl  r1, r2, #0x14
020dd644  tst  r0, r1, lsr #20    ; against bits 0 to 11
```

So **bit `v − 1` for vocation `v`, in bits 0 to 11**, exactly as the vocation
presets had it inferred — and applied **only to categories 2 to 7**. Weapons
and shields skip it entirely, which is why their word is zero.

### Weapons and shields: the trees, or the panel

The item's tree is **word 0 bits 7 to 10** of the record. Two things are asked,
and **the earned panel is asked first**:

```
020dd5a4  lsl  r1, r1, #0x15
020dd5a8  lsr  r1, r1, #0x1c      ; the tree
020dd5b0  bl   #0x20dd200         ; has the tree's Omnivocational panel?
020dd5b8  movne r1, #0 / bne      ; yes: allowed
020dd5d8  bl   #0x20dd154         ; else: does the vocation hold the tree?
020dd5e4  moveq r1, #1            ; neither: refused
```

- `0x020dd154` → `0x020dd19c`, which walks the vocation's row of
  [vocationSkillTrees](Vocation-Skill-Trees) at `0x020ee748`. Its loop is
  `i < 4`, **not** five, and that is right rather than a bug: the fifth entry
  of a row is the vocation's *own* tree, 15 to 26, which is never a weapon's.
- `0x020dd200` walks a thirteen-entry `(flag, tree)` table at `0x020ee710` —
  `(9,1) (20,2) (31,3) (64,4) (97,5) (75,6) (119,7) (130,8) (185,9) (196,10)
  (251,11) (218,12) (42,13)` — and asks `0x02083b00` for that flag out of a
  per-character bit array at **`live+0x8EC`**. That array is written by the
  skill-award walker at `0x0209a700`, which reads the twelve-byte
  [skill panel](Skill-Panels) records and grants a panel's flag once the
  tree's points reach its cost.

  **INFERRED, on strong numbers:** all thirteen flag ids are ≡ 9 (mod 11), so
  each is the **tenth panel of a tree** in the 26 × 11 layout — which is the
  hundred-point Omnivocational panel of each weapon and shield tree, the one
  the panel table marks `grants = 4`. Thirteen values landing on that residue
  by chance is about 11⁻¹³.

### Sex

The character's sex is **bit 0 of the byte at `live+0x49C`**, immediately after
the ten-halfword equipment array at `live+0x488`. The item's record carries two
bits, and they are used as a **two-entry lookup indexed by that bit**, never
compared:

```
020dd6e0  lsl  r2, r1, #4         ; bit 27 -> sp[0]
020dd6e4  lsl  r1, r1, #3         ; bit 28 -> sp[1]
020dd6f8  ldr  r0, [r0, r6, lsl #2]   ; sp[sex]
020dd700  movne r0, #0            ; set: may wear
020dd704  moveq r0, #0x80         ; clear: refused
```

- **bit 27** — sex 0 may wear it; **bit 28** — sex 1 may wear it.
- **bit 29** is not a plain restriction. It matters only when the character has
  **accessory 18048 (`0x4680`) in equipment slot 9**: with that worn,
  `bit29 == 0` skips the sex test altogether. Read it as "**this item's sex
  lock cannot be lifted by 18048**".

```
020dd6a4  ldrb r2, [r2, #0x49c]
020dd6b4  bl   #0x2052df8         ; what is in slot 9
020dd6bc  cmp  r0, r1             ; r1 = 18048
020dd6c0  bne  #0x20dd6d8         ; not it: do the sex test
020dd6cc  lsrs r0, r0, #0x1f      ; bit 29
020dd6d0  moveq r0, #0            ; clear: allowed outright
```

Which of sex 0 and sex 1 is male is **not established** from code, and neither
is where sex lives in the 0x23C persistent record — every read goes through
`live+0x49C`, which is past that record's end.

Two other places do the same triple and then push the piece into the bag —
`0x02175ba8` and `0x02178448` in overlay 3 — so there *is* a "strip what you
may no longer wear" routine. It is **not** the one
[Alltrades](Party#changing-vocation-alltrades-abbey) calls.

### Not found as numbers

Charm, max HP and max MP — the spirit bracer "boosts max. MP by thirty", and there is no 30 anywhere in its entry — and the vocation medals' own effects. They may be worked by each item's own code.

## Shops — `/data/bin/menu/shopdata1.bin`

A loose file, a [tagged data table](Tagged-Data-Table): a date and a version string, one `0x66` record holding 37, and 37 `0x67` records of 22 integers, one per shop.

| value | meaning |
|---|---|
| 0 | the shop's number — **the one a talk line's `<SHOP=n>` names**: the village shopkeeper's line ends `<ADD><SHOP=32>`, and shop 32 is the village's |
| 1 | 1 to 5; not established |
| 2–19 | eighteen item ids, 0 for an empty slot — full on most shops, 1, 6 or 12 on others |
| 20 | 100 on 36 shops and 500 on one, whose six things are the ordinary shops' herbs and wings: a price rate in percent, INFERRED |
| 21 | 0 on every shop that sells only weapons, 1 on shops of armour, 2 on tools and accessories, 3 to 5 on a mix: the kind of shop, INFERRED |

Every item a shop sells is in the item tables, with a price.

## Services in talk — `<SHOP=n>`, `<INN=n>`, `<CHURCH=n>`

A talk line that hands over to a service ends `<ADD>` and a service tag (see [Character-Dialogue](Character-Dialogue)). Across the English talk files there are 352 `<SHOP=n>`, 505 `<INN=n>`, 325 `<CHURCH=n>` and 48 `<BANK>`. In the village: the shopkeeper's `<SHOP=32>`, the innkeeper's `<INN=1>` and `<INN=2>` on different lines, and the priest's `<CHURCH=1>`.

The innkeeper's lines leave the price and the party's size to be filled in — "That'll be `<val_2>` gold coins" — and `str_inn.bin` beside the scenario is empty; no table of inn prices has been found. `str_church.bin` is a tagged table of the church's words, in Japanese only.

### How a tag opens a facility

Read 25 September 2026, and it is the same mechanism for all of them. The text
compiler turns each of these tags into a **facility code** carried in the
message; `func_0206f6cc` — the one function the talk service (5) calls for this
— switches on that byte:

```
0206f6fc  ldrb  r1, [r5, r4]           ; the facility code out of the message
0206f700  cmp   r1, #0xc
0206f704  addls pc, pc, r1, lsl #2     ; so code n is at 0x0206f70c + 4n
```

| code | begins | what | its tag |
|---|---|---|---|
| 1 | `0x21bac24` | the inn | `<INN=n>` |
| 2 | `0x21ba8e0` | the church | `<CHURCH=n>` |
| 3 | `0x217e300` | the bank | `<BANK>` |
| 4 | `0x21b2c24` | the shop | `<SHOP=n>` |
| 5, 8 | `0x21b65e0` | [Patty's Party Planning Place](Party#recruitment) | `<LUIDA>` |
| 6, 12 | `0x218d77c` | the Quester's Rest counter | — |
| **7** | `0x21b146c` | **the [Krak Pot](Alchemy)** | `<RENKIN>` |
| 9, 10 | `0x21c12fc` | [Alltrades](Party#changing-vocation-alltrades-abbey), the second being revocation | — |
| 11 | `0x21a8614` | the Starflight Express | — |

**So a facility is never a menu command.** `<RENKIN>` and `<LUIDA>` are bare —
there is one pot and one Patty, so they select nothing — and both appear as a
line of their own *and* as a suffix after `<END>`. The pot's own line is "A pot
I may be, but I am in no way potty!"; Patty's is "Here's hoping you find plenty
of folks you can go adventuring with!"

Counts across the English talk files: **88 `<RENKIN>`** and **48 `<LUIDA>`**,
all in the `R01`–`R0n` archives, which are the Quester's Rests. The pot and
Patty share a room: `R01M01` is "Stornway, Lobby Interior 1".

Codes 6, 9, 10, 11 and 12 have **no text tag** in the compiler's list, so
whatever produces their code is elsewhere and is **not established**.

## Evidence

- Record stride: where the names' ids fall in each `itemdt` file — stride 32 on 1,007 of the combined table's gaps and on every per-category table.
- Record start: read first from the id behind a 36-byte head, each record's last four bytes held the *next* item's actions — the medicinal herb's ended `(256, 256)`, strong medicine's action — and the head's own last four were `(255, 255)`, the herb's. So a record begins four bytes before its id.
- Price scale: a let's play video of the European release (village shop, 18 items), plus the 0-or-5 check above.
- Rarity: two captures of the equipment screen (copper sword, flame shield), and the distribution across weapons.
- Stats: the sign test over neighbours in price order within weapon kinds; item descriptions for the other fields.
- Used-by bits: the 23 vocation presets in `charapreset.bin`.
- Shop 32: the village shopkeeper's talk line `<ADD><SHOP=32>`.

### Earlier searches for the stats

These found nothing, and are recorded so they are not repeated:

- **No field of the item record climbs with price** as a weapon's attack would. The best, bits of `+0x11`, agrees with the price's order at 0.64 over 264 weapons, where attack against price would be expected far higher.
- **No file holds the weapons' ids at a fixed spacing beside such numbers**: `itembtlprm.nat`'s 44-byte records, `itemsort`'s 28, the ARM9 binary and all its overlays, decompressed.
- **The tail after the records** was at first taken for a layout rather than per-item numbers: 32-byte entries with 4096s in them (1.0 in fixed point), 386 of them for 268 weapons. It is the stats table above.
- **A search by position.** Every run of 268 numbers, 8- or 16-bit, at every spacing from 1 to 64 bytes, was scored by the sign test over neighbours in price order — only the 168 neighbours whose price strictly rises — laid out once by the weapon table's own order and once by `id − 19050`, leaving room for missing ids. The weapon table's order follows price at only 0.21, so a counter does not pass. The test works: the item tables' own price field scores 1.00, in all ten copies in five languages. Nothing else reached 0.35 in 918 sources — every file in `/data/prm` and `/data/bin`, the ARM9 and its 35 overlays, decompressed. In the 10,550 files of `/data/menu`, `/data/skill`, `/data/enemy`, `/data/tmap`, `/data/pack` and `/data/pack_lv5`, laid out by the table's own order only, the best was 0.38, in a model's and a background's pixels. The search failed because it scanned in the weapon records' order; the stats table is in the names' order.
- A Rusty sword's "Attack E 215", on a level-58 character wearing it, is the character's attack, not the sword's, so it is not a value to search for.
- An earlier pass matched stats entries to records by position and found the used-by bits inconsistent; matched by name, they are consistent.

## Not established

- The names file's second `u16`.
- The rest of the record's `+0x0A` run: which bytes are the sort position, the counting numbers and the icon; whether a record really begins 16 bytes earlier.
- `+0x08` values other than the four listed (0 and a few others); the price of the bamboo lance (`0x55`) and the halberd (`0x2BC0`); why the scale is kept so.
- Rarity byte `+0x15`: bit 0 and the high nibble.
- Stats: the 100 bytes between the entries and the names; word 0 (resistances, perhaps); words 1 and 2; word 3's top bits; word 4 bits 12–15 on weapons; word 5 bits 20–29 on wands; word 6 bits 0–9 on shields.
- Where charm, max HP, max MP and the vocation medals' effects come from.
- Shops: value 1.
- What the inn's and the church's numbers select; where inn prices are kept.
- Whether the Omnivocational passives show on the equipment screen's "Used by" grid.

## See also

- [Equipment battle parameters](Equipment-Battle-Parameters) — what a worn thing does in a battle, and the resistances it carries

- [Item-Kinds](Item-Kinds) — category, subtype and bag order
- [Item-Descriptions](Item-Descriptions)
- [Item-Icons](Item-Icons)
- [Vocation-Skill-Trees](Vocation-Skill-Trees)
- [Character-Presets](Character-Presets)
- [Actions](Actions)
- [Articles](Articles)
- [Tagged-Data-Table](Tagged-Data-Table)
- [GPC2](GPC2)
