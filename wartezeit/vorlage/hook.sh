#!/bin/bash
# Wartezeit: öffnet ein Dashboard, solange Claude Code arbeitet, und schließt es danach wieder.
#
# Aufruf durch die Hooks in ~/.claude/settings.json (Daten kommen über stdin):
#   hook.sh auftrag | schritt | helfer-start | helfer-fertig | frage | fertig | ende
# Von Hand:
#   hook.sh test     kurzer Probelauf: Fenster auf, Beispiel-Aufgabe, Glocke, Fenster zu
#   hook.sh zeigen   Dashboard öffnen, ohne dass Claude arbeitet
#   hook.sh zu       Dashboard schließen
#   hook.sh aus|an   Wartezeit pausieren / wieder einschalten
#   hook.sh status   zeigt, was eingestellt ist und was das Skript auf diesem Rechner gefunden hat
#
# Braucht nur bash und, für das eigene Fenster, einen Chrome-artigen Browser (Chrome, Edge, Brave).
# Das Skript schreibt nie etwas auf die Standardausgabe, wenn ein Hook es aufruft:
# sonst würde der Text in Claudes Gespräch landen.

DIR="${WARTEZEIT_DIR:-$HOME/.claude/wartezeit}"
D="$DIR/daten"
PROFIL="$DIR/browser-profil"
EVT="$1"

# Einstellungen (Standardwerte, einstellungen.conf überschreibt sie)
VERZOEGERUNG=5        # Sekunden, bevor das Fenster aufgeht. Kurze Antworten bleiben so ohne Fenster.
GLOCKE=ja             # ja | nein
SCHLIESSEN=ja         # ja | nein: Fenster schließen, wenn Claude fertig ist
ZIEL=""               # leer = Dashboard. Sonst eine Adresse, die stattdessen aufgeht.
BREITE=560
HOEHE=900
BROWSER=""            # leer = selbst suchen. Sonst voller Pfad zum Browser.
[ -f "$DIR/einstellungen.conf" ] && . "$DIR/einstellungen.conf" 2>/dev/null

case "$(uname -s 2>/dev/null)" in
  Darwin) OS=mac ;;
  MINGW*|MSYS*|CYGWIN*) OS=win ;;
  *) OS=linux ;;
esac

mkdir -p "$D/laeuft" "$D/fertig" 2>/dev/null

b64() { base64 | tr -d '\n\r'; }
# Profilpfad als Suchmuster für pgrep/pkill: Sonderzeichen entschärfen
MUSTER="user-data-dir=$(printf '%s' "$PROFIL" | sed 's/[][\.*^$+?(){}|]/\\&/g')"
jetzt() { date +%s; }

# ---------- Browser finden ----------
browser() {
  [ -n "$BROWSER" ] && { printf '%s' "$BROWSER"; return; }
  local k
  case "$OS" in
    mac)
      for k in "Google Chrome" "Microsoft Edge" "Brave Browser" "Chromium" "Vivaldi"; do
        for p in "/Applications/$k.app" "$HOME/Applications/$k.app"; do
          [ -d "$p" ] && { printf '%s' "$p"; return; }
        done
      done ;;
    win)
      for k in "$PROGRAMFILES/Google/Chrome/Application/chrome.exe" "$LOCALAPPDATA/Google/Chrome/Application/chrome.exe" \
               "/c/Program Files/Google/Chrome/Application/chrome.exe" "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" \
               "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" "/c/Program Files/Microsoft/Edge/Application/msedge.exe" \
               "/c/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe"; do
        [ -f "$k" ] && { printf '%s' "$k"; return; }
      done ;;
    linux)
      for k in google-chrome google-chrome-stable chromium chromium-browser microsoft-edge brave-browser; do
        command -v "$k" >/dev/null 2>&1 && { command -v "$k"; return; }
      done ;;
  esac
}

adresse() {
  [ -n "$ZIEL" ] && { printf '%s' "$ZIEL"; return; }
  local p="$DIR/dashboard.html"
  if [ "$OS" = win ] && command -v cygpath >/dev/null 2>&1; then p="/$(cygpath -m "$p")"; fi
  p="${p// /%20}"
  printf 'file://%s' "$p"
}

