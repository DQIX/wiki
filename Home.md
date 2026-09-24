# Dragon Quest IX file formats

Notes on the file formats of *Dragon Quest IX: Sentinels of the Starry Skies* for the Nintendo DS, as far as they have been worked out. They come from writing readers for the game's files and checking them against the cartridge. Nothing here is a dump of the game's data: values are quoted only where they're needed to show a layout or its evidence.

## How to read these pages

- **Confirmed** fields are backed by observed bytes, or by published documentation that's cited on the page.
- **INFERRED** marks a meaning reasoned from evidence but not proven. The reasoning is given with it.
- **`unknown_0x..`** regions and **Not established** sections are gaps. They're listed on purpose: a known gap is more useful than a guess.
- **Evidence** sections say what was observed, in which file, at which offset.

## Which cartridge

Unless a page says otherwise, observations are from the **European release (game code `YDQP`)**. Offsets into the ARM9 binary or an overlay are into the *unpacked* binary. Both are BLZ-compressed on the cartridge; see [DS compression](DS-Compression). Where a table has also been found in the USA release, the page gives its address there and its name in the [dqix-decomp](https://github.com/DQIX/dqix-decomp) project.

File paths are paths inside the cartridge's filesystem ([NitroFS](NitroFS)).

## Contents

**DS platform** — general Nintendo DS formats, with what this cartridge shows of them: [NitroFS](NitroFS) · [DS compression](DS-Compression) · [NSBMD](NSBMD) · [2D graphics](2D-Graphics) · [SDAT](SDAT)

**Level-5 containers:** [GPC2](GPC2) · [.pac](Pac) · [Tagged data table](Tagged-Data-Table)

**Maps:** [Map list](Map-List) · [Map archive](Map-Archive) · [Collision](Map-Collision) · [Objects](Map-Objects) · [Textures](Map-Textures) · [Doors](Doors) · [Area cast](Area-Cast) · [Triggers](Triggers) · [Treasure](Treasure) · [Mini-map](Mini-Map) · [Poison marsh](Poison-Marsh)

**Graphics:** [Bitmap font](Bitmap-Font) · [Sprites](Sprites) · [Menu backgrounds](Menu-Backgrounds) · [Item icons](Item-Icons) · [Character parts](Character-Parts) · [Character presets](Character-Presets) · [Motion tables](Motion-Tables)

**Text and scripts:** [Text markup](Text-Markup) · [Event text](Event-Text) · [Event scripts](Event-Scripts) · [Character dialogue](Character-Dialogue) · [Item descriptions](Item-Descriptions) · [Item kinds](Item-Kinds) · [Articles](Articles) · [Battle text](Battle-Text) · [System strings](System-Strings)

**Game data:** [Party](Party) · [Items](Items) · [Vocation skill trees](Vocation-Skill-Trees) · [Skill panels](Skill-Panels) · [Alchemy](Alchemy) · [Battle weight tables](Battle-Weight-Tables) · [Level tables](Level-Tables) · [Spell table](Spell-Table) · [Attending characters](Attending-Characters) · [Monsters](Monsters) · [Event battles](Event-Battles) · [Encounters](Encounters) · [Actions](Actions) · [Battle resolution](Battle-Resolution)

## Contributing

If you can confirm, correct or fill in a field, edit the page and give your evidence: the file, the offset, and what you saw. Please don't turn an INFERRED into a confirmed without new evidence.
