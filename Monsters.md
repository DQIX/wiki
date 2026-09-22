# Monsters

Four sets of files describe the monsters: the monster list (`/data/prm/mon_list.gp2/mon_list_<lang>.nat`), the battle data (`/data/prm/mon_btldata.nat`), the name and grammar records (`/data/prm/mon_data.gp2/mon_data_<lang>.nat`) and the models (`/data/pack_lv5/enemy.gp2`). The head words, the record sizes, monster numbers, codes, name and plural offsets, the drops and their chances, experience, gold, HP, MP, attack, defence, agility and how a monster chooses among its six ways are confirmed — the last of them from the game's own code. The boss bit is read by nothing; several fields in each record are not established.

All observations were made on the European release (game code `YDQP`). Where the ARM9 binary is mentioned, it is the *unpacked* binary of that release.

## The shared head word

The monster list, the battle data, the name records, the [system strings](System-Strings) and the [action tables](Actions) all open with the same head word:

| bits | meaning |
|---|---|
| 0–11 | the record count |
| 12–31 | the size of the string section, in bytes |

In the monster list its low 12 bits are 345 on all five languages, and its upper 20 the size of the string section — 5,445 bytes in English, 5,785 in German, 5,788 in French. On all five the strings start at `4 + 345 × 32` = 11,044 and run exactly to the end of the file.

## The monster list — `mon_list_<lang>.nat`

`/data/prm/mon_list.gp2/mon_list_<lang>.nat`: the head word, then 345 records of 32 bytes, then the strings. It holds a code and a name for each monster, the codes first from `0x2b24` in English: `z000a` slime, `z000b` she-slime…

| offset | type | meaning |
|---|---|---|
| `+0x00` | `u32` | 0 on every record |
| `+0x04` | `u32` | the code's offset from the strings: `z000a` … |
| `+0x08` | `u32` | the name's offset from the strings |
| `+0x0C` | `u16` | the monster's number |
| `+0x0E` | `u16` | not established — 364, 356, 246 … on the first |
| `+0x10` | 16 bytes | not established |

Every offset lands at the start of a string on all five languages. Several records share a name — records 250 and 251 are both named at offset 6, the first monster's — so the offsets do not climb record by record.

The numbers run 1 to 64 and then 75 on, with gaps. Every code is a letter, three digits and a letter: 278 open `z`, numbered 1 to 298, and 67 open `b`, numbered 284 to 514. What the two letters divide is not established.

**The record numbered 38 is `z009a`, 39 `z009b` and 40 `z009c`** — cannibox, mimic and Pandora's box. These are the values of the monster rows in the chest tables; see [Treasure](Treasure).

## Monster data — `mon_btldata.nat` and `mon_data_<lang>.nat`

Two files of 438 records each, one a monster, both opening with the shared head word:

- `/data/prm/mon_btldata.nat`: 132-byte records and no strings;
- `/data/prm/mon_data.gp2/mon_data_<lang>.nat`: 28-byte records and then the strings.

**Each record's monster number agrees between the two on all 438**, so they are read side by side.

### Battle data