lebt() {
  [ -f "$D/fenster" ] || return 1
  if [ "$OS" != win ] && command -v pgrep >/dev/null 2>&1; then
    pgrep -f -- "$MUSTER" >/dev/null 2>&1 && return 0
    [ -f "$D/fenster.ohne-profil" ] && return 0
    return 1
  fi
  return 0
}

oeffnen() {
  lebt && return 0
  local b url profil
  b="$(browser)"; url="$(adresse)"; profil="$PROFIL"
  rm -f "$D/fenster.ohne-profil"
  if [ -n "$b" ]; then
    case "$OS" in
      mac)   open -na "$b" --args --app="$url" --user-data-dir="$profil" --window-size="$BREITE,$HOEHE" \
               --no-first-run --no-default-browser-check --disable-features=Translate >/dev/null 2>&1 ;;
      win)   command -v cygpath >/dev/null 2>&1 && profil="$(cygpath -w "$profil")"
             "$b" --app="$url" --user-data-dir="$profil" --window-size="$BREITE,$HOEHE" \
               --no-first-run --no-default-browser-check >/dev/null 2>&1 & ;;
      linux) "$b" --app="$url" --user-data-dir="$profil" --window-size="$BREITE,$HOEHE" \
               --no-first-run --no-default-browser-check >/dev/null 2>&1 & ;;
    esac
  else
    # Kein passender Browser: im Standardbrowser öffnen. Dann schließt sich der Tab nicht von selbst.
    : > "$D/fenster.ohne-profil"
    case "$OS" in
      mac)   open "$url" >/dev/null 2>&1 ;;
      win)   cmd.exe //c start "" "$url" >/dev/null 2>&1 ;;
      linux) xdg-open "$url" >/dev/null 2>&1 & ;;
    esac
  fi
  jetzt > "$D/fenster"
}

schliessen() {
  if [ ! -f "$D/fenster.ohne-profil" ]; then
    case "$OS" in
      mac|linux) pkill -f -- "$MUSTER" >/dev/null 2>&1 ;;
      win) local w="$PROFIL"; command -v cygpath >/dev/null 2>&1 && w="$(cygpath -w "$PROFIL")"
           WZ_PROFIL="$w" powershell.exe -NoProfile -Command \
             'Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -and $_.CommandLine.Contains("--user-data-dir=" + $env:WZ_PROFIL) } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }' >/dev/null 2>&1 ;;
    esac
  fi
  rm -f "$D/fenster" "$D/fenster.ohne-profil"
}

glocke() {
  [ "$GLOCKE" = ja ] || return 0
  local f="$DIR/glocke.wav"
  [ -f "$f" ] || return 0
  case "$OS" in
    mac)   afplay "$f" >/dev/null 2>&1 & ;;
    win)   local w="$f"; command -v cygpath >/dev/null 2>&1 && w="$(cygpath -w "$f")"
           WZ_TON="$w" powershell.exe -NoProfile -Command '(New-Object Media.SoundPlayer $env:WZ_TON).PlaySync()' >/dev/null 2>&1 & ;;
    linux) { paplay "$f" || aplay -q "$f" || play -q "$f"; } >/dev/null 2>&1 & ;;
  esac
}

