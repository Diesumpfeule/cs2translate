# cs2translate

```
  ___ ___ ___    ___ _         _
 / __/ __|_  )  / __| |_  __ _| |_
| (__\__ \/ /  | (__| ' \/ _` |  _|
 \___|___/___|  \___|_||_\__,_|\__|
        translate  →  DE
```

> ⚠ **Proof of concept, written by Claude (AI) – no warranty, use at your own risk.** See [Disclaimer](#disclaimer).

Live translation of the Counter-Strike 2 chat on **Linux and Windows 10/11**, shown as a
see-through overlay right on top of the in-game chat. Translates into German by default – any
other language works (settings window, or `--lang en`).

- **Starts by itself** when CS2 runs and stops with the game
- **Overlay** without a frame, always on top, mouse clicks go through to the game
- **Team colours** – CT blue, T orange, all chat green, original text small underneath
- Messages **fade out** after 15 seconds; an empty overlay is invisible
- **Two translation services** (Google, MyMemory) with automatic fallback
- **No extra packages** – only Python's standard library and Tkinter

> Using [swayforge](https://github.com/Diesumpfeule/swayforge)? It ships cs2translate, starts it
> from Sway and colours the overlay in your system theme – nothing to do here.

---

## Is it VAC-safe?

cs2translate does **not** touch the game. It only reads the text file `console.log`, which
CS2 writes itself when started with the official launch option `-condebug`. No memory reading,
no changed game files, no injected code, no simulated key presses. The overlay is an ordinary
window of its own.

Valve guarantees nothing for third-party tools, but tools built this way have been used openly
for years.

**Privacy:** chat messages are sent to Google or MyMemory for translation. Nothing else leaves
your PC.

## Windows 10 / 11

1. Download **`cs2translate.exe`** from the [latest release](https://github.com/Diesumpfeule/cs2translate/releases/latest)
   and put it somewhere it can stay (e.g. `Documents\cs2translate`). No Python needed.
2. **Steam launch option:** CS2 → right-click → *Properties → General → Launch options*: `-condebug`
3. **Display mode:** in CS2 under *Video* set **Fullscreen Windowed** (Windows hides every overlay
   in exclusive fullscreen).
4. **Double-click `cs2translate.exe`.** A small settings window opens: language, font size, width,
   how long messages stay, opacity, original text on/off and **Start with Windows** (on by
   default). Press *Save & close*.
5. Start CS2 once and click **Position overlay …** in the settings to drag the overlay over the
   CS2 chat (Esc to finish – the position is saved).

From then on it runs quietly in the background and shows the overlay **only while CS2 runs**.
Clicks go through the overlay into the game, and it never takes focus. To change settings,
double-click the exe again. To stop it starting with Windows, untick *Start with Windows*.

Settings are stored in `%APPDATA%\cs2translate\config.json`. Windows SmartScreen may warn about
an "unknown publisher" the first time, because the exe isn't code-signed. Click *More info → Run
anyway*, or build it yourself from `cs2translate.py` with PyInstaller (see
`.github/workflows/windows.yml`). Every release is built by GitHub Actions straight from this
repository.

## Install on Linux

1. **Tkinter** (for the overlay window):
   ```sh
   sudo dnf install python3-tkinter     # Fedora
   sudo apt install python3-tk          # Debian / Ubuntu / Mint
   sudo pacman -S tk                    # Arch
   ```
2. **Steam launch option:** CS2 → right-click → *Properties → General → Launch options*:
   ```
   -condebug
   ```
3. **Install:**
   ```sh
   git clone https://github.com/Diesumpfeule/cs2translate.git && cd cs2translate
   bash install.sh
   ```
4. **Display mode:** in CS2 under *Video* set **Fullscreen windowed**. Nothing can be drawn over
   exclusive fullscreen.
5. **Position it** – once, while CS2 runs:
   ```sh
   python3 ~/.local/share/cs2translate/cs2translate.py --move
   ```
   Drag the sample overlay over the CS2 chat, close with `Esc`. The position is saved.

Done. From now on just start CS2 – the logo shows briefly, then the translator is ready.

## How it works

```
login
  └─ watcher starts (autostart, uses almost nothing)
       └─ waits for a process called "cs2"
            └─ starts the translator
                 └─ reads new lines from console.log
                      └─ finds chat lines → translates → shows them in the overlay
       └─ CS2 closed → translator stops
