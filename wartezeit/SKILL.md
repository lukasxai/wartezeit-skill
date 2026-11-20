---
name: wartezeit
description: Richtet in Claude Code ein Wartezeit-Dashboard ein. Solange Claude arbeitet, geht ein Fenster auf (eigene Aufgabenliste, Nachrichten, was Claude und seine Helfer gerade machen, Links, Lernkarten oder eine eigene Seite). Ist Claude fertig, ertönt eine Glocke und das Fenster schließt sich. Nutzen, wenn jemand /wartezeit tippt oder sagt "Wartezeit-Dashboard", "ich greife beim Warten immer zum Handy", "mach was auf, während du arbeitest", "Fenster öffnen, solange Claude arbeitet", "sag mir Bescheid, wenn du fertig bist", "Glocke, wenn Claude fertig ist". Auch nutzen, um das Dashboard zu ändern, zu pausieren, zu testen oder wieder zu entfernen. Funktioniert nur in Claude Code (Desktop-App im Tab "Code" oder Terminal), nicht im normalen Chat.
---

# Wartezeit

Wer Claude Code eine Aufgabe gibt, wartet. Viele greifen dann zum Handy. Dieser Skill richtet stattdessen ein Fenster ein, das von selbst aufgeht, solange Claude arbeitet, und wieder zugeht, wenn er fertig ist. Was im Fenster steht, bestimmt die Person.

Technisch sind das Hooks von Claude Code: kleine Befehle, die Claude Code selbst bei bestimmten Ereignissen ausführt (Aufgabe abgeschickt, Werkzeug benutzt, fertig). Sie rufen ein Skript auf, das ein lokales Dashboard öffnet, mit Daten füttert und wieder schließt. Alles bleibt auf dem Rechner. Nur für Nachrichten werden die gewählten Nachrichtenseiten abgerufen.

## Immer zuerst sagen: nur in Claude Code

Sag das am Anfang jedes Einsatzes in einem Satz, auch wenn nicht gefragt wurde:

> Kurz vorab: Das läuft nur in Claude Code, also in der Desktop-App im Tab „Code" oder im Terminal. Im normalen Chat geht es nicht.

Der Grund: Hooks gibt es nur in Claude Code. Der normale Chat (claude.ai, die Handy-App, der Chat-Tab) kann weder Dateien auf dem Rechner anlegen noch ein Fenster öffnen.

Prüf dann, wo du gerade läufst. Kannst du keine Befehle auf dem Rechner der Person ausführen und nicht in ihren Benutzerordner schreiben, dann bist du im Chat. Dann nichts versprechen und nichts „so tun als ob". Sag freundlich, dass es hier nicht geht, und erklär den Weg: Claude-Desktop-App öffnen, oben auf „Code" wechseln, den Skill dort noch einmal aufrufen.

## Der Ton

Die Leute, die das nutzen, sind meist keine Entwickler. Kurze Sätze, keine Fachwörter ohne Erklärung. „Hook" einmal erklären, danach reicht „Automatik".

Versprich nichts, was du nicht geprüft hast. Getestet ist der Skill auf dem Mac mit Chrome. Für Windows und Linux ist alles vorbereitet, aber dort kann eine Kleinigkeit haken. Deshalb gibt es den Probelauf in Schritt 4: erst wenn die Person bestätigt, dass Fenster und Glocke bei ihr funktioniert haben, sagst du, dass es läuft. Klappt etwas nicht, sag das offen und reparier es.

Der Skill ändert eine Einstellungsdatei von Claude Code. Sag vorher, was du änderst, hol ein Ja, leg eine Sicherung an. Sag am Ende immer, wie man es pausiert und wieder loswird.

## Was die Person sagen kann

