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
| `+0x08` | `u32` | experience | the metal family: 4,096, 40,200 and 120,040, against a median of 940. **EU only:** confirmed by a published guide — below |
| `+0x0C` | `u16` | gold | a median of 2,490 on the bosses against 120. **EU only:** confirmed by a published guide — below |
| `+0x14` | | not established | 500 to 605 on ordinary monsters and 0 on most bosses — Hexagoon's among them, though not the Wight Knight's or Morag's |
| `+0x18` | `u16` ×6 | its six ways of acting: action numbers (see [Actions](Actions)), INFERRED | 1 Attack on 1,064 of the 2,628 words and 225 Flee on 109; the healslime's Heal, the drakulard's Inferno, the uncommon cold's C-C-Cold Breath. The reference's own boss, Ragin' Contagion (`b006a`), has 1, 275, 1, 48, 44, 228 — the reference's six candidates exactly and in order: attack, poison attack, attack, Deceleratle, Kasap, Sweet Breath |
| `+0x10`, bits 5–7 | | **how it chooses among its six ways**: one of eight handlers, four of which draw by a weight table — see [Battle-Weight-Tables](Battle-Weight-Tables) | the game's own selector, `func_0208a91c` |
| `+0x10`, bits 20–25 | | a per-slot mask: which of the six ways may be used once a battle only | read at `0x0208a0a0` |
| `+0x24` | `u32` | **two statuses a blow of its can carry, and a chance for each**: bits 0–6 the first status, 7–13 its chance, 14–20 the second, 21–27 its chance | its one reader, `0x021eb124`, compares a requested status against each field and a draw below 100 against each chance; the chances in the file are 0, 25, 50, 75 and 100 |
| `+0x27`, bit 4 | | set on the bosses, and **read by no instruction in the ROM** | set on 149 records — 144 of the 159 boss-coded monsters and five grotto bosses — and clear on the bosses' minions and every ordinary monster. It is bit 28 of the word above, which that word's only reader never touches; searches by byte, by halfword, by word and through every function handed the record found nothing that tests it. **EU only:** the byte's other values are `0x09`, `0x0C` and `0x19`; its other bits are not read |
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

**A monster's HP is drawn**: it comes to a battle with `(int)(0.5 + HP × r)`, `r` a random float from 0.8 to 1.0, so this table's HP is the most it can have. Not so where the battle's setup says otherwise — INFERRED: a scripted battle. **USA only:** the draw is from the world's generator, not the battle's, and the code is the USA release's; a second reading of the flag, also INFERRED, is a grotto's or a legacy boss's battle. See [Battle resolution](Battle-Resolution).

"The reference" is DQIX/BattleEmulator (MIT, © 2024 DaisukeDaisuke), which reproduces the game's arithmetic.

**How a monster chooses among its six**: bits 5 to 7 of the word at `+0x10` pick one of eight handlers (`func_0208a91c`). Four of them draw a number from 1 to 256 against one of the four weight tables in the ARM9 — 96 monsters by the even table, 281 by the falling one, 2 by a steep one and 25 by a fourth. The other four ways are a round robin, a pair chosen by a counter with a coin inside it, and two passes over the slots; 34 monsters use those. `+0x27` bit 4 has nothing to do with it. See [Battle-Weight-Tables](Battle-Weight-Tables).

The field data's attack and defence equal the battle data's on all 438; see [Encounters](Encounters).

