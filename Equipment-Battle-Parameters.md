# Equipment battle parameters — `itembtlprm.nat`

What a worn thing does in a battle, and where a **party member's resistances** come from. `/data/prm/itembtlprm.nat` is a loose file: a count word and then one record per item, in order of the item's id. The record size, the count, the id field and the resistance bytes are confirmed; the rest of the record is not established. Observations are from the European release (game code `YDQP`); the code addresses are the USA release's.

## Layout

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 4 | `u32` | the record count in its **low 20 bits** — 1,423. `func_0209a088` masks it so |
| `+0x04` | 44 × count | records | see below |

`4 + 1423 × 44` is 62,616 bytes, the file's whole size.

## A record — 44 bytes

| offset | size | type | meaning |
|---|---|---|---|
| `+0x00` | 4 | `u32` | flags, tested a bit at a time by a run of accessors (`func_020852a4` … `func_020855d0`); not established |
| `+0x08` | 12 | twelve 6-bit fields | **a weapon's killer bonus by monster family**, in tenths, signed — 10 is none; see below |
| `+0x14` | 20 | `i8` ×20 | **what it adds to a resistance**, one an element — see below |
| `+0x28` | 2 | `i16` | the item's id, as [Items](Items) gives it |
| `+0x2A` | 2 | | 0 on every record |

The records are sorted by the id at `+0x28` — strictly ascending from 994 to 22,290 — and the game finds one by binary search (`func_0209a004`, stride 44, key `+0x28`).

## A weapon's killer bonuses and element

Read 6 October 2026 from the party's damage forecast in the battle AI (overlay 24, `func_ov024_021fa7ec`, `0x021faa20`–`0x021fac98`). For each monster family *n* from 1 to 12, it asks whether the target is a monster of that family (`func_ov000_02156068(battle, target, n, 0)`: the monster's `mon_data +0x0A` bits 7–10 equal *n*) and, if so, multiplies by a six-bit signed field of the **weapon's** copied record over `10.0f` — 1.0 with no weapon. The twelve accessors and their fields:

| family | accessor | word | bits |
|---|---|---|---|
| 1 | `func_02085968` | `+0x0C` | 6–11 |
| 2 | `func_02085818` | `+0x08` | 0–5 |
| 3 | `func_02085a10` | `+0x0C` | 24–29 |
| 4 | `func_02085a48` | `+0x10` | 0–5 |
| 5 | `func_020859d8` | `+0x0C` | 18–23 |
| 6 | `func_020859a0` | `+0x0C` | 12–17 |
| 7 | `func_02085930` | `+0x0C` | 0–5 |
| 8 | `func_02085850` | `+0x08` | 6–11 |
| 9 | `func_020858f8` | `+0x08` | 24–29 |
| 10 | `func_02085a80` | `+0x10` | 6–11 |
| 11 | `func_020858c0` | `+0x08` | 18–23 |
| 12 | `func_02085888` | `+0x08` | 12–17 |

On the European cartridge 928 records hold 10 in all twelve, 245 hold nothing (the records seen empty here before), and 250 hold 11 or 12 for one or two families.

**The weapon's element** is the flags' bits 23–25 (`func_02085748`). The AI turns it into an element by pairs at ov024 `0x021fefb0` — 1 to 7 stand for themselves, 0 for 8, the plain Attack's — and asks the target's resistance to it. 23 records carry 1 to 5. That this is the weapon's element is inferred from that one use.

## The twenty resistance bytes

In order, the twenty bytes at `+0x14` belong to elements

```
1 2 3 4 5 6 7 9 10 11 12 13 14 15 16 17 18 19 20 21
```

— **8 and 22 are not among them**. The game's loop writes the eighth byte to the ninth element's place and never touches the twenty-second, so the plain Attack's element, which every monster takes whole, cannot be resisted by anything worn. See [Battle resolution](Battle-Resolution) for what the elements are.

**Only 183 of the 1,423 records carry any number at all**, and the values are whole multiples of five, mostly negative: −20, −25, −30, −35.

## How the game uses it

1. **Overlay 17, `func_ov017_021b3780`** walks the eight equipment places the character keeps battle numbers for — the slot order is a byte table at `0x021d6b20`, and slots 2, 3 and 4 are excluded — looks each worn item's id up in this file, and **memcpy's the whole 44-byte record** into the character at `char + 0x2F4 + entry × 0x2C`. An empty place leaves its entry zeroed with the id `−1`. A dirty check (`func_ov017_021b3678`) compares each place's item against the entry already there and queues the file's load when they differ.
2. **`func_02083e28`** recomputes the character's stats. For each of the eight entries whose `+0x28` is above 0 it adds the twenty signed bytes to a baseline of **100 each** (`char + 0x934`), holds the sum at **nothing below**, and writes 22 bytes to `char + 0x21`.
3. Building a combatant copies those 22 bytes into the battle status at `+0x3E` (`func_02082d38` [`CopyResistances`]), which is where `GetResistance` reads them.

So a party member's resistances are **the sum of what they wear, onto a hundred** — not a table of their own, and nothing else writes them: no vocation, no skill, no spell. A monster's come from its own record instead; see [Monsters](Monsters).

## What is not in this file

> **EU only.** The counts were taken on the European release (`YDQP`) and are not yet checked on the US release (`YDQE`); the code addresses are the USA release's, from the decomp.

**A shield's chance of blocking** is not here. `func_02084ee8` sums ten bits of each worn piece's record in the item tables — the low ten of the equipment table's word 6, set on 42 of the 45 shields and on nothing else — over `10.0f`. See [Items](Items) and [Battle resolution](Battle-Resolution).

**An item's defence, its rarity and who may use it** were not found in this file, at any position, width or scale tested against 41 shields' published defence and rarity. Where those published values came from was not recorded, which weakens the test. A weapon's attack and a piece's defence are read, INFERRED, from the item tables' stats; see [Items](Items).

## Evidence

- Read from the USA binaries on 22 September 2026: the filename string is at `0x021d7ab6`, and `func_ov017_021b3780` is the only code that fills `char + 0x2F4`.
- The layout checks out against the European file: the count is 1,423, the size is exactly `4 + 1423 × 44`, and the id at `+0x28` is strictly ascending across every record.

## Not established

- The flags word at `+0x00`, apart from bit 16 (the experience bonus) and bits 23–25 (the weapon's element); bits 4 and 10 are asked about a metal body by the AI and not read.
- Which of the eleven equipment places each of the eight entries stands for, beyond the byte table at `0x021d6b20`.

## See also

- [Items](Items) — the item tables, prices and stats
- [Battle resolution](Battle-Resolution) — `GetResistance`, and what the elements are
- [Monsters](Monsters) — a monster's own resistances
