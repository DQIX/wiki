# Character Parts (`/data/pack_lv5/chara_pc.gp2`, `chara_pd.gp2`)

The worn parts of the playable characters are models ([NSBMD](NSBMD)) and texture files (NSBTX). They are packed in two [GPC2](GPC2) archives. `chara_pc.gp2` is the wardrobe on the 14-bone rig that walks. `chara_pd.gp2` is the same wardrobe on a 21-bone rig. A part is named by its item's id, using the same rule as item icons. The naming rule, the texture binding and the rigs' bones are confirmed. Where weapons and shields attach, how hair variants pair with headgear, and some item-to-part mappings are not established.

All counts on this page are from the European release (game code YDQP).

## Naming

**A worn part is named by its item's id, as the item's icon is** (see [Item-Icons](Item-Icons)). The thousands choose a letter, and the rest become a three-digit number. For example, the celestial suit is item 13007, so its part is `p_b007`.

| id | worn | letter | in `chara_pc` | in `chara_pd` |
|---|---|---|---|---|
| 12xxx | headgear | `m` | 142 models, each with a bone of its own | 142 models |
| 13xxx | armour | `b` | 192 models on the 14-bone rig | 192, on a 21-bone rig |
| 14xxx | a body's bare arms (no item) | `a` | 192 texture files | 192 models |
| 15xxx | gloves | `g` | 63 texture files | 63 models |
| 16xxx | legwear | `p` | 79 models on the rig | 79 |
| 17xxx | footwear | `r` | 89 texture files | 89 models |
| 20xxx | weapons | `w` | 200 models, each with a bone of its own | 178 |
| 21xxx | shields | `s` | 35 models, each with a bone of its own | 35 |
| — | faces | `f` | 24 models, each with a bone of its own | 24 |
| — | hair | `h` | 121 models, each with a bone of its own; 207 texture files | 122; 207 |

**Evidence for the rule:**

- **The letters match the icons' letters** in every category that has both.
- **The counts agree.** 35 shields have icons, and there are 35 `p_s` files. 87 footwear items have icons, and there are 89 `p_r` files.
- **Every `d_` number is a `p_` number.** For weapons, 175 of `d_w`'s 178.
- **The presets wear parts by the rule** (see [Character-Presets](Character-Presets)). Of the 155 ids worn in the vocations' presets, 141 name a part that exists.

The other 14 preset ids name no part. Most are legwear:

- 16190, worn by five women. It is also not an item id.
- 16101, 16102, 16110, 16112 and 16201.

So something maps some items to another item's part. That mapping has not been found.

**Earlier reading:** the `p_s` files were taken to be shoes, until the counts were compared with the icons.

## Textures: arms, gloves, footwear and hair colour

**Arms, gloves, footwear and hair colours are textures, and all files of one kind use the same texture name.**

- A `p_a`, `p_g` or `p_r` file is an NSBTX holding one 8×16 texture and its palette.
- The texture is named `p_a000_00` in 191 of the 192 arms files, and in all 63 gloves files.
- It is named `p_r000_00` in all 89 footwear files.

**Every body model has a material bound to `p_a000_00`.** 188 of the 192 bodies name that material after their own number; for example, `p_b002`'s material is `p_a002_00`. Every body has an arms file with its own number.

**Every legs model has a material bound to `p_r000_00`.**

So the file that is loaded decides the arms and the footwear. Watch out: if textures are resolved by name, taking the first match, every character wears the first file found.

**Hair works the same way.** Each of the 207 `p_h<ss><c>a.nsbtx` files holds one texture, `p_h<ss>0a_00`, which the style's models bind.

- Styles 00 to 19 have ten such files each, `c` 0 to 9. Styles 20 to 23 have one or two. `c` is a colour, **INFERRED**.
- A hair model is `p_h<ss>0<v>.nsbmd`. There are 24 styles, each in variants `a` to `e`; style 01 also has `f`.
- The variants differ in height. Style 00's `a` reaches 7.41 above its origin, and its `e` reaches 4.04. This reads as hair cut to fit under headgear, **INFERRED**.