```

`install.sh` uses an XDG autostart entry (`~/.config/autostart`). GNOME, KDE, Xfce & co.
run it; tiling WMs like Sway or i3 don't – start `~/.local/bin/cs2translate-watcher` from
your WM config instead (or use swayforge).

## Options

Start by hand, e.g. for testing:

```sh
python3 ~/.local/share/cs2translate/cs2translate.py [options]
```

| Option | Effect | Default |
|---|---|---|
| `--move` | position the overlay with the mouse | |
| `--x 20 --y 400` | position in pixels | saved |
| `--width 600` | overlay width | 520 |
| `--font-size 14` | font size | 12 |
| `--lines 8` | max. messages shown at once | 6 |
| `--duration 20` | seconds until a message disappears | 15 |
| `--alpha 0.5` | transparency (0.2 = very see-through, 1.0 = solid) | 0.7 |
| `--no-original` | hide the grey original text | |
| `--lang en` | target language | de |
| `--history 0` | old messages shown at start (0 = none) | 5 |
| `--window` | normal window instead of overlay | |
| `--terminal` | terminal output only, no window | |
| `--debug` | shows **every** new log line | |
| `--log "PATH"` | path to `console.log` (in quotes!) | auto-detected |
| `--settings` | settings window (what a double-click on the Windows exe opens) | |
| `--watch` | stay in the background, overlay only while CS2 runs | |
| `--autostart on/off` | Windows: start the watcher at login | |
| `--test` | show the overlay with sample messages | |

Values saved in the settings window become the defaults; options on the command line still win.

For the automatic start, add options to the watcher: `~/.local/bin/cs2translate-watcher`,
the line with `--history 0` – e.g. `--history 0 --font-size 14 --no-original`.

## Customizing

**Colours and font** → `~/.config/cs2translate.json` (next to the saved position).
Missing values use the defaults:

```json
{
  "x": 20, "y": 430,
  "theme": {
    "bg": "#0b0b0b", "text": "#ffffff", "orig": "#8a8a8a",
    "ct": "#6fb6ff", "t": "#f2b84b", "all": "#9be37a", "logo": "#9be37a",
    "font": "DejaVu Sans", "mono": "DejaVu Sans Mono"
  }
}
```

**Everything else** is in `cs2translate.py`:

| What | Where |
|---|---|
| Logo | `LOGO = r"""` at the top (keep the `r`!) – make your own with `figlet -f small "Text"` |
| How long the logo stays | `LOGO_SECONDS = 4` |
| Default transparency | `"--alpha"` … `default=0.7` in `main` |

Check the file after editing, then run `bash install.sh` again:

```sh
python3 -m py_compile cs2translate.py     # no output = fine
```

> Transparency applies to the whole overlay including the text – Tkinter on Linux can't make
> only the background see-through.

## Troubleshooting

Everything is logged to `~/.cache/cs2translate.log`.

| Problem | Fix |
|---|---|
| No "CS2 detected" line in the log | Is the watcher running? `pgrep -af cs2translate-watcher`. Otherwise run `bash install.sh` again or log in again. |
| "Waiting for console.log" | `-condebug` is missing, or CS2 is in another Steam library → `--log "PATH"`. Find it: `find / -name console.log -path "*csgo*" 2>/dev/null` |
| Overlay doesn't show | Display mode *Fullscreen windowed*? `python3-tkinter` installed? |
| Overlay is behind the game | Some Wayland desktops ignore "always on top". CS2 usually runs through XWayland, where it works. Otherwise try `--fenster`. |
| "translation failed" | A service blocked you for a moment (common with VPNs). It switches automatically and retries after a minute. |
| Messages aren't detected | Start with `--debug --terminal`, write in game and look at what the line looks like. |
| CS2 won't start anymore | The launch options must contain **only** `-condebug` (or `… %command% -condebug`). |

## Uninstall

```sh
bash uninstall.sh
```

Then remove `-condebug` from the CS2 launch options if you don't need it anymore.

## Files

```
cs2translate.py    the program
install.sh         installs it + the watcher and autostart (also replaces the old German version)
uninstall.sh       removes everything again
```

## Credits & notes

- Translation uses Google Translate's **unofficial** `translate_a` endpoint, with
  [MyMemory](https://mymemory.translated.net) as fallback. Neither is an official API for
  third-party tools – they can block, rate-limit or change at any time, and their terms apply.
  Chat messages are sent to these services.
- Not affiliated with Valve. Counter-Strike 2 is a trademark of Valve Corporation.

## Disclaimer

**This is a proof of concept** – not finished, not polished and not tested on every setup.
The code was written by **Claude**, an AI model by Anthropic, following my ideas and
instructions. It is provided **as is, without any warranty**, and I take **no responsibility**
for anything it does to your system, your data or your accounts. Read the scripts before you
run them – use at your own risk.

## Contributions

This is a personal project: pull requests and outside code are not accepted. Feel free to fork it.

## License

MIT – see [LICENSE](LICENSE).