# ---------- Stand für das Dashboard schreiben ----------
liste() {  # Dateinamen eines Ordners als "a","b"
  local out="" f
  for f in "$1"/*; do [ -e "$f" ] && out="$out\"$(basename "$f")\","; done
  printf '%s' "${out%,}"
}
stand() {  # $1 = arbeitet | wartet | fertig | bereit
  find "$D/laeuft" -type f -mmin +240 -delete 2>/dev/null      # hängengebliebene Sitzungen
  find "$D/fertig" -type f -mmin +20 -delete 2>/dev/null
  find "$D" -maxdepth 1 -name 'log_*.js' -mmin +1440 -delete 2>/dev/null
  local z="$1"
  if [ -z "$z" ]; then
    if [ -n "$(ls -A "$D/laeuft" 2>/dev/null)" ]; then z=arbeitet; else z=fertig; fi
  fi
  printf 'WZ.stand({zeit:%s,zustand:"%s",zu:%s,sitzungen:[%s],fertige:[%s]});\n' "$(jetzt)" "$z" "$([ "$SCHLIESSEN" = ja ] && echo true || echo false)" "$(liste "$D/laeuft")" "$(liste "$D/fertig")" > "$D/stand.js.$$"
  mv "$D/stand.js.$$" "$D/stand.js"
}
merke() {  # $1 Sitzung, $2 Art, $3 Rohdaten, $4 höchstens so viele Bytes
  printf 'WZ.e("%s",%s,"%s","%s");\n' "$1" "$(jetzt)" "$2" "$(printf '%s' "$3" | head -c "$4" | b64)" >> "$D/log_$1.js"
}

# ---------- Nachrichten holen (nur, wenn feeds.txt etwas enthält) ----------
nachrichten() {
  [ -s "$DIR/feeds.txt" ] || return 0
  command -v curl >/dev/null 2>&1 || return 0
  [ -n "$(find "$D/nachrichten.js" -mmin -20 2>/dev/null)" ] && return 0
  local t="$D/nachrichten.js.$$" name url x
  printf 'WZ.feeds([' > "$t"
  while IFS='|' read -r name url || [ -n "$name" ]; do
    name="$(printf '%s' "$name" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    url="$(printf '%s' "$url" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    case "$name" in ''|'#'*) continue ;; esac
    case "$url" in http://*|https://*) ;; *) continue ;; esac
    x="$(curl -sL -m 8 -A 'Mozilla/5.0 (Wartezeit-Dashboard)' "$url" 2>/dev/null | head -c 600000 | b64)"
    [ -n "$x" ] && printf '{n:"%s",d:"%s"},' "$(printf '%s' "$name" | b64)" "$x" >> "$t"
  done < "$DIR/feeds.txt"
  printf ']);\n' >> "$t"
  mv "$t" "$D/nachrichten.js"
}

feld() {  # ein Textfeld aus dem JSON fischen, ohne Zusatzprogramme
  printf '%s' "$IN" | tr '\n' ' ' | sed -n 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*"\([A-Za-z0-9_.:-]*\)".*/\1/p' | head -c 200
}

