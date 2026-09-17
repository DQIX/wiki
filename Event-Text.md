# Event Text (`ev#####_<lang>.bin`)

Each event's text comes in five files, one per language. Each file is an ordinary [Tagged-Data-Table](Tagged-Data-Table). Every record is a message number and a string offset. The text is plain ASCII: accents, pauses, names, conditions and prompts are all written as `<…>` markup. The container and records are confirmed. A few tags have a known meaning. Most tags are **not established**.

All counts on this page are from the European release (game code YDQP).

## Where the files are

Each event unpacks from its own `ev#####.gp2` (see [GPC2](GPC2)) into a `.stb` script and five text files: `_de`, `_en`, `_es`, `_fr` and `_it`. The events are in one of two folders:

- `/data/event` holds 523 events.
- `/data/evspt_lv5` holds 164 more, numbered 21500 to 29791, packed the same way.

No event number is in both folders.

Two events in `/data/evspt_lv5`, `ev21593` and `ev23190`, also carry a plain `ev#####.bin`. It has not been read.

Example events:

| event | what it is |
|---|---|
| `ev22590` | the scene at Angel Falls' Guardian statue |
| `ev22510` | Patty's talk before the Hexagoon fight |
| `ev22591`, `ev22592` | events on the pass |

The `.stb` file is the script, magic `SB2\0`. See [Event-Scripts](Event-Scripts).

## Layout

A text file is a [Tagged-Data-Table](Tagged-Data-Table). Every record has tag `0x64` and two values:

| value | meaning |
|---|---|
| 0 | the message number |
| 1 | the string offset |

When the string offset is `0xFFFFFFFF`, the message says nothing. This is true of 40 of the 18,245 messages. No message points at an empty string.

## The text is ASCII, and markup does the rest

Accents are written as markup in every language, which is why no string needs a byte above `0x7F`.

| language | accent tags |
|---|---|
| Spanish | `<'i>` (1,705), `<~n>` |
| German | `<:u>` (1,569), `<ss>` |
| French | `` <`e> ``, `<^e>`, `<,c>` |
| Italian | `` <`e> `` |

Spanish and French also write some punctuation this way: `<^!>`, `<^?>`, `<!>`, `<?>`, `<:>`.

A line break is written as the two characters `\n`. This happens 454 times in English.

A message splits into text, line breaks and tags. A tag is either `<name>` or `<name=a,b,c>`. Across the cartridge, no `<` is left open and no `>` stands alone.

## What the tags mean

49 tag names occur in the English text. Only a few have a known meaning, and those were read from the text itself:

| tag | uses in English | what it is |
|---|---|---|
| `<1>` | 3,435 | an apostrophe |
| `<,>` | 3,395 | a pause |
| `<HERO>` | 317 | the player's name |
| `<Cap>` | 218 | capitalise |
| `<SE_014>` | 16 | a sound effect, by number |
| `<IF_x>` … `<ELSE_…>` … `<ENDIF_x>` | 91 `HERO_MALE`, 34 `MALE`, 11 `SOLO` | conditional text. These tags nest properly in **all 1,159** messages that use them, in every language. Each condition is only named; what it tests is not established |

French adds conditions of its own, such as `IF_VOWEL_FR_HERO` and `IF_FEMALE_PARTY`. They look like the choice between *de* and *d'* before a name.

704 English messages open with `*:`. This is how the text marks a line spoken by someone. What the game does with it is not established. A named speaker is written `//Name//` instead.

## Prompts: `<YESNO>` and `<UKEYAME>`

Prompts are a small branching language inside the text. It is the same in all five languages. Almost all prompts are in what characters say: the English talk files ([Character-Dialogue](Character-Dialogue)) have 6,651 prompts, against 57 in events.

**The two prompts.**

- `<YESNO>` offers two answers. Their branches open with `<YES>` and `<NO>`.
- `<UKEYAME>` offers two more, `<UKE>` and `<YAME>`. These mean **accept** and **decline**. This is **INFERRED** from three things:
  - the Japanese words
  - the system strings, which list "Yes", "No", "Accept" and "Decline" in that order
  - where the prompt appears: at quest offers. The commonest shape in the talk files is `UKEYAME YAME END UKE CLOSE`, 2,087 times.

**Where a branch ends.** A branch runs to one of the following:

| branch ends at | count |
|---|---|
| `<END>` | 5,449 |
| `<CLOSE>` | 4,591 |
| another branch's marker | 675 |
| a further prompt | 583 |
| a jump | 383 |
| the end of the message | 241 |

**Branches do not rejoin.** Only 16 messages have anything after an `<END>` other than a marker, a label or `<CLOSE>`.

**Labels and jumps.** `<LB_x>` is a label and `<JP_x>` is a jump to it. **All 1,915 jumps** find their label in the same message. 1,075 of them jump backwards, which is how answering no can ask the question again.

**Prompts per message.** At most two prompts share a message. Suppose each answer's branch is taken to be the first marker for it after the prompt. That lands past another prompt on 65 of 13,302 answers. Most of these are a quest offer asked twice in a row, or a prompt inside a yes/no branch, where the markers differ anyway.

**Answers whose markers stand side by side share a branch.** This is **INFERRED**. The shape is `<YESNO><YES><NO>` followed by the text. It occurs 36 times in the English talk files and 10 times in the village. The innkeeper's counter line is one of them.

- Read as two branches, the first branch is empty and ends the line.
- Read as one shared branch, both answers run on into the text after them. The innkeeper's line then ends by handing over to the inn (`<ADD><INN=1>`).

**Answers with no branch.** 1,380 answers in the talk files, and 110 of the 114 answers in events, have no branch at all. What follows the answer is up to the script.

## Evidence

| check | result |
|---|---|
| text files | 2,615, five per event |
| read as a table | 2,590. The other 25 are zero bytes, five events' worth |
| records | 18,245, **every one tag `0x64` with two values**: a number, then a string offset |
| events whose five languages carry the same message numbers in the same order | **518 of 518** |
| bytes of `0x80` or above in any string of any language | **none** |

## Not established

- What most tags mean: `<ADD>` (1,303), `<6>`, `<9>`, `<-->`, `<PAD_WAIT_NOCUR>`, `<CLOSE>`, `<LEADER>`, `<CEN>`, `<QUEST…>`, `<YESNO>`, `<TIME=…>`, `<ME_…>`, `<END>`, `<PAGE>`, and a dozen rarer ones.
- What each `<IF_x>` condition tests.
- What the game does with a line that opens with `*:`.
- The plain `ev#####.bin` in `ev21593` and `ev23190`.

## See also

- [Event-Scripts](Event-Scripts): the `.stb` beside the text, which names its own messages
- [Character-Dialogue](Character-Dialogue): the talk files, which use the same markup and prompts
- [Tagged-Data-Table](Tagged-Data-Table)
- [GPC2](GPC2)
- [System-Strings](System-Strings)
- [Item-Descriptions](Item-Descriptions): these carry the same markup