| Wunsch | Was du tust |
|---|---|
| einrichten, „ich will das" | Schritte 1 bis 5 |
| „zeig andere Sachen", „andere Nachrichten" | Schritt 1 für den Teil wiederholen, dann nur `config.js` / `feeds.txt` ändern |
| „mach mal Pause", „für die Aufnahme aus" | `bash ~/.claude/wartezeit/hook.sh aus`, später `an` |
| „keine Glocke", „Fenster später öffnen" | `einstellungen.conf` ändern |
| „geht nicht" | Abschnitt „Wenn etwas nicht klappt" |
| „wieder weg damit" | Abschnitt „Entfernen" |

## 1. Herausfinden, was die Person sehen will

Das ist der wichtigste Schritt. Frag nicht die Liste der Bausteine ab, sondern frag nach der Wartezeit selbst:

> Wofür würdest du die Minuten gern nutzen, in denen ich arbeite? Zum Beispiel: deine Aufgaben abhaken, Schlagzeilen lesen, sehen, was ich gerade mache, Vokabeln lernen, kurz aufstehen. Oder soll einfach eine bestimmte Seite aufgehen, etwa dein Kalender?

Hör auf die Antwort und übersetz sie in Bausteine. Frag nur nach, was dir wirklich fehlt, höchstens zwei, drei kurze Rückfragen. Sagt jemand „keine Ahnung, mach einfach", nimm die Grundausstattung: `agenten`, `aufgaben`, `nachrichten` mit Tagesschau.

Die Bausteine:

- **agenten**: was Claude gerade macht. Aufgabe, aktueller Schritt, Fortschritt, laufende Zeit. Arbeiten mehrere Sitzungen oder Helfer (Unteragenten) gleichzeitig, steht jeder mit seinem Stand da. Fast immer sinnvoll, weil man so sieht, ob es sich noch lohnt, sitzen zu bleiben.
- **aufgaben**: eigene To-do-Liste zum Abhaken. Neue Einträge tippt die Person direkt im Dashboard. Frag nach drei, vier Aufgaben für den Start.
- **nachrichten**: Schlagzeilen aus RSS-Feeds. Frag nach Themen oder Lieblingsseiten, nicht nach „Feeds".
- **links**: Knöpfe zu Seiten, die die Person oft braucht (Kalender, Postfach, Notizen).
- **karten**: Lernkarten zum Aufdecken. Vokabeln, Fachbegriffe, Prüfungsfragen. Du schreibst die Karten, sag wie viele (20 bis 40 sind ein guter Start).
- **bloecke**: fester Text oder Listen für alles andere: Dehnübungen, ein Leitsatz, die Wochenziele, eine Trink-Erinnerung.

Statt des Dashboards kann auch eine beliebige Adresse aufgehen (`ZIEL` in `einstellungen.conf`), etwa der Kalender oder ein Notizbuch im Netz. Wichtig dabei und der Person sagen: Das Fenster hat ein eigenes, leeres Browser-Profil. Bei Seiten mit Anmeldung muss sie sich dort einmal neu anmelden, danach bleibt sie angemeldet.

Passt ein Wunsch in keinen Baustein (Wetter, Aktienkurse, Musik), sag ehrlich, was davon mit Bordmitteln geht: ein Link dorthin geht immer, ein eigener Bereich im Dashboard hieße, `dashboard.html` umzubauen. Das kannst du tun, wenn die Person es will. Halt es klein und teste es.

Klär außerdem in einem Satz: Glocke ja oder nein (Standard ja), und dass das Fenster erst nach 5 Sekunden aufgeht, damit es bei kurzen Antworten nicht aufblitzt.

## 2. Sagen, was passiert, und Ja abholen

Bevor du etwas anlegst, in eigenen Worten:

- Es entsteht ein Ordner `~/.claude/wartezeit` mit dem Dashboard.
- In `~/.claude/settings.json` kommen sieben Einträge dazu, die das Fenster steuern. Was schon drinsteht, bleibt. Vorher legst du eine Sicherung an.
- Das gilt dann für alle Sitzungen in Claude Code auf diesem Rechner.
- Es lässt sich jederzeit pausieren oder entfernen.

