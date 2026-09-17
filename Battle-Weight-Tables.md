# Battle Weight Tables

A run of four tables in the ARM9 binary, each six bytes summing to 256: the weights by which a monster's six ways of acting (see [Monsters](Monsters), battle record `+0x18`) are drawn. The run's position and values are confirmed in two releases; which monsters use tables 0 and 1 is INFERRED from a boss bit; what selects tables 2 and 3 is not established.

Offsets are into the unpacked ARM9 binary of the European release (game code `YDQP`) unless stated. The binary is BLZ-packed on the cartridge (see [DS-Compression](DS-Compression)).

## Layout

| where | European (`YDQP`), unpacked ARM9 offset | USA release, address |
|---|---|---|
| start of the run | `0xE8CBA` | `0x020e8caa` |

The dqix-decomp project names the run `monsterActionWeights`. It holds the same four tables in both releases.

| table | size | weights | who draws by it |
|---|---|---|---|
| 0 | 6 bytes | 43 42 43 43 42 43 | every monster without the boss bit — the reference battle emulator's even table |
| 1 | 6 bytes | 68 58 48 38 27 17 | monsters with the boss bit — the reference battle emulator's table for its own boss |
| 2 | 6 bytes | 210 29 10 4 2 1 | not established |
| 3 | 6 bytes | 70 70 70 16 15 15 | not established |

## The draw

A draw from 1 to 256 is taken against the six weights in turn, as the reference battle emulator's `ProcessEnemyRandomAction2A` has it.

## The boss bit

**Bit 4 of the byte at `+0x27` of a monster's battle record** (see [Monsters](Monsters)), INFERRED from where it is set:

- set on 144 of the 159 boss-coded monsters;
- set on the five grotto bosses that carry ordinary codes — Equinox, Atlas, Shogum, Trauminator, Nemean;
- clear on the bosses' minions (scarlet fever, octagoon, cannibelle, the whales …) and on every other monster;
- set on Ragin' Contagion, the reference emulator's boss, and on the Hexagoon.

The byte's other values are `0x09`, `0x0C` and `0x19`; its other bits are not read.

## Evidence

- Found 16 September 2026 in the unpacked ARM9, as a run of four six-byte tables each summing to 256.
- The first two tables are the reference battle emulator's two tables exactly, which it took from the game's disassembly — the witness that this run is the one.
- The USA address and name come from the dqix-decomp project.

## Not established

- What chooses tables 2 and 3.
- The other bits of the byte at `+0x27`.

## See also

- [Monsters](Monsters) — the battle record and its six ways
- [Actions](Actions)
- [Encounters](Encounters)
- [Event-Battles](Event-Battles)
