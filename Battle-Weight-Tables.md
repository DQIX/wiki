# Battle Weight Tables

A run of four tables in the ARM9 binary, each six bytes summing to 256: the weights by which a monster's six ways of acting (see [Monsters](Monsters), battle record `+0x18`) are drawn. The run's position and values are confirmed in two releases, and **which table a monster draws by is read from the game** — three bits of its battle record, not the boss bit this page once named.

Offsets are into the unpacked ARM9 binary of the European release (game code `YDQP`) unless stated. The binary is BLZ-packed on the cartridge (see [DS-Compression](DS-Compression)).

## Layout

| where | European (`YDQP`), unpacked ARM9 offset | USA release, address |
|---|---|---|
| start of the run | `0xE8CBA` | `0x020e8caa` |

The dqix-decomp project names the run `monsterActionWeights`. It holds the same four tables in both releases.

| table | size | weights | who draws by it | of the 438 |
|---|---|---|---|---|
| 0 | 6 bytes | 43 42 43 43 42 43 | a monster whose way of choosing is 0 — the reference battle emulator's even table | 96 |
| 1 | 6 bytes | 68 58 48 38 27 17 | way 1 — the reference battle emulator's table for its own boss | 281 |
| 2 | 6 bytes | 210 29 10 4 2 1 | way 2 | 2 |
| 3 | 6 bytes | 70 70 70 16 15 15 | way 4 | 25 |

## The draw — `func_0208a370`

The only code that reads the run:

```
roll = NextRandomMax(256) + 1          ; 1 to 256
for i in 0..5:
    if table[i] >= roll: take slot i
    roll -= table[i]
```

which is a running subtraction down the six, as the reference battle emulator's `ProcessEnemyRandomAction2A` has it. The action taken is the `u16` at the record's `+0x18 + 2i`. Because every table sums to 256 the clamp after the loop is unreachable.

A slot the monster cannot use — no MP for it, a once-a-battle way already spent, no target left — is **not re-drawn**: `func_0208a03c` judges the slot, and the picker then scans down from it to 0 and afterwards up to 5, falling back to action 2 if nothing serves.

## What chooses the table — `func_0208a91c`

**Bits 5 to 7 of the word at `+0x10`** of the monster's battle record. The three bits index eight handlers at `0x020f10b0`, which is read by one instruction in the whole build:

| way | what it does | of the 438 |
|---|---|---|
| 0 | weight table 0 | 96 |
| 1 | weight table 1 | 281 |
| 2 | weight table 2 | 2 |
| 4 | weight table 3 | 25 |
| 3, 7 | round robin over the six, by a counter kept for the monster | 9 |
| 5 | a counter picks a pair of slots, and a coin picks within the pair | 22 |
| 6 | two passes over the slots, the first often skipped | 3 |

So four of the eight ways draw by weights at all, and 34 of the 438 monsters choose some other way.

## The boss bit does not choose it

This page had it that **bit 4 of the byte at `+0x27`** (see [Monsters](Monsters)) selected between tables 0 and 1, INFERRED from where the bit is set: on 144 of the 159 boss-coded monsters, on five grotto bosses with ordinary codes — Equinox, Atlas, Shogum, Trauminator, Nemean — and clear on the bosses' minions and every ordinary monster.

**It does not.** The two commonest ways stand on both sides of that bit, and **the Hexagoon — a boss, and the one this reading was checked against — is way 0**, the even table. The bit is read by no instruction in the ROM at all; see [Monsters](Monsters).

## Evidence

- Found 16 September 2026 in the unpacked ARM9, as a run of four six-byte tables each summing to 256.
- The first two tables are the reference battle emulator's two tables exactly, which it took from the game's disassembly — the witness that this run is the one.
- The USA address and name come from the dqix-decomp project.
- The selector, the picker and the eight ways were read from the USA binaries on 22 September 2026, and the run is the only copy of those bytes anywhere in the build.

## Not established

- What the four ways that do not draw by weights do in detail — the round robin's counter, the pair and the coin, the two passes.
- What makes a slot unusable, beyond MP, a spent once-a-battle way and a missing target.

## See also

- [Monsters](Monsters) — the battle record and its six ways
- [Actions](Actions)
- [Encounters](Encounters)
- [Event-Battles](Event-Battles)
