// ---------------------------------------------
// DIE REGELN DES TÄTERS — Interaktiver Thriller
// Ink Version
// Tags: #MOOD:...
// ---------------------------------------------

VAR LenaGerettet = false
VAR TäterGefasst = false

-> prolog

// =========================================================
// PROLOG — DER ANRUF
// =========================================================
=== prolog ===
#MOOD:tension,noir

Der Regen trommelte gegen die Fensterscheiben, als die Nachricht auf deinem Handy aufleuchtete:

*Entführt – Lena Müller, 16 Jahre. Keine Zeugen. Kein Hinweis.*

Du blickst auf dein Team: Kira, Markus und Ben. Schweigen.
Die Stadt wirkt riesig und leer zugleich.

Ein Video war aufgetaucht: Lena, zusammengerollt auf dem Boden eines dunklen Raumes, die Augen groß vor Angst. Keine Stimme, nur ein flackernder Bildschirm.

* [Sofortige Analyse des Videos] -> analyse_video
* [Sicherung des Umfelds] -> sicherung

// =========================================================
// SZENE 01 — ANALYSE
// =========================================================
=== analyse_video ===
#MOOD:focus,tension

Du untersuchst das Video akribisch. Jede Bewegung, jeder Schatten könnte entscheidend sein.
Auf dem Boden siehst du Kreidezeichen: 3 – 1 – 4 – 1 – 5.

* [Zahlenfolge entschlüsseln] -> zahlenfolge
* [Räume im Umfeld überprüfen] -> raeume
* [Auf Verdächtige konzentrieren] -> verdaechtige

=== sicherung ===
#MOOD:action,tension

Du sicherst das Umfeld. Straßen, Nebengassen und mögliche Fluchtwege werden überprüft.
Das Team ist nervös, aber konzentriert.

-> analyse_video

// =========================================================
// SZENE 02 — HINWEISE
// =========================================================
=== zahlenfolge ===
#MOOD:mystery,focus

Die Zahlen scheinen ein Muster zu ergeben. Vielleicht eine Reihenfolge von Orten, die der Täter plant.
Kira flüstert: „Er will, dass wir bestimmte Dinge sehen… oder übersehen."

* [Zum Lagerhaus gehen] -> lagerhaus
* [Weitere Hinweise analysieren] -> weitere_hinweise

=== raeume ===
#MOOD:suspense

Jeder Raum im Umfeld wird vorsichtig untersucht. Keine Bewegung, keine Geräusche.
Ein Hauch von Gefahr liegt in der Luft.

-> weitere_hinweise

=== verdaechtige ===
#MOOD:investigation

Du prüfst Personen mit Zugang zu den Orten. Verdächtige tauchen auf, doch niemand scheint aktuell entscheidend.

-> weitere_hinweise

=== weitere_hinweise ===
#MOOD:discovery,tension

Die Kreidezeichen führen zu einem verlassenen Lagerhaus am Rand der Stadt. Jede Straßenlaterne wirft lange Schatten.
Ben sagt: „Hier muss er gewesen sein. EBENE 3."

* [Langsam vorgehen] -> langsam
* [Tempo erhöhen] -> tempo
* [Tätersignale spielen] -> signale

// =========================================================
// SZENE 03 — LAGERHAUS
// =========================================================
=== lagerhaus ===
#MOOD:danger,noir

Das alte Lagerhaus ragt vor euch auf. Verrostete Tore, zerbrochene Fenster.
Die Luft riecht nach Staub und altem Metall.

-> langsam

=== langsam ===
#MOOD:suspense,careful

Vorsichtig untersucht ihr das Lagerhaus. Alte Kreidezeichen führen euch zu einem akustischen Signal.
Ihr hört leises Klopfen. Lena könnte nah sein.

-> zwischenraeume

=== tempo ===
#MOOD:action,risk

Ihr rennt von Ort zu Ort, doch Lena wurde bereits verlegt. Hinweise verschwinden teilweise.
Zeitverlust ist hoch, Spannung steigt.

-> zwischenraeume

=== signale ===
#MOOD:strategy,tension

Ihr spielt ein Tätersignal. Er reagiert erstmals direkt.
Lena lebt noch, ihr Muster beginnt sich zu zeigen.

-> zwischenraeume

// =========================================================
// SZENE 04 — ZWISCHENRÄUME
// =========================================================
=== zwischenraeume ===
#MOOD:planning,noir

Die Stadtkarte auf dem Tisch zeigt viele rote Markierungen. Lena bewegt sich zwischen Orten.
Schatten deuten auf versteckte Übergänge.

