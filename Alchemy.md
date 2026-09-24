# Alchemy — `/data/bin/recipe.gp2`

What the Krak Pot makes. Read 25 September 2026.

A plain [tagged data table](Tagged-Data-Table): one `0x66` record holding the
count and **470 `0x67` records of twenty integers**. There is no string table —
a recipe has no name of its own and is shown by the name of the item it makes.
41,392 bytes; the five `recipe_<LG>.bin` members are the same length and give
the same records, because the file holds no text.

## How it was found

**Overlay 6 is the Krak Pot.** It carries `renkin`, `data/bin/recipe.gp2`
(`0x02160297`) and `recipe_<LG>.bin` beside `data/bin/menu/str_ren.gp2`,
`data/prm/itemname.gp2` and the pot's own art (`bm_rri`, `bm_rrb`, `lay_rrb`,
`orrb`, `bg_kamael`).

**The ARM9 route did not work here, and that is worth saying plainly.** The
trick that settled the [skill panels](Skill-Panels) — a per-tag handler table
sitting immediately before a file's own path string — does not apply: 21 such
tables exist across the ARM9 and the 35 overlays and **none belongs to this
file**. The load site in overlay 6 was disassembled and the record consumer was
not located. So the fields below are read from the data and from outside
witnesses, **not from an instruction**, which is a weaker footing than most of
this wiki.

## The twenty values

| # | meaning | how it is known |
|---|---|---|
| 0 | **the recipe's number**, 1–471 | all distinct; **359 is absent**, hence 470 records for 471 numbers |
| 1 | **the item it makes** | all 470 valid item ids, all distinct; values 14/15 are this item's own category and subtype |
| 2 | ingredient 1's item — never 0 | 470/470 valid item ids |
| 3 | ingredient 1's count, 1–3 | |
| 4 | ingredient 2's item, 0 for none | 0 exactly when value 5 is 0 |
| 5 | ingredient 2's count, 0–9 | |
| 6 | ingredient 3's item, 0 for none | 139 recipes have none |
| 7 | ingredient 3's count, 0–9 | |
| 8 | 0 on 448; 1–7 on the 22 alchemiracles | **not established** |
| 9 | **the per-cent chance this recipe is what comes out**: 100 on 448, 10 on 17, 20 on 5 | `str_ren` 18, below |
| 10 | 100 on 448, 40 on 12, 50 on 10 | a second chance of some kind; **not established** |
| 11 | 0, or 300 on the 22 | **not established** |
| 12 | 0, or 999 on the ten-per-cent ones and 700 on the twenty | **not established** |
| 13 | 0 on 131, 1 on 339 | **not established** — shop stock, "is an ingredient elsewhere" and "has a buy price" were each tested and none fits |
| 14 | the result's item category | **470/470** against `itemsort` |
| 15 | the result's item subtype | **469/470** — the miss is the leather kilt, a skirt filed under trousers |
| 16 | **the recipe to reach instead** when an alchemiracle works, `−1` for none | 22 set; INFERRED, below |
| 17 | **the recipe to fall back to**, `−1` for none | 22 set; INFERRED, below |
| 18 | a display rank, 1–471, by equipment slot — the Alchenomicon's order | |
| 19 | a display rank, 1–471, **alphabetical by the result's name** | rises with `itemsort`'s own alphabetical rank at **469/469** steps |

**At most three ingredients**, at least one, and the empty slots are always a
suffix — checked on all 470. 331 recipes use three, 135 two, 4 one.

### Decoded

```
#1    1x soldier's sword + 1x raging ruby + 1x warrior's helm    =>  warrior's sword
#3    1x steel broadsword + 2x iron ore + 1x Hephaestus' flame   =>  gigasteel broadsword
#7    1x dragonsbane + 1x mighty armlet                          =>  dragon slayer
#12   1x metal slime sword + 1x orichalcum + 6x slimedrop        =>  liquid metal sword
#144  1x oaken club + 3x belle cap                               =>  ace of clubs
```

## What holds the reading up

1. **A file this one does not point at.** `/data/prm/itemsort.gp2` gives every
   item a category and a subtype. Value 14 matches the result's on **470 of
   470** and value 15 on **469**. That only lines up if value 1 is the result.
2. **The same file again, on the ordering.** Value 19's order matches
   `itemsort`'s alphabetical rank at every one of 469 steps.
3. **A published strategy guide**, on eight sampled recipes, **counts
   included** — which is what pins values 3, 5 and 7.
4. **The pot's own words.** `str_ren` 18 is "I should think there's a `<val_2>`
   per cent chance of success in this case…"; 19 "A successful alchemiracle
   results in an item superior to the one indicated in the recipe"; 20 "even if
   you fail to work an alchemiracle, you shan't go away empty-handed". Values
   9, 16 and 17 are read as exactly those three sentences.

## The alchemiracle pairs

22 recipes name a better recipe at value 16; 22 others name a fallback at value
17; **each pairs with the other both ways and takes the same ingredients**, at
two grades of the same thing — supernova sword to hypernova sword, wonder helm
to heavenly helm. All 22 use 3× agate of evolution plus 3× one of the six orbs.

The odds are the **better** recipe's own value 9, not the one being attempted:
#17 makes the supernova sword at 100 and points at #18, which makes the
hypernova sword at 10 and points back at #17.

**How the game draws that roll is not found.**

## Where a recipe book is found is not read

Recipes are world objects and quest rewards, not items: **no item in any of the
nine `itemdt_*` tables is a recipe**, and `itemsort`'s subtype 31 holds the 26
skill books and nothing like a recipe book. A published guide's "where found"
column names bookcases, rooms and quest numbers, so the mapping — if it is a
table at all — is in the scenario scripts, and it was not found.

## Mini medals

Not in any data file. **Two arrays in overlay 4**, each `(u16 medals, u16 item)`.

**Ten milestones**, USA `0x02170010`, terminated `(0,0)`, bounded by
`0x021679b4: cmp r3, #0xa`, taking the first threshold that *exceeds* the
medals handed in:

| medals | reward | medals | reward |
|---|---|---|---|
| 4 | thief's key | 32 | miracle sword |
| 8 | Mercury's bandana | 40 | sacred armour |
| 13 | bunny suit | 50 | meteorite bracer |
| 18 | jolly roger jumper | 62 | rusty helmet |
| 25 | transparent tights | 80 | dragon robe |

**Six repeatable**, USA `0x0216fff8`, bounded by `0x02168440: cmp r4, #6`, its
two literals `0x0216fff8` and `0x0216fffa` fixing the pair layout: 3 prayer
ring · 5 elfin elixir · 8 saint's ashes · 10 reset stone · 15 orichalcum ·
20 pixie boots.

Which array is which is **INFERRED** from `str_mdl`: id 40 "For `<val_3>`
medals, ye get …" is the milestone line, and 60 "From now on, ye can pick for
yerself the booty" with 130 "That'll cost ye `<val_3>` mini medals" is the
after-eighty shop.

**How many medals exist is not found.** The mini medal is item 22039 and
nothing in the data counts them; quests award them too.

## See also

- [Items](Items) — the item tables the ingredients and results are in
- [Tagged data table](Tagged-Data-Table)
- [System strings](System-Strings) — `str_ren`, the pot's words; `str_mdl`, the medal man's
