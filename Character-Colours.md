# Character Colours

How a made character's skin, eyes and brows are coloured: fresh colours written over a part's palette, the texels left alone. The colours are `/data/chara/palette.bin`, a [tagged data table](Tagged-Data-Table) the game runs as a script. **Read from the game's code** (US addresses) as well as its bytes; observations of the file are from the European release (game code `YDQP`), whose `palette.bin` and every file under `data/chara` are byte for byte the US release's (`YDQE`).

## The file is a script

`func_02099cb8` loads `data/chara/palette.bin` with `LoadFileIntoMemory` and runs it with `Script::Execute` against an opcode table at `0x020f1574`: six `{tag, handler}` pairs, then a zero pair. Each handler reads its record's values with `Script::Parameter::ToInt` and stores each as a **halfword**, in rows, into a table of its own. The tables stand back to back from `0x02109928`.

| tag | handler | table | rows × each | what it is |
|---|---|---|---|---|
| `0x64` | `0x02099ac4` | `0x02109928` | 10 × 2 | brows, a pair per hair colour |
| `0x65` | `0x02099b20` | `0x02109950` | 8 × 2 | skin, two shades a tone |
| `0x66` | `0x02099b7c` | `0x02109970` | 8 × 4 | skin, four shades a tone |
| `0x67` | `0x02099bd8` | `0x021099b0` | 8 × 8 | skin, eight shades a tone |
| `0x68` | `0x02099c34` | `0x02109a30` | 8 × 2 | eyes, a pair per colour |
| `0x69` | `0x02099c90` | `0x02109a50` | 1 | not established |

**Added 1 October 2026, from the USA release's code in the decomp:** the loader is called once, from `main` at `0x02000eac`. It first clears exactly `0x12c` bytes from `0x02109928`, which the six tables fill exactly, and it loads and runs the file under the background loader's global lock.

Colours are BGR555. The skin rows run pale to dark by tone, each ramp light to dark by shade; the eye pairs are greys, browns, red, gold, green, blue and purple.

## Where they go

`func_020730e0` recolours a character part by part, by a part index 0–7 taken from the ten part numbers at the start of the character record's `+0x488` block (`func_02072afc`; index 4 repeats index 3's number).

- **The face, index 2** — `func_02099e18(model, skin, hair colour, eye colour)` copies into the start of the face's palette data, from byte offsets `{4, 8, 16}` (`0x020e8e20`) with lengths `{4, 4, 16}` (`0x020e8e14`): **the brow pair at slots 2–3, the eye pair at 4–5, the tone's eight shades at 8–15.** Every face palette on the cartridge holds brow pair 0 at slot 2, eye pair 0 at 4–5, and tone 3's eight shades at 8–15, seven of eight to the bit: the colours they are painted in.
- **Indices 0, 1, 5, 6, 7** — `func_02099d34(model, kind, tone, 4)`: `kind` 1, 2 or 4 picks the two-, four- or eight-shade table, and the tone's ramp is copied to byte offset 4 (slot 2) of **every** 32-byte palette in the model's TEX0. Index 4 the same at byte 16, slot 8. Index 3 is skipped. The body parts' own palettes hold a four-shade ramp at slots 2–5, even the clothing's.
- **`kind` comes from the item worn, not the part.** `func_020de2a4` reads a four-bit field from a record found by part number among eleven at `+0x194` (`func_02083554`): bits 15–18 of its first word for a man, 23–26 for a woman; 1, 2 or 4, or 0 for none.

## The appearance fields

From the same caller: the **skin tone is bits 1–3** of the appearance record's `+0x14` byte, the **eye colour bits 4–7**, and the **hair colour the low four bits of `+0x15`**. Bit 0 of `+0x14` is the sex.

**EU only:** overlay 15 holds a debug viewer whose labels name the appearance's knobs: `[Gender] [Face] [Eye Colour] [Skin Colour] [Hairstyle] [Hair Colour]`, then seven equipment slots, then `[Build]`. Read in the European release's overlay; not yet checked on the US release (`YDQE`).

## Not established

- What `0x69`'s value is read by.
- Which file fills the eleven part records `func_020de2a4` reads, so how many skin shades each worn item takes.
- Which of the character's parts each index 0–7 is, beyond the face (2).

## See also

- [Character parts](Character-Parts), [Character presets](Character-Presets)
