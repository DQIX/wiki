# Alchemy — `/data/bin/recipe.gp2`

What the Krak Pot makes. Read 25 September 2026.

**→ [The whole list of 470 recipes](Alchemy-Recipes)**, grouped by what they
make. This page is the format: what a record's twenty values are and how the
reading was checked.

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
| 14 | the result's item category — **EU only:** and the Alchenomicon's grouping, [below](#the-alchenomicons-own-grouping) | **470/470** against `itemsort` |
| 15 | the result's item subtype — **EU only:** and the book's By Type headings | **469/470** — the miss is the leather kilt, a skirt filed under trousers |
| 16 | **the recipe to reach instead** when an alchemiracle works, `−1` for none | 22 set; INFERRED, below |
| 17 | **the recipe to fall back to**, `−1` for none | 22 set; INFERRED, below |
| 18 | a display rank, 1–471, by equipment slot — **EU only:** the Alchenomicon's **By Type** sort | |
| 19 | a display rank, 1–471, **alphabetical by the result's name** — **EU only:** the book's **By Name** sort | rises with `itemsort`'s own alphabetical rank at **469/469** steps |

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

## The pot is spoken to

> **EU only.** Read on the European release (`YDQP`); the code addresses are the USA release's, from the decomp. Not yet checked on the US release's files (`YDQE`).

Read 25 September 2026. **The Krak Pot is a facility, opened by a tag at the end of a talk line**, as the shop, the inn and the church are. `<RENKIN>` compiles to facility code 7, and the talk service's switch at `0x0206f6cc` sends code 7 to `0x021b146c`; see [Items](Items#how-a-tag-opens-a-facility). The tag is bare — there is one pot, so it selects nothing — and it appears both as a line of its own and as a suffix after `<END>`.

**The pot is in the Quester's Rest at Stornway**, `R01M01`, "Stornway, Lobby Interior 1" in the map index. Its own line: "I am in tip-top shape, I assure you. Mentally and physically. A pot I may be, but I am in no way potty!"

**Its interface is in `bm_rrb`**: **Use A Recipe** ("Pick a recipe from the Alchenomicon and get kraking"), **Try Your Luck** ("Take pot luck with your own pick of ingredients"), Cancel, and "How many?".

**The Alchenomicon is a second way in.** The pot says so when it hands the book over — "The Alchenomicon is now accessible from the battle records menu." — and the code agrees: Battle Records (service 41) begins service 43, the alchemy overlay.

## The Alchenomicon's own grouping

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`).

Read 25 September 2026. `bm_rrb` is a `0x67` table of 48 labels, the same shape as `sta_skl` (see [Skill panels](Skill-Panels#where-the-words-are)). Besides the pot's menu, it names the recipe book's grouping, and **recipe values 14, 15, 18 and 19 are that grouping** — not only the cross-check against `itemsort` they were first read as.

The book groups by category:

| the book's category | [`itemsort`](Item-Kinds) categories | recipes |
|---|---|---|
| All Recipes | all | 470 |
| Weapons | 0 | 185 |
| Armour | 1–6 | 224 |
| Accessories | 7 | 30 |
| Items | 8, 9 | 31 |
| ??? | none | **0** |

Then eighteen **By Type** headings: the twelve weapon types — Swords, Spears, Knives, Wands, Whips, Staves, Claws, Fans, Axes, Hammers, Boomerangs, Bows — then Shields, Head, Torso, Arms, Legs and Feet. They cover Weapons and Armour and nothing else, because Accessories and Items have no sub-kinds: a recipe has exactly one heading if it is in one of those two categories, and none if it is not.

Each list sorts by one of two buttons, **By Type** (value 18) or **By Name** (value 19).

Every one of the 470 recipes falls in exactly one category with **none left over**, which is what makes this the book's grouping rather than a plausible arrangement. **What `???` is for is not established**: nothing on the cartridge lands in it.

## Where a recipe book is found is not read

Recipes are world objects and quest rewards, not items: **no item in any of the
nine `itemdt_*` tables is a recipe**, and `itemsort`'s subtype 31 holds the 26
skill books and nothing like a recipe book. A published guide's "where found"
column names bookcases, rooms and quest numbers, so the mapping — if it is a
table at all — is in the scenario scripts, and it was not found.

## Not established

- How the game draws the alchemiracle roll.
- Values 8 and 10 to 13.
- Where a recipe book is found.
- **EU only:** how **Try Your Luck** matches what goes in to a recipe. The game's own matching was not found. `str_ren` 11 suggests that only a recipe's exact ingredients, counts and all, make it; that is a reading of the line, not of the code.
- **EU only:** what the book's `???` category is for.

## Earlier readings

- This page carried the [mini medal](Mini-Medals) tables, with which array is the milestones and which the exchange **INFERRED** from `str_mdl`'s lines. Overlay 4's code has since been read, which settles it; the tables and the service are on their own page now.
- Values 14, 15, 18 and 19 were read as a cross-check and "two display ranks". They are the Alchenomicon's own grouping and its two sort buttons; see [above](#the-alchenomicons-own-grouping).

## See also

- [The recipes themselves](Alchemy-Recipes) — all 470, with their ingredients
- [Items](Items) — the item tables the ingredients and results are in
- [Tagged data table](Tagged-Data-Table)
- [System strings](System-Strings) — `str_ren`, the pot's words
- [Mini medals](Mini-Medals) — Cap'n Max's tables and service, once on this page
- [Party](Party) — Patty, who shares the pot's room
