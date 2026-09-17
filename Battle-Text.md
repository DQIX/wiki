# Battle Text

Three message files hold what is said in battle and when something is used in the field: `strbtl`, `actmsg` and `str_tm`. Each is in the [system strings](System-Strings) layout — messages by number — and uses the same markup as the dialogue, with more of it. The files and the messages listed here are read; which message an action says is INFERRED to be in the action's record.

All observations were made on the European release (game code `YDQP`).

## Files

| file | messages | contents |
|---|---|---|
| `/data/bin/strbtl.gp2/strbtl_<lang>.nat` | 17 | monsters drawing near (5 to 9) and fleeing (1 to 3) |
| `/data/prm/actmsg.gp2/actmsg_<lang>.nat` | 591 | what an action says |
| `/data/bin/menu/str_tm.gp2/str_tm_<lang>.nat` | 329 | the field menu's |

## `actmsg`

| number | message |
|---|---|
| 1 | `<DEF_ART_ACTOR> attacks.` |
| 2 | `<DEF_ART_TARGET> takes <val_1> points of damage.` |
| 9 | defeated |
| 10 | defends |
| 12 | `uses <INDEF_ART_SGL_I_NAME>.` |
| 22 | `<DEF_ART_TARGET><1>s wounds are healed.` |
| 46 | `<DEF_ART_ACTOR> casts <ACTION>.` |
| 140 | `Critical hit!` |
| 141 | `<DEF_ART_ACTOR><1>s <ACTION> goes haywire!` |
| 153 | `Not enough MP!` |

A spell cast in battle says 46, then its own message. 141 is a spell's critical — the reference's 1.5 to 2.0 times (the reference is DQIX/BattleEmulator).

Neither healing message names the amount. **Which message an action says is in its record**, INFERRED: bits 20–31 of `+0x20`, with the opening message in bits 10–19 — see [Actions](Actions).

## `str_tm`

| number | message |
|---|---|
| 1 | `Items` |
| 2 | `Attributes` |
| 3 | `Spells & Abilities` |
| 4 | `Misc.` |
| 1200 | `What would you like to do?` |
| 1201 | `Use` |
| 1203 | `Discard` |
| 1204 | `Cancel` |
| 1903 | `Equipment` |
| 2100 on | the thirteen vocations, `Guardian` to `Ranger`, in the [level tables'](Level-Tables) order |
| 4351 | `MP` |
| 9002 | `uses <INDEF_ART_SGL_I_NAME>.` |
| 9003 | `But nothing happens.` |
| 9004 | wounds healed |
| 9005 | `casts <str_2>.` |
| 9006 | `doesn<1>t know any non-battle spells!` |
| 9007 | `Not enough MP!` |
| 9012 | `it doesn<1>t seem like it<1>d be much use on <DEF_ART_TARGET>` |
| 9062 | `<SGL_I_NAME> discarded.` |
| 9065 | `The bag is currently empty.` |

## `str_btl`

The battle menu's `str_btl` numbers its commands:

| number | message |
|---|---|
| 30004 | `Attack` |
| 30005 | `Spells` |
| 30006 | `Defend` |
| 30007 | `Abilities` |
| 30008 | `Items` |
| 30021 | `spells` |
| 30023 | `<DEF_ART_ACTOR> doesn<1>t know any battle <str_2> yet.` |

30023 is said with 30021, `spells`.

## Markup

| markup | meaning |
|---|---|
| `<DEF_ART_ACTOR>` | the actor's name behind its definite article |
| `<INDEF_ART_SGL_M_NAME>` | a monster's name behind its indefinite article |
| `<IF_SING val_1>` … `<ELSE_NOT_SING>` … `<ENDIF_SING>` | choose on a count |
| `<IF_TARGET_SING>` … `<ELSE_TARGET_PLR>` | choose on the target being one |
| `<IF_ACTOR_M>` … `<IF_ACTOR_F>` … `<IF_ACTOR_N>` … `<ENDIF_ACTOR_MFN>` | choose on the actor's gender: three branches and one end (see [Articles](Articles)) |
| `<IF_SOLO>` | choose on the party being one |

For the markup shared with dialogue, see [Event-Text](Event-Text).

## See also

- [Actions](Actions)
- [Articles](Articles)
- [System-Strings](System-Strings)
- [Event-Text](Event-Text)
- [Monsters](Monsters)