* [Alte Übergänge prüfen] -> tunnel
* [Personen mit Zugang prüfen] -> personen
* [Lenas Hinweise entschlüsseln] -> lena_hinweise

=== tunnel ===
#MOOD:dark,danger

Akustische Hinweise führen euch in ein verlassenes Untergeschoss. Lena könnte hier sein.

-> falle

=== personen ===
#MOOD:investigation,suspicion

Verdächtiger Jonas Weber taucht auf. War er aktiv an den Orten?
Er wirkt nervös.

-> falle

=== lena_hinweise ===
#MOOD:analysis,hope

Die Betonungen und Pausen in Lenas Nachrichten geben Hinweise auf ihren nächsten Standort.

-> falle

// =========================================================
// SZENE 05 — DIE FALLE
// =========================================================
=== falle ===
#MOOD:danger,climax

Altes Bürogebäude. Überall wiederholen sich die Zahlen 3–1–4–1–5.
Der Täter testet euer Denken.

* [Schritt für Schritt folgen] -> schritt
* [Alternativen Zugang suchen] -> alternativ
* [Tätersignale provozieren] -> provozieren

=== schritt ===
#MOOD:methodical,tension

Ihr folgt der Logik exakt. Jeder Hinweis wird geprüft.

-> lagerhaus_final

=== alternativ ===
#MOOD:risk,suspense

Ihr wählt einen anderen Zugang, findet Lena aber verspätet.
Die Spannung steigt.

-> lagerhaus_final

=== provozieren ===
#MOOD:bold,danger

Ihr provoziert den Täter. Er reagiert sofort.
Lena wird bewegt, ihr erkennt nun sein Muster.

-> lagerhaus_final

// =========================================================
// SZENE 06 — FINALE ENTSCHEIDUNG
// =========================================================
=== lagerhaus_final ===
#MOOD:climax,decision

Noch 24 Stunden. Zahlen, Kreise, Lenas Hinweise – alles ein Muster.
Ihr müsst entscheiden, welche Strategie ihr folgt.

* [Zeitmuster rekonstruieren] -> zeitmuster
* [Orte verfolgen] -> ort
* [Lenas Hinweise analysieren] -> lena_final

=== zeitmuster ===
#MOOD:precision,focus

Altes Lagerhaus identifiziert, präziser Zugriff möglich.

* [Direkter Zugriff] -> ende_a
* [Vorbereitung und Außensicherung] -> ende_d
* [Täuschung] -> ende_c

=== ort ===
#MOOD:pursuit,risk

Lena wird verschoben, Risiko hoch.

* [Direkter Zugriff] -> ende_a
* [Vorbereitung und Außensicherung] -> ende_d
* [Täuschung] -> ende_c

=== lena_final ===
#MOOD:analysis,hope

Muster erkannt, Zugriff verzögert.

* [Direkter Zugriff] -> ende_a
* [Vorbereitung und Außensicherung] -> ende_d
* [Täuschung] -> ende_c

// =========================================================
// ENDEN
// =========================================================
=== ende_a ===
#MOOD:relief,bittersweet

Lena wird direkt gefunden und gerettet.
Der Täter entkommt.

~ LenaGerettet = true

-> epilog

=== ende_b ===
#MOOD:victory,relief

Lena wird gerettet und der Täter gefasst.

~ LenaGerettet = true
~ TäterGefasst = true

-> epilog

=== ende_c ===
#MOOD:relief,uncertainty

Lena wird gerettet, Täter entkommt. Gefahr bleibt.

~ LenaGerettet = true

-> epilog

=== ende_d ===
#MOOD:victory,perfect

Lena wird gerettet, Täter gefasst. Perfektes Ende.

~ LenaGerettet = true
~ TäterGefasst = true

-> epilog

// =========================================================
// EPILOG
// =========================================================
=== epilog ===
#MOOD:resolution,calm

Lena sitzt im Einsatzwagen, warm eingehüllt in eine Decke.
Ben, Kira und Markus atmen erleichtert auf.

{LenaGerettet:
    Lena ist in Sicherheit. Ihre Augen zeigen Dankbarkeit, auch wenn sie noch zittert.
- else:
    Lena konnte nicht rechtzeitig gefunden werden. Die Schuld lastet schwer auf dem Team.
}

{TäterGefasst:
    Der Täter wurde festgenommen. Endlich Gerechtigkeit.
- else:
    Der Täter ist noch auf freiem Fuß. Irgendwo da draußen wartet er auf seine nächste Chance.
}

Die Stadt erwacht langsam, der Regen hat aufgehört.
Ihr habt die Regeln gelernt: beobachten, denken, nicht überstürzen.

-> END


