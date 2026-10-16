#!/bin/bash
# Installiert den CS2 Chat-Übersetzer mit einem kleinen Wächter:
# Er startet mit deiner Anmeldung, wartet auf CS2, startet dann den Übersetzer
# und beendet ihn wieder, wenn CS2 geschlossen wird. Steam wird nicht verändert.
#
# Ausführen im Ordner, in dem cs2_chat_uebersetzer.py liegt:
#     bash installieren.sh
set -e

HIER="$(cd "$(dirname "$0")" && pwd)"
ZIEL="$HOME/.local/share/cs2-chat-uebersetzer"
WAECHTER="$HOME/.local/bin/cs2-uebersetzer-waechter"
AUTOSTART="$HOME/.config/autostart/cs2-chat-uebersetzer.desktop"

if [ ! -f "$HIER/cs2_chat_uebersetzer.py" ]; then
    echo "cs2_chat_uebersetzer.py nicht gefunden. Lege installieren.sh in denselben Ordner."
    exit 1
fi

mkdir -p "$ZIEL" "$HOME/.local/bin" "$HOME/.cache" "$HOME/.config/autostart"
cp "$HIER/cs2_chat_uebersetzer.py" "$ZIEL/"

# Altes Steam-Startskript aus der vorigen Version entfernen
rm -f "$HOME/.local/bin/cs2-uebersetzer-start"

cat > "$WAECHTER" <<EOF
#!/bin/bash
# Wartet auf CS2 und startet/beendet den Übersetzer passend dazu.
LOG="\$HOME/.cache/cs2_chat_uebersetzer.log"
while true; do
    until pgrep -x cs2 >/dev/null; do sleep 5; done
    echo "\$(date '+%F %T') CS2 erkannt, starte Übersetzer" >>"\$LOG"
    python3 "$ZIEL/cs2_chat_uebersetzer.py" --verlauf 0 >>"\$LOG" 2>&1 &
    UEB=\$!
    while pgrep -x cs2 >/dev/null && kill -0 "\$UEB" 2>/dev/null; do sleep 3; done
    kill "\$UEB" 2>/dev/null
    wait "\$UEB" 2>/dev/null
    echo "\$(date '+%F %T') Übersetzer beendet" >>"\$LOG"
    # Falls der Übersetzer abgestürzt ist: nicht sofort neu starten, sondern warten bis CS2 zu ist
    while pgrep -x cs2 >/dev/null; do sleep 5; done
done
EOF
chmod +x "$WAECHTER"

cat > "$AUTOSTART" <<EOF
[Desktop Entry]
Type=Application
Name=CS2 Chat Übersetzer (Wächter)
Comment=Startet den Chat-Übersetzer automatisch, wenn CS2 läuft
Exec=$WAECHTER
X-GNOME-Autostart-enabled=true
NoDisplay=true
EOF

# Wächter jetzt sofort starten (alte Instanz vorher beenden)
pkill -f "$WAECHTER" 2>/dev/null || true
nohup "$WAECHTER" >/dev/null 2>&1 &
disown

if ! python3 -c "import tkinter" 2>/dev/null; then
    echo "Hinweis: python3-tkinter fehlt noch:  sudo dnf install python3-tkinter"
    echo
fi

echo "Fertig. Der Wächter läuft und startet ab jetzt bei jeder Anmeldung automatisch."
echo
echo "In Steam bei CS2 -> Eigenschaften -> Startoptionen soll NUR stehen:"
echo "    -condebug"
echo
echo "Meldungen: $HOME/.cache/cs2_chat_uebersetzer.log"
echo "Deinstallieren:  rm $AUTOSTART $WAECHTER; pkill -f cs2-uebersetzer-waechter"
