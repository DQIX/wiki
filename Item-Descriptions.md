# Item Descriptions

`itemexpl_<lang>.nat`, in `/data/prm/itemexpl.gp2` and again, byte for byte, in `/data/prm/iteminfo_<lang>.gp2`: one description per item, keyed by the item's id. The file has the same format as the [system strings](System-Strings) and reads as one. Its structure and coverage are confirmed; what each markup tag stands for belongs to the talk text. Observations are from the European release (game code `YDQP`).

## Layout

A record per item, keyed by the item's id, in the [System-Strings](System-Strings) format.

In English there are 1,178 records, one for every item in `itemname_en.nat` (see [Items](Items)) and nothing else. The copper sword, 20004: "A commonplace cutter made of copper."

- None is longer than 82 characters.
- None holds a line break: the screen breaks the lines.

## Markup

The text carries the talk text's markup (see [Character-Dialogue](Character-Dialogue)). Counts in English:

| tag | count |
|---|---|
| `<1>` | 212 |
| `<,>` | 92 |
| `<6>` | 8 |
| `<9>` | 8 |
| `<^a>` | 5 |
| `<'e>` | 4 |
| `<^e>` | 2 |
| `<-->` | 1 |

## Evidence

- Record count and ids matched against `itemname_en.nat`.
- The descriptions were used as evidence for the item stats fields (see [Items](Items)).

## Not established

- What each markup tag stands for is not recorded here; see the talk text.

## See also

- [Items](Items)
- [Item-Kinds](Item-Kinds)
- [System-Strings](System-Strings)
- [Character-Dialogue](Character-Dialogue)
- [GPC2](GPC2)
