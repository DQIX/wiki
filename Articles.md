# Articles

`/data/prm/article.gp2/article_<lang>.nat` lists the articles the game puts before names, by number, and each monster and item name carries one packed word saying which articles it takes and its gender. The article numbering and the indefinite and definite singular fields are read; which plural a field holds, the gender field (INFERRED) and the top bits are not fully established.

All observations were made on the European release (game code `YDQP`).

## Article list — `article_<lang>.nat`

The file is in the [system strings](System-Strings) layout: messages by number. English has 38 articles:

| numbers | kind | examples |
|---|---|---|
| 0–5 | definite singular | `the`, `the pair of`, `the book called` … |
| 100–125 | indefinite singular | `a`, `an`, `a suit of`, `a phial of` … |
| 200–202 | definite plural | |
| 300–302 | indefinite plural | `some`, `some pairs of` |

## A name's grammar word

**A name says which article it takes**, in one packed word beside it: `+0x18` of a monster's name record (see [Monsters](Monsters)), `+0x08` of an item's (see [Items](Items)).

| bits | reading | evidence |
|---|---|---|
| 0–5 | indefinite singular, 100 + n | `an` on every English monster whose name opens with a vowel and `a` on every other, 289 of 289; 679 of 687 items the same, and the eight are English's own — `an honour among thieves`, `a utility belt` — or open with an accent's markup; `a suit of` on leather armour, `a book called` on the books |
| 6–11 | a plural article, n — the indefinite (300 + n) or the definite: which, not established | equal to bits 18–23 on every English record |
| 12–17 | definite singular, n | `the book called` on the books, `the keg of` on the kegs; 0, no article at all, on the story's named monsters |
| 18–23 | the other plural | |
| 24–25 | the name's gender, INFERRED: 0 he, 1 she, 2 it | 2 on 303 of 438 English monsters, 0 on the named men; German, whose nouns have genders, spreads its monsters across all three. The battle text's `<IF_ACTOR_M>`, `_F`, `_N` choose by it |
| 26–31 | not established | bit 26 set on 305 English items, and not on every name the plural suits |

## Not established

- Which of bits 6–11 and 18–23 is the indefinite plural and which the definite.
- Bits 26–31.

## See also

- [Monsters](Monsters)
- [Items](Items)
- [Battle-Text](Battle-Text) — the markup that uses the articles and gender
- [System-Strings](System-Strings)
