# Mini Medals

Cap'n Max Meddlin's service in Dourbridge: mini medals (item 22039) handed in for booty at ten milestones, then exchanged at will. **Read from overlay 4's code** (US addresses); the tables and lines were checked on the US release (`YDQE`), where the tables sit at the offsets below, and on the European (`YDQP`), whose `str_mdl` and trigger files are byte for byte the same.

## Reaching him

Max is `s083`, cast member 103 in `M08M07` (map 1807). He has no talk file of his own. His [trigger](Triggers) record is `6:103 145:7`: operation `145` opens a facility when the character is talked to, and 7 occurs only on him. INFERRED from the operation's distribution; see [Triggers](Triggers).

**EU only:** the distribution. Operation `145` occurs 58 times on the cartridge, always beside `6` on a character's record, and always where there is a counter — 0, 2 and 3 in Stornway, 2, 5 and 6 at the Quester's Rest — and 7 only on Max. Its numbering is **not** the line-tag facility codes' (see [Items](Items#how-a-tag-opens-a-facility)), where 7 is the Krak Pot. Counted on the European release's trigger files, which are byte for byte the US release's.

## The tables

Two arrays of `(u16 medals, u16 item)` back to back in overlay 4 — US `0x1c918`, `0x0216fff8` in memory, and `0x1c930`, `0x02170010`:

| array | bounded by | on the reference cartridge |
|---|---|---|
| six exchanges | `cmp r4, #6` | 3 prayer ring · 5 elfin elixir · 8 saint's ashes · 10 reset stone · 15 orichalcum · 20 pixie boots |
| ten milestones | `cmp r3, #0xa` | 4 thief's key · 8 Mercury's bandana · 13 bunny suit · 18 jolly roger jumper · 25 transparent tights · 32 miracle sword · 40 sacred armour · 50 meteorite bracer · 62 rusty helmet · 80 dragon robe |

Found in another release by shape: six rising pairs, then ten rising pairs ending at 80, each naming an item.

The bounds are at `0x02168440` (`cmp r4, #6`) and `0x021679b4` (`cmp r3, #0xa`). The exchanges' two literals, `0x0216fff8` and `0x0216fffa`, fix the pair layout, and the milestones end with `(0, 0)`. A milestone is the first threshold that *exceeds* the medals handed in.

## The service

His lines are `str_mdl` (`/data/bin/menu/str_mdl.gp2`, `str_mdl_<lang>.bin`), a [tagged data table](Tagged-Data-Table) whose `0x67` records are a number and a string: 10–11 his introduction, 20–21 a first hand-over, 30–32 a later one, 40–41 a milestone's reward, 50–51 the tally and the next target, 60–63 the eightieth medal, 100 the list's title, 110–151 the exchange, 200 a long introduction.

| function | what it does |
|---|---|
| `func_ov004_02167d90` | where a visit starts: a global set (not established) → 200; nothing handed in → 10; every milestone passed → 100; else 30 |
| `func_ov004_0216794c` | the numbers: handed in so far (the progress record's `+0xf74`), medals held, the next milestone — the first above the total — and whether handing in reaches it |
| `func_ov004_02167b78` | fills the lines: `val_1` handed in, `val_2` held, `val_3` the next milestone or the price, `val_4` the total after, held to 80; the item's name |
| `func_ov004_02167adc` | hands over: **only as many as the next milestone needs** when they reach it, and gives its reward; otherwise all |
| `func_ov004_02167a0c` | takes that many item 22039 from the bag and adds them to `+0xf74`, **held to 500** |
| `func_ov004_02167a6c` | gives an item |
| `02167e28`, `02167e6c`, `02167eb0`, `02167f1c`, `02167fb0` | what follows: medals held → hand them over; none → the tally on a later visit; reached → 40; not reached → 51, after 50 on a later visit; every milestone passed → 60 |
| `func_ov004_021680cc` | lays out the exchange: the six at their prices, and the medals held |
| `func_ov004_02168318` | an exchange chosen: enough held → 130 and a yes-or-no; else 132 |
| `func_ov004_02168400` | yes: the price through `02167a0c` — **so exchanges count towards the total** — and the item; then 140, which asks if there is more |

The eightieth medal's scene is `ev28590`, its own record in map 1807; its lines are `str_mdl` 60–63 again.

### The exchange after eighty

> **EU only.** Code addresses are the USA release's, from the decomp; `str_mdl` is byte for byte the same on the European and US releases.

Read 27 September 2026, the lines each step says:

- **Opening** (`02168074`): after his greeting, 110, with medals held he says 120 and shows the list; with none, 151.
- **The list** (`021680cc`) is the six exchanges at their prices, titled by line 100.
- **A choice** (`02168318`) sets `val_3` to its price; with enough held he says 130 and asks, else 132.
- **Yes** (`02168400`) takes the price through the same hand-over as a milestone, gives the item and says 140, which asks if there is more. **No** says 131. **More** says 141.
- **Leaving** says 150 and 151 (`02168244`, `02168268`).

## Not established

- What global sends a visit to the long introduction at 200.
- **How many medals exist.** The mini medal is item 22039 and nothing in the data counts them; quests award them too.
- The exact order of lines where a step's handler was not tied to its label: that handing over resumes after a reward while medals are left, and where 21 and 32 fall.

## See also

- [Triggers](Triggers) — operation `145`, which opens his service
- [Items](Items#how-a-tag-opens-a-facility) — the other facilities, opened by a line's tag
- [Alchemy](Alchemy) — where these tables were first written up
- [Tagged data table](Tagged-Data-Table) — `str_mdl`'s shape