| offset | type | reading | evidence |
|---|---|---|---|
| `+0x00` | `u16` | the monster's number, bit 15 set on all 438 | agrees with the names file |
| `+0x02` | `u8` ×2 | **each drop's chance**, a step: the ordinary drop's, then the rare's. 0 always, 1 to 6 one in `2^(step+2)`, 7 never — the table at `0x021fd888`; see [Battle resolution](Battle-Resolution) | the game's own table, and it agrees with the chances a published strategy guide prints for 20 drops |
| `+0x04` | `u16` ×2 | its two drops, the ordinary and the rare | every one is an item id |
| `+0x08` | `u32` | experience, INFERRED | the metal family: 4,096, 40,200 and 120,040, against a median of 940 |
| `+0x0C` | `u16` | gold, INFERRED | a median of 2,490 on the bosses against 120 |
| `+0x14` | | not established | 500 to 605 on ordinary monsters and 0 on most bosses — Hexagoon's among them, though not the Wight Knight's or Morag's |
| `+0x18` | `u16` ×6 | its six ways of acting: action numbers (see [Actions](Actions)), INFERRED | 1 Attack on 1,064 of the 2,628 words and 225 Flee on 109; the healslime's Heal, the drakulard's Inferno, the uncommon cold's C-C-Cold Breath. The reference's own boss, Ragin' Contagion (`b006a`), has 1, 275, 1, 48, 44, 228 — the reference's six candidates exactly and in order: attack, poison attack, attack, Deceleratle, Kasap, Sweet Breath |
| `+0x10`, bits 5–7 | | **how it chooses among its six ways**: one of eight handlers, four of which draw by a weight table — see [Battle-Weight-Tables](Battle-Weight-Tables) | the game's own selector, `func_0208a91c` |
| `+0x10`, bits 20–25 | | a per-slot mask: which of the six ways may be used once a battle only | read at `0x0208a0a0` |
| `+0x24` | `u32` | **two statuses a blow of its can carry, and a chance for each**: bits 0–6 the first status, 7–13 its chance, 14–20 the second, 21–27 its chance | its one reader, `0x021eb124`, compares a requested status against each field and a draw below 100 against each chance; the chances in the file are 0, 25, 50, 75 and 100 |
| `+0x27`, bit 4 | | set on the bosses, and **read by no instruction in the ROM** | set on 149 records — 144 of the 159 boss-coded monsters and five grotto bosses — and clear on the bosses' minions and every ordinary monster. It is bit 28 of the word above, which that word's only reader never touches; searches by byte, by halfword, by word and through every function handed the record found nothing that tests it |
| `+0x5C` | `u16` | maximum HP — **read by the game's code**, below | a median of 6,500 on the bosses against 134; the metal slime's 4 |
| `+0x5E` | `u16` | maximum MP — likewise | 255 on most bosses and the metal family |
| `+0x60` | `u16` | attack — likewise | by order |
| `+0x62` | `u16` | defence — likewise | the metal family's 256 and 512 |
| `+0x64` | `u16` | agility — likewise | by order; high on the metal family |
| `+0x68` | `u32` | three 10-bit numbers the code copies into the battle status; not established | |
| `+0x6C` | `u8` ×22 | **resistances**: what it takes of each of 21 elements, in hundredths, by `element − 1` — below | firespirit 50 of fire and 150 of ice; slime 125 of all seven; metal slime 0 of every status |
| `+0x82` | `u8` ×2 | copied beside them; not established | 0 on every monster looked at |

The rest of the record is not established. Hexagoon is `b003a`.

**The five numbers and the resistances are read from the game's code.** The battle builds a monster's status from this record **at `+0x2C`** (`func_02089630`, called from overlay 0 at USA `0x0215eed0`): HP from that block's `+0x30`, MP `+0x32`, three `u16`s to `+0x38`, a packed word at `+0x3C`, and 24 bytes copied from its `+0x40` — which are this record's `+0x5C` to `+0x64`, `+0x68` and `+0x6C`.

**Resistances.** A byte an element, a hundredth each: 100 is whole, 0 immune, 125 a quarter more. Fifteen values are in use — 0, 1, 5, 10, 15, 25, 30, 35, 50, 60, 75, 100, 125, 150, 200. Damage is multiplied by the byte for the action's element; a change of state's accuracy likewise; and what rides on a blow lands under its chance times it. **Element 8, the plain Attack's, is 100 on all 438.** A metal slime takes all of every element — it is the actions that do not work on a metal body — and nothing of sleep, poison or a fall in defence. The elements are listed on [Battle resolution](Battle-Resolution).

**A monster's HP is drawn**: it comes to a battle with `(int)(0.5 + HP × r)`, `r` a random float from 0.8 to 1.0, so this table's HP is the most it can have. Not so where the battle's setup says otherwise — INFERRED: a scripted battle.

"The reference" is DQIX/BattleEmulator (MIT, © 2024 DaisukeDaisuke), which reproduces the game's arithmetic.

