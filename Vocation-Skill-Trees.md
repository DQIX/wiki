# Vocation Skill Trees

A table in the ARM9 binary, not in a file, that gives each of the twelve vocations its five skill trees: four weapon, shield or fisticuffs trees and its own. The ARM9 binary is BLZ-packed on the cartridge (see [DS-Compression](DS-Compression)), which is why searches of the cartridge's bytes found nothing; the table is found in the unpacked binary. The table's position, row shape and contents are confirmed in two releases; the meaning of the tree numbers is INFERRED on three independent legs.

Offsets are into the unpacked ARM9 binary of the European release (game code `YDQP`) unless stated.

## Layout

Thirteen rows of five bytes, indexed by the vocation's number, with row 0 for none.

| where | European (`YDQP`), unpacked ARM9 offset | USA release, address |
|---|---|---|
| table start (row 0) | `0xEE758` | `0x020ee748` |
| row 1 (warrior) | `0xEE75D` | |

The dqix-decomp project names the table `vocationSkillTrees`.

| byte | meaning |
|---|---|
| 0–3 | four distinct trees, each from 1 to 14 |
| 4 | the vocation's own tree — 15 for row 1, 16 for row 2, and so on to 26 |

**Row 0** is five zero bytes. The game's code refers to the table at row 0, not at the warrior's row. Rows 1 to 12 are the vocations in the [level tables'](Level-Tables) order.

The table can be found by its shape alone: twelve rows of five bytes, each four distinct trees from 1 to 14 and, last, the vocation's own tree running 15 to 26. No other run of sixty bytes in the binary or its overlays has that shape.

## Contents

| vocation | trees |
|---|---|
| warrior | sword 1, spear 2, knife 3, shield 13, Courage 15 |
| priest | spear 2, wand 4, staff 6, shield 13, Faith 16 |
| mage | wand 4, knife 3, whip 5, shield 13, Spellcraft 17 |
| martial artist | claws 7, staff 6, fan 8, fisticuffs 14, Focus 18 |
| thief | knife 3, sword 1, claws 7, fisticuffs 14, Acquisitiveness 19 |
| minstrel | sword 1, whip 5, fan 8, shield 13, Litheness 20 |
| gladiator | axe 9, hammer 10, sword 1, fisticuffs 14, Guts 21 |
| armamentalist | bow 12, sword 1, wand 4, shield 13, Force 22 |
| paladin | hammer 10, spear 2, wand 4, shield 13, Virtue 23 |
| sage | wand 4, bow 12, boomerang 11, shield 13, Enlightenment 24 |
| luminary | fan 8, whip 5, boomerang 11, shield 13, Je Ne Sais Quoi 25 |
| ranger | boomerang 11, axe 9, bow 12, fisticuffs 14, Ruggedness 26 |

The tree numbers are `str_sklc`'s (see [System-Strings](System-Strings)): 1 to 14 are the weapons, the shield and fisticuffs; 15 to 26 the vocations' own trees, named for them.

## Who wields a weapon

Weapons and shields carry no "Used by" bits in their stats (see [Items](Items)). An item's kind is the tree's number, so the vocations that may wield it are those whose row holds that tree. Expressed as bits in the same layout as armour's "Used by" word (bit v − 1 for vocation v), a weapon's users come out as the armour's do.

**Confirmed in the game, 24 September 2026**, and it is this table that is consulted. `func_020dd4c4` — ["may this character equip this?"](Items#who-may-wear-it) — reaches it through `0x020dd154` → `0x020dd19c` → `0x020dd11c`, whose literal at `0x020dd150` is `0x020ee748`, the table's own address:

```
020dd11c  ; if (voc != 0 && voc < 13 && i < 5) return ((u8*)0x020ee748)[voc*5 + i]
020dd1ec  cmp  r6, #4           ; only the first FOUR of the row
020dd1f0  blo  #0x20dd1a8
```

**Only the first four of each row are searched**, and that is right rather than an oversight: the fifth is the vocation's own tree, 15 to 26, which is never a weapon's. Each is compared through the identity byte table at `0x020ee700` (`00 01 02 … 0e`).

The other way past the rule is the tree's hundred-point Omnivocational [panel](Skill-Panels), which is asked **first** — see [Items](Items#weapons-and-shields-the-trees-or-the-panel).

## Evidence

The tree numbers' meaning is INFERRED, on three legs:

- the shape — no other run of sixty bytes in the binary or its overlays has it;
- the own trees running 15 to 26 in the vocations' order;
- the minstrel's row holding the sword, the fan and the shield, which a let's play video's Hero, a minstrel, wields and wears.

The search that found it asked for that minstrel row and for the warrior's sword and shield, and nothing else. Found 16 September 2026. Row 0 and the table's start were seen 17 September 2026 in a European dump and in the USA build.

## What is in a tree

The eleven panels of each tree — their costs, what they give and the words
they say — are `/data/prm/skilltable.bin`. See [Skill panels](Skill-Panels).

## Not established

- Whether the Omnivocational passives, which let one character wield a kind "regardless of vocation", show on the equipment screen's grid.

## See also

- [Items](Items) — item stats, weapon kinds and the "Used by" bits
- [Item-Kinds](Item-Kinds) — weapon subtypes
- [Level-Tables](Level-Tables) — the vocation order
- [Character-Presets](Character-Presets)
