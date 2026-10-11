# Grid Composer

A script for the [monome](https://monome.org) grid running **iii**, made for live performance
and composition. It is built around a chord and arp sequencer that follows harmonic-mixing
principles, so you can move between keys instead of staying inside one fixed scale.

**[Read the manual →](https://lunanane.github.io/iii-grid-composer/)**

## What is in it

| Page | What it does |
|---|---|
| **Perform** | Mutes and transpose for every voice, three banks of eight animated faders (MIDI CC), and the scene launcher |
| **Drum Sequencer** | Six tracks with independent loop lengths and ratchets |
| **Chord/Arp** | Chords and arpeggios on a Camelot-wheel layout, an eight-stage tracker for progressions, and a procedural groove generator that shapes gate and accents for the whole instrument |
| **Mono Sequencers** | Three melodic lines locked to the lead scale, up to eight pages of 16 steps each |

The whole instrument saves to and recalls from 127 scene slots, quantised to the bar.

## What you need

- A 16×8 monome grid running the iii firmware
- A source of MIDI clock (24 PPQN) — Grid Composer follows external clock with start, continue and stop
- Something to receive MIDI on channels 1–6

## Install

1. Download **`monome_iii_c31_min.lua`**. This is the file that goes on the grid.
2. Open [diii](https://monome.org/diii) in a browser that supports Web Serial and connect the grid.
3. Upload the file and run it.

See the [iii documentation](https://monome.org/docs/iii/diii) for how to upload scripts and
set one to start automatically.

Use the `_min` file. The script has to fit a transfer limit of about 32 KB, and only the
minified build does. `monome_iii_c31.lua` is the same script with comments and readable names,
for anyone who wants to read or change it.

c31 sits only a few bytes under that limit. If the grid does not come up with c31 set to start
automatically, run it by hand from diii, or use c30, which is kept here.

## Files

| File | |
|---|---|
| `monome_iii_c31_min.lua` | **Current release** — flash this |
| `monome_iii_c31.lua` | Readable source of the current release |
| `monome_iii_c30*`, `c26*`, `c22*`, `c21*`, `*c11*` | Earlier releases, kept for reference |
| `index.html` | The manual |

## Upgrading from an earlier build

Scenes saved on earlier builds still load. New in c31:

- The sixteen velocity patterns are replaced by a procedural groove on the Chord/Arp page. It is
  off by default; older scenes come back with it off and their velocity-pattern choices ignored.
- There are three fader banks instead of five. Fader banks 4 and 5 in older scenes are ignored.
- After power-up, press a tier or archetype pad, or load a scene, before switching the
  procedural groove on for the first time. Switching it on with nothing set can stop the script.

Changed since c26 (these arrived in c30):

- Writing a tracker stage now needs a chord held in the Playing Area.
- Pad `(3,3)` of the Playing Area is C♯ major (3B). It used to repeat D♯.
- The mono step-speed row was rebuilt. Speed pads 6 and 8–11 mean what they always did; a
  scene that used another speed pad plays that line at the pad's new rate, so pick the speed
  again and re-save.

## Credits

Grid Composer is by [Luna Nane](https://lunanane.com). It is conceptually descended from
[Grid Ninja](https://github.com/tekcor/GridNinja). The manual lists the instruments and
ideas that shaped it.

## License

Copyright © 2026 Luna Nane (https://lunanane.com)

Grid Composer is released under the
[PolyForm Noncommercial License 1.0.0](LICENSE.md). You may use, copy, change and share it
for any noncommercial purpose. You may not sell it or include it in a commercial product.

**Making music with it is welcome, paid or not.** As an additional permission from the
author, performing, recording and releasing music made with Grid Composer is allowed,
including for money. The noncommercial restriction applies to the script itself.

When you share Grid Composer or a version based on it, keep this notice with it:

> Required Notice: Copyright © 2026 Luna Nane (https://lunanane.com)

For anything else, get in touch through [lunanane.com](https://lunanane.com).
