# Item Kinds

`itemsort_<lang>.bin`, in `/data/prm/itemsort.gp2`: a [tagged data table](Tagged-Data-Table) with one record per item giving its category, subtype and two orders. The id, category and subtype are confirmed; the two orders are INFERRED. Observations are from the European release (game code `YDQP`).

## Layout

After its date and version records, one record of tag `0x67` for each item — 1,178 in English — of five integers.

| value | meaning | evidence |
|---|---|---|
| 0 | the item's id | every one is an id in `itemname_en.nat`, each once |
| 1 | `unknown_1` | **an order over the whole bag**, INFERRED: each category a run of its own — the weapons 1 to 268, the shields 269 to 313, the headgear 314 to 445, the armour 446 to 628, the gloves 629 to 706, the legwear 707 to 793, the footwear 794 to 894, the accessories 895 to 946, the tools from 947 — and 9,999 on the blarney stone alone |
| 2 | `unknown_2` | 1 to 1,178, each once: **alphabetical order by English name**, INFERRED — the names rise along it at 1,159 of 1,177 steps; the skill books, whose names open with markup, come first |
| 3 | the category | see below — **exactly the item tables' members** |
| 4 | the subtype | 0 to 31, see below |

### Categories

| value | category | items |
|---|---|---|
| 0 | weapons | 268 |
| 1 | shields | 45 |
| 2 | armour | 183 |
| 3 | legwear | 85 |
| 4 | headgear | 132 |
| 5 | gloves | 78 |
| 6 | footwear | 101 |
| 7 | accessories | 52 |
| 8, 9 | tools | 234 |

### Subtypes

By the items in each:

| value | subtype |
|---|---|
| 0 | swords |
| 1 | spears |
| 2 | knives |
| 3 | wands (the staffs) |
| 4 | whips |
| 5 | staves (the poles) |
| 6 | claws |
| 7 | fans |
| 8 | axes |
| 9 | hammers (and clubs) |
| 10 | boomerangs |
| 11 | bows |
| 12 | shields |
| 13 | armour |
| 14 | clothes |
| 15 | robes |
| 16 | trousers |
| 17 | skirts |
| 18 | helmets |
| 19 | hats |
| 20 | gauntlets |
| 21 | gloves |
| 22 | boots |
| 23 | shoes |
| 24 | accessories |
| 25 | medicines |
| 26 | seeds |
| 27 | keys |
| 28 | alchemy materials |
| 29 | important items |
| 31 | skill books |

**The weapon kinds 0 to 11 are in the order of the item-info icons**, `obj_iteminfo`'s cells 1 to 12 in `oiij_<lang>.pac` (see [Pac](Pac)): a sword, a spear, a knife, a wand, a whip, a staff, a claw, a fan, an axe, a hammer, a boomerang, a bow — and cell 13, a shield, is subtype 12's. The equipment screen draws a weapon's kind with them.

A weapon's subtype + 1 equals bits 7–11 of word 3 of its stats entry on all 267 weapons (see [Items](Items)), and `unknown_1` is the order of the stats entries on most categories.

## Evidence

- Ids matched against `itemname_en.nat`.
- Category counts match the item tables' record counts.
- **Neither `unknown_1` nor `unknown_2` follows price** in any category — 0.33 at best, the shields' `unknown_1`, by the sign test over neighbours in price order — so neither is a stat.

### Earlier readings

This file was once searched, with the item tables, `itembtlprm.nat` and the item records, for an item's numbers, rarity and who may use it, at any position, width or scale, tested against 41 shields' published defence and rarity (from a source not recorded, which weakens that test). Nothing was found here. Those values have since been read from the stats table after each equipment table's records and from the item record's byte `+0x15` — see [Items](Items).

## Not established

- Subtype 30 (the list skips from 29 to 31).

## See also

- [Items](Items)
- [Item-Icons](Item-Icons)
- [Item-Descriptions](Item-Descriptions)
- [Vocation-Skill-Trees](Vocation-Skill-Trees)
- [Tagged-Data-Table](Tagged-Data-Table)
