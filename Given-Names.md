# Given Names

The names a made character's last creation screen offers to roll from, and its keyboard. Observations are from the European release (game code `YDQP`); `str_cm` and the three keyboard files are byte for byte the same in the US release (`YDQE`).

## The names

`/data/bin/menu/str_cm.gp2`, `str_cm_<lang>.nat`, [system strings](System-Strings): **20000–20100 a man's names and 21000–21100 a woman's**, 101 of each in English — "Irving", "Armin" … "Wayne"; "Iris" … "Wanda". Strings 0 on name the creation screens' own files (`data/ani/bg_cm_ms.gp2`, `bg_cm_sx.gp2`, `bg_cm_fig_m.gp2` …).

**Eight letters at most**: the name screen in a let's play is "8 Name", its field eight slots.

## The keyboard

`/data/bin/keyboard_cm.bin`, 7,216 bytes, a loose [tagged data table](Tagged-Data-Table): one `0x65` record a key, each with its place on the 256 × 192 bottom screen and two of the game's own character codes — for a letter, its two cases, INFERRED. Which code is which letter is not established; the let's play's keyboard (QWERTY, with a case key, accents and symbols) shows which letter sits at each place, which would settle it without a guess. `keyboard_cs.bin` (7,264 bytes) and `keyboard_pr.bin` (7,248) sit beside it, not read.

## See also

- [Character presets](Character-Presets)