Schau vorher in `~/.claude/settings.json`, ob dort schon Hooks stehen. Ist bereits etwas Ähnliches eingerichtet (ein anderes Werkzeug, das bei `UserPromptSubmit` ein Fenster öffnet oder bei `Stop` einen Ton spielt), sag das jetzt, denn sonst gehen zwei Fenster auf und es klingelt doppelt. Biete an: nur die Wartezeit nutzen und das andere pausieren, beides behalten und hier die Glocke abstellen (`GLOCKE=nein`), oder es lassen. Fremde Hooks änderst oder entfernst du nur auf ausdrücklichen Wunsch.

Erst nach einem Ja weitermachen.

## 3. Einrichten

**a) Dateien kopieren.** Das Skript liegt neben dieser Datei:

```bash
bash "<Ordner dieses Skills>/scripts/installieren.sh"
```

Es kopiert alles nach `~/.claude/wartezeit` und zeigt am Ende, welchen Browser es gefunden hat. Vorhandene eigene Einstellungen überschreibt es nicht. Steht dort „keiner gefunden", sag der Person: Das Dashboard öffnet sich dann als normaler Tab und schließt sich nicht von selbst; mit Chrome, Edge oder Brave bekommt es ein eigenes Fenster, das wieder zugeht.

Unter Windows braucht es Git Bash (bei Claude Code unter Windows normalerweise dabei). Fehlt `bash`, sag das und hilf, Git für Windows zu installieren, statt einen anderen Weg zu basteln.

**b) Inhalte eintragen.** Drei Dateien in `~/.claude/wartezeit`:

`config.js` bestimmt, was das Dashboard zeigt:

```js
window.WARTEZEIT = {
  name: "Lukas",                                   // Anrede, leer = keine
  bereiche: ["agenten", "aufgaben", "nachrichten", "links", "karten", "bloecke"],  // nur die gewünschten, in dieser Reihenfolge
  aufgaben: ["Video schneiden", "Rechnung schicken"],   // nur Startwerte, siehe unten
  nachrichtenAnzahl: 4,
  links: [{ name: "Kalender", url: "https://calendar.google.com" }],
  karten: { titel: "Spanisch", eintraege: [{ vorn: "la casa", hinten: "das Haus" }] },
  bloecke: [{ titel: "Kurz bewegen", text: "", liste: ["Schultern kreisen", "Wasser holen"] }]
};
```

Die Datei muss gültiges JavaScript bleiben, sonst bleibt das Dashboard leer. Anführungszeichen in Texten mit `\"` schreiben.

Zur Aufgabenliste: `aufgaben` in `config.js` sind nur die Startwerte für das allererste Öffnen. Danach lebt die Liste im Dashboard selbst (im Browser-Profil unter `~/.claude/wartezeit/browser-profil`). Spätere Änderungen an `aufgaben` in der Datei kommen deshalb nicht mehr an. Sag der Person, dass sie die Liste im Fenster pflegt.

`feeds.txt` enthält die Nachrichtenquellen, eine pro Zeile als `Name | Adresse`. Such zu den genannten Themen passende RSS-Feeds und prüf jeden mit einem Abruf, bevor du ihn einträgst (kommt XML mit `<item>` oder `<entry>` zurück?). Verlässliche Startpunkte:

```
Tagesschau | https://www.tagesschau.de/index~rss2.xml
heise online | https://www.heise.de/rss/heise-atom.xml
```

Rate keine Feed-Adressen von Themenseiten, das geht oft schief. Für jedes beliebige Thema geht die Google-News-Suche als Feed, das Suchwort in der Adresse URL-kodiert:
`https://news.google.com/rss/search?q=K%C3%BCnstliche+Intelligenz&hl=de&gl=DE&ceid=DE:de`

Zwei bis vier Quellen reichen. Will die Person keine Nachrichten, `nachrichten` aus `bereiche` nehmen und `feeds.txt` leeren, dann wird auch nichts abgerufen.

