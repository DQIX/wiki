# Ship

How the ship is kept, moored, boarded, sailed and brought ashore. Read 6 October 2026.

> **USA only** for the code (the ARM9 and overlays 2 and 17), read through the [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the files and their values.

## Where it sails

The ship sails only on **the ocean, map 10000 (`O00`, "Field - Ocean")**: the whole world at a sixth, as the sky (10100) is for the Starflight Express, wrapping at the same ±144 by ±112 (`0x020a7688`–`0x020a7740`). In a field it is **moored**: a model standing at one of the field's moorings, where it is boarded.

## What the game keeps

At `func_02012fe4()` `+0x2774` on:

| at | what | new game (`func_020134e0`, `0x020136b8`–`0x02013704`) |
|---|---|---|
| `+0x2774` | its place on the ocean, x y z × 4096 | (25, 0.1, 56.8) |
| `+0x2780` | its facing there, radians × 4096 | 0 |
| `+0x2784` | the mooring it is tied up at | 0 |
| `+0x2786` | the map it is moored in | **1900, Bloomingdale** |
| `+0x2788` | at sea | 0 |
| `+0x2794` | the sea's encounter count | 80 |

## Moorings — `.bmbl` regions of type 10

The region reader's case 10 (`func_0201d638`, `0x0201dd98`) reads the `0x74` after a type-10 `0x73` (see [Map archive](Map-Archive)). The ship stands at the region's **centre**, turned by the `0x73`'s **value 8**; the box is where the Hero stands to board.

| `0x74` value | kept at | what |
|---|---|---|
| 0 | `+0x2c` | its number |
| 1–3 | `+0x30` | where the party is put ashore |
| 4 | `+0x2e` | the facing there, radians |
| 5 | `+0x3c` | its reach on the ocean |
| 6–8 | `+0x40` | where the ship puts to sea, on the ocean (only with more than six values) |
| 9 | `+0x4c` | its facing there |

The values are integers on the cartridge — whole units, whole radians — read as floats.

**EU:** 204 moorings in 30 fields (`F02`–`F63`), all with ten values; no other map has one. The `.bmbl`'s `0x7b`/`0x7c` boxes, which the steering would turn the ship along (`func_0201e8fc`), are on no map: all 509 `0x7b` count none.

## The ship's object — `func_020a6728`

Object 201 (`0xc9`), `data/chara_sub/s201.chr`, made on the ocean, the sky and every field region (20000–29999) whose code has no `M`:

| at | value | what |
|---|---|---|
| `+0xb0` | `0xc9` | the most it turns in a vblank, radians × 4096 |
| `+0xb4` | `0x106` | its most speed, a vblank |
| `+0xb6` | 10 | how much faster or slower in a vblank |
| scale | `0xa0` at sea and on the sky, `0x180` moored | (`func_020a6aac`) |

It is drawn at its mooring in the map it is moored in; on the ocean where it is; on the sky at its place on the ocean; in **Bloomingdale** it is the town's own pieces 4 and `0x28`, shown while it is moored there (`func_020a72ac`).

## Boarding

ov017 `func_ov017_02198618`: standing in a type-10 region that is **the mooring the ship is at, in the map it is moored in**, the A Button's check is kind 11; A runs `func_ov017_02199360` (the handlers at `data_ov017_021d64f4`): its place and facing on the ocean become the mooring's values 6–9, **at sea** is set, and the map asked for is 10000. No question.

## Sailing

Each pass of the field (`func_020a654c`, `func_020a75ec`):

- **Steering** (`func_020a78dc`): the +Control Pad held is one of eight directions, the Express's table (`0x020e90a8`: up π, down 0, left 3π/2, right π/2), turned by the camera's own turn; the object is set going and its facing to be that way. Nothing held, it is set to stop. A touch-screen drag steers too.
- **Moving**, the object's own mover: `func_02033710` turns toward the facing wanted by at most `+0xb0` a vblank; `func_0203348c` raises the speed by `+0xb6` a vblank to `+0xb4` while going and lowers it as much to 0 when stopped — **it coasts** — and moves by the least of the speed and the most speed × (1 − the turn still to make ÷ π).
- **The party rides it**, put at its place; its facing is kept at `+0x2780`.
- **Every 3 units sailed** takes one from the encounter count (`func_020a7ce0`).

## A shore

`func_020a7d74`: the ship steered, against a wall whose [collision](Map-Collision) record has **land bits** (bits 5–9 of the second halfword), heading into it — facing against the wall's normal below −0.75 — for **40 vblanks** in all. The record gives the field (packed as the sky's, 20000 + 100a + 10b + c) and a kind, bits 10–14: **kind 1 is Bloomingdale**.

Then the question task `0x39` (`func_ov017_021a9454`): **`strstd` 58, "Disembark?"** Yes asks for that map with no place; no sails on.

Coming in (`func_020a6aac`): into a field, **the mooring nearest** the ship (`func_0201b678`: its ocean place × 6 less the field's place in the world, the nearest within its reach, else the nearest) — the party ashore at its values 1–3, the ship tied up there, at sea cleared. Into Bloomingdale: the party at (−28.5, −1.8, −7.5), mooring 0.

**The ocean's collision**, `O00A0000.col2` (EU): 936 triangles, 36 records. The shores are low walls, −0.06 to 0.09 high, each naming its field with land bits (26 fields), one of kind 1; 508 wall triangles have no land; the floor, flat at 0, names encounter zones 276–279.

## The deck — 5900, `S09`

- **B at sea**, with flag `0x2b`: **`strstd` 59, "Switch to the inside of the boat?"**; yes goes to the deck at (5.94, 3.38, 0.34) facing 3π/2 — at the ship's wheel.
- **Back to sea**: the wheel is character 1, a talk box; its talk record `6:1 164:1` runs **trigger action 164**, a task (`0x37`, `func_ov017_021c1af0`) that asks for map 10000 at the ship's place and facing.
- **At sea** the gangway is closed: z ≥ 6 with x from −8.2 to −5.8 puts the Hero back at (−7, 0.18, 5.9).
- **Moored**, a request from the deck for a field or Bloomingdale goes to the map the ship is moored in, the party put at its mooring's shore (`func_020a696c`).

## Zoom

With flag `0x2b`, Zoom's landing moves the ship to the place's [Travel](Travel) values 9–12: its map, **value 10 its mooring**, and its x and z on the ocean.

## Encounters at sea

`func_ov017_02196c4c`: on the ocean with flag `0x2b`, a spent count is drawn again **between 30 and 100** and a battle is asked for in the zone of the floor's record under the ship (its third halfword, 100a + 10b + c, `func_0204be3c`).

## Not established

- the ship's size against the walls, and how the field's collision meets objects;
- the camera at sea;
- how the sea's battle request, with no roamer, chooses its monsters.

## See also

- [Travel](Travel), [Getting around](Getting-Around)
- [Map archive](Map-Archive), [Map collision](Map-Collision)
- [Triggers](Triggers)
