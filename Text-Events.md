# Text events

The tags in the game's text that **make the game do something** — open a
service, start a quest banner, play a sound, turn the speaker, ask a question
— as opposed to the ones that only shape what is drawn. One line each; the
evidence for each, with its addresses, is on [Text markup](Text-Markup), and
this page links there rather than repeating it.

> **USA only** for the code, read through the
> [dqix-decomp](https://github.com/DQIX/dqix-decomp). **EU only** for the
> text quoted and the counts, from the European release's English files.

## Services — a talk line hands over

A talk line that ends with one of these opens a service when its box closes.
They are not compiled into the message at all: `func_0206f550` reads them off
the line and strips them, a tag's place in its table at `0x020f0afc` being
its **facility code** — see
[Services in talk](Text-Markup#services-in-talk--the-facility-tags) for the
code, the table of where each flow begins, and the counts.

| tag | code | what it opens | in the game's own words |
|---|---|---|---|
| `<INN=n>` | 1 | **an inn**: stay the night, or rest until evening, one price for either by the beds wanted | "You wish to stay the night, or merely to rest until evening? Either service costs a highly reasonable `<val_2>` gold coins" — 181 innkeepers' lines; "There are `<val_1>` of you in need of a bed" |
| `<CHURCH=n>` | 2 | **a church** | its priests' own talk lines; the service's words are not established |
| `<BANK>` | 3 | **the bank**: Deposit, Withdrawal, Leave — Ginny's Rainbow's End Gold Bank at the Quester's Rest | `str_bank`: "We accept deposits in units of one thousand gold coins" |
| `<SHOP=n>` | 4 | **a shop**, the stock named by *n* (see [Items](Items#services-in-talk--shopn-innn-churchn)) | `str_s00`–`str_s04`, the shopkeepers' lines: "You're here to buy today, are you?" |
| `<LUIDA>` | 5 | **Patty's Party Planning Place**, mode 0 — see [Party](Party#recruitment--pattys-party-planning-place) | `str_lui`, `bm_lui` |
| `<RIKKA>` | 6 | **the Quester's Rest counter**: Stay at the inn, Canvass for guests, View the guestbook, Leave | `str_rkm`; `str_rki`: "Would you like to stay the whole night or just rest until evening?" |
| `<RENKIN>` | 7 | **the Krak Pot**, alchemy — see [Alchemy](Alchemy) | `str_ren` |
| `<LAVIELL>` | 8 | **Patty's flow, mode 1**: INFERRED **the Rapportal**, Pavo's | `str_lav` holds Pavo's lines: "I alone open the door of fate… Then I shall open the Rapportal for you." Which file mode 1 loads is not traced |
| `<DAMA>` | 9 | **Alltrades Abbey**, Jack of Alltrades: change vocation, revocation — see [Party](Party#changing-vocation-alltrades-abbey) | `str_dam`, `bm_dama` |
| `<DAMA_SATORI>` | 10 | **Alltrades Abbey, mode 1**: the same change, said by the "Voice of Vocation", HP and MP kept in proportion | `str_dam` 26–34, 50, 51 |
| `<ARKSANDY>` | 11 | **the Starflight Express** — see [Starflight Express](Starflight-Express) | `str_ark`, its stops: "The Observatory", "Alltrades Abbey", "The Realm of the Almighty", … |
| `<RIKKAFIRST>` | 12 | **the Quester's Rest counter**, as `<RIKKA>`; INFERRED from the name, the first visit | — |

The tags carry the Japanese names: ルイーダ, Patty's tavern; リッカ, the
Quester's Rest's keeper (INFERRED Erinn in the English release); ダーマ, the
Abbey; アークザンディ, the Express. **Four appear in no English talk line**:
`<LAVIELL>`, `<DAMA_SATORI>`, `<ARKSANDY>` and `<RIKKAFIRST>`. The Express is
reached by a trigger's action instead.

A character can also open a service with no tag, by a trigger's
[operation 145](Triggers), which numbers its own: Cap'n Max's
[mini medals](Mini-Medals) are 7 there.

## Quests

See [The quest family](Text-Markup#the-quest-family) and [Quests](Quests).

| tag | what it does |
|---|---|
| `<QUEST=n>` | binds quest *n* to the message window; only the last in a message counts |
| `<QUEST_HAN>` | opens the quest banner over the bound quest, with sound `0x33` |
| `<QUEST_FAILED>` | the same, marked failed, with sound `0x44` |
| `</QUEST>` | closes the banner |
| `<QUEST_SE>` | records the quest's progress word and asks for the fanfare, sound `0x32` |

What the banner looks like, and what `HAN` abbreviates, are not established.

## Gameplay

| tag | what it does |
|---|---|
| `<ALL_RECOVER=a,b,c>` | **a gameplay action written as a message**: three values to the window, then a call into an overlay — one event's whole English message is `<ALL_RECOVER=0,0,999>`. What `a` and `b` select is not established. See [Text markup](Text-Markup#what-the-codes-do) |

## Sound

| tag | what it does |
|---|---|
| `<ME_n>` | asks for a jingle, **id `n + 49`** — `<ME_008>` is 57 |
| `<SE_n>` | asks for **id 14**, whatever *n* says; `<SE_014>` is the only one the English text uses |
| `<EXC>`, `<QES>` | sound 6 or 28, with a balloon (below) |

What those ids index is not established. See
[`<ME_n>` and `<SE_n>`](Text-Markup#what-the-codes-do).

## The speaker, and the scene

**Every message turns its speaker to face the player** unless it says
otherwise; these say otherwise. See
[The two parsers](Text-Markup#the-two-parsers) and
[What the codes do](Text-Markup#what-the-codes-do).

| tag | what it does |
|---|---|
| `<N_TURN>` | the speaker does **not** turn: their facing is kept |
| `<TURN_P>` | turns to face the party leader |
| `<TURN=n>` | turns to an absolute angle, *n* radians |
| `<R_TURN>` | turns back to where they faced when the talk began, and waits |
| `<END_R_TURN>` | ends the message and turns back, without waiting |
| `<EXC>` | a `!` balloon over them for a second (INFERRED from the name) |
| `<QES>` | a `?` balloon the same way (INFERRED) |
| `<SHAKE>` | shakes the message window — not the screen — for 30 frames |

## Questions

| tag | what it does |
|---|---|
| `<YESNO>` | asks Yes or No; the answer's branch begins after `<YES>` or `<NO>` |
| `<UKEYAME>` | asks Accept or Decline; branches `<UKE>` and `<YAME>` |
| `<NOYES>`, `<YESNO_NOTSE>`, `<YESNO_NOTSE_IIE>` | prompts too, by their codes beside `<YESNO>`; how each differs is not read |
| `<LB_x>`, `<JP_x>` | a label, and a jump to it, `x` one letter |

## The message's own pace

| tag | what it does |
|---|---|
| `<END>` | ends the message |
| `<CLOSE>` | its own code beside `<END>`; what it does differently is not read here |
| `<ADD>` | **ends the message and leaves the window standing**, so the next is drawn into it — not an "add". Also how a talk line leads into a service |
| `<PAGE>` | a new page, after a button |
| `<PAGE_T=n>` | a new page after a time; only the last in a message counts |
| `<PAD_WAIT>`, `<PAD_WAIT_NOCUR>` | wait for a button, with or without the cursor |
| `<PAD_T=n>` | its own code; not read here |
| `<TIME=n>` | holds the text for *n* ticks — a pause, not a speed |
| `<AUTO=n>` | the typing speed; only the last in a message counts |

## Not events

The window's own shape and look — `<WIN>`, `<CEN>`, `<GYOU=n>`, `<MOJI=w,h>`,
`<COLOR=…>`, `<RECT=…>`, `<WIN_ON>`/`<WIN_OFF>`, `<CEN_ON>`/`<CEN_OFF>` — and
the values the engine fills in — `<val_n>`, `<str_n>`, `<TARGET>`, `<ACTOR>`,
`<LEADER>`, `<Cap>`, the item and article tags — are on
[Text markup](Text-Markup) and [Articles](Articles).
