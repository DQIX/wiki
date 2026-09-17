# System Strings

`/data/bin/strstd.gp2/strstd_<lang>.nat` holds the engine's own short messages, by number. The same layout — a head word, then (number, offset) records, then strings — is shared by several other message files. The layout is confirmed on all five languages; a handful of messages are identified.

All observations were made on the European release (game code `YDQP`).

## Layout

| part | contents |
|---|---|
| head word | low 12 bits the record count, 81; upper 20 bits the string section's size — 2,225 bytes in English, 2,486 in German |
| records | 81 records of two `u32`s: a message number and its offset from the strings |
| strings | running exactly to the end of the file |

The head word is the same packing as the monster list's (see [Monsters](Monsters)).

The numbers skip — 0 to 69, 83 to 86, 200 to 202, 1000 on — and are the same in all five languages. Every offset lands at the start of a string.

### Other files in this layout

- `actname.nat` — action names by number; see [Actions](Actions).
- `/data/prm/article.gp2/article_<lang>.nat` — see [Articles](Articles).
- `strbtl`, `actmsg`, `str_tm` — see [Battle-Text](Battle-Text).

## Messages

| number | message |
|---|---|
| 27–30 | "Yes", "No", "Accept", "Decline" |
| 42 | "Oh no! The chest was really `<str_1>`!" |
| 46–48 | "a cannibox", "a mimic", "a Pandora's box" |
| 57 | a head banged on the ceiling |

The strings around the chest run "Oh no! The chest was really `<str_1>`!" · "`<ACTOR>` unlocks the chest." · "It's empty!" · "a cannibox" · "a mimic" · "a Pandora's box". Messages 46 to 48 are the three chest monsters with their article — each "a " and a name in the monster list, so the phrase for a monster is found by its name. See [Treasure](Treasure).

**27 to 30 are "Yes", "No", "Accept", "Decline"**, in the order the prompts' answers are read in — which backs the markup codes `<UKE>` and `<YAME>` as accept and decline (see [Event-Text](Event-Text)).

## Earlier readings

An earlier reading took the head word's low half as a count of 139 and 8-byte records from there, and found the offsets landing mid-word. It was the same packing as the monster list's, misread: low 12 bits count, upper 20 bits string size.

## See also

- [Monsters](Monsters) — the same head word
- [Battle-Text](Battle-Text)
- [Articles](Articles)
- [Actions](Actions)
- [Treasure](Treasure)
- [Event-Text](Event-Text)
