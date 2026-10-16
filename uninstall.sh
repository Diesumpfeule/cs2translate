#!/bin/bash
# Removes cs2translate completely (also the old German cs2-chat-uebersetzer).
#     bash uninstall.sh

pkill -f "$HOME/.local/bin/cs2translate-watcher" 2>/dev/null
pkill -f "$HOME/.local/bin/cs2-uebersetzer-waechter" 2>/dev/null
pkill -f "cs2translate.py" 2>/dev/null
pkill -f "cs2_chat_uebersetzer.py" 2>/dev/null

rm -f  "$HOME/.config/autostart/cs2translate.desktop" "$HOME/.config/autostart/cs2-chat-uebersetzer.desktop"
rm -f  "$HOME/.local/bin/cs2translate-watcher" "$HOME/.local/bin/cs2-uebersetzer-waechter" \
       "$HOME/.local/bin/cs2-uebersetzer-start"
rm -rf "$HOME/.local/share/cs2translate" "$HOME/.local/share/cs2-chat-uebersetzer"
rm -f  "$HOME/.cache/cs2translate.log" "$HOME/.cache/cs2_chat_uebersetzer.log"

echo "Uninstalled."
echo "The saved overlay position is still in ~/.config/cs2translate.json"
echo "(delete with: rm ~/.config/cs2translate.json)"
echo "Remember to remove -condebug from the CS2 launch options in Steam if you don't need it anymore."
