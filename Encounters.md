# Encounters

Three loose [tagged data tables](Tagged-Data-Table) describe the monsters met in the field. `/data/prm/encfld.bin` lists each map's zones and the monsters that roam them; `/data/prm/encbtl.bin`, of the same zones, lists the same zones' roamers again with the monsters that may join a battle there; and `fld_mondata.bin` holds each monster's field numbers. The map ids, zone membership and monster numbers are read; weights, join counts, zone kinds, levels and run-away margins are INFERRED; how a map chooses among its zones is not established.

All observations were made on the European release (game code `YDQP`).

## `encfld.bin` — by map

A `0x69` record opens a map, and **its first value is the map's own id** — the first value of the map's entry in `maplist9.bin` (see [Map-List](Map-List)): 20001 is `F01`, Angel Falls Region; 7102 to 7104 are the Hexagon's floors. All 210 groups name a map, and the village has none. The `0x69` record's other four values are 0 on all 210.

The zones follow:

| tag | meaning |
|---|---|
| `0x69` | opens a map; value 0 is the map's id |
| `0x68` | names a zone |
| `0x66` | one word for the zone — see [The zone word](#the-zone-word) |
| `0x67` | a monster that roams the zone |

A `0x67` record's first value holds the monster's number in the low 12 bits, and above them, INFERRED, its weight among the zone's (slime 7, teeny sanguini 6, cruelcumber 5, sacksquatch 3 in `F01`'s first zone). Its second value is 1 on most and not established; on some it is a float — 0.85 and 0.9 in `F06`.

## `encbtl.bin` — by zone

A `0x68` record per zone — 290 of them — then:

