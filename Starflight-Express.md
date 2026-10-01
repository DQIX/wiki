# Starflight Express

The Starflight Express is reached two ways. Aboard (map S14, 6401), a conductor offers a list of stops, and a stop chosen is a ride: two scenes, one leaving and one arriving. Late in the story, Sterling's whistle summons it over the field, and it is flown over a map of its own, the sky (O01, 10100), and landed in a region below. The conductors' list was read from the game's code on 28 September 2026, the flight on 29 September 2026.

> **EU only.** Code addresses are the USA release's, from the [dqix-decomp](https://github.com/DQIX/dqix-decomp); the files were read on the European release (`YDQP`) and are not yet checked on the US one (`YDQE`).

## The conductors' list

The list is one task of the field's in overlay 17: started by `func_ov017_021a8614`, run by `func_ov017_021a86d0`.

- **Started** by trigger operation **`215 : mode`** (case `0x02063e80`), whose two values' halves, high first, are up to four **stops**; or by the talk service's facility 11 with the stops 1, 2, 3 and 4 (see [Items](Items), the facility codes). Mode 0 is Stella (the Hero turns to character 2), mode 1 Sterling (character 203). 16 records carry it, all on the conductors.
- **Its words** are `data/bin/menu/str_ark` (箱舟, the ark). The stops' names are strings 1 to 5: the Observatory, Alltrades Abbey, the Realm of the Almighty, Gittingham Palace, the Realm of the Almighty. "Cancel" is 6. Stella's lines are from 100, and Sterling's are the same lines from 100 (`func_ov017_021a933c`).
- **The list** is line 100, then the non-empty stops in the record's order, then Cancel. Cancel or the B Button closes it.
- **The stop it is at** is the field state's halfword at `+0x27b4`. Operation **`216 : n`** sets it (`0x02063eac`), and every ride sets it to the stop (`func_ov017_021d1c2c`, which also sends it to the others in a session). `ev5110` sets 1, `ev25524` 2.
- **Choosing the stop it is at** asks line 101, a yes or no. Yes says 102, then changes map to the stop's own place with no scene (a table at `0x021a8d88`: maps 4504, 20007, 4301, 20034, 4400). At the two field stops it also calls `func_ov017_021a65c4`, which is not read. No says 103 and shows the list again.
- **Another stop is a ride**, two scenes. One **leaves** the stop it is at: the Observatory 29506, the Realm 29509, the Realm beyond 29512; the Abbey 29500 bound for Gittingham, else 29515; Gittingham 29503 bound for the Abbey, else 29516. One **arrives** at the stop chosen: 29507, 29501, 29510, 29504, 29513. The arriving scene is parked behind the leaving one (`func_ov017_021bbbf8`), and the leaving scenes end with `834` and `810`, carrying on into it.
- **Two of the story's own scenes replace the arrival.** Stella, to the Observatory, at 10.8 step 1 with game-wide flags 4 to 10 set — one at each thread's end — plays **`ev28800`** (`0x021a8fe0`), whose record brings the threads together at 13.2. Sterling, to the Realm, at 17.1 step 1 with flag 21, plays `ev29210`.
- **A parked scene outlives a map change.** A scene that ends with its second still parked stores it in `GameState` (`+0x63d8`, ov017 `0x021bca4c`), and the field plays it once the next map is in (`0x0218c5fc`).

The arrival scenes are listed at stage 20.1 in the [event lists](Event-Lists). A scene's start raises the story to its listed stage only when the major is 19 at most, so the rides leave the story where it is.

Talking to character `106` aboard at 4.7 plays `ev24598` (map 6401), which chains through three more maps to `ev5110` in the Observatory (see [Event lists](Event-Lists)).

## The sky

**The sky is a map of its own**: O01, 10100, "Field - Sky" (see [Map list](Map-List)). It is the whole world, drawn small, in two archives, `O01a` and `O01b`, both named by its link table (`O01.bmbl`: `O01M00T1`, `O01a`, `O01b`; see [Map textures](Map-Textures)), with every piece placed at the origin.

### Its collision: regions

The sky's collision is `O01A0000.col2` in `O01b` (see [Map collision](Map-Collision)).

- **Each triangle's top seven bits index a trailing record.** INFERRED from the data: 799 triangles, every top byte even, halved 0 to 56, and all 57 records used; and the vehicle's code takes the index from the query `func_02017d90`.
- **A record is a region.** Its first halfword holds the region's field map, packed as three five-bit digits a, b, c, read as 20000 + 100a + 10b + c (`func_0204bef4`). **Whether the Express may land there** is bits 5 to 9 of the second halfword (`func_0204bedc`).
- There are 56 regions, 20001 to 20063, and one record all zero, the sea.
- The vehicle keeps the record under it at `+0x114` (`0x02033fa0`), cast down from its height each frame (ov017 `func_ov017_02193dc4`).

The same three digits name a battle's stage in an ordinary field's collision, read from 30000 by `func_0204bd7c` (see [Battle stages](Battle-Stages)).

### Where the world sits in the sky

**The map list's values 14 and 15** place maps in the world (see [Map list](Map-List)). On the field regions they are integers: the region's place, in the maps' own units. On towns and dungeons they are floats: **the map's place in the sky**.

The sky holds the world at a sixth:

