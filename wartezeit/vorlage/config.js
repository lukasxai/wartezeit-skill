// Was das Dashboard zeigt. Claude passt diese Datei an, du kannst sie auch selbst ändern.
window.WARTEZEIT = {
  name: "",                                          // Anrede oben, z. B. "Lukas". Leer = keine.
  bereiche: ["agenten", "aufgaben", "nachrichten"],  // Reihenfolge. Möglich: agenten, aufgaben, nachrichten, links, karten, bloecke
  aufgaben: [],                                      // Startwerte für die Liste. Danach pflegst du sie im Dashboard.
  nachrichtenAnzahl: 4,                              // Schlagzeilen pro Quelle. Die Quellen stehen in feeds.txt.
  links: [],                                         // [{ name: "Kalender", url: "https://..." }]
  karten: { titel: "Lernkarten", eintraege: [] },    // [{ vorn: "la casa", hinten: "das Haus" }]
  bloecke: []                                        // [{ titel: "Dehnen", text: "...", liste: ["...", "..."] }]
};