`einstellungen.conf` regelt das Verhalten: `VERZOEGERUNG` (Sekunden bis zum Öffnen), `GLOCKE` (ja/nein), `SCHLIESSEN` (ja/nein, ob das Fenster am Ende zugeht), `ZIEL`, `BREITE`, `HOEHE`, `BROWSER`. Die Glocke ertönt bei jeder Aufgabe, die länger gedauert hat als `VERZOEGERUNG`, auch wenn die Person das Fenster vorher selbst geschlossen hat. Schreibweise ohne Leerzeichen um das `=`.

**c) Die Automatik eintragen.** Die sieben Einträge stehen fertig in `~/.claude/wartezeit/hooks.json`. Sie müssen in `~/.claude/settings.json` unter `hooks`. Geh dabei sorgfältig vor, denn eine kaputte Einstellungsdatei stört ganz Claude Code:

1. Gibt es `~/.claude/settings.json`, kopier sie zuerst nach `~/.claude/settings.json.vor-wartezeit`. Gibt es die Sicherung schon, lass sie stehen.
2. Lies die Datei. Füg je Ereignis den Eintrag aus `hooks.json` an die vorhandene Liste an. Vorhandene Hooks anderer Werkzeuge bleiben unverändert stehen, auch beim selben Ereignis. Alles außerhalb von `hooks` bleibt unberührt.
3. Steht schon ein Eintrag mit `wartezeit/hook.sh` drin, nicht doppelt eintragen.
4. Prüf danach, dass die Datei gültiges JSON ist. Wenn nicht: Sicherung zurückspielen und neu ansetzen.

Gibt es die Datei noch nicht, leg sie mit dem Inhalt von `hooks.json` an.

Zum Zusammenführen nimm, was auf dem Rechner da ist (`python3`, `node` oder `jq`), statt die Datei von Hand umzuschreiben. Ist nichts davon da, bearbeite sie behutsam direkt und prüf das Ergebnis doppelt.

## 4. Probelauf

```bash
bash ~/.claude/wartezeit/hook.sh test
```

Der Probelauf dauert etwa 12 Sekunden: Fenster geht auf, eine Beispiel-Aufgabe läuft durch, die Glocke ertönt, das Fenster geht zu. Sag der Person vorher, dass gleich ein Fenster aufgeht, und frag danach drei Dinge:

1. Ist das Fenster aufgegangen und stand etwas drin?
2. Hast du die Glocke gehört?
3. Ist es von selbst wieder zugegangen?

Erst wenn alle drei mit Ja beantwortet sind, gilt es als eingerichtet. Antwortet die Person nicht eindeutig, kannst du auf Mac und Linux gegenprüfen, ob der Fensterprozess lief: `pgrep -f "wartezeit/browser-profil"` während des Probelaufs. Bei einem Nein: Abschnitt „Wenn etwas nicht klappt".

Der Probelauf prüft Fenster und Ton, aber nicht, ob Claude Code die Automatik auslöst. Das zeigt erst die nächste echte Aufgabe.

## 5. Abschluss

Sag der Person kurz:

- Ab der nächsten Aufgabe geht das Fenster von selbst auf, wenn Claude länger als die eingestellten Sekunden braucht. Passiert bei der nächsten Aufgabe nichts: eine neue Sitzung starten, dann sind die Einstellungen sicher geladen.
- Braucht Claude zwischendurch eine Freigabe oder Antwort, klingelt es ebenfalls und im Fenster steht „Claude braucht dich". Sonst würde Claude unbemerkt warten.
- Pause: „Wartezeit aus" sagen. Wieder an: „Wartezeit an".
- Ändern: einfach sagen, was anders sein soll.
- Entfernen: „Wartezeit entfernen" sagen.

Und noch einmal der Hinweis, wo es läuft: nur in Claude Code, nicht im Chat.

## Wenn etwas nicht klappt

Fang immer mit `bash ~/.claude/wartezeit/hook.sh status` an. Die Ausgabe zeigt System, gefundenen Browser, die Adresse, die geöffnet wird, und ob pausiert ist.