### Confirmed by a guide

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`). The drop table's addresses are the USA release's, from the decomp.

The *Dragon Quest IX* Signature Series guide (Prima) prints, for each monster in its bestiary, HP, MP, attack, defence, agility, experience, gold, and an ordinary and a rare drop with the chance of each. For the seven monsters around Angel Falls (printed page 255: slime, cruelcumber, teeny sanguini, sacksquatch, batterfly, dracky, bodkin archer) **every one of the seven numbers and both items agrees with the record** — 49 numbers and 14 items — the first item being the ordinary drop and the second the rare. The walkthrough's table of the area's monsters (page 59) gives the same HP, experience and gold.

The drop chances, against the guide:

| step | the guide's chance | where it was checked |
|---|---|---|
| 0 | 100% | King Godwyn, Barbarus, Corvus — each with one drop and 7 beside the empty second |
| 1 | 1/8 | slime, cruelcumber, restless armour, purrestidigitator |
| 2 | 1/16 | slime, batterfly, dracky, teeny sanguini, bodkin archer |
| 3 | 1/32 | sacksquatch |
| 4 | 1/64 | sacksquatch, batterfly, dracky, teeny sanguini, bodkin archer |
| 5 | 1/128 | cruelcumber, wight emperor (both) |
| 6 | 1/256 | restless armour, purrestidigitator |
| 7 | — | beside item 0 on every record but ten, all legacy and grotto bosses; not established on those ten |

Over all 438: step 0 on 31 first drops; 7 on 14 first and 128 second.

The game's own table says the same. The drop roll, `func_ov023_021f454c` in overlay 23, indexes the eight words at `0x021fd888`, `1 8 16 32 64 128 256 0`, by these bytes. It loads the table at `0x021f49ac` for the byte at `+0x03` and at `0x021f4a74` for the one at `+0x02` — which settles that **`+0x02` is the ordinary drop's chance and `+0x03` the rare's**, and that a step of 7 never drops. No other copy of the table is in the ROM.

### Names and grammar

A `mon_data_<lang>.nat` record:

| offset | type | meaning |
|---|---|---|
| `+0x00` | `u32` | the name's offset from the strings |
| `+0x04` | `u32` | the code's offset from the strings |
| `+0x08` | `u16` | the monster's number |
| `+0x0A` | 2 bytes | not established |
| `+0x0C` | `s16` | **EU only:** its body's collision **radius**, in 1024ths — below |
| `+0x0E` | `s16` | **EU only:** its body's collision **height**, `fx32` — below |
| `+0x10` | 4 bytes | not established |
| `+0x14` | `u32` | the plural's offset from the strings |
| `+0x18` | `u32` | the name's grammar: its articles and gender — see [Articles](Articles) |

The strings run name, plural, code for each monster — `slime`, `slimes`, `z000a` — and the plural's offset starts a string on all 438 records in all five languages.

**Codes repeat**: 438 records carry 312 codes, a code naming the story's versions of one monster (the scarlet fever four times); the lowest number is the ordinary one.

### The body — `+0x0C` and `+0x0E`

> **EU only.** Code addresses are the USA release's, from the decomp; the records were read on the European release and are not yet checked on the US one.

Read from the code rather than from the bytes. Overlay 17 builds a field monster's `Object3D` in `func_ov017_021a2128` and ends it with

```
ldrsh r1, [r5, #0xc] ; lsl r1, r1, #2 ; bl Object3D::SetRadius
ldrsh r1, [r5, #0xe] ;                 bl Object3D::SetHeight
```

`Object3D::SetRadius` and `SetHeight` are the decomp's names, at USA `0x020377c4` and `0x020377b4` (`0x10` higher on the European release). `r5` is an entry of the collection at `+0x2F8` of the resident map — a slot of four, `0x318` bytes each, found by map id (`func_02028bd0`) — and `0x021b5250` fills that collection from this file. So `+0x0C` is a radius in 1024ths, shifted left 2 into `fx32`, and `+0x0E` a height already in `fx32`. The decomp's `Object3D` constructor defaults both to `1 << 12`, so a monster that named neither would be a one-unit ball.

**The witness is that the numbers sort the bestiary.** The slime is 0.80 wide and 0.80 tall, a ball; the metal slime as wide and 0.60 tall; the bag o' laughs 0.78 and 0.84. The largest are Lleviathan, Barbarus and Greygnarl at 7.80 and 5.25, and the alphyn and the Nemean at 6.40 and 3.50 — ten times the slime for the great dragons, and none of the 438 negative. A wrong offset does not order a bestiary by size.

The battle uses the radius too: overlay 0 lines the monsters up in a row by their widths, each its radius × 4. See [Battle stages](Battle-Stages).

## Monster models — `/data/pack_lv5/enemy.gp2`

601 members, `<code>.mon` and `<code>_f.mon`, stored whole — see [GPC2](GPC2) on members with no region prefix. Each is a `NARC` (see [NitroFS](NitroFS)) of three files:

| file | contents |
|---|---|
| `.cchr` | an LZ10-compressed `NARC` (see [DS-Compression](DS-Compression)): the model (`<code>.nsbmd`), its first motions (`appear`, `attack0a`, `run`, `stand` on the slime) and a `.bcfg` |
| `.cmot` | another: the rest of its motions — `attack1a`, `call`, `damage`, `death`, `escape`, `sake` on the slime — and a `.bcfg` |
| `.bact` | **EU only:** the monster's attack as an action script, a data table whose tags are opcodes; see [Battle action scripts](Battle-Action-Scripts) |

The `_f` members have no `.cmot`. Every roaming monster has a field model, `<code>_f.mon`, beside its battle one, with its `appear`, `attack0a`, `run` and `stand` motions.

INFERRED: the models are in the characters' own space, as the cast's are — the slime stands 9 units and Hexagoon 35, to a person's 23.

`/data/effect/<family>000.chr` and its siblings, which a search by code finds first, are the monsters' attack effects — the slime's a splash textured `z000a_at1`, the chest monster's smoke, `z009a_kem01` — not their bodies.

## Evidence

- Head word: count and string size checked on all five languages of the monster list; strings run exactly to the end of the file.
- Monster numbers agree between `mon_btldata.nat` and `mon_data_<lang>.nat` on all 438 records.
- Drops: every `+0x04` word is an item id, and the chance bytes at `+0x02` agree with a published strategy guide at all 20 drops checked and at the three bosses whose drops it prints as certain.
- Six actions: Ragin' Contagion's record against the reference's candidates.
- Boss bit: 144 of 159 boss-coded monsters and the five grotto bosses.
- **EU only:** the seven numbers and both drops of seven monsters against a published guide's bestiary — 49 numbers and 14 items.
- **EU only:** the body's radius and height sort the 438 by size.

## Earlier readings

- In English the monster list's head word happens to read `YQT` (`0x01545159`: 345, and 5,445 × 4,096). It was first taken for a magic number; the other languages' do not read so. It is the count and the string size.
- The two weight tables were first searched for in the packed ARM9 bytes and missed; they are in the unpacked binary.
- **EU only:** experience at `+0x08` and gold at `+0x0C` were INFERRED from their values until a published guide confirmed them, 22 September 2026.
- **EU only:** the names record's `+0x0A` to `+0x13` were all carried as not established; `+0x0C` and `+0x0E` are now read from the code.

## Not established

- Monster list `+0x0E` and `+0x10`–`+0x1F`.
- What the code letters `z` and `b` divide.
- Battle data `+0x14`, and every field not in the table above.
- Names record `+0x0A`, `+0x10` and `+0x12`.
- **EU only:** the drop step 7 on the ten legacy and grotto bosses whose drop beside it is not item 0.

## See also

- [Battle-Weight-Tables](Battle-Weight-Tables)
- [Actions](Actions)
- [Articles](Articles)
- [Encounters](Encounters)
- [Event-Battles](Event-Battles)
- [Treasure](Treasure)
- [System-Strings](System-Strings)
- [Battle-Action-Scripts](Battle-Action-Scripts) — the `.bact` in each model archive
- [Battle-Stages](Battle-Stages) — where the radius places a monster
- [Battle-Resolution](Battle-Resolution) — drops, HP and resistances in the battle
- [GPC2](GPC2) · [NSBMD](NSBMD)
