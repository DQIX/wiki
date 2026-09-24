# Character Presets

Two tables of ready-made human characters built from worn parts: `/data/bin/charapreset.bin` (29 presets — 23 vocation-and-sex outfits and four named characters) and `presetdt_<lang>.bin` in `/data/bin/presetdt.gp2` (12 presets, the last four named Aquila, Erinn, Patty and Sellma). Both are [tagged data tables](Tagged-Data-Table). The worn-item slots are confirmed by item ids; the face, sex, proportions and several other values are INFERRED; many values are not established. Observations are from the European release (game code `YDQP`).

## `charapreset.bin`

A loose tagged data table: a `0x64` record holding 29, then 29 `0x65` records of 102 values. Every value is an integer by its kind bits except value 76, a string, and 90 and 91, floats. The strings are Shift-JIS.

Four strings are names — ナイン, シャノン, テンバタラ, ミーナ, the last two used by two records each. Twenty-three name a vocation and a sex: せん (warrior), ぶと (martial artist), そう (priest), まほ (mage), ぞく (thief, a man only), たび (minstrel) and the six vocations after them, each おとこ, man, or おんな, woman.

### Layout

| value | meaning | evidence |
|---|---|---|
| 0–74 | `unknown_items`: item ids, `0xFFFFFFFF` for none, in runs — weapons, then shields, legwear, footwear, gloves, armour, then headgear | every one an item's id; what the lists are for is not established |
| 75 | `unknown_75` | 64, 66 and 55 on the vocations; 18 to 25 on the named four |
| 76 | the name | a string, as above |
| 77 | `unknown_77` | 9024 on all 23 vocations; 9023 or 9024 on the named |
| 78 | a face, 9000 plus its number — INFERRED | `f006` on every man's vocation record, `f005` on every woman's; on all 41 presets here and in `presetdt` it lands on a face that exists |
| 79 | armour worn | 13xxx |
| 80 | legwear worn | 16xxx; 8001 on the sage man, which names nothing |
| 81 | gloves worn, or the arms when there are none | 15xxx or 14xxx |
| 82 | footwear worn | 17xxx |
| 83 | headgear worn | 12xxx |
| 84 | weapon | 20xxx |
| 85 | shield | 21xxx |
| 86 | sex: 0 a man, 1 a woman | on all 23 vocations, as おとこ and おんな say |
| 87 | the arms, 14xxx, numbered as the armour | 28 of 29; ナイン's is 1825 |
| 88, 89 | `unknown_88`, `unknown_89` | 1 or 2; 0 |
| 90, 91 | floats, 1.0 on most — 0.95 and 0.98 on the mage woman, 1.154 to 1.195 on テンバタラ; a figure's proportions, INFERRED | |
| 92–101 | `unknown_92` to `unknown_101` | the same ten on most vocations |

Worn ids name parts by the rule in [Character-Parts](Character-Parts).

### What each vocation wears

By the item names (see [Items](Items)):

- **The minstrel man**: flamenco shirt, loud trousers, acroboots and feather headband, no weapon.
- **The minstrel woman**: dancer's dress, starlet sandals and circlet; her legwear, 16190, names no item.
- **The warrior man**: the warrior's armour, trousers, gloves, boots, helm, sword and shield — which ナイン wears too.

These outfits are the evidence for the "Used by" bits of equipment stats (see [Items](Items)).

## `presetdt_<lang>.bin`

One to a language in `/data/bin/presetdt.gp2` (see [GPC2](GPC2)): a tagged data table whose `0x66` and `0x68` records each list 20 string offsets, then a `0x69` record holding 12, and 12 `0x6a` records of 35 values — value 1 a string, the rest integers. The strings are 40 Shift-JIS names and, in English, Aquila, Erinn, Patty and Sellma, whom the last four records name.

**So the village's Erinn is built of parts**: "Erinn's outfit" 13622 (`p_b622`), her boots 17140, her headkerchief 12432.

### Layout

| value | meaning |
|---|---|
| 0 | the record's number |
| 1 | its name |
| 2 | 0 on Aquila, 1 on Erinn, Patty and Sellma — a sex, INFERRED |
| 3 | the arms, 14xxx — numbered as the armour on 11 of 12 |
| 4–8 | `unknown_4` to `unknown_8` |
| 9 | armour |
| 10 | legwear |
| 11, 12 | as `charapreset`'s 77 and 78 — 12 a face, INFERRED |
| 13 | none on all 12 — gloves, INFERRED |
| 14 | footwear |
| 15 | headgear |
| 16 | weapon — a knife, 19061, on Patty |
| 17 | shield |
| 18 | an accessory, 18039, on Patty |
| 19–34 | `unknown_19` to `unknown_34` |

## Evidence

- Worn slots: the ids fall in the item id ranges of their slot (12xxx headgear, 13xxx armour, and so on) and the outfits match the vocations by item name.
- In `charapreset`, 141 of the 155 ids the vocations' presets wear name a part that exists (see [Character-Parts](Character-Parts)).
- In `presetdt`, 55 of the 57 ids the records wear name a part that exists.
- Face: value 78 (and `presetdt`'s 12) lands on an existing face on all 41 presets.

## Not established

- `charapreset` values 0–74 (what the item lists are for), 75, 88, 89 and 92–101.
- `presetdt` values 4–8 and 19–34.
- The first of the two 90xx values (`charapreset` value 77, `presetdt` value 11).
- Where a preset's hair style, variant and colour are kept, if in it at all. (The Hero's own are the player's, chosen at character creation.)
- Why six legwear numbers name no part on the cartridge. See below — the reading that those bodies cover the legs is INFERRED from two of thirteen.

## Thirteen of the twenty-nine name legwear that is not on the cartridge

Found 24 September 2026, by dressing all twenty-nine from the parts in
`chara_pc.gp2` (see [Character parts](Character-Parts)).

Sixteen dress from their own values. The other thirteen name legwear that is
**not in `chara_pc.gp2` and not in `chara_pd.gp2` either**:

| legwear | presets that want it |
|---|---|
| `16190` → `p_p190` | 11, 16, 24, 26, 28 |
| `16201` → `p_p201` | 3, 5, 10 |
| `16101` → `p_p101` | 18 |
| `16102` → `p_p102` | 20 |
| `16110` → `p_p110` | 25 |
| `16112` → `p_p112` | 27 |
| `8001` — in no part band at all | 23 |

Their neighbours are all present — `p_p191`, `p_p200`, `p_p202`, `p_p100`,
`p_p103` — so these are gaps in the numbering rather than a whole range being
missing, and the armour each of the thirteen names **is** on the cartridge.
Only the legwear is absent.

**INFERRED: those bodies cover the legs.** Preset 11 is a woman in a
full-length dress and preset 23 a sage in a hooded robe to the ankles, and
neither shows any leg to dress. That would make a legwear value with no part
behind it the file's way of saying "nothing goes here", and the
[underclothes](Character-Parts) `p_p090` — a body, legs and feet made as a set
for no item — the thing to put underneath. **Only two of the thirteen were
looked at**, so the other eleven are a guess by family resemblance.

## See also

- [Character-Parts](Character-Parts)
- [Items](Items)
- [Attending-Characters](Attending-Characters)
- [Tagged-Data-Table](Tagged-Data-Table)
- [GPC2](GPC2)