## Where parts hang

### Weapons and shields

**Weapons and shields hang from the rig, and where they hang is only partly read.** Each is one bone of its own, named for the part, and is modelled around its origin:

- The copper sword, `p_w004`, runs along +z from −1.30 to 12.80, with its guard across x.
- The pot lid, `p_s296`, is a disc spanning x −2.22 to 3.60, y 0.26 to 1.48, and z ±2.91.

The rig's forearm bones, `arm1L` and `arm1R`, start at the elbows: (±5.81, 13.49, −0.50) in the bind pose. The arms reach ±9.23. So **a shield is modelled in the left forearm's space**, lying along the forearm from elbow to wrist on its outer side. This is **INFERRED** from those extents.

Besides its limbs, trunk and head, the rig has one more bone, **`usiro`**, at (0, 13.00, −2.00). That is behind the shoulders, and *usiro* is Japanese for "behind". It is where things carried on the back hang. This is **INFERRED** from the name and from a let's play video. In that video, outside battle, the Hero carries a shield on his back and a fan at his side. In battle he holds the sword in his hand.

How the game turns a part to hang on the back, and exactly where a weapon sits in the hand, is in its code, which has not been read.

`chara_pc`'s rig has no hand bone.

Ivor's rig, `s017`, has the same limbs and no `usiro`.

### Faces, hair and headgear

**Faces, hair and headgear hang from the head (INFERRED).** Each carries one bone of its own, and all three are modelled around their origin in the same space:

| part | example | y extent |
|---|---|---|
| headgear | `p_m200` | 1.82 to 7.93 |
| hair | `p_h000a` | −0.73 to 7.41 |
| face | `p_f006` | −0.32 to 4.00 |

Faces and hair have been shown to land on the neck when placed through the rig's `head` bone.

## `chara_pd`: the same wardrobe on another rig

`chara_pd.gp2` holds the same parts on a rig of 21 bones:

| bones |
|---|
| `root`, the part's own bone |
| `waist`, `chest` |
| `arm1L` to `arm3L`, `weaponL` |
| `arm1R` to `arm3R`, `weaponR` |
| `head`, `manto1` |
| `leg1L` to `leg3L`, `leg1R` to `leg3R` |
| `skirt` |

Its only motions are one standing loop per pack, across 28 packs: `md0200m` and `md0200w` through `md0213m` and `md0213w`, with no `0202`. There are also `md0200m_start` and `md0200w_start`, of 51 frames each.

Every motion in `chara_mp.gp2` drives 14 bones, including the walk. So do the Hero's own event poses (`ev7700p000.chr`: `ne_lp`, `oki`). So the figure that walks is `chara_pc`'s. That `chara_pd`'s figure is the equipment screen's is **INFERRED** from its standing-only motions.

Beside the parts, `chara_pd` also holds:

- wings, `d_hane`, on 8 bones of their own, with `d_hane_m` and `d_hane_w` motions of 51 frames
- `d_wa`, a ring whose node is named `d_m805`: the part for the halo, item 12805
- `d_wing`
- a coffin, `d_kanoke`

## Not established

- The four bodies whose arms material is named otherwise: `p_b003`, `p_b016`, `p_b490`, `p_b505`.
- The one arms file whose texture is named for itself.
- Where weapons and shields attach, and how the game places a part on the back or in the hand.
- Which hair variant goes with which headgear.
- The items worn that have no part of their own, and what maps them to another item's part.

## See also

- [Item-Icons](Item-Icons): the same naming rule
- [Character-Presets](Character-Presets)
- [Motion-Tables](Motion-Tables)
- [Items](Items)
- [NSBMD](NSBMD)
- [GPC2](GPC2)
- [Menu-Backgrounds](Menu-Backgrounds): the equipment screen