- **Kein Fenster im Probelauf.** Steht ein Browser im Status? Wenn nein, den vollen Pfad als `BROWSER="..."` in `einstellungen.conf` eintragen. Wenn ja, den Öffnen-Befehl aus `hook.sh` (Funktion `oeffnen`) einmal von Hand ausführen und die Fehlermeldung lesen.
- **Fenster leer oder nur die Überschrift.** Meist ein Tippfehler in `config.js`. Datei prüfen.
- **Keine Glocke.** Ton am Rechner an? `GLOCKE=ja`? Mac: `afplay ~/.claude/wartezeit/glocke.wav` von Hand probieren. Windows: der Ton läuft über PowerShell. Linux: es braucht `paplay`, `aplay` oder `play`.
- **Fenster geht nicht zu.** Öffnet das Dashboard als Tab im normalen Browser, wurde kein Chrome-artiger Browser gefunden; dann kann es sich nicht selbst schließen. Sonst `bash ~/.claude/wartezeit/hook.sh zu` probieren und schauen, ob der Schließen-Befehl in `hook.sh` (Funktion `schliessen`) auf diesem System greift.
- **Probelauf klappt, aber bei echten Aufgaben passiert nichts.** Stehen die Einträge wirklich in `~/.claude/settings.json`? Ist die Datei gültiges JSON? Neue Sitzung gestartet? In einem neuen Ordner muss erst die Frage von Claude Code bestätigt sein, ob man dem Ordner vertraut; vorher laufen keine Hooks. War die Aufgabe kürzer als `VERZOEGERUNG`, bleibt das Fenster absichtlich zu.
- **Keine Nachrichten.** Sie werden beim Öffnen geholt und höchstens alle 20 Minuten erneuert. Feed-Adresse von Hand abrufen und prüfen.
- **Windows oder Linux verhält sich anders als beschrieben.** Dort ist der Skill nicht erprobt. Lies `hook.sh`, pass die betroffene Stelle für dieses System an, teste mit `hook.sh test` und sag der Person, was du geändert hast.

Wenn du `hook.sh` änderst: Das Skript darf bei den Aufrufen durch Claude Code nichts ausgeben. Was es ausgibt, landet sonst als Text in Claudes Gespräch.

## Pausieren und Entfernen

Pausieren: `bash ~/.claude/wartezeit/hook.sh aus` (schließt auch ein offenes Fenster), zurück mit `an`. Die Einträge in den Einstellungen bleiben dabei stehen, das Skript tut nur nichts.

Entfernen, nach einem ausdrücklichen Ja:

1. In `~/.claude/settings.json` genau die Einträge löschen, deren Befehl `wartezeit/hook.sh` enthält. Alle anderen Hooks bleiben. Wird eine Liste dadurch leer, das Ereignis entfernen. Danach prüfen, dass die Datei gültiges JSON ist.
2. Fragen, ob der Ordner `~/.claude/wartezeit` auch weg soll. Darin liegt die Aufgabenliste der Person. Erst nach einem Ja löschen.

Die Sicherung `settings.json.vor-wartezeit` nicht einfach zurückspielen: Seit der Einrichtung kann sich die Einstellungsdatei aus anderen Gründen geändert haben.

## Grenzen

- Nur Claude Code. Kein Chat, keine Handy-App, keine Sitzungen in der Cloud.
- Erprobt auf dem Mac mit Chrome. Windows und Linux sind vorbereitet, aber nicht erprobt.
- Das eigene Fenster braucht Chrome, Edge oder Brave. Mit Safari oder Firefox allein öffnet sich ein normaler Tab, der offen bleibt.
- Unterbricht die Person Claude mitten in der Arbeit, meldet Claude Code kein „fertig". Das Fenster bleibt dann offen, bis die nächste Aufgabe endet oder man es selbst schließt.
- Geöffnete Nachrichten-Artikel gehören zum Dashboard-Fenster und schließen sich mit ihm.
- Die Anzeige, was Claude gerade macht, ist eine grobe Orientierung, kein genaues Protokoll.
