#!/bin/bash
# Entfernt den CS2 Chat-Übersetzer wieder vollständig.
#     bash deinstallieren.sh

pkill -f "$HOME/.local/bin/cs2-uebersetzer-waechter" 2>/dev/null
pkill -f "$HOME/.local/share/cs2-chat-uebersetzer/cs2_chat_uebersetzer.py" 2>/dev/null

rm -f  "$HOME/.config/autostart/cs2-chat-uebersetzer.desktop"
rm -f  "$HOME/.local/bin/cs2-uebersetzer-waechter"
rm -f  "$HOME/.local/bin/cs2-uebersetzer-start"
rm -rf "$HOME/.local/share/cs2-chat-uebersetzer"
rm -f  "$HOME/.cache/cs2_chat_uebersetzer.log"

echo "Deinstalliert."
echo "Die gespeicherte Overlay-Position liegt noch in ~/.config/cs2_chat_uebersetzer.json"
echo "(löschen mit: rm ~/.config/cs2_chat_uebersetzer.json)"
echo "Vergiss nicht, in Steam die Startoption -condebug zu entfernen, falls du sie nicht mehr brauchst."
