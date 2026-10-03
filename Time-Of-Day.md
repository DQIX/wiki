# The day's clock

> **USA only** for the code, read through the
> [dqix-decomp](https://github.com/DQIX/dqix-decomp) (`GameTime.cpp`, and the
> `GameState` functions it names). **EU only** for the map kinds and records.

## One clock, of a 420-second day

| | |
|---|---|
| the time | `GameState+0x3CC`, a float of seconds |
| running | `GameState+0x3D8` |
| the phase | `GameState+0x3DC` — **night 0, morning 1, day 2, evening 3** |
| the phases | night from 0 s, morning from **180**, day from **210**, evening from **390**, to 420 |
| a new game | 210, the day's start, running |
| saved | the time, as a float in the save's head; the running flag is not (INFERRED) |

`SetDayTimer(t)` (`0x02010288`) is the one writer of the phase; `SetTimeOfDay(p)`
(`0x02010364`) puts the time at phase *p*'s start.

**It runs only on a map of kind 0 or 7** — a field, or the ocean and the sky —
by the frame's VBlank count over 60, about a second a second. The kind is
[map list](Map-List) value 3, kept as the low nibble of the map record's
`+0xC` (`func_020995f8`). **EU only:** the fields are 0, the ocean and sky 7,
towns 2, dungeons 1, the Quester's Rest 8 — so the clock stops in all of them.
Nothing stops it for menus, talk, scenes or battles on a field (INFERRED from
there being no gate).

**Night is the night phase alone**, wherever a yes-or-no is asked: who stands
where ([area cast](Area-Cast), `place.bin` tag 5), a [trigger](Triggers)'s
condition 17, the inn's menu. Morning and evening count as day.

## What sets it

| | does |
|---|---|
| [engine function](Engine-Functions) `808 : p` | the phase |
| `579 : a` | running when *a* is 0 |
| `588 : p` | pins the **lighting** to phase *p*, not the clock; `589` re-pins it to the clock's own phase |
| `597` | answers the lighting's phase |
| [trigger](Triggers) action `110 : p` | the phase |
| trigger action `177 : a, v` | running when *a* is 0, and the phase *v* (the next word's high half) |
| the inn's **Stay** | the time to **210**, the day's start |
| the inn's **Rest** | the time to **0**, the night's start — offered only by day |

The Quester's Rest's counter sets no time of its own.

**The slice's evening at 2.2 comes of the story's records**, with no special
case: the clock is stopped from 1.4; at 2.1 the Mayor's house's record stops
it at evening; Erinn's dinner (`177:0`, phase 1) starts it at morning; so 210
seconds of field at 2.2 bring the evening, and 30 more the night. `ev2360` and
`ev2560` put it back to morning; the inn at 2.5 stops it at night, and 2.6
starts it at day. Set battle 26, the opening's, sets evening at its start and
day at its end.

## What reads it

- **Zone lighting**: advanced zones blend into the next phase over each
  phase's last 2 seconds; basic zones take one phase on entering, and entering
  one within 4 seconds of a phase's end moves the clock on to the next.
- **Music**: at night, track 3 becomes 4 and 5 becomes 6 — Angel Falls has a
  night tune.
- **Map effects**: the `.mse` files' tag `0x6D` hides effects by phase.
- **Doors**: a map link has a day variant and a night one.
- **Roaming monsters**, `encfld`'s zone word: its low bits 0 roam when it is
  not night, 1 only at night, 2 at all hours; bits 13–20 are a region mask of
  the ground (INFERRED where the loader stores the word).

## Not established

How a town is re-lit after the inn; which `.bats` declare basic lighting and
which advanced; what raw story bit `0x1140`, which marks a turn into night or
morning, is for; whether the clock really runs through battles and menus — a
let's play would settle it.