- Taking off from a field region, the Express starts at (the Hero's place + the region's) ÷ 6 (`func_020acecc`, `0x6000`).
- Taking off from a town, it starts at the town's sky place.
- Landing, the Hero is put at the sky's place × 6 − the region's (`0x020acf40`), at the nearest of the region's landing places (category-11 objects, `func_0201b78c`, not read).

## The vehicle

US ARM9 `0x020ac020`–`0x020ae4c8`. `func_020ad61c` runs it each frame, and only in map 10100.

| what | value | where |
|---|---|---|
| height | fixed, 10 (`0xa000`) | `func_020adaac` |
| steering | the +Control Pad held turns it toward one of eight directions against the camera's turn: up π, down 0, left 3π/2, right π/2, the diagonals between. At most `0xcc` radians × 4096 a frame | table `0x020e9118` |
| speed | `0x1eb` − `0x28` a tick | the mover `func_0203348c` |
| wrap | past x ±144 by 288, and z ±112 by 224 | `func_020ad61c` |
| carriages | two, each following 0.9 behind the one before | `func_020adda4`; laid out in a line by `func_020adfa8` |
| models | `chara_sub/s203.chr` and `s204.chr`, with `s203s` and `s204s` their shadows, at a scale of 192 of 4096 | `func_020aca88` |
| descend | 0.1 a frame for 16 frames | `func_020ae398`; `func_020ae3f4` climbs |

`func_020ae20c` draws the shadows, and `func_020ae074` the train with its bob. Touch steers it too.

### The buttons

Both are handled by ov017 `func_ov017_021a7378` (started by `func_ov017_021a72f4`).

- **A** asks "Disembark here?" (`str_ark` 36). Yes descends and lands in the region below. Where the region may not be landed on, it asks instead "It's not possible to disembark here. Head for the Realm of the Almighty?" (38), and yes climbs and plays `ev29510`, the Realm's arrival.
- **B** asks "Switch to the view inside the Starflight Express?" (35). Yes goes aboard: map 6401 at (3.5, 0.6, −3.5).

## Sterling's whistle

Item 22256 (`0x56f0`; see [Items](Items)) is a case of its own in the field item code, which handles some items by their number (ov002 `func_ov002_02157634`).

- In a field region, or in one of 19 towns (a list at `0x020e6ea8`), it summons the Express: an effect, waits, and a fade (ov017 `func_ov017_021a6b9c`, `func_ov017_021a6c2c`). The sky map follows.
- Elsewhere its lines say it cannot reach. That they are `str_ark` 13 and 14 is INFERRED from the item code's messages from `0x7530` on.
- It is given at 19.1 by `114:22256`, on the record for winning set battle 27 (see [Event battles](Event-Battles)).

**Operations `114 : i` and `115 : i`** give and take an item. Both are queued (queue cases `0x0206fcc0` and `0x0206fd74`). Which is which is INFERRED from the items: `114` carries the fygg, the party popper and the whistle; `115` the Drunken Dragon and the Gittish seal handed back.

## Evidence

- The conductors' task, the flight, the regions and the whistle are read from their functions in the USA ARM9 and overlays 2 and 17 (addresses above).
- `O01A0000.col2`: 799 triangles, every top byte even, 57 trailing records all indexed; 56 regions from 20001 to 20063 and one all zero. Read on the European cartridge.
- `str_ark`'s strings 1 to 6, 35, 36, 38 and 100 on, read against the code that asks for them.
- 16 records carry `215`, all on the conductors.

## Not established

- **What plays `ev29150`**, Celestria opening the way, listed at 16.1 in map 20034 (Gittingham's field). INFERRED: arriving there by the Express at 15.3 step 5. Nothing read names it — not the Express's task, the event lists' flags, nor the queued-scene slot. No record moves the story to 16.1, so whether 16.1 is reached at all rests on it. A scene's start raises the major and minor and leaves the step, so from 15.3 step 5 the story would be at 16.1 step 5, and 16.1 steps 2 to 4 could not then be set.
- **Whether the Express ever stops.** Its speed is set every frame, and the mover (`func_0203348c`) takes `0x28` off it unless `+0xbe` is 1, so it flies on at `0x1c3` a tick with nothing held. INFERRED that it never coasts to a stop. What sets `+0xbe`, and whether anything slows it with no key held, is not read.
- **The sky collision's region index.** That the top seven bits of each triangle's attributes are the index is INFERRED from the data (above).
- **Where a landing puts the Hero.** The game takes the nearest of the region's landing places (category-11 objects, `func_0201b78c`), which are not read.
- **The whistle's lines.** INFERRED that the item code's messages from `0x7530` on are `str_ark` 13 on.
- **Which of `114` and `115` gives an item**, INFERRED as above.
- The camera in flight.
- The whistle's route from operation 252.
- What `func_ov017_021a65c4` does at a field stop.
- What operation `225 : map` does. It is queued, and sits on records that end in a new map (`ev29004`'s `225:4301`).

## See also

- [Map-List](Map-List)
- [Map-Collision](Map-Collision)
- [Map-Textures](Map-Textures)
- [Event-Lists](Event-Lists)
- [Triggers](Triggers)
- [Items](Items)
- [Event-Battles](Event-Battles)
- [Battle-Stages](Battle-Stages)
- [Quests](Quests)
