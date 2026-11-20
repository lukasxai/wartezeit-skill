#!/bin/bash
# Kopiert die Wartezeit-Dateien nach ~/.claude/wartezeit.
# Eigene Einstellungen (config.js, feeds.txt, einstellungen.conf) bleiben bei einem Update erhalten.
# Die Hooks in ~/.claude/settings.json trägt dieses Skript NICHT ein: das macht Claude danach, mit Sicherung.
set -e
QUELLE="$(cd "$(dirname "$0")/../vorlage" && pwd)"
ZIEL="${WARTEZEIT_DIR:-$HOME/.claude/wartezeit}"
mkdir -p "$ZIEL"
for f in hook.sh dashboard.html glocke.wav hooks.json; do cp "$QUELLE/$f" "$ZIEL/$f"; done
for f in config.js feeds.txt einstellungen.conf; do
  if [ -f "$ZIEL/$f" ]; then echo "behalten:   $f"; else cp "$QUELLE/$f" "$ZIEL/$f"; echo "neu:        $f"; fi
done
chmod +x "$ZIEL/hook.sh"
echo "installiert in: $ZIEL"
bash "$ZIEL/hook.sh" status
