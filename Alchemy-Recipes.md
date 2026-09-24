# Alchemy recipes — the whole list

Every one of the **470 recipes** in `/data/bin/recipe.gp2`, read off the
cartridge. [Alchemy](Alchemy) is the format page: what the twenty values of a
record are, how the reading was checked, and what in it is still not
established. This page is just the contents.

**Read from the European release** (game code `YDQP`). Recipes are numbered
1 to 471 and **359 is absent from the file**, which is why there are 470.

## How to read it

- **#** is the recipe's own number, the file's first value.
- Grouped by what the recipe makes, using `itemsort`'s subtype, and ordered
  within each group by the Alchenomicon's own rank — so the order here is the
  order the game's recipe book would list them in.
- **Counts are the file's.** `3× agate of evolution` means three.
- The last column marks the **alchemiracles**. 22 recipes can come out better
  than they say: the pair takes the same ingredients, and the odds shown are
  the better result's own. "only by alchemiracle" marks the better half, which
  has no recipe of its own — you attempt the ordinary one and may get this.

Item names are as the English text has them, with the game's own markup
resolved — `<1>` is an apostrophe, `<:u>` a diaeresis.

## Regenerating it

From your own dump, with [minstrel](https://github.com/Moss255/minstrel):

```sh
node --experimental-strip-types tools/inventory/src/cli.ts your.nds --recipes
```

which prints the same 470 rows tab-separated, with the ids, the categories and
the two cross-references as well.

Every recipe grouped by what it makes, 470 in all.

[Swords](#swords) (18) · [Spears](#spears) (17) · [Knives](#knives) (16) · [Wands](#wands) (15) · [Whips](#whips) (15) · [Staves](#staves) (14) · [Claws](#claws) (15) · [Fans](#fans) (19) · [Axes](#axes) (14) · [Hammers](#hammers) (12) · [Boomerangs](#boomerangs) (16) · [Bows](#bows) (14) · [Shields](#shields) (30) · [Helmets](#helmets) (23) · [Hats](#hats) (28) · [Armour](#armour) (23) · [Clothes](#clothes) (26) · [Robes](#robes) (21) · [Gauntlets](#gauntlets) (14) · [Gloves](#gloves) (11) · [Skirts](#skirts) (1) · [Trousers](#trousers) (22) · [Boots](#boots) (11) · [Shoes](#shoes) (14) · [Accessories](#accessories) (30) · [Medicines](#medicines) (16) · [Alchemy materials](#alchemy-materials) (15)

## Swords

| # | Makes | Ingredients | |
|---|---|---|---|
| 1 | **warrior’s sword** | 1× soldier’s sword + 1× raging ruby + 1× warrior’s helm |  |
| 2 | **steel broadsword** | 1× iron broadsword + 1× iron ore + 1× lava lump |  |
| 3 | **gigasteel broadsword** | 1× steel broadsword + 2× iron ore + 1× Hephaestus’ flame |  |
| 4 | **Fizzle foil** | 1× rapier + 3× narspicious + 1× mythril ore |  |
| 5 | **aurora blade** | 1× cautery sword + 3× brighten rock + 1× holy water |  |
| 6 | **platinum sword** | 1× iron broadsword + 1× platinum ore + 1× Hephaestus’ flame |  |
| 7 | **dragon slayer** | 1× dragonsbane + 1× mighty armlet |  |
| 8 | **über falcon blade** | 1× falcon blade + 1× meteorite bracer |  |
| 9 | **über miracle sword** | 1× miracle sword + 2× life bracer |  |
| 10 | **fire blade** | 1× Valkyrie sword + 3× lava lump + 1× rockbomb shard |  |
| 11 | **inferno blade** | 1× fire blade + 1× sunstone + 3× rockbomb shard |  |
| 12 | **liquid metal sword** | 1× metal slime sword + 1× orichalcum + 6× slimedrop |  |
| 13 | **metal king sword** | 1× liquid metal sword + 1× orichalcum + 1× slime crown |  |
| 14 | **Erdrick’s sword** | 1× rusty sword + 9× glass frit + 1× orichalcum |  |
| 15 | **stardust sword** | 1× supernova sword + 1× reset stone |  |
| 16 | **nebula sword** | 1× stardust sword + 1× agate of evolution + 1× silver orb |  |
| 17 | **supernova sword** | 1× nebula sword + 3× agate of evolution + 3× silver orb | **alchemiracle** → hypernova sword at 10% |
| 18 | **hypernova sword** | 1× nebula sword + 3× agate of evolution + 3× silver orb | only by alchemiracle, 10%; else supernova sword |

## Spears

| # | Makes | Ingredients | |
|---|---|---|---|
| 19 | **steel lance** | 1× iron lance + 1× iron ore + 1× lava lump |  |
| 20 | **gigasteel lance** | 1× steel lance + 2× iron ore + 1× Hephaestus’ flame |  |
| 21 | **celestial spear** | 1× long spear + 1× holy talisman + 2× platinum ore |  |
| 22 | **holy lance** | 1× iron lance + 1× gold rosary |  |
| 23 | **trident** | 1× battle fork + 2× seashell + 2× crimson coral |  |
| 24 | **Gracos’s trident** | 1× trident + 1× mighty armlet + 2× densinium |  |
| 26 | **sandstorm spear** | 1× holy lance + 2× kitty litter + 2× glass frit |  |
| 25 | **halberd** | 1× partisan + 1× battle-axe |  |
| 27 | **lightning lance** | 1× celestial spear + 3× thunderball + 1× mythril ore |  |
| 28 | **storm spear** | 1× lightning lance + 5× thunderball + 1× gold bar |  |
| 29 | **demon spear** | 1× celestial spear + 3× terrible tattoo + 1× malicite |  |
| 30 | **liquid metal spear** | 1× metal slime spear + 1× orichalcum + 6× slimedrop |  |
| 31 | **metal king spear** | 1× liquid metal spear + 1× orichalcum + 1× slime crown |  |
| 32 | **poker** | 1× split-pot poker + 1× reset stone |  |
| 33 | **stud poker** | 1× poker + 1× agate of evolution + 1× red orb |  |
| 34 | **split-pot poker** | 1× stud poker + 3× agate of evolution + 3× red orb | **alchemiracle** → red-hot poker at 10% |
| 35 | **red-hot poker** | 1× stud poker + 3× agate of evolution + 3× red orb | only by alchemiracle, 10%; else split-pot poker |

## Knives

| # | Makes | Ingredients | |
|---|---|---|---|
| 36 | **divine dagger** | 1× bronze knife + 3× holy water |  |
| 37 | **poison moth knife** | 1× divine dagger + 2× coagulant + 1× manky mud |  |
| 38 | **batterfly knife** | 1× poison moth knife + 3× coagulant + 3× butterfly wing |  |
| 39 | **dread dagger** | 1× batterfly knife + 1× disturbin’ turban + 5× butterfly wing |  |
| 40 | **poison needle** | 1× magic beast horn + 3× manky mud |  |
| 45 | **falcon knife earring** | 1× deadly nightblade + 1× slime earrings + 3× agility ring |  |
| 41 | **assassin’s dagger** | 1× deadly nightblade + 1× poison needle + 2× evencloth |  |
| 42 | **icicle dirk** | 1× divine dagger + 3× ice crystal + 1× edged boomerang |  |
| 43 | **Fenrir fang** | 1× icicle dirk + 5× ice crystal + 3× magic beast horn |  |
| 44 | **soul breaker** | 1× sword breaker + 1× life bracer + 1× spirit bracer |  |
| 46 | **gladius** | 1× flame tang + 1× reset stone |  |
| 47 | **flame tang** | 1× gladius + 1× sunstone + 3× crimson coral |  |
| 48 | **deft dagger** | 1× dashing dagger + 1× reset stone |  |
| 49 | **darting dagger** | 1× deft dagger + 1× agate of evolution + 1× purple orb |  |
| 50 | **dashing dagger** | 1× darting dagger + 3× agate of evolution + 3× purple orb | **alchemiracle** → dynamo dagger at 10% |
| 51 | **dynamo dagger** | 1× darting dagger + 3× agate of evolution + 3× purple orb | only by alchemiracle, 10%; else dashing dagger |

## Wands

| # | Makes | Ingredients | |
|---|---|---|---|
| 52 | **staff of sentencing** | 1× wizard’s staff + 1× flurry feather + 1× magic water |  |
| 53 | **staff of divine wrath** | 1× staff of sentencing + 3× flurry feather + 1× sage’s elixir |  |
| 57 | **watermaul wand** | 1× Stolos’ staff + 3× seashell + 3× crimson coral |  |
| 58 | **tsunami staff** | 1× watermaul wand + 1× celestial skein + 1× enchanted stone |  |
| 54 | **lightning staff** | 1× Stolos’ staff + 3× thunderball + 1× magic water |  |
| 55 | **lightning conductor** | 1× lightning staff + 5× thunderball + 1× sage’s elixir |  |
| 56 | **magma staff** | 1× Stolos’ staff + 3× rockbomb shard + 3× brighten rock |  |
| 59 | **rune staff** | 1× Stolos’ staff + 1× ruby of protection + 5× magic water |  |
| 60 | **hieroglyph staff** | 1× rune staff + 1× sorcerer’s ring + 3× sage’s elixir |  |
| 61 | **mega-magical mace** | 1× magical mace + 1× astral plume + 3× mythril ore |  |
| 62 | **savant’s staff** | 1× sage’s staff + 1× agate of evolution + 3× sage’s elixir |  |
| 63 | **bright staff** | 1× brilliant staff + 1× reset stone |  |
| 64 | **shining staff** | 1× bright staff + 1× agate of evolution + 1× blue orb |  |
| 65 | **brilliant staff** | 1× shining staff + 3× agate of evolution + 3× blue orb | **alchemiracle** → aurora staff at 10% |
| 66 | **aurora staff** | 1× shining staff + 3× agate of evolution + 3× blue orb | only by alchemiracle, 10%; else brilliant staff |

## Whips

| # | Makes | Ingredients | |
|---|---|---|---|
| 67 | **snakeskin whip** | 1× leather whip + 3× snakeskin |  |
| 68 | **serpentine whip** | 1× snakeskin whip + 5× snakeskin + 1× magic beast horn |  |
| 69 | **sidewinder** | 1× serpentine whip + 6× snakeskin + 1× tough guy tattoo |  |
| 70 | **spiked steel whip** | 1× iron whip + 1× iron ore + 1× lava lump |  |
| 71 | **gigaspike whip** | 1× spiked steel whip + 2× iron ore + 1× Hephaestus’ flame |  |
| 72 | **dragontail whip** | 1× iron whip + 3× dragon scale + 1× aggressence |  |
| 73 | **demon whip** | 1× iron whip + 1× terrible tattoo + 3× wing of bat |  |
| 74 | **archdemon whip** | 1× demon whip + 2× terrible tattoo + 1× malicite |  |
| 75 | **scourge whip** | 1× archdemon whip + 1× saint’s ashes |  |
| 76 | **empress’s whip** | 1× queen’s whip + 1× highness heels + 1× monarchic mark |  |
| 77 | **Goddess whip** | 1× empress’s whip + 1× Goddess ring + 1× agate of evolution |  |
| 78 | **Gringham whip** | 1× giga Gringham whip + 1× reset stone |  |
| 79 | **mega Gringham whip** | 1× Gringham whip + 1× agate of evolution + 1× green orb |  |
| 80 | **giga Gringham whip** | 1× mega Gringham whip + 3× agate of evolution + 3× green orb | **alchemiracle** → über Gringham whip at 10% |
| 81 | **über Gringham whip** | 1× mega Gringham whip + 3× agate of evolution + 3× green orb | only by alchemiracle, 10%; else giga Gringham whip |

## Staves

| # | Makes | Ingredients | |
|---|---|---|---|
| 82 | **steel bar** | 1× iron bar + 1× iron ore + 1× lava lump |  |
| 83 | **gigasteel bar** | 1× steel bar + 2× iron ore + 1× Hephaestus’ flame |  |
| 84 | **pillar of strength** | 3× oaken pole + 1× utility belt |  |
| 85 | **slumber stick** | 1× sleepy stick + 3× sleeping hibiscus + 1× narspicious |  |
| 86 | **killer pillar** | 1× driller pillar + 1× mighty armlet |  |
| 87 | **mistick** | 1× driller pillar + 3× fresh water + 3× flurry feather |  |
| 88 | **optimistick** | 1× mistick + 2× celestial skein + 1× agility ring |  |
| 89 | **ballistick** | 1× optimistick + 1× technicolour dreamcloth + 1× Mercury’s bandana |  |
| 90 | **Xenlon rod** | 1× dragon rod + 3× dragon scale + 3× sainted soma |  |
| 91 | **orichalcudgel** | 3× orichalcum + 3× Hephaestus’ flame |  |
| 92 | **knockout rod** | 1× catatonic cosh + 1× reset stone |  |
| 93 | **senseless stick** | 1× knockout rod + 1× agate of evolution + 1× blue orb |  |
| 94 | **catatonic cosh** | 1× senseless stick + 3× agate of evolution + 3× blue orb | **alchemiracle** → coma cudgel at 10% |
| 95 | **coma cudgel** | 1× senseless stick + 3× agate of evolution + 3× blue orb | only by alchemiracle, 10%; else catatonic cosh |

## Claws

| # | Makes | Ingredients | |
|---|---|---|---|
| 96 | **steel claws** | 1× iron claws + 1× iron ore + 1× lava lump |  |
| 97 | **gigasteel claws** | 1× steel claws + 2× iron ore + 1× Hephaestus’ flame |  |
| 98 | **sacred claws** | 1× iron claws + 1× holy talisman |  |
| 99 | **kestrel claws** | 1× crow’s claws + 1× agility ring |  |
| 100 | **kite claws** | 1× kestrel claws + 2× enchanted stone |  |
| 101 | **hammer handrills** | 1× handrills + 5× iron nails + 1× iron ore |  |
| 102 | **fire claws** | 1× dragon claws + 3× lava lump + 1× rockbomb shard |  |
| 103 | **combusticlaws** | 1× fire claws + 1× sunstone + 3× rockbomb shard |  |
| 104 | **king cobra claws** | 1× cobra claws + 4× terrible tattoo + 4× wing of bat |  |
| 105 | **beastmaster claws** | 1× beast claws + 1× monarchic mark + 9× magic beast horn |  |
| 106 | **orichalcum claws** | 1× combusticlaws + 2× orichalcum + 2× Hephaestus’ flame |  |
| 107 | **Dragonlord claws** | 1× Dragovian lord claws + 1× reset stone |  |
| 108 | **Dragovian claws** | 1× Dragonlord claws + 1× agate of evolution + 1× red orb |  |
| 109 | **Dragovian lord claws** | 1× Dragovian claws + 3× agate of evolution + 3× red orb | **alchemiracle** → Xenlon claws at 10% |
| 110 | **Xenlon claws** | 1× Dragovian claws + 3× agate of evolution + 3× red orb | only by alchemiracle, 10%; else Dragovian lord claws |

## Fans

| # | Makes | Ingredients | |
|---|---|---|---|
| 111 | **steel fan** | 1× iron fan + 1× iron ore + 1× lava lump |  |
| 112 | **gigasteel fan** | 1× steel fan + 2× iron ore + 1× Hephaestus’ flame |  |
| 113 | **foehn fan** | 1× feather fan + 1× flurry feather + 1× agility ring |  |
| 114 | **gale force fan** | 1× foehn fan + 1× enchanted stone + 1× agility ring |  |
| 115 | **tortoiseshell fan** | 1× war fan + 2× tortoiseshell + 1× evencloth |  |
| 116 | **Black Tortoise fan** | 1× tortoiseshell fan + 3× royal soil + 1× tortoise shell |  |
| 117 | **feline fan** | 1× war fan + 2× kitty litter + 2× seashell |  |
| 118 | **White Tiger fan** | 1× feline fan + 3× ice crystal + 1× kitty shield |  |
| 119 | **fowl fan** | 1× war fan + 2× flurry feather + 2× crimson coral |  |
| 120 | **Vermillion Bird fan** | 1× fowl fan + 3× lava lump + 1× razor-wing boomerang |  |
| 121 | **cobra fan** | 1× war fan + 2× snakeskin + 1× dragon scale |  |
| 122 | **Azure Dragon fan** | 1× cobra fan + 3× thunderball + 2× dragon scale |  |
| 123 | **lunar fan** | 1× stellar fan + 1× full moon ring + 1× lucida shard |  |
| 124 | **solar fan** | 1× lunar fan + 1× sunstone + 3× crimson coral |  |
| 125 | **friendly fan** | 1× solar fan + 1× life bracer + 9× horse manure |  |
| 126 | **critical fan** | 1× hypercritical fan + 1× reset stone |  |
| 127 | **overcritical fan** | 1× critical fan + 1× agate of evolution + 1× green orb |  |
| 128 | **hypercritical fan** | 1× overcritical fan + 3× agate of evolution + 3× green orb | **alchemiracle** → dire critical fan at 10% |
| 129 | **dire critical fan** | 1× overcritical fan + 3× agate of evolution + 3× green orb | only by alchemiracle, 10%; else hypercritical fan |

## Axes

| # | Makes | Ingredients | |
|---|---|---|---|
| 130 | **steel axe** | 1× iron axe + 1× iron ore + 1× lava lump |  |
| 131 | **gigasteel axe** | 1× steel axe + 2× iron ore + 1× Hephaestus’ flame |  |
| 132 | **golden axe** | 1× iron axe + 1× gold bar |  |
| 133 | **moon axe** | 1× battle-axe + 1× lunaria + 1× mystifying mixture |  |
| 134 | **full moon axe** | 1× moon axe + 1× full moon ring + 3× mystifying mixture |  |
| 135 | **king axe** | 1× golden axe + 1× slime crown |  |
| 136 | **kaiser axe** | 1× king axe + 1× slime crown + 1× monarchic mark |  |
| 137 | **executioner’s axe** | 1× headsman’s axe + 2× ethereal stone + 1× raging ruby |  |
| 138 | **ice axe** | 1× kaiser axe + 3× ice crystal + 3× icicle dirk |  |
| 139 | **avalanche axe** | 1× ice axe + 6× ice crystal + 1× agate of evolution |  |
| 140 | **bad axe** | 1× climaxe + 1× reset stone |  |
| 141 | **maxi axe** | 1× bad axe + 1× agate of evolution + 1× purple orb |  |
| 142 | **climaxe** | 1× maxi axe + 3× agate of evolution + 3× purple orb | **alchemiracle** → galaxy axe at 10% |
| 143 | **galaxy axe** | 1× maxi axe + 3× agate of evolution + 3× purple orb | only by alchemiracle, 10%; else climaxe |

## Hammers

| # | Makes | Ingredients | |
|---|---|---|---|
| 144 | **ace of clubs** | 1× oaken club + 3× belle cap |  |
| 145 | **über war hammer** | 1× war hammer + 1× mighty armlet |  |
| 146 | **terra tamper** | 1× über war hammer + 3× royal soil + 1× flintstone |  |
| 147 | **terra firmer** | 1× terra tamper + 5× royal soil + 2× densinium |  |
| 148 | **terra hammer** | 1× terra firmer + 7× royal soil + 3× ethereal stone |  |
| 149 | **titan’s hammer** | 1× giant’s hammer + 1× agate of evolution + 1× tough guy tattoo |  |
| 150 | **megaton hammer** | 1× Hela’s hammer + 1× orichalcum + 3× densinium |  |
| 151 | **warlord’s hammer** | 1× megaton hammer + 1× orichalcum + 1× mighty armlet |  |
| 152 | **groundbreaker** | 1× moonmasher + 1× reset stone |  |
| 153 | **earthsplitter** | 1× groundbreaker + 1× agate of evolution + 1× yellow orb |  |
| 154 | **moonmasher** | 1× earthsplitter + 3× agate of evolution + 3× yellow orb | **alchemiracle** → starsmasher at 10% |
| 155 | **starsmasher** | 1× earthsplitter + 3× agate of evolution + 3× yellow orb | only by alchemiracle, 10%; else moonmasher |

## Boomerangs

| # | Makes | Ingredients | |
|---|---|---|---|
| 156 | **reinforced boomerang** | 1× boomerang + 3× iron nails |  |
| 157 | **cutting-edge boomerang** | 1× edged boomerang + 3× magic beast horn + 3× iron nails |  |
| 158 | **crucerang** | 1× reinforced boomerang + 1× hunter’s bow + 1× gold rosary |  |
| 159 | **razer-wing boomerang** | 1× razor-wing boomerang + 3× lunaria |  |
| 160 | **erazor-wing boomerang** | 1× razer-wing boomerang + 3× aggressence + 1× mythril ore |  |
| 161 | **eaglewing** | 1× swallowtail + 1× kestrel claws + 3× flurry feather |  |
| 162 | **gusterang** | 1× swallowtail + 3× flurry feather + 1× agility ring |  |
| 163 | **blusterang** | 1× gusterang + 1× staff of divine wrath + 2× agility ring |  |
| 164 | **flametang boomerang** | 1× gusterang + 3× lava lump + 3× rockbomb shard |  |
| 165 | **banefire boomerang** | 1× flametang boomerang + 1× sunstone + 3× rockbomb shard |  |
| 166 | **pentarang** | 1× hexarang + 1× reset stone |  |
| 167 | **hexarang** | 1× pentarang + 3× lucida shard + 3× mythril ore |  |
| 168 | **meteorang** | 1× stellarang + 1× reset stone |  |
| 169 | **asterang** | 1× meteorang + 1× agate of evolution + 1× silver orb |  |
| 170 | **stellarang** | 1× asterang + 3× agate of evolution + 3× silver orb | **alchemiracle** → galaxarang at 10% |
| 171 | **galaxarang** | 1× asterang + 3× agate of evolution + 3× silver orb | only by alchemiracle, 10%; else stellarang |

## Bows

| # | Makes | Ingredients | |
|---|---|---|---|
| 172 | **longbow** | 1× short bow + 1× laundry pole |  |
| 173 | **hunter’s bow** | 1× longbow + 1× chain whip |  |
| 174 | **hotshot bow** | 1× potshot bow + 1× hunter’s hat + 1× archer’s armguard |  |
| 175 | **blowy bow** | 1× potshot bow + 3× flurry feather + 1× agility ring |  |
| 176 | **billowing bow** | 1× blowy bow + 1× staff of divine wrath + 2× celestial skein |  |
| 177 | **blustery bow** | 1× billowing bow + 1× gusterang + 3× celestial skein |  |
| 178 | **purblind bow** | 1× great bow + 1× mystifying mixture + 3× enchanted stone |  |
| 179 | **blinding bow** | 1× purblind bow + 2× mystifying mixture + 3× ethereal stone |  |
| 180 | **oh-no bow** | 1× Odin’s bow + 1× malicite |  |
| 181 | **Odin’s bow** | 1× oh-no bow + 3× saint’s ashes |  |
| 182 | **angel’s bow** | 1× aeon’s bow + 1× reset stone |  |
| 183 | **archangel’s bow** | 1× angel’s bow + 1× agate of evolution + 1× yellow orb |  |
| 184 | **aeon’s bow** | 1× archangel’s bow + 3× agate of evolution + 3× yellow orb | **alchemiracle** → seraph’s bow at 10% |
| 185 | **seraph’s bow** | 1× archangel’s bow + 3× agate of evolution + 3× yellow orb | only by alchemiracle, 10%; else aeon’s bow |

## Shields

| # | Makes | Ingredients | |
|---|---|---|---|
| 186 | **gold platter** | 1× silver platter + 1× gold bracer |  |
| 187 | **platinum platter** | 1× gold platter + 1× platinum ore |  |
| 188 | **shell shield** | 1× scale shield + 1× tortoiseshell |  |
| 189 | **steel shield** | 1× iron shield + 1× iron ore + 1× royal soil |  |
| 190 | **gigasteel shield** | 1× steel shield + 2× iron ore + 1× Hephaestus’ flame |  |
| 191 | **kitty shield** | 1× light shield + 1× kitty litter |  |
| 192 | **catty shield** | 1× kitty shield + 2× kitty litter |  |
| 193 | **white shield** | 1× light shield + 5× seashell + 5× holy water |  |
| 194 | **enchanted shield** | 1× magic shield + 1× enchanted stone |  |
| 195 | **ethereal shield** | 1× enchanted shield + 1× ethereal stone |  |
| 196 | **flame shield** | 1× magic shield + 1× lava lump + 1× resurrock |  |
| 197 | **ice shield** | 1× magic shield + 1× ice crystal + 1× resurrock |  |
| 198 | **platinum shield** | 1× light shield + 1× platinum ore + 1× Hephaestus’ flame |  |
| 199 | **dragon shield** | 1× magic shield + 3× dragon scale + 1× raging ruby |  |
| 200 | **tempest shield** | 1× magic shield + 3× flurry feather + 1× ruby of protection |  |
| 201 | **power shield** | 1× warrior’s shield + 1× raging ruby + 1× panacea |  |
| 202 | **empowered shield** | 1× power shield + 2× life bracer |  |
| 203 | **white knight’s shield** | 1× white shield + 1× holy talisman + 1× mythril ore |  |
| 204 | **ogre shield** | 1× dark shield + 2× densinium + 5× magic beast horn |  |
| 205 | **silver shield** | 1× white knight’s shield + 3× mirrorstone + 2× mythril ore |  |
| 206 | **big boss shield** | 1× boss shield + 1× agate of evolution + 1× mighty armlet |  |
| 207 | **saintess shield** | 1× ruinous shield + 3× saint’s ashes |  |
| 208 | **Goddess shield** | 1× saintess shield + 1× Goddess ring + 1× orichalcum |  |
| 209 | **liquid metal shield** | 1× metal slime shield + 1× orichalcum + 6× slimedrop |  |
| 210 | **metal king shield** | 1× liquid metal shield + 1× orichalcum + 1× slime crown |  |
| 211 | **Erdrick’s shield** | 1× rusty shield + 9× glass frit + 1× orichalcum |  |
| 212 | **brain drainer** | 1× devilry drinker + 1× reset stone |  |
| 213 | **psyche swiper** | 1× brain drainer + 1× agate of evolution + 1× green orb |  |
| 214 | **devilry drinker** | 1× psyche swiper + 3× agate of evolution + 3× green orb | **alchemiracle** → soul sucker at 10% |
| 215 | **soul sucker** | 1× psyche swiper + 3× agate of evolution + 3× green orb | only by alchemiracle, 10%; else devilry drinker |

## Helmets

| # | Makes | Ingredients | |
|---|---|---|---|
| 308 | **steel helmet** | 1× iron helmet + 1× iron ore + 1× royal soil |  |
| 309 | **gigasteel helmet** | 1× steel helmet + 2× iron ore + 1× Hephaestus’ flame |  |
| 310 | **filigree mask** | 1× iron mask + 1× silver platter + 1× silver tiara |  |
| 311 | **platinum headgear** | 1× iron mask + 1× platinum ore + 1× Hephaestus’ flame |  |
| 312 | **mythril coif** | 1× mail coif + 2× mythril ore |  |
| 313 | **thinking cap** | 1× steel helmet + 1× gold circlet + 3× sorcerer’s stone |  |
| 314 | **scholar’s circlet** | 1× thinking cap + 1× brainy bracer + 1× sage’s elixir |  |
| 315 | **raging bull helm** | 1× gigasteel helmet + 2× magic beast horn + 1× tough guy tattoo |  |
| 316 | **minotaur helm** | 1× raging bull helm + 4× magic beast horn + 1× mighty armlet |  |
| 317 | **Hades’ helm** | 1× great helm + 1× malicite |  |
| 318 | **mythril helm** | 1× platinum headgear + 3× mythril ore |  |
| 319 | **great helm** | 1× Hades’ helm + 1× saint’s ashes |  |
| 320 | **crown of clarity** | 1× thinking cap + 5× thinkincense + 1× mythril ore |  |
| 321 | **skull helm** | 1× Apollo’s crown + 1× malicite |  |
| 322 | **sun crown** | 1× skull helm + 3× saint’s ashes |  |
| 323 | **Apollo’s crown** | 1× sun crown + 1× agate of evolution + 1× sunstone |  |
| 324 | **liquid metal helm** | 1× metal slime helm + 1× orichalcum + 6× slimedrop |  |
| 325 | **metal king helm** | 1× liquid metal helm + 1× orichalcum + 1× slime crown |  |
| 326 | **Erdrick’s helmet** | 1× rusty helmet + 9× glass frit + 1× orichalcum |  |
| 327 | **hallowed helm** | 1× wonder helm + 1× reset stone |  |
| 328 | **blessed helm** | 1× hallowed helm + 1× agate of evolution + 1× purple orb |  |
| 329 | **wonder helm** | 1× blessed helm + 3× agate of evolution + 3× purple orb | **alchemiracle** → heavenly helm at 10% |
| 330 | **heavenly helm** | 1× blessed helm + 3× agate of evolution + 3× purple orb | only by alchemiracle, 10%; else wonder helm |

## Hats

| # | Makes | Ingredients | |
|---|---|---|---|
| 331 | **trailblazing bandana** | 1× bandana + 1× bow tie |  |
| 332 | **Mercury’s bandana** | 1× trailblazing bandana + 1× agility ring |  |
| 333 | **feathered cap** | 1× leather hat + 1× flurry feather |  |
| 334 | **bunny ears** | 1× hairband + 2× bunny tail |  |
| 335 | **cat ears** | 1× hairband + 2× kitty litter |  |
| 336 | **fur hood** | 1× leather hat + 1× magic beast hide + 1× lambswool |  |
| 337 | **pointy hat** | 1× leather hat + 1× magic beast horn |  |
| 338 | **golden tiara** | 1× silver tiara + 1× gold ring + 1× gold bracer |  |
| 339 | **slood** | 1× pointy hat + 3× slimedrop |  |
| 340 | **feather headband** | 1× hairband + 2× flurry feather |  |
| 341 | **hunter’s hat** | 1× pointy hat + 1× lambswool + 1× magic beast hide |  |
| 342 | **ear cosy** | 1× fur hood + 1× bunny tail + 1× lambswool |  |
| 343 | **gold circlet** | 1× circlet + 1× gold ring + 1× gold bracer |  |
| 344 | **star circlet** | 1× gold circlet + 1× lucida shard |  |
| 345 | **tricky turban** | 1× turban + 1× toad oil + 1× snakeskin |  |
| 346 | **thief’s turban** | 1× turban + 2× evencloth |  |
| 347 | **malleable mask** | 1× circlet + 2× butterfly wing + 2× narspicious |  |
| 348 | **papillon mask** | 1× malleable mask + 1× dread dagger + 3× narspicious |  |
| 349 | **canny cap** | 1× feathered cap + 2× brainy bracer |  |
| 350 | **musketeer hat** | 1× feathered cap + 1× feather headband + 3× magic beast hide |  |
| 351 | **mega-magical hat** | 1× magical hat + 2× prayer ring + 1× sorcerer’s stone |  |
| 352 | **happy hat** | 1× unhappy hat + 1× lucky pendant |  |
| 353 | **spellward circlet** | 1× gold circlet + 1× monarchic mark + 1× gold bar |  |
| 354 | **phantom mask** | 1× papillon mask + 1× dark robe + 3× slipweed |  |
| 355 | **spring breeze hat** | 1× winter sky hat + 1× agate of evolution + 1× green orb |  |
| 356 | **summer cloud hat** | 1× spring breeze hat + 1× agate of evolution + 1× green orb |  |
| 357 | **autumn shower hat** | 1× summer cloud hat + 1× agate of evolution + 1× green orb |  |
| 358 | **winter sky hat** | 1× autumn shower hat + 1× agate of evolution + 1× green orb |  |

## Armour

| # | Makes | Ingredients | |
|---|---|---|---|
| 216 | **large-scale armour** | 1× scale armour + 1× scale shield + 1× snakeskin |  |
| 217 | **silver cuirass** | 1× iron cuirass + 1× silver platter |  |
| 218 | **full plate armour** | 1× iron armour + 1× iron ore + 1× royal soil |  |
| 219 | **gigasteel armour** | 1× full plate armour + 2× iron ore + 1× Hephaestus’ flame |  |
| 220 | **tortoise shell** | 1× iron cuirass + 1× tortoiseshell + 1× emerald moss |  |
| 221 | **tortoiseshell armour** | 1× tortoise shell + 2× tortoiseshell + 2× emerald moss |  |
| 222 | **gold mail** | 1× silver mail + 1× gold ring + 1× gold bracer |  |
| 223 | **platinum mail** | 1× gold mail + 1× platinum ore + 1× Hephaestus’ flame |  |
| 224 | **enchanted armour** | 1× magic armour + 1× enchanted stone |  |
| 225 | **ethereal armour** | 1× enchanted armour + 1× ethereal stone |  |
| 226 | **dragon mail** | 1× magic armour + 2× dragon scale + 1× raging ruby |  |
| 227 | **spiked armour** | 1× magic armour + 2× magic beast horn + 5× iron nails |  |
| 228 | **holy mail** | 1× chain mail + 1× holy talisman + 1× mythril ore |  |
| 229 | **sacrosanct armour** | 1× sacred armour + 1× ruby of protection + 1× life bracer |  |
| 230 | **mirror armour** | 1× magic armour + 3× mirrorstone + 1× sober ring |  |
| 231 | **catoptric armour** | 1× mirror armour + 5× mirrorstone + 1× catholicon ring |  |
| 232 | **liquid metal armour** | 1× metal slime armour + 1× orichalcum + 6× slimedrop |  |
| 233 | **metal king armour** | 1× liquid metal armour + 1× orichalcum + 1× slime crown |  |
| 234 | **Erdrick’s armour** | 1× rusty armour + 9× glass frit + 1× orichalcum |  |
| 235 | **victorious armour** | 1× mythical armour + 1× reset stone |  |
| 236 | **glorious armour** | 1× victorious armour + 1× agate of evolution + 1× red orb |  |
| 237 | **mythical armour** | 1× glorious armour + 3× agate of evolution + 3× red orb | **alchemiracle** → legendary armour at 10% |
| 238 | **legendary armour** | 1× glorious armour + 3× agate of evolution + 3× red orb | only by alchemiracle, 10%; else mythical armour |

## Clothes

| # | Makes | Ingredients | |
|---|---|---|---|
| 239 | **tracksuit top** | 1× training top + 1× finessence |  |
| 240 | **fur poncho** | 1× leather cape + 3× magic beast hide |  |
| 241 | **cloak of concealment** | 1× cloak of evasion + 2× slipweed + 1× lambswool |  |
| 242 | **gooey gear** | 1× garish garb + 3× slimedrop |  |
| 243 | **majestic mantle** | 1× velvet cape + 1× bow tie + 3× brighten rock |  |
| 244 | **tussler’s top** | 1× tracksuit top + 1× finessence + 2× magic beast hide |  |
| 245 | **dragon dress** | 1× strongsam + 1× dragon scale + 2× finessence |  |
| 246 | **flamenco shirt** | 1× garish garb + 3× brighten rock + 1× technicolour dreamcloth |  |
| 247 | **dancer’s dress** | 1× dancer’s costume + 3× brighten rock + 1× technicolour dreamcloth |  |
| 248 | **fur vest** | 1× fur poncho + 3× magic beast hide |  |
| 249 | **superstar’s suit** | 1× star’s suit + 3× lucida shard |  |
| 250 | **technicolour tutu** | 1× tint-tastic tutu + 1× technicolour dreamcloth |  |
| 251 | **hot bikini top** | 1× dangerous bikini top + 3× seashell + 2× crimson coral |  |
| 252 | **sizzling bikini top** | 1× hot bikini top + 1× technicolour dreamcloth + 2× astral plume |  |
| 253 | **dragon top** | 1× tussler’s top + 2× dragon scale + 2× finessence |  |
| 254 | **dark robe** | 1× velvet cape + 3× evencloth + 3× slipweed |  |
| 255 | **macabre mantle** | 1× dark robe + 4× wing of bat + 3× terrible tattoo |  |
| 256 | **twinkling tuxedo** | 1× smart suit + 1× bow tie + 3× brighten rock |  |
| 257 | **shimmering dress** | 1× spangled dress + 1× pink pearl + 3× brighten rock |  |
| 258 | **dangerous bustier** | 1× divine bustier + 1× reset stone |  |
| 259 | **silk bustier** | 1× dangerous bustier + 7× tangleweb + 3× silk robe |  |
| 260 | **divine bustier** | 1× silk bustier + 7× slipweed + 3× sainted soma |  |
| 261 | **tropotoga** | 1× mesotoga + 1× reset stone |  |
| 262 | **stratotoga** | 1× tropotoga + 1× agate of evolution + 1× blue orb |  |
| 263 | **mesotoga** | 1× stratotoga + 3× agate of evolution + 3× blue orb | **alchemiracle** → exotoga at 10% |
| 264 | **exotoga** | 1× stratotoga + 3× agate of evolution + 3× blue orb | only by alchemiracle, 10%; else mesotoga |

## Robes

| # | Makes | Ingredients | |
|---|---|---|---|
| 265 | **robe of sweet dreams** | 1× robe of serenity + 3× sleeping hibiscus + 3× lambswool |  |
| 266 | **enchanted robes** | 1× magical robes + 1× enchanted stone |  |
| 267 | **ethereal robes** | 1× enchanted robes + 1× ethereal stone |  |
| 268 | **saintly robe** | 1× ascetic robe + 1× rosary + 3× grubby bandage |  |
| 269 | **Fizzle-proof suit** | 1× Fizzle-retardant suit + 1× sorcerer’s ring + 3× grubby bandage |  |
| 270 | **sage’s robe** | 1× saintly robe + 1× Fizzle-proof suit + 3× thinkincense |  |
| 271 | **flowing dress** | 1× enchanted robes + 3× celestial skein |  |
| 272 | **cape of good karma** | 1× majestic mantle + 6× thinkincense + 3× sage’s elixir |  |
| 273 | **princess’s robe** | 1× shimmering dress + 1× monarchic mark |  |
| 274 | **queen’s robe** | 1× princess’s robe + 1× monarch’s mittens + 2× lambswool |  |
| 275 | **empress’s robe** | 1× queen’s robe + 1× spellward circlet + 3× lambswool |  |
| 276 | **prince’s pea coat** | 1× twinkling tuxedo + 1× monarchic mark |  |
| 277 | **king’s coat** | 1× prince’s pea coat + 1× king axe + 2× lambswool |  |
| 278 | **emperor’s attire** | 1× king’s coat + 1× slime crown + 3× lambswool |  |
| 471 | **Celestria’s gown** | 1× nightmare gown + 3× saint’s ashes |  |
| 279 | **Celestria’s raiment** | 1× Celestria’s gown + 1× agate of evolution + 7× astral plume |  |
| 280 | **Xenlon robe** | 1× dragon robe + 1× dragon top + 1× dragon dress |  |
| 281 | **angel’s robe** | 1× aeon’s robe + 1× reset stone |  |
| 282 | **archangel’s robe** | 1× angel’s robe + 1× agate of evolution + 1× yellow orb |  |
| 283 | **aeon’s robe** | 1× archangel’s robe + 3× agate of evolution + 3× yellow orb | **alchemiracle** → seraph’s robe at 10% |
| 284 | **seraph’s robe** | 1× archangel’s robe + 3× agate of evolution + 3× yellow orb | only by alchemiracle, 10%; else aeon’s robe |

## Gauntlets

| # | Makes | Ingredients | |
|---|---|---|---|
| 360 | **steel gauntlets** | 1× iron gauntlets + 1× iron ore + 1× royal soil |  |
| 361 | **gigasteel gauntlets** | 1× steel gauntlets + 2× iron ore + 1× Hephaestus’ flame |  |
| 362 | **enchanted gloves** | 1× magic mittens + 1× enchanted stone |  |
| 363 | **ethereal gloves** | 1× enchanted gloves + 1× ethereal stone |  |
| 364 | **sturdy gauntlets** | 1× light gauntlets + 2× iron ore + 1× aggressence |  |
| 365 | **heavy gauntlets** | 1× sturdy gauntlets + 2× densinium + 1× aggressence |  |
| 366 | **blessed bindings** | 1× bruiser’s bracers + 3× thinkincense + 2× sage’s elixir |  |
| 367 | **liquid metal slime gloves** | 1× metal slime gauntlets + 1× orichalcum + 6× slimedrop |  |
| 368 | **metal king slime gloves** | 1× liquid metal slime gloves + 1× orichalcum + 1× slime crown |  |
| 369 | **Erdrick’s gauntlets** | 1× rusty gauntlets + 9× glass frit + 1× orichalcum |  |
| 370 | **Vesta gauntlets** | 1× Tempestes gauntlets + 1× reset stone |  |
| 371 | **Diana gauntlets** | 1× Vesta gauntlets + 1× agate of evolution + 1× red orb |  |
| 372 | **Tempestes gauntlets** | 1× Diana gauntlets + 3× agate of evolution + 3× red orb | **alchemiracle** → Sol Invictus gauntlets at 20% |
| 373 | **Sol Invictus gauntlets** | 1× Diana gauntlets + 3× agate of evolution + 3× red orb | only by alchemiracle, 20%; else Tempestes gauntlets |

## Gloves

| # | Makes | Ingredients | |
|---|---|---|---|
| 374 | **leather gloves** | 1× cotton gloves + 1× magic beast hide |  |
| 375 | **marquess’s mittens** | 1× mayoress’s mittens + 1× monarchic mark |  |
| 376 | **monarch’s mittens** | 1× marquess’s mittens + 1× highness heels |  |
| 377 | **guru’s gloves** | 1× heavy handwear + 3× thinkincense + 2× sage’s elixir |  |
| 378 | **gloomy gloves** | 1× heavy handwear + 3× evencloth |  |
| 379 | **murky mittens** | 1× gloomy gloves + 1× malicite + 3× evencloth |  |
| 380 | **matador’s gloves** | 1× mental mittens + 4× slipweed + 1× Mercury’s bandana |  |
| 381 | **apprentice’s gloves** | 1× grandmaster’s gloves + 1× reset stone |  |
| 382 | **master’s gloves** | 1× apprentice’s gloves + 1× agate of evolution + 1× silver orb |  |
| 383 | **grandmaster’s gloves** | 1× master’s gloves + 3× agate of evolution + 3× silver orb | **alchemiracle** → godly gloves at 20% |
| 384 | **godly gloves** | 1× master’s gloves + 3× agate of evolution + 3× silver orb | only by alchemiracle, 20%; else grandmaster’s gloves |

## Skirts

| # | Makes | Ingredients | |
|---|---|---|---|
| 285 | **leather kilt** | 1× boxer shorts + 1× magic beast hide |  |

## Trousers

| # | Makes | Ingredients | |
|---|---|---|---|
| 286 | **tracky bottoms** | 1× training trousers + 1× finessence |  |
| 287 | **boomer briefs** | 1× boxer shorts + 1× boomerang |  |
| 288 | **wonder pants** | 1× boomer briefs + 1× aggressence |  |
| 289 | **steel kneecaps** | 1× iron kneecaps + 1× iron ore + 1× royal soil |  |
| 290 | **gigasteel kneecaps** | 1× steel kneecaps + 2× iron ore + 1× Hephaestus’ flame |  |
| 291 | **hot bikini bottoms** | 1× dangerous midriff wrap + 3× seashell + 3× crimson coral |  |
| 292 | **sizzling bikini bottoms** | 1× hot bikini bottoms + 1× technicolour dreamcloth + 2× astral plume |  |
| 293 | **blessed bottoms** | 1× wizard’s trousers + 1× sorcerer’s stone + 2× lambswool |  |
| 294 | **tussler’s trousers** | 1× tracky bottoms + 1× finessence + 2× magic beast hide |  |
| 295 | **fancy pants** | 1× loud trousers + 3× belle cap + 1× narspicious |  |
| 296 | **chainmail socks** | 1× pop socks + 2× chain mail + 2× iron nails |  |
| 297 | **red tights** | 1× pop socks + 4× crimson coral |  |
| 298 | **green tights** | 1× pop socks + 4× emerald moss |  |
| 299 | **white tights** | 1× pop socks + 4× seashell |  |
| 300 | **transparent tights** | 1× red tights + 1× green tights + 1× white tights |  |
| 301 | **dragon trousers** | 1× tussler’s trousers + 2× dragon scale + 2× finessence |  |
| 302 | **tantric trousers** | 1× dragon trousers + 3× thinkincense + 2× sage’s elixir |  |
| 303 | **impregnable leggings** | 1× sturdy slacks + 1× densinium + 1× orichalcum |  |
| 304 | **invincible trousers** | 1× eternity trousers + 1× reset stone |  |
| 305 | **immortal trousers** | 1× invincible trousers + 1× agate of evolution + 1× purple orb |  |
| 306 | **eternity trousers** | 1× immortal trousers + 3× agate of evolution + 3× purple orb | **alchemiracle** → infinity trousers at 20% |
| 307 | **infinity trousers** | 1× immortal trousers + 3× agate of evolution + 3× purple orb | only by alchemiracle, 20%; else eternity trousers |

## Boots

| # | Makes | Ingredients | |
|---|---|---|---|
| 385 | **hobnail boots** | 1× leather boots + 1× magic beast hide |  |
| 386 | **steel sabatons** | 1× iron sabatons + 1× iron ore + 1× royal soil |  |
| 387 | **gigasteel sabatons** | 1× steel sabatons + 2× iron ore + 1× Hephaestus’ flame |  |
| 388 | **payback pumps** | 1× steel sabatons + 2× magic beast horn + 2× iron nails |  |
| 389 | **brahman boots** | 1× clever clogs + 3× thinkincense + 2× sage’s elixir |  |
| 390 | **liquid metal slime boots** | 1× metal slime sollerets + 1× orichalcum + 6× slimedrop |  |
| 391 | **metal king slime boots** | 1× liquid metal slime boots + 1× orichalcum + 1× slime crown |  |
| 392 | **hero’s boots** | 1× emperor’s boots + 1× reset stone |  |
| 393 | **basilic boots** | 1× hero’s boots + 1× agate of evolution + 1× yellow orb |  |
| 394 | **emperor’s boots** | 1× basilic boots + 3× agate of evolution + 3× yellow orb | **alchemiracle** → boots of beatitude at 20% |
| 395 | **boots of beatitude** | 1× basilic boots + 3× agate of evolution + 3× yellow orb | only by alchemiracle, 20%; else emperor’s boots |

## Shoes

| # | Makes | Ingredients | |
|---|---|---|---|
| 396 | **classy clogs** | 1× clogs + 2× belle cap |  |
| 397 | **stiletto heels** | 1× high heels + 1× fishnet stockings |  |
| 398 | **highness heels** | 1× stiletto heels + 1× monarchic mark |  |
| 399 | **sorceress sandals** | 1× siren sandals + 3× sleeping hibiscus + 2× belle cap |  |
| 400 | **wu shoes** | 1× kung fu shoes + 2× finessence |  |
| 401 | **safer shoes** | 1× safety shoes + 1× ruby of protection + 1× mythril ore |  |
| 402 | **safest shoes** | 1× safer shoes + 1× ruby of protection + 1× orichalcum |  |
| 403 | **elevating shoes** | 1× depressing shoes + 1× lucky pendant |  |
| 404 | **pixie boots** | 1× elevating shoes + 2× elfin charm |  |
| 405 | **tricksie boots** | 1× pixie boots + 1× agate of evolution |  |
| 406 | **sensible sandals** | 1× sapient sandals + 1× reset stone |  |
| 407 | **sagacious sandals** | 1× sensible sandals + 1× agate of evolution + 1× blue orb |  |
| 408 | **sapient sandals** | 1× sagacious sandals + 3× agate of evolution + 3× blue orb | **alchemiracle** → sentient sandals at 20% |
| 409 | **sentient sandals** | 1× sagacious sandals + 3× agate of evolution + 3× blue orb | only by alchemiracle, 20%; else sapient sandals |

## Accessories

| # | Makes | Ingredients | |
|---|---|---|---|
| 410 | **strength ring** | 1× gold ring + 1× aggressence |  |
| 411 | **tough guy tattoo** | 1× terrible tattoo + 1× aggressence |  |
| 412 | **raging ruby** | 1× strength ring + 1× corundum |  |
| 413 | **mighty armlet** | 1× gold bracer + 1× strength ring + 1× tough guy tattoo |  |
| 414 | **slime earrings** | 1× slimedrop + 1× gold ring |  |
| 415 | **ruby of protection** | 1× dragon scale + 1× corundum |  |
| 416 | **bow tie** | 2× butterfly wing + 1× grubby bandage |  |
| 417 | **utility belt** | 1× leather kilt + 1× ultramarine mittens + 1× grubby bandage |  |
| 418 | **agility ring** | 1× prayer ring + 2× flurry feather |  |
| 419 | **meteorite bracer** | 1× gold bar + 2× agility ring + 3× lucida shard |  |
| 420 | **sorcerer’s ring** | 1× skull ring + 1× saint’s ashes |  |
| 421 | **rosary** | 1× pink pearl + 3× fresh water + 3× thinkincense |  |
| 422 | **brainy bracer** | 1× gold bracer + 2× sorcerer’s stone |  |
| 423 | **life bracer** | 1× gold bracer + 2× life ring |  |
| 424 | **spirit bracer** | 1× gold bracer + 1× prayer ring + 1× elfin charm |  |
| 425 | **monarchic mark** | 1× lucky pendant + 1× raging ruby + 1× ruby of protection |  |
| 426 | **prayer ring** | 1× gold ring + 2× sage’s elixir |  |
| 427 | **holy talisman** | 1× gold rosary + 5× holy water + 1× resurrock |  |
| 428 | **sober ring** | 1× gold ring + 1× sandstorm spear + 1× panacea |  |
| 429 | **contra band** | 1× gold ring + 1× poison needle + 1× special antidote |  |
| 430 | **full moon ring** | 1× gold ring + 1× poison moth knife + 1× lunaria |  |
| 431 | **rousing ring** | 1× gold ring + 1× sleepy stick + 3× wakerobin |  |
| 432 | **ring of clarity** | 1× gold ring + 1× moon axe + 3× angel bell |  |
| 433 | **catholicon ring** | 1× rousing ring + 1× sober ring + 1× contra band |  |
| 434 | **skull ring** | 1× sorcerer’s ring + 1× malicite |  |
| 435 | **elfin charm** | 1× holy talisman + 1× elfin elixir + 3× emerald moss |  |
| 436 | **life ring** | 1× prayer ring + 3× resurrock |  |
| 437 | **Goddess ring** | 1× life ring + 1× sainted soma + 1× gold bar |  |
| 438 | **reckless necklace** | 1× lucky pendant + 1× malicite |  |
| 439 | **lucky pendant** | 1× reckless necklace + 1× saint’s ashes |  |

## Medicines

| # | Makes | Ingredients | |
|---|---|---|---|
| 440 | **strong medicine** | 2× medicinal herb |  |
| 441 | **special medicine** | 2× strong medicine |  |
| 442 | **superior medicine** | 1× medicinal herb + 1× strong medicine |  |
| 443 | **strong antidote** | 1× antidotal herb + 1× medicinal herb |  |
| 444 | **special antidote** | 2× strong antidote |  |
| 445 | **softwort** | 1× strong medicine + 1× moonwort bulb |  |
| 446 | **lunaria** | 3× moonwort bulb |  |
| 447 | **birdsong nectar** | 3× nectar + 1× fresh water + 5× sleeping hibiscus |  |
| 448 | **panacea** | 1× special medicine + 1× superior medicine + 1× moonwort bulb |  |
| 449 | **perfect panacea** | 1× panacea + 1× angel bell + 1× wakerobin |  |
| 450 | **Yggdrasil dew** | 1× Yggdrasil leaf + 1× elfin elixir |  |
| 451 | **magic water** | 1× holy water + 1× royal soil + 1× nectar |  |
| 452 | **sage’s elixir** | 1× magic water + 1× royal soil + 3× nectar |  |
| 453 | **elfin elixir** | 1× Yggdrasil leaf + 3× royal soil + 5× nectar |  |
| 454 | **mystifying mixture** | 1× belle cap + 1× manky mud + 3× cowpat |  |
| 455 | **sage’s stone** | 1× orichalcum + 3× birdsong nectar + 1× silver orb |  |

## Alchemy materials

| # | Makes | Ingredients | |
|---|---|---|---|
| 456 | **densinium** | 3× flintstone + 3× iron ore |  |
| 457 | **gold bar** | 3× sainted soma + 2× ethereal stone + 5× birdsong nectar |  |
| 458 | **Hephaestus’ flame** | 1× lava lump + 1× royal soil + 1× toad oil |  |
| 459 | **enchanted stone** | 2× thunderball + 2× ice crystal + 1× mystifying mixture |  |
| 460 | **ethereal stone** | 1× enchanted stone + 1× perfect panacea + 2× narspicious |  |
| 461 | **astral plume** | 3× flurry feather + 2× fresh water + 1× angel bell |  |
| 462 | **celestial skein** | 3× fresh water + 5× tangleweb |  |
| 463 | **technicolour dreamcloth** | 3× grubby bandage + 1× brighten rock + 1× celestial skein |  |
| 464 | **sainted soma** | 2× lucida shard + 2× sage’s elixir + 2× astral plume |  |
| 465 | **lucida shard** | 3× brighten rock + 3× evencloth |  |
| 466 | **agate of evolution** | 2× sainted soma + 2× ethereal stone + 1× chronocrystal |  |
| 467 | **sunstone** | 2× lucida shard + 3× mirrorstone + 1× Hephaestus’ flame |  |
| 468 | **malicite** | 1× pink pearl + 2× terrible tattoo + 3× narspicious |  |
| 469 | **finessence** | 2× fisticup + 1× slipweed + 1× superior medicine |  |
| 470 | **aggressence** | 2× fisticup + 1× wakerobin + 1× softwort |  |
