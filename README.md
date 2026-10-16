# cs2translate

```
  ___ ___ ___    ___ _         _
 / __/ __|_  )  / __| |_  __ _| |_
| (__\__ \/ /  | (__| ' \/ _` |  _|
 \___|___/___|  \___|_||_\__,_|\__|
        Übersetzer  →  Deutsch
```

Live translation of the Counter-Strike 2 chat on Linux, shown as a see-through overlay right
on top of the in-game chat. Translates into German by default – any other language works
with `--lang`.

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

## Install

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
   bash installieren.sh
   ```
4. **Display mode:** in CS2 under *Video* set **Fullscreen windowed**. Nothing can be drawn over
   exclusive fullscreen.
5. **Position it** – once, while CS2 runs:
   ```sh
   python3 ~/.local/share/cs2-chat-uebersetzer/cs2_chat_uebersetzer.py --verschieben
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

`installieren.sh` uses an XDG autostart entry (`~/.config/autostart`). GNOME, KDE, Xfce & co.
run it; tiling WMs like Sway or i3 don't – start `~/.local/bin/cs2-uebersetzer-waechter` from
your WM config instead (or use swayforge).

## Options

Start by hand, e.g. for testing:

```sh
python3 ~/.local/share/cs2-chat-uebersetzer/cs2_chat_uebersetzer.py [options]
```

| Option | Effect | Default |
|---|---|---|
| `--verschieben` | position the overlay with the mouse | |
| `--x 20 --y 400` | position in pixels | saved |
| `--breite 600` | overlay width | 520 |
| `--schrift 14` | font size | 12 |
| `--zeilen 8` | max. messages shown at once | 6 |
| `--dauer 20` | seconds until a message disappears | 15 |
| `--alpha 0.5` | transparency (0.2 = very see-through, 1.0 = solid) | 0.7 |
| `--ohne-original` | hide the grey original text | |
| `--lang en` | target language | de |
| `--verlauf 0` | old messages shown at start (0 = none) | 5 |
| `--fenster` | normal window instead of overlay | |
| `--terminal` | terminal output only, no window | |
| `--alles` | debug mode: shows **every** new log line | |
| `--log "PATH"` | path to `console.log` (in quotes!) | auto-detected |

For the automatic start, add options to the watcher: `~/.local/bin/cs2-uebersetzer-waechter`,
the line with `--verlauf 0` – e.g. `--verlauf 0 --schrift 14 --ohne-original`.

## Customizing

**Colours and font** → `~/.config/cs2_chat_uebersetzer.json` (next to the saved position).
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

**Everything else** is in `cs2_chat_uebersetzer.py`:

| What | Where |
|---|---|
| Logo | `LOGO = r"""` at the top (keep the `r`!) – make your own with `figlet -f small "Text"` |
| How long the logo stays | `LOGO_SEKUNDEN = 4` |
| Default transparency | `"--alpha"` … `default=0.7` in `main` |

Check the file after editing, then run `bash installieren.sh` again:

```sh
python3 -m py_compile cs2_chat_uebersetzer.py     # no output = fine
```

> Transparency applies to the whole overlay including the text – Tkinter on Linux can't make
> only the background see-through.

## Troubleshooting

Everything is logged to `~/.cache/cs2_chat_uebersetzer.log`.

| Problem | Fix |
|---|---|
| No "CS2 erkannt" line in the log | Is the watcher running? `pgrep -af waechter`. Otherwise run `bash installieren.sh` again or log in again. |
| "Warte auf console.log" | `-condebug` is missing, or CS2 is in another Steam library → `--log "PATH"`. Find it: `find / -name console.log -path "*csgo*" 2>/dev/null` |
| Overlay doesn't show | Display mode *Fullscreen windowed*? `python3-tkinter` installed? |
| Overlay is behind the game | Some Wayland desktops ignore "always on top". CS2 usually runs through XWayland, where it works. Otherwise try `--fenster`. |
| "Übersetzung fehlgeschlagen" | A service blocked you for a moment (common with VPNs). It switches automatically and retries after a minute. |
| Messages aren't detected | Start with `--alles --terminal`, write in game and look at what the line looks like. |
| CS2 won't start anymore | The launch options must contain **only** `-condebug` (or `… %command% -condebug`). |

## Uninstall

```sh
bash deinstallieren.sh
```

Then remove `-condebug` from the CS2 launch options if you don't need it anymore.

## Files

```
cs2_chat_uebersetzer.py    the program
installieren.sh            installs it + the watcher and autostart
deinstallieren.sh          removes everything again
```

The program's messages and option names are in German.

## License

MIT – see [LICENSE](LICENSE).
