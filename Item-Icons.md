# Item Icons

Item icons are 1,021 loose [sprites](Sprites) in `/data/ani`, named `d_<letter><nnn>.spr`, each one 24×24 frame. **An item's icon is named by its id in decimal**: the thousands choose a letter, the remaining three digits the number. The naming rule is confirmed for 985 of the 1,178 items; the icon of the other 193 is not established. Observations are from the European release (game code `YDQP`).

## Naming rule

The copper sword, id 20004 (`0x4E24`), is `d_w004.spr`.

| id | items | letter | items with an icon by the rule |
|---|---|---|---|
| 12xxx | helms | `m` | 108 of 132 |
| 13xxx | armour | `b` | 157 of 183 |
| 15xxx | gloves | `g` | 62 of 78 |
| 16xxx | legwear | `p` | 77 of 85 |
| 17xxx | footwear | `r` | 87 of 101 |
| 18xxx | accessories | `c` | 52 of 52 |
| 19xxx | knives | `w` | 27 of 40 |
| 20xxx | weapons | `w` | 148 of 228 |
| 21xxx | shields | `s` | 35 of 45 |
| 22xxx | tools | `i` | 232 of 234 |

985 of the 1,178 items have an icon by the rule.

The worn parts in `/data/pack_lv5/chara_pc.gp2` take the same letters and numbers — see [Character-Parts](Character-Parts).

## Evidence

- The copper sword's icon, `d_w004.spr`, was found by browsing the files, and the rule followed from it.
- The letters were found by which letter each thousand's remainders land on, then checked by eye: one item of each thousand drawn with its icon is the thing it is named — a gold helm, red armour, a glove, purple shorts, boots, a ring, a knife, the copper sword, a shield, a herb.
- The gloves' remainders land on `i` a little more often than on `g`, 68 to 62, because the tools' icons share the numbers. Drawn under `i`, a glove is a medicinal herb; under `g`, a glove.

## Not established

- The icon of the 193 items the rule gives none — the wonder helm, the tracksuit top and others.
- Whether the item record names the icon among its undecoded bytes (see [Items](Items)).

## See also

- [Sprites](Sprites)
- [Items](Items)
- [Item-Kinds](Item-Kinds)
- [Character-Parts](Character-Parts)
