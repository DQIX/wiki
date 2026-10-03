# Heal All, and a heal outside a battle

The Misc. menu's **Heal All** — `str_tm` 4001, "Uses party members' magic to
fully restore the party's HP as efficiently as possible" — and the roll every
heal cast outside a battle goes through.

> **USA only** for the code (overlay 2, the field menu), read through the
> [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the text
> and tables, which match the code's numbers one for one.

## Where it is

The field menu's **Misc. submenu** (state 21, `func_ov002_02166168`) labels
row code *c* with `str_tm` **4001 + c**: 0 Heal All, 1 Tactics, 2 Allocate
Skill Points (listed only once game-wide flag `0x119c` is set), 3 Assign Party
Tricks, 4 Profile Settings, 5 Volume Settings, 6 Quest List (**never** listed:
`0x021560e4` forces it out), 7 Quick Save, 8 Call to Arms (multiplayer). The
help lines are INFERRED to be 4020 + *c*: 4026, Quest List's, is the one
missing.

## The rule — `func_ov002_021665b0`

**Casters are ranked by vocation** (`0x02166a80`), then by what they know:

| vocation | score |
|---|---|
| Priest | 10 |
| Sage | 8 |
| Minstrel, Paladin, Luminary | 5 |
| Thief, Ranger | 3 |
| any other | never casts |

plus 4 for each of Heal, Midheal, Moreheal, Fullheal and Multiheal they can
cast (counted only with 2 MP or more), and 200 for Omniheal or else 100 for
Multiheal, and 5 for a bit of the character whose meaning is not established
(`ch+0x78` bit 30). Best first, ties in party order. These seven vocations are
exactly the seven the spell table teaches a heal or Squelch to.

**For each member in party order**, the best caster first:

1. **Poisoned**: the first ranked member who can cast Squelch does.
2. **Multiheal** only when all four are hurt enough — the counts it compares
   can reach 4 only in a party of four, so a smaller party never sees it.
3. Otherwise the **smallest heal the caster's own rolls say will do**: Heal if
   the hurt `d` ≤ Heal's amount, Midheal if `d` < 2 × Midheal's, Moreheal if
   `d` < 3 × Moreheal's, else Fullheal, else the strongest known. The caster's
   five amounts are **real rolls, made once** when they begin.
4. **Short of MP**, it steps down a spell at a time — Fullheal, Moreheal,
   Midheal, Heal — and when even Heal is too dear the next caster takes over.

It stops when everyone is full or fallen, or every ranked caster is out. It
reads **no items, no tactics and no MP reserve**.

Each cast says `str_tm` **9005** "X casts Heal.", then **9017** "Y's wounds are
healed!" (**31052** "…is no longer poisoned." for Squelch), or **9003** "But
nothing happens." when it did nothing, spending no MP. 9003 alone closes a run
in which nothing was cast. The lines run on in the field menu's message window
with `<ADD>`, no button between casts.

## A heal's amount outside a battle — `func_ov002_021538e4`

**The same three arms as the battle's `GetAttackBaseDamage`** (see
[Battle resolution](Battle-Resolution)), in the same float order, but:

| | battle | outside a battle |
|---|---|---|
| last step | `_ffix`: **truncate** | **`RoundUp`** (`0x020744a8`): `(int)(0.5f + x)` |
| generator | the battle's own | the world's, `GetBTRandom` |
| scaled by | the current numbers, might or mending | **base** magical mending only; a might-scaling action takes the unscaled arm |
| Fullheal | — | **999**, its handler's (`0x02153dc0`) |

A Multiheal rolls once for each member it reaches.

## Not established

Which status bits are fallen and poisoned (bit 0 and bit 1 of `[e+0x130]+0`,
from use); the learnt-spell bits at `ch+0x910` and their agreement with the
spell table; ability bit `0x106`, which takes a quarter off each cast's MP;
the +5's bit. **Read and not witnessed**: a run whose only cast is a Multiheal
ends "But nothing happens."; the Squelch line names the ranked caster rather
than the one who cast it.
