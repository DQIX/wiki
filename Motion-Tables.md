# Motion Tables

A `.bcfg` file beside a model is a [tagged data table](Tagged-Data-Table) naming stretches of that model's animation as motions. 2,844 of the cartridge's 2,854 `.bcfg` files carry one. The motion record (name, first frame, last frame, speed) is confirmed on a cabinet; the `0x65` and `0x70` records are not established. Observations are from the European release (game code `YDQP`).

## Where they are

| folder | `.bcfg` files with a motion table |
|---|---|
| `/data/effect` | 1,416 |
| `/data/event_lv5` | 554 |
| `/data/chara` | 262 |
| `/data/chara_sub` | 226 |
| `/data/pack_lv5` | 197 |
| `/data/map` | 145 |
| `/data/enemy` | 26 |
| `/data/bin` | 18 |

A motion table belongs to the model that shares its file stem.

## Layout

| tag | values | meaning |
|---|---|---|
| `0x66` | string, number, number, number | **a motion**: its name, first frame, last frame, speed |
| `0x64` | integer | the motion count, on the cabinets |
| `0x65`, `0x70` | | not established |

## Example: a cabinet

`M01M03G1.bcfg` reads:

| name | first | last | speed |
|---|---|---|---|
| `open` | 0 | 25 | 1 |
| `closed` | 0 | 0 | 1 |
| `opend` (sic) | 25 | 25 | 1 |
| `close` | 0 | 25 | 1 |

The model beside it has three nodes — the cabinet and its two doors, `a` and `b` — and a 25-frame animation that turns `a` to +135° and `b` to −135° about the vertical, from shut at frame 0 to open at frame 24. So `closed` and `opend` hold the two ends, and `open` plays between them. `close`, with the same frames, presumably plays them backwards (INFERRED).

**A piece with a motion table plays a motion when asked, not its animation on a loop.** A waterfall's or a sky's animation should loop; a cabinet's, played round and round, swings it open and shut for ever.

## Not established

- The `0x65` and `0x70` records.
- That `close` plays its frames backwards (INFERRED only).
- The 10 `.bcfg` files that carry no motion table.

## See also

- [Tagged-Data-Table](Tagged-Data-Table)
- [Map-Objects](Map-Objects)
- [Doors](Doors)