**How a monster chooses among its six**: bits 5 to 7 of the word at `+0x10` pick one of eight handlers (`func_0208a91c`). Four of them draw a number from 1 to 256 against one of the four weight tables in the ARM9 — 96 monsters by the even table, 281 by the falling one, 2 by a steep one and 25 by a fourth. The other four ways are a round robin, a pair chosen by a counter with a coin inside it, and two passes over the slots; 34 monsters use those. `+0x27` bit 4 has nothing to do with it. See [Battle-Weight-Tables](Battle-Weight-Tables).

The field data's attack and defence equal the battle data's on all 438; see [Encounters](Encounters).

### Names and grammar

A `mon_data_<lang>.nat` record:

| offset | type | meaning |
|---|---|---|
| `+0x00` | `u32` | the name's offset from the strings |
| `+0x04` | `u32` | the code's offset from the strings |
| `+0x08` | `u16` | the monster's number |
| `+0x0A` | 10 bytes | not established |
| `+0x14` | `u32` | the plural's offset from the strings |
| `+0x18` | `u32` | the name's grammar: its articles and gender — see [Articles](Articles) |

The strings run name, plural, code for each monster — `slime`, `slimes`, `z000a` — and the plural's offset starts a string on all 438 records in all five languages.

**Codes repeat**: 438 records carry 312 codes, a code naming the story's versions of one monster (the scarlet fever four times); the lowest number is the ordinary one.

## Monster models — `/data/pack_lv5/enemy.gp2`

601 members, `<code>.mon` and `<code>_f.mon`, stored whole — see [GPC2](GPC2) on members with no region prefix. Each is a `NARC` (see [NitroFS](NitroFS)) of three files:

| file | contents |
|---|---|
| `.cchr` | an LZ10-compressed `NARC` (see [DS-Compression](DS-Compression)): the model (`<code>.nsbmd`), its first motions (`appear`, `attack0a`, `run`, `stand` on the slime) and a `.bcfg` |
| `.cmot` | another: the rest of its motions — `attack1a`, `call`, `damage`, `death`, `escape`, `sake` on the slime — and a `.bcfg` |
| `.bact` | no Nitro signature in it: not read |

The `_f` members have no `.cmot`. Every roaming monster has a field model, `<code>_f.mon`, beside its battle one, with its `appear`, `attack0a`, `run` and `stand` motions.

INFERRED: the models are in the characters' own space, as the cast's are — the slime stands 9 units and Hexagoon 35, to a person's 23.

`/data/effect/<family>000.chr` and its siblings, which a search by code finds first, are the monsters' attack effects — the slime's a splash textured `z000a_at1`, the chest monster's smoke, `z009a_kem01` — not their bodies.

## Evidence

- Head word: count and string size checked on all five languages of the monster list; strings run exactly to the end of the file.
- Monster numbers agree between `mon_btldata.nat` and `mon_data_<lang>.nat` on all 438 records.
- Drops: every `+0x04` word is an item id, and the chance bytes at `+0x02` agree with a published strategy guide at all 20 drops checked and at the three bosses whose drops it prints as certain.
- Six actions: Ragin' Contagion's record against the reference's candidates.
- Boss bit: 144 of 159 boss-coded monsters and the five grotto bosses.

## Earlier readings

- In English the monster list's head word happens to read `YQT` (`0x01545159`: 345, and 5,445 × 4,096). It was first taken for a magic number; the other languages' do not read so. It is the count and the string size.
- The two weight tables were first searched for in the packed ARM9 bytes and missed; they are in the unpacked binary.

## Not established

- Monster list `+0x0E` and `+0x10`–`+0x1F`.
- What the code letters `z` and `b` divide.
- Battle data `+0x14`, and every field not in the table above.
- Names record `+0x0A`–`+0x13`.
- The `.bact` file in each model archive.

## See also

- [Battle-Weight-Tables](Battle-Weight-Tables)
- [Actions](Actions)
- [Articles](Articles)
- [Encounters](Encounters)
- [Event-Battles](Event-Battles)
- [Treasure](Treasure)
- [System-Strings](System-Strings)
- [GPC2](GPC2) · [NSBMD](NSBMD)