# ---------- Befehle von Hand ----------
case "$EVT" in
  aus)    : > "$DIR/aus"; rm -f "$D/laeuft"/* 2>/dev/null; stand bereit; schliessen; echo "Wartezeit ist aus."; exit 0 ;;
  an)     rm -f "$DIR/aus"; echo "Wartezeit ist an."; exit 0 ;;
  zeigen) [ -f "$D/stand.js" ] || stand bereit; oeffnen; nachrichten >/dev/null 2>&1; exit 0 ;;
  zu)     schliessen; exit 0 ;;
  status)
    echo "Ordner:        $DIR"
    echo "System:        $OS"
    echo "Browser:       $(b="$(browser)"; [ -n "$b" ] && echo "$b" || echo "keiner gefunden (Dashboard öffnet im Standardbrowser und schließt sich nicht selbst)")"
    echo "Öffnet:        $(adresse)"
    echo "Eingeschaltet: $([ -f "$DIR/aus" ] && echo nein || echo ja)"
    echo "Verzögerung:   $VERZOEGERUNG Sekunden, Glocke: $GLOCKE, Schließen: $SCHLIESSEN"
    echo "Nachrichten:   $([ -s "$DIR/feeds.txt" ] && grep -vc '^[[:space:]]*\(#\|$\)' "$DIR/feeds.txt" || echo 0) Quellen"
    echo "Läuft gerade:  $(ls -A "$D/laeuft" 2>/dev/null | wc -l | tr -d ' ') Sitzungen"
    exit 0 ;;
  test)
    S="probelauf"; rm -f "$D/log_$S.js" "$D/laeuft/$S" "$D/fertig/$S"
    IN='{"session_id":"probelauf","cwd":"/beispiel/mein-projekt","prompt":"Probelauf: Räum meinen Downloads-Ordner auf"}'
    jetzt > "$D/laeuft/$S"; merke "$S" auftrag "$IN" 3000; stand arbeitet
    echo "1/4  Fenster geht auf …"; oeffnen; nachrichten >/dev/null 2>&1; sleep 4
    echo "2/4  Claude „arbeitet“ …"
    merke "$S" schritt '{"tool_name":"TodoWrite","tool_input":{"todos":[{"content":"Dateien ansehen","status":"completed"},{"content":"Nach Art sortieren","status":"in_progress"},{"content":"Bericht schreiben","status":"pending"}]}}' 14000
    merke "$S" schritt '{"tool_name":"Agent","tool_input":{"description":"Doppelte Dateien suchen","subagent_type":"Explore"}}' 14000
    merke "$S" schritt '{"tool_name":"Bash","tool_input":{"description":"Dateien nach Art zählen"}}' 2400
    sleep 5
    echo "3/4  Glocke …"
    rm -f "$D/laeuft/$S"; : > "$D/fertig/$S"; merke "$S" fertig '{}' 100; stand fertig; glocke; sleep 3
    echo "4/4  Fenster geht zu."
    [ "$SCHLIESSEN" = ja ] && schliessen
    rm -f "$D/fertig/$S" "$D/log_$S.js"; stand bereit
    exit 0 ;;
esac

# ---------- Aufrufe durch die Hooks ----------
IN="$(head -c 60000)"
SID="$(feld session_id)"
[ -z "$SID" ] && exit 0
SID="$(printf '%s' "$SID" | tr -cd 'A-Za-z0-9_-')"
[ -z "$SID" ] && exit 0

# Pausiert: nichts Neues anfangen. Laufendes wird noch sauber beendet.
if [ -f "$DIR/aus" ]; then
  case "$EVT" in fertig|ende) ;; *) exit 0 ;; esac
fi

case "$EVT" in
  auftrag)
    jetzt > "$D/laeuft/$SID"; rm -f "$D/fertig/$SID" "$D/log_$SID.js"
    merke "$SID" auftrag "$IN" 3000
    stand arbeitet
    # Erst nach kurzer Wartezeit öffnen: ist Claude dann schon fertig, bleibt das Fenster zu.
    ( sleep "$VERZOEGERUNG"; [ -f "$D/laeuft/$SID" ] && { oeffnen; nachrichten; } ) >/dev/null 2>&1 &
    ;;
  schritt)
    [ -f "$D/laeuft/$SID" ] || exit 0
    touch "$D/laeuft/$SID"
    case "$(feld tool_name)" in
      TodoWrite|Agent|Task|*update_plan|*wrap_up) GRENZE=14000 ;;
      *) GRENZE=2400 ;;
    esac
    merke "$SID" schritt "$IN" "$GRENZE"
    # Sehr lange Aufgaben: Protokoll kürzen, damit das Dashboard flott bleibt
    if [ "$(wc -c < "$D/log_$SID.js" 2>/dev/null || echo 0)" -gt 1500000 ]; then
      { head -n 1 "$D/log_$SID.js"; tail -n 150 "$D/log_$SID.js"; } > "$D/log_$SID.js.$$" && mv "$D/log_$SID.js.$$" "$D/log_$SID.js"
    fi
    grep -q '"wartet"' "$D/stand.js" 2>/dev/null && stand arbeitet
    ;;
  helfer-start|helfer-fertig)
    [ -f "$D/laeuft/$SID" ] || exit 0
    merke "$SID" "$EVT" "$IN" 1200
    ;;
  frage)
    # Claude braucht eine Freigabe oder Antwort: hörbar machen, sonst wartet er unbemerkt.
    [ -f "$D/laeuft/$SID" ] || exit 0
    merke "$SID" frage '{}' 100
    stand wartet
    glocke
    ;;
  fertig|ende)
    [ -f "$D/laeuft/$SID" ] || exit 0
    START="$(tr -cd '0-9' < "$D/laeuft/$SID" 2>/dev/null)"; DAUER=$(( $(jetzt) - ${START:-$(jetzt)} ))
    rm -f "$D/laeuft/$SID"; : > "$D/fertig/$SID"
    merke "$SID" fertig '{}' 100
    stand
    # Glocke, sobald die Aufgabe länger gedauert hat als die Verzögerung (auch wenn das Fenster von Hand geschlossen wurde)
    if [ "$EVT" = fertig ] && { lebt || [ "$DAUER" -ge "$VERZOEGERUNG" ]; }; then glocke; fi
    if lebt; then
      # Arbeitet noch eine andere Sitzung, bleibt das Fenster offen.
      if [ "$SCHLIESSEN" = ja ] && [ -z "$(ls -A "$D/laeuft" 2>/dev/null)" ]; then
        ( sleep 3; [ -z "$(ls -A "$D/laeuft" 2>/dev/null)" ] && schliessen ) >/dev/null 2>&1 &
      fi
    fi
    ;;
esac
exit 0