- `0x66` records: **the zone's roamers again, the same monsters as `encfld`'s on all 287 zones it has**;
- `0x67` records: monsters that may join a battle there, most of them not among the roamers (zone 12's company includes a batterfly).

The records' second values are 0 on every company record.

### A companion's word

Three 3-bit fields sit above the monster's number (bits 0–11) — a weight among the zone's company, then the least and the most of it that join, INFERRED:

| bits (of the word) | reading | seen |
|---|---|---|
| 12–14 | weight | 0 to 7; 0 on ten, which then never join |
| 15–17 | least | 1 on 1,501, 2 on 20, 3 on 6 |
| 18–20 | most | 1 to 5 |
| 21 up | — | 0 on all 1,527 |

The least is no more than the most **on all 1,527**, as a count's range must be. The weights are the company's own: they agree with `encfld`'s weight for the same monster in the same zone on 272 of 829. `F01`'s first zone's company is the slime and the cruelcumber at 5, the teeny sanguini and the sacksquatch at 3, and the batterfly at 1, one of each.

### A roamer's word

A roamer's bits hold the same three fields and more above them. There the second is no more than the third on only 1,027 of 1,058, and the 31 that break it carry large values above. What these say about the roamer walked into — how many of it there are, how big the battle is — is not established.

## The zone word

A zone's `0x66` word, in part. Its low three bits are 0, 1 or 2 on all 287 — INFERRED a kind:

| kind | where | measure |
|---|---|---|
| 0, then 1 | a pair, always in that order, and **only on fields** (`Fxx`) | the same monsters on other weights on **37 of 40** pairs — `F01`'s 12 and 14 are the slime, teeny sanguini, cruelcumber and sacksquatch, 7-6-5-3 and 4-4-4-5 |
| 2 | the only zone of 170 maps — every dungeon's, the Hexagon's floors among them — and a field's third and fourth | `F01`'s 15 is the bodkin archer, the batterfly and the cruelcumber |

The kinds in a map's order: `2` ×170, `012` ×17, `01` ×11, `0122` ×8, `22` ×2, `0101` and `2222` once each.

| bits | reading |
|---|---|
| 0–2 | kind, INFERRED (above) |
| 3–7 | not established: rises with the order the game reaches its places — 2 and 3 in Angel Falls Region, 5 to 7 in Stornway's, past 30 late on; a pair's kind 1 is its kind 0 plus one on 28 of the 40 |
| 21–23 | not established: takes every three-bit value, dungeons' lone zones included, so they are no time of day to choose by |
| 24–31 | 0 on all |

What bits 3 to 7 count is not established, and the monsters' battle data has no level to test it against.

## How a map chooses among its zones

**Not established.** Tried, and ruled out:

- **The collision triangles' attribute word** (see [Map-Collision](Map-Collision)). Bits 25 up, read as an index into the map's zones, match the zone count on only 41 of 109 field and dungeon maps, and on 61 run past the last zone. The rest is no better: the low 24 bits are six nibbles, each only ever from one of {0, 3, 6}, {1, 4, 7} and {2, 5, 8} — per-edge data, by the look of it — on `F01`, `F02`, `F06`, `F17`, `F18` and `D01M02` alike.
- **Night pieces, for kind 1 as the night.** Fields have none: 36 of the 37 maps with a pair build the same by night, so the test cannot decide it.
- **The `0x69` record's other four values**: 0 on all 210.
- **The map's own tables** (see [Map-Archive](Map-Archive)). Nothing in `F01`'s `.bmbl`, `.dat` or `.bmdj` names 12, 14 or 15 as a zone. Its three `0x72` records — doorways, see [Doors](Doors) — match its three zones by chance: the counts agree on 36 maps and differ on 118.

## Field monsters — `fld_mondata.bin`

A loose tagged data table: a `0x64` record holding 438, and a `0x65` record of seven values for each monster.

| value | reading |
|---|---|
| 0 | the monster's number |
| 1 | the monster's level, INFERRED: excluding the 149 bosses (value 2 is 0 on all of them and no other), its rank agrees with maximum HP's at 0.84 and experience's at 0.88 over 280 monsters — slime 1, dracky 3, spirit 5, skeleton 12 |
| 2 | the margin by which the party's level must pass value 1 before the monster runs, INFERRED: −99 on the metal family (whose value 1 is −99: they run at once), 99 on 185 (never), 5 to 22 on most of the rest; 1 and 5 on the slime, 7 and 12 on the she-slime |
| 3 | a packed word, not established |
| 4 | a float, INFERRED a speed: 0.40 on the slimes, 0.70 the drackies, 0.80 the firespirit, 0.90 the funghouls, 1.20 the meowgician |
| 5, 6 | attack and defence — **equal to the battle data's on all 438** |

Every roaming monster has a field model beside its battle one, `<code>_f.mon` in `enemy.gp2`, with its `appear`, `attack0a`, `run` and `stand` motions; see [Monsters](Monsters).

## Evidence

- Map ids: all 210 `encfld` groups name a map in `maplist9.bin`.
- Roamers: `encbtl`'s `0x66` records match `encfld`'s monsters on all 287 zones.
- Companion ranges: least ≤ most on all 1,527 records; weights agree with `encfld` on 272 of 829.
- Zone kinds: 37 of 40 field pairs share their monsters.
- Field monsters: attack and defence equal the battle data's on all 438.

## Earlier readings

An earlier reading took the zone numbers for places in the map list, and put late-game monsters in the village's houses. It is the `0x69` value that names the map.

## How a fight opens

Walking into a roaming monster does not always open an even fight. As the two meet, the encounter check (`func_ov017_02196430`) measures each one's facing against the bearing to the other and calls it a turned back past 49.48°, then rolls for a surprise round: `func_ov017_021970a0`. Face to face the party surprises the monsters on `2 + deftness ÷ 20` in a hundred and is surprised on 2; walk into a monster whose back is turned and the party's chance is `12 + deftness ÷ 20` and it cannot be surprised; let one reach the party from behind and the monsters take the round on 12. The answer travels to `[battle + 0xe49]`, and a scripted battle carries its own value instead. See [Battle resolution](Battle-Resolution).

## Not established

- How a map chooses among its zones.
- `encfld` `0x67` second value (1 on most; a float on some).
- What a roamer's upper bits say; the 31 roamer words whose fields break the least ≤ most rule.
- Zone word bits 3–7 and 21–23.
- `fld_mondata` value 3.

## See also

- [Monsters](Monsters)
- [Event-Battles](Event-Battles)
- [Map-List](Map-List)
- [Map-Collision](Map-Collision)
- [Tagged-Data-Table](Tagged-Data-Table)
