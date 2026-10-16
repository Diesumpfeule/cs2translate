#!/bin/bash
# Installs cs2translate with a small watcher: it starts with your login, waits for CS2,
# starts the translator and stops it again when CS2 closes. Steam isn't changed.
#
# Run in the folder that contains cs2translate.py:
#     bash install.sh
set -e

HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.local/share/cs2translate"
WATCHER="$HOME/.local/bin/cs2translate-watcher"
AUTOSTART="$HOME/.config/autostart/cs2translate.desktop"
LOG="$HOME/.cache/cs2translate.log"

if [ ! -f "$HERE/cs2translate.py" ]; then
    echo "cs2translate.py not found. Put install.sh in the same folder."
    exit 1
fi

mkdir -p "$DEST" "$HOME/.local/bin" "$HOME/.cache" "$HOME/.config/autostart"
cp "$HERE/cs2translate.py" "$DEST/"

# Remove the old German version (cs2-chat-uebersetzer) if it's there
pkill -f "$HOME/.local/bin/cs2-uebersetzer-waechter" 2>/dev/null || true
rm -f "$HOME/.local/bin/cs2-uebersetzer-waechter" "$HOME/.local/bin/cs2-uebersetzer-start" \
      "$HOME/.local/bin/cs2-uebersetzer" "$HOME/.config/autostart/cs2-chat-uebersetzer.desktop"
rm -rf "$HOME/.local/share/cs2-chat-uebersetzer"
[ -f "$HOME/.config/cs2_chat_uebersetzer.json" ] && [ ! -f "$HOME/.config/cs2translate.json" ] && \
    mv "$HOME/.config/cs2_chat_uebersetzer.json" "$HOME/.config/cs2translate.json"

cat > "$WATCHER" <<EOW
#!/bin/bash
# Waits for CS2 and starts/stops the translator with it.
LOG="$LOG"
while true; do
    until pgrep -x cs2 >/dev/null; do sleep 5; done
    echo "\$(date '+%F %T') CS2 detected, starting translator" >>"\$LOG"
    python3 "$DEST/cs2translate.py" --history 0 >>"\$LOG" 2>&1 &
    TR=\$!
    while pgrep -x cs2 >/dev/null && kill -0 "\$TR" 2>/dev/null; do sleep 3; done
    kill "\$TR" 2>/dev/null
    wait "\$TR" 2>/dev/null
    echo "\$(date '+%F %T') translator stopped" >>"\$LOG"
    # if it crashed: don't restart in a loop, wait until CS2 is closed
    while pgrep -x cs2 >/dev/null; do sleep 5; done
done
EOW
chmod +x "$WATCHER"

cat > "$AUTOSTART" <<EOA
[Desktop Entry]
Type=Application
Name=cs2translate watcher
Comment=Starts the CS2 chat translator automatically while CS2 runs
Exec=$WATCHER
X-GNOME-Autostart-enabled=true
NoDisplay=true
EOA

# start the watcher now (replace an old one)
pkill -f "$WATCHER" 2>/dev/null || true
nohup "$WATCHER" >/dev/null 2>&1 &
disown

if ! python3 -c "import tkinter" 2>/dev/null; then
    echo "Note: python3-tkinter is missing:  sudo dnf install python3-tkinter"
    echo
fi

echo "Done. The watcher runs now and starts with every login."
echo "(GNOME, KDE, Xfce … use the autostart entry. Sway/i3: add  exec $WATCHER  to your config.)"
echo
echo "In Steam, CS2 -> Properties -> Launch options must contain:"
echo "    -condebug"
echo
echo "Log: $LOG"
echo "Uninstall: bash uninstall.sh"
