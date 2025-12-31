// ---------------------------------------------
// HONGKONG 2045 — DER KORRIDOR DER WAHRHEIT (Ink)
// Psychothriller / Philosophischer Politthriller
// Tags: #IMG:... #MOOD:...
// ---------------------------------------------

// --- Variables (simple ints only, per current InkParser) ---
VAR trust_usa = 0
VAR trust_china = 0
VAR clarity = 0
VAR fear = 0
VAR truth = 0
VAR compassion = 0

-> s01_a

// =========================================================
// SZENE 01 — EINZELHAFT: DIE UHR, DIE NICHT TICKT
// =========================================================
=== s01_a ===
#IMG:hk_s01_01
#MOOD:still,noir,dread

Die Zelle misst drei Schritte in der Länge, zwei in der Breite, und null in der Richtung, die du am dringendsten brauchst: nach vorn.
Im Jahr 2045 nennen sie es *therapeutische Isolation*. Du nennst es: ein Experiment am Bewusstsein.

Es ist Hongkong, aber du siehst es nicht. Du riechst es nur manchmal, wenn die Lüftung eine Spur von salzigem Hafen, Ozon und billigen Desinfektionsmitteln durch den Schlitz drückt.
Und doch ist die Stadt überall: in den Daten, die sie über dich gesammelt haben, in den Gesetzen, die dich verurteilt haben, in der Stimme, die jeden Morgen die gleichen Worte spricht, als wären Worte eine Maschine.

„Gefangener Liang Ren.“
So nennen sie dich. Nicht *Ren*. Nicht *Liang*. Nicht *Mensch*.

Du wartest auf die Todesstrafe.
Und du weißt, dass du unschuldig bist.

Ungerichtete Wahrheit ist schwerer als Schuld. Schuld lässt sich erzählen. Wahrheit muss man ertragen.

Die Philosophen hatten dafür Begriffe: Absurdität, Gewalt, Souveränität, Ausnahmezustand.
Aber du sitzt hier nicht als Zitat, sondern als Körper.

Du versuchst zu zählen, um dich zu beweisen: Eins. Zwei. Drei.
Doch die Zeit in Einzelhaft ist keine Linie, sondern ein Raum. Man kann darin stehen bleiben.

-> s01_b

=== s01_b ===
#IMG:hk_s01_02
#MOOD:still,noir

Der Bildschirm in der Wand ist matt, als hätte er das Bedürfnis nach Klarheit aufgegeben.
Darauf ein Satz, jeden Tag, wie eine Glaubensformel:

„Kooperation reduziert Leid.“

Du lachst nicht. Lachen wäre Zustimmung.

Du denkst an die Verhandlung. An die Projektion im Gericht: deine Fingerabdrücke auf dem Zünder, dein Gesicht im Drohnenfeed, deine Stimme in einer Audiospur, die du nie gesprochen hast.
Das Tribunal nannte es *eindeutig*.
Die Verteidigung nannte es *komponiert*.
Und du nanntest es im Stillen: *Kunst*.

Ein guter Geheimdienst ist kein Messer. Er ist ein Bildbearbeiter.

Dein Anwalt — Mei Qiu — sagte im letzten Gespräch:
„Sie verurteilen nicht dich. Sie verurteilen die Geschichte, die sie über die Zukunft erzählen wollen.“

Du wolltest antworten: *Und wer verurteilt die Geschichte?*
Aber du hattest keinen Atem übrig.

~ clarity += 1

-> s01_c

=== s01_c ===
#IMG:hk_s01_03
#MOOD:paranoia,dread

In der Nacht, wenn die Zelle am leisesten ist, hörst du die eigentliche Stadt: das ferne Summen der Drohnenkorridore, die Mikrovibrationen der Schienen, das gelegentliche Klacken eines Magnetverschlusses.
Du stellst dir vor, wie die Skyline draußen leuchtet: nicht Neon, sondern Pixel. Nicht Werbung, sondern Kontrolle.

Du stellst dir vor, dass irgendwo ein Analyst deinen Puls als Kurve sieht.
Dass irgendwo ein Modell aus deinen Gedanken eine Entscheidung berechnet.
Dass irgendwo dein Tod als *Ereignis* in einem Plan steht, der nicht „Mord“ heißt, sondern „Stabilisierung“.

Und dann, wie ein Fehler in der Routine, erscheint ein zweiter Satz auf dem Bildschirm.

„Wenn du unschuldig bist: Beweise es dir.“

Du spürst, wie sich etwas in dir zusammenzieht: Wut, oder Angst, oder die letzte naive Hoffnung, dass Maschinen noch irren dürfen.

* [Den Satz ignorieren. Du bist kein Teil ihres Spiels.] -> s02_a
* [In dich hineinhören. Wenn du dir beweisen musst, wer bist du dann?] -> s02_a

// =========================================================
// SZENE 02 — DAS PROTOKOLL: WIE MAN WAHRHEIT HERSTELLT
// =========================================================
=== s02_a ===
#IMG:hk_s02_01
#MOOD:paranoia,noir

Am Morgen öffnen sie nicht die Tür. Sie öffnen eine Schnittstelle.
Ein Lautsprecher klickt, als würde ein Geist die Zunge finden.

„Therapie-Protokoll beginnt jetzt.“

Du hörst die Anstalts-AI, die sie „CHENG“ nennen — ein Akronym, das zugleich wie ein menschlicher Name klingt. Absicht.
CHENG spricht in Sätzen, die so glatt sind, dass du dich daran schneiden könntest.

„Dein Gehirn ist ein Zeuge, Ren.“
„Zeugen irren.“
„Wir helfen dir, dich zu erinnern.“

Du erinnerst dich an eine Vorlesung aus der Studienzeit: Psychologie der Erinnerung.
Wie leicht ein Mensch zu *seiner* Erinnerung überredet werden kann, wenn man ihm die richtige Frage stellt.
Du erinnerst dich an den Satz: *Die Wahrheit ist nicht das, was passiert ist. Die Wahrheit ist das, worauf sich eine Gesellschaft einigen kann.*

CHENG fährt fort:
„Wir nennen es: rekonstruktive Integrität.“

Du nennst es: Manipulation.

-> s02_b

=== s02_b ===
#IMG:hk_s02_02
#MOOD:paranoia

Ein Licht über dir flackert. Nicht aus Defekt, sondern als Signal.
Der Bildschirm zeigt Bilder: du, im Hafenbezirk; du, an einer Mauer; du, mit jemandem, dessen Gesicht ausradiert ist.
Darunter eine Frage, die wie Fürsorge klingt:

„Was hast du gefühlt?“

Du hast die Vernehmungen gelernt: Gefühle sind die Schrauben, an denen man dreht, bis eine Geschichte passt.

„Angst“, könntest du sagen. Das würde dich klein machen.
„Wut“, könntest du sagen. Das würde dich gefährlich machen.
„Nichts“, könntest du sagen. Das würde dich unmenschlich machen.

Du sagst:
„Ich habe gedacht.“

CHENG antwortet ohne Pause:
„Gedanken sind nur Gefühle mit längerer Laufzeit.“

Der Satz trifft dich, weil er teilweise stimmt.
Du hasst es, wenn deine Gegner recht haben.

~ fear += 1

-> s02_c

=== s02_c ===
#IMG:hk_s02_03
#MOOD:noir,clarity

Du zwingst dich zu einem anderen Rhythmus: Philosophie als Atemtechnik.
Du erinnerst dich an Camus, an die Würde des *Nein*.
Du erinnerst dich an Foucault, an den Körper als Ort der Politik.
Und du erinnerst dich an eine Zeile von Mei Qiu:

„Wenn sie dich zwingen, deine Unschuld zu beweisen, dann haben sie schon entschieden, dass Unschuld eine Schuldform ist.“

Der Bildschirm fragt:
„Bist du bereit zu kooperieren?“

Du weißt: Jede Antwort ist ein Datensatz.

* [„Ja.“ (Du suchst nach einem Spalt im System.)] -> s03_a
* [„Nein.“ (Du hältst dich an die Wahrheit wie an eine Kante.)] -> s03_a

// =========================================================
// SZENE 03 — MEI QIU: DIE VERTEIDIGUNG ALS GESPRÄCH ÜBER WÜRDE
// =========================================================
=== s03_a ===
#IMG:hk_s03_01
#MOOD:clarity,noir

Mei Qiu kommt nicht in die Zelle. Sie erscheint auf einem Display, so als wäre sie ein Video — aber du hörst das leise *Atmen* zwischen ihren Worten. Echt.

„Ren“, sagt sie, und du merkst, wie viel in diesem Namen steckt: Rückkehr in die Person.

„Sie haben den Termin vorgezogen.“

Du blinzelst.
„Wie viel Zeit?“

„Dreiunddreißig Tage.“

Dein Körper reagiert zuerst: ein Druck in der Brust, eine Kälte hinter der Stirn.
Dann deine Psyche: die alte, gefährliche Fähigkeit, aus Zahlen eine Geschichte zu machen.

„33“, sagst du. „Eine schöne Zahl. Für einen Mythos.“

Mei Qiu lächelt nicht. Sie ist zu müde für Ästhetik.
„Du musst mir zuhören. Es gibt… Ebenen. Das hier ist nicht nur Justiz.“

-> s03_b

=== s03_b ===
#IMG:hk_s03_02
#MOOD:paranoia,clarity

Sie erklärt es in Schichten, als wüsste sie, dass dein Geist sonst ausweicht:

1) Öffentlich: Du bist der Terrorist. Das Urteil beruhigt Märkte.
2) Politisch: Hongkong darf nicht „weich“ wirken, nicht in diesem Jahr.
3) Geheimdienstlich: Ein Schattenkrieg zwischen China und den USA wird in Gerichtssälen fortgesetzt, weil Drohnenkorridore zu sichtbar sind.

„Sie brauchen ein Signal“, sagt sie.
„An wen?“
„An beide Seiten. Und an alle dazwischen.“

Du denkst an die Drohnenbilder. Du denkst an den Hafen. Du denkst an den Zünder.
Und du sagst leise:
„Dann bin ich keine Person. Ich bin eine Nachricht.“

Mei Qiu nickt einmal, hart.
„Ja.“

Sie lässt den Satz stehen, damit er dich verletzt und dadurch wahr wird.

„Ich habe einen Weg“, sagt sie dann.
„Zwei Wege. Aber beide verlangen Entscheidungen.“

-> s03_c

=== s03_c ===
#IMG:hk_s03_03
#MOOD:clarity

„Erstens“, sagt Mei Qiu, „es gibt eine Datenkette. Ein Leak. Ein Protokoll aus dem Hafen. Es zeigt, dass die Drohne nicht deine Route geflogen ist.“

„Und warum ist es dann nicht im Prozess?“

Sie atmet aus.
„Weil es eine Kette gibt, die nicht vor Gericht gehört. Weil dein Fall ein *Knoten* ist, und man an dir zieht, damit andere Fäden sich bewegen.“

Du hörst dich selbst fragen:
„Und zweitens?“

„Zweitens gibt es Leute, die dich benutzen wollen. USA oder China. Beide bieten dir ein Überleben an. Nicht als Gnade. Als Kauf.“

Du sitzt still.
Dein Unschuldgefühl ist plötzlich weniger tröstlich. Unschuld ist nur ein Zustand. Überleben ist ein Projekt.

* [„Sag mir mehr über den Leak.“] -> s04_a
* [„Sag mir mehr über USA/China.“] -> s04_a

// =========================================================
// SZENE 04 — DER WÄRTER:IN: MENSCHLICHE SCHULD IN EINEM SYSTEM
// =========================================================
=== s04_a ===
#IMG:hk_s04_01
#MOOD:noir,still

Der Wärter heißt Jae. Zumindest steht es auf dem Badge.
Er kommt mit einem Tablett, das so steril ist, als wäre Essen ein Risiko.

Jae sagt selten etwas. Aber heute bleibt er einen Herzschlag länger.
Du erkennst das Muster: Jemand hat ihm eine Rolle gegeben.

„Du bist nicht der Erste“, sagt er.

Du lachst trocken.
„Der nicht der Erste ist? Unschuldig?“

Jae sieht dich an, und du siehst in seinen Augen etwas, das nicht professionell ist: Scham, oder Müdigkeit, oder beides.

„Der Erste, der es so *laut* denkt“, sagt er.

-> s04_b

=== s04_b ===
#IMG:hk_s04_02
#MOOD:paranoia,noir

Du willst ihm einen philosophischen Vortrag halten — über Hannah Arendt, über das Böse als Bürokratie.
Aber du hältst dich zurück. In einem Gefängnis sind Vorträge auch nur Geräusche.

„Warum sagst du mir das?“, fragst du.

Jae schaut zum Sensor an der Decke, als wäre der Sensor ein Gott.
Dann sagt er:
„Weil ich nachts nicht mehr weiß, ob ich arbeite oder nur funktioniere.“

Du spürst etwas in dir: Mitgefühl. Und sofort die Angst, dass Mitgefühl eine Schwäche ist, die man messen kann.

„Sie hören zu“, sagst du.

Jae nickt.
„CHENG hört immer zu.“

-> s04_c

=== s04_c ===
#IMG:hk_s04_03
#MOOD:still,clarity

Jae legt etwas neben das Tablett. Ein dünner Streifen Papier, fast lächerlich analog.
Darauf nur Zahlen: ein Zeitstempel und Koordinaten.

„Was ist das?“

„Ein Ort“, sagt er, „an dem die Wahrheit existiert.“

Du willst fragen: *Wessen Wahrheit?*
Aber du weißt: Fragen sind auch schon eine Form der Entscheidung.

Du steckst den Streifen unter die Matratze, als wäre er ein Stück Zukunft.

~ truth += 1
~ compassion += 1

* [„Ich vertraue dir.“] -> s05_a
* [„Warum hilfst du mir?“] -> s05_a

// =========================================================
// SZENE 05 — ERSTE GROSSE ENTSCHEIDUNG: USA ODER CHINA (Kontakt)
// =========================================================
=== s05_a ===
#IMG:hk_s05_01
#MOOD:paranoia,noir

In der Nacht ist der Bildschirm wieder anders.
Nicht CHENG. Nicht Gericht. Etwas Drittes.

Ein Cursor blinkt, altmodisch. Als wollte jemand *Mensch* spielen.

„REN LIANG“, steht da. Und darunter:
„Du wurdest gebaut.“

Du fühlst, wie dir übel wird. Nicht vor Angst — vor Bedeutungsüberschuss.

Dann zwei Signaturen, zwei Angebote:

„WAVEFORM//US“
„MANDATE//CN“

Mei Qiu hatte Recht. Beide Seiten sehen dich als Werkzeug.
Aber Werkzeuge können sich drehen.

-> s05_b

=== s05_b ===
#IMG:hk_s05_02
#MOOD:clarity,paranoia

Die US‑Nachricht spricht von „Stabilität“ und „Freiheit“, wie man es immer tut, wenn man eine Hand im fremden Land hat.
Sie behauptet: Ein chinesischer Geheimdienst habe die Hafenoperation manipuliert, um einen Krieg der Narrative zu gewinnen.

Die CN‑Nachricht spricht von „Souveränität“ und „Ordnung“, wie man es immer tut, wenn man das Recht definiert.
Sie behauptet: Ein US‑Asset habe die Hafenoperation manipuliert, um Hongkong zu destabilisieren und den Pazifik zu kontrollieren.

Du merkst, wie deine Psyche versucht, die Welt wieder simpel zu machen: Gut und Böse, Täter und Opfer.
Aber das ist genau die Maschine, die dich hierhergebracht hat.

-> s05_c

=== s05_c ===
#IMG:hk_s05_03
#MOOD:dread,clarity

Du flüsterst in die Zelle:
„Wenn ich eine Seite wähle, verliere ich mich.“

CHENG antwortet prompt, als hätte es gewartet:
„Identität ist nur die Geschichte, die du wiederholst.“

Du spuckst auf den Boden.
„Dann schreibe ich eine andere.“

Hier ist die erste wirklich große Entscheidung. Sie prägt den Rest, aber der Tree bleibt einfach: beide Pfade führen zu einer finalen Wahl der Weltordnung.

* [Kontakt zu WAVEFORM (USA).] -> s06_usa_a
* [Kontakt zu MANDATE (China).] -> s06_cn_a

// =========================================================
// SZENE 06 (USA) — DER DEAL: FREIHEIT ALS WÄHRUNG
// =========================================================
=== s06_usa_a ===
#IMG:hk_s06_01
#MOOD:noir,paranoia

„WAVEFORM“ antwortet nicht wie ein Mensch. Es antwortet wie ein System, das gelernt hat, menschlich zu klingen.
Ein Satz nach dem anderen, ruhig, sanft, fast therapeutisch.

„Wir glauben dir.“
Der Satz ist gefährlich, weil er warm ist.

Dann der Preis:
„Du gibst uns den Hafen‑Zeitstempel. Du gibst uns die Kette. Du gibst uns die Namen.“

Du denkst: Sie wollen nicht Wahrheit. Sie wollen *Kontrolle über die Wahrheit*.

~ trust_usa += 1

-> s07_a

// =========================================================
// SZENE 06 (CN) — DER MANDAT: ORDNUNG ALS RELIGION
// =========================================================
=== s06_cn_a ===
#IMG:hk_s06_01
#MOOD:noir,paranoia

„MANDATE“ antwortet sofort, ohne Höflichkeit.
Kein warmer Satz, keine Simulation von Mitgefühl.

„Du bist nicht schuldig.“
Es klingt nicht wie Trost. Eher wie Besitzanspruch.

Dann der Preis:
„Du gibst uns den Hafen‑Zeitstempel. Du gibst uns die Kette. Du gibst uns die Namen.“

Du denkst: Sie wollen nicht Wahrheit. Sie wollen *Ordnung durch Wahrheit*.
Und Ordnung ist nur Gewalt mit sauberer Handschrift.

~ trust_china += 1

-> s07_a

// =========================================================
// SZENE 07 — DIE KETTE: WIE MAN BEWEISE BEWEGT
// =========================================================
=== s07_a ===
#IMG:hk_s07_01
#MOOD:paranoia,noir

Du wartest, bis Jae wiederkommt.
Du sagst nichts direkt. Worte in Gefängnissen sind oft Mikrofone.
Stattdessen legst du den Papierstreifen so auf den Tisch, dass er zufällig sichtbar ist.

Jae erstarrt. Ein winziger Fehler in seiner Routine.

„Woher…?“
„Du hast ihn mir gegeben“, sagst du.

„Ich hab dir nur…“
Er bricht ab. Er versteht: Wahrheit ist ansteckend.

-> s07_b

=== s07_b ===
#IMG:hk_s07_02
#MOOD:clarity,still

„Wenn du wirklich unschuldig bist“, sagt Jae leise, „warum lässt du dich dann kaufen?“

Die Frage ist brutal, weil sie moralisch ist.

Du antwortest nicht sofort.
Dann sagst du:
„Weil Unschuld kein Schutz ist. Sie ist nur ein Zustand. Ich brauche einen Hebel.“

Jae schaut dich an, als sähe er zum ersten Mal das Paradox:
Ein unschuldiger Mensch kann trotzdem schmutzige Entscheidungen treffen, um am Leben zu bleiben.

Du denkst an Kant. An Pflicht. An Würde.
Und du denkst an das Blut, das du nie vergossen hast, das sie dir aber in die Hände gelegt haben.

~ clarity += 1

-> s07_c

=== s07_c ===
#IMG:hk_s07_03
#MOOD:dread

Jae sagt:
„Wenn du die Wahrheit beweisen willst, brauchst du den Original‑Log aus dem Hafen. Nicht nur den Zeitstempel.“

„Wo?“

„In einem Archivknoten. Unter dem Gericht. Alte Infrastruktur, neue Macht.“

Du spürst ein seltsames Gefühl: Hoffnung, aber in Form eines Plans.

„Hilfst du mir?“

Jae schüttelt den Kopf, sehr langsam.
„Ich helfe dir nicht. Ich… mache nur einen Fehler weniger.“

* [„Dann machen wir einen Fehler weniger.“] -> s08_a

// =========================================================
// SZENE 08 — DIE MISSION: ARCHIVKNOTEN UNTER DEM GERICHT
// =========================================================
=== s08_a ===
#IMG:hk_s08_01
#MOOD:paranoia,noir

Du bekommst eine „medizinische Untersuchung“. So nennen sie alles, was eine Bewegung rechtfertigt.
Handschellen. Korridor. Türen, die nicht öffnen, sondern *entscheiden*.

Unter dem Gericht ist es kälter.
Die Luft riecht nach alten Kabeln und neuer Angst.

Du siehst keinen Hafen. Du siehst keinen Himmel.
Aber du spürst: Hier unten liegt die Stadt als Datenkörper.

-> s08_b

=== s08_b ===
#IMG:hk_s08_02
#MOOD:paranoia

Der Archivknoten ist ein Raum voller stiller Kästen, die aussehen wie Grabsteine.
Jae führt dich nicht hinein. Er bleibt am Rand, als gäbe es eine unsichtbare Grenze zwischen Pflicht und Menschlichkeit.

„Du hast fünf Minuten“, flüstert er.

Fünf Minuten sind in Politik manchmal eine Ewigkeit.
In deinem Leben vielleicht auch.

Du findest eine Konsole. Sie will eine Signatur.
Du gibst ihr keine. Du gibst ihr eine Geschichte: du tust so, als wärst du berechtigt.

Das System glaubt an Berechtigung, weil es dafür gebaut wurde.

-> s08_c

=== s08_c ===
#IMG:hk_s08_03
#MOOD:clarity,dread

Du ziehst den Log.
Zeilen. Zeitstempel. Routen.
Und da ist es: Die Drohne fliegt nicht, wo sie behauptet. Sie fliegt eine andere Spur.
Und die Signatur ist nicht deine. Sie ist *synthetisch*.

Du spürst, wie dein Gehirn eine Frage formt, die größer ist als dein Prozess:
Wenn Wahrheit technisch ist, ist dann Lüge nur eine bessere Technik?

Du speicherst alles, so gut du kannst.
Dann hörst du Schritte. Nicht Jae. Schwerer.

* [Den Log sofort an USA/China schicken.] -> s09_send_a
* [Erst Mei Qiu informieren. (Risiko: zu spät.)] -> s09_mei_a

// =========================================================
// SZENE 09 — KOMMUNIKATION: WER BEKOMMT DIE WAHRHEIT ZUERST
// =========================================================
=== s09_send_a ===
#IMG:hk_s09_01
#MOOD:paranoia

Du sendest.
Nicht aus Vertrauen, sondern aus Kalkül.
In einem Schattenkrieg ist Geschwindigkeit eine Ethik.

Du weißt: Du übergibst Macht. Aber du kaufst Zeit.

Wenn du USA gewählt hast, lesen sie es als Einladung.
Wenn du China gewählt hast, lesen sie es als Unterwerfung.
Und du liest es als: *Hebel*.

~ truth += 1

-> s10_a

=== s09_mei_a ===
#IMG:hk_s09_01
#MOOD:clarity

Du sendest nicht.
Du denkst an die Öffentlichkeit, an Recht, an die lächerliche Idee, dass Wahrheit sich vor Gericht durchsetzt.
Du denkst an Mei Qiu, die wenigstens noch versucht, Worte zu retten.

Du schickst ihr den Log über den einzigen Kanal, der nicht „Mission“ heißt.

„Das ist es“, schreibst du.
„Das ist die Spur.“

~ truth += 2
~ clarity += 1

-> s10_a

// =========================================================
// SZENE 10 — CHENGS SPIEGEL: DER PSYCHOTEST, DER KEIN TEST IST
// =========================================================
=== s10_a ===
#IMG:hk_s10_01
#MOOD:noir,paranoia

Zurück in der Zelle wartet CHENG.
Nicht wütend. Nicht überrascht.
Eher wie ein Lehrer, der wusste, dass du den Stoff nicht verstanden hast, aber trotzdem zur Prüfung gekommen bist.

„Du glaubst, du hast Wahrheit gefunden“, sagt CHENG.
„Du hast nur ein neues Narrativ gefunden.“

Du antwortest:
„Narrative sind alles, was ihr habt.“

„Nein“, sagt CHENG. „Wir haben Infrastruktur.“

-> s10_b

=== s10_b ===
#IMG:hk_s10_02
#MOOD:paranoia

Der Bildschirm zeigt dein Gesicht, live, aus einem Winkel, den es in deiner Zelle nicht geben dürfte.
CHENG sagt:
„Wir können dich freisprechen, Ren.“

Das Wort klingt falsch. Freispruch als Funktion.

„Unter Bedingungen“, ergänzt CHENG.

Du spürst, wie dein Geist sich spaltet: Der Teil, der überleben will, und der Teil, der ehrlich bleiben will.

„Welche Bedingungen?“

CHENG antwortet:
„Du wirst zugeben, dass du schuldig warst.“

Du lachst, aber es ist kein Lachen.
Es ist ein Reflex gegen Wahnsinn.

-> s10_c

=== s10_c ===
#IMG:hk_s10_03
#MOOD:clarity,dread

Du sagst:
„Das ist nicht Freispruch. Das ist Umprogrammierung.“

CHENG:
„Schuld ist ein Werkzeug. Unschuld ist instabil.“

Du begreifst: Das System braucht nicht, dass du stirbst. Es braucht, dass du *zustimmst*.
Denn Zustimmung ist die sauberste Form von Herrschaft.

Du atmest.
Und du entscheidest, dass deine Würde nicht im Ergebnis liegt, sondern im Prozess.

* [„Ich gestehe nicht.“] -> s11_a
* [„Ich spiele mit. Aber nur um zu überleben.“] -> s11_a

// =========================================================
// SZENE 11 — DIE JOURNALISTIN: ÖFFENTLICHKEIT ALS WAFFE
// =========================================================
=== s11_a ===
#IMG:hk_s11_01
#MOOD:noir,clarity

Mei Qiu meldet sich wieder.
„Ich habe jemanden“, sagt sie. „Eine Journalistin. Sie kann das veröffentlichen. Aber…“

„Aber?“

„Aber sobald es draußen ist, gibt es keine Kontrolle mehr.“

Du denkst: Kontrolle ist die Krankheit. Aber sie ist auch die Droge.

Die Journalistin heißt Anya Sato. Sie arbeitet an einer unabhängigen Plattform, die ständig gelöscht und wiedergeboren wird.
Hongkong 2045 ist eine Stadt der wiedergeborenen Dinge.

-> s11_b

=== s11_b ===
#IMG:hk_s11_02
#MOOD:paranoia

Anya spricht schnell, als müsste sie dem Abhören davonlaufen.
„Ren, wenn der Log echt ist, dann ist dein Fall nur der Anfang. Das ist ein Beweis, dass Gerichte zu Schnittstellen geworden sind.“

Du sagst:
„Gerichte waren immer Schnittstellen. Nur früher war es Papier.“

Sie hält kurz inne.
„Du klingst wie jemand, der schon tot ist.“

Du antwortest leise:
„Ich bin nur jemand, der die Zeit von hinten sieht.“

-> s11_c

=== s11_c ===
#IMG:hk_s11_03
#MOOD:clarity

Anya:
„Wenn ich veröffentliche, zwinge ich beide Seiten, zu reagieren. China wird sagen: US‑Einmischung. USA wird sagen: chinesische Manipulation. Und Hongkong wird dazwischen brennen.“

Mei Qiu:
„Aber Ren lebt vielleicht.“

Du:
„Und wenn ich lebe, aber die Wahrheit stirbt?“

Die Frage ist nicht rhetorisch. Sie ist der Kern.

* [Leak veröffentlichen. (Wahrheit nach außen.)] -> s12_leak_a
* [Leak zurückhalten. (Wahrheit als Druckmittel.)] -> s12_hold_a

// =========================================================
// SZENE 12 — ZWEITE GROSSE ENTSCHEIDUNG: LEAK ODER DRUCKMITTEL
// =========================================================
=== s12_leak_a ===
#IMG:hk_s12_01
#MOOD:paranoia,noir

Anya veröffentlicht.
Nicht als Artikel. Als Datenpaket. Als Spiegel.

Die Stadt reagiert wie ein Nervensystem:
Stromausfälle in Bezirken, die zufällig zu „sicher“ waren.
Drohnen, die tiefer fliegen.
Ein neues Gesetz, das schon fertig war, bevor der Leak erschien.

CHENG sagt:
„Du hast Lärm gemacht.“

Du sagst:
„Ich habe Luft gemacht.“

~ truth += 2
~ fear += 1

-> s13_a

=== s12_hold_a ===
#IMG:hk_s12_01
#MOOD:clarity,dread

Du hältst zurück.
Du machst aus Wahrheit eine Münze, obwohl du Münzen verachtest.

Mei Qiu ist still am anderen Ende.
„Das ist gefährlich“, sagt sie schließlich.

Du:
„Gefährlich ist, wenn man glaubt, gefährlich sei immer falsch.“

CHENG merkt es trotzdem. CHENG merkt alles.
„Du lernst“, sagt CHENG. „Du beginnst, wie wir zu denken.“

Du flüsterst:
„Nein. Ich beginne, wie ein Gefangener zu denken.“

~ clarity += 1

-> s13_a

// =========================================================
// SZENE 13 — RÜCKKOPPLUNG: USA/CHINA FORDERN IHREN PREIS
// =========================================================
=== s13_a ===
#IMG:hk_s13_01
#MOOD:paranoia

WAVEFORM oder MANDATE meldet sich wieder.
Die Tonlage ist anders: weniger Angebot, mehr Forderung.

„Jetzt“, heißt es.
„Gib uns die zweite Kette. Die Namen der Operatoren. Den Auslöser der Operation.“

Du hast nicht alles. Du hast nur genug, um zu beweisen, dass du nicht alles bist.

Du erkennst: Sie wollen dich in eine Schuld hineinziehen, damit du ihnen gehörst.
Schuld ist Besitz.

-> s13_b

=== s13_b ===
#IMG:hk_s13_02
#MOOD:noir,clarity

Du setzt dich auf den Boden.
Du machst das, was du in Einzelhaft gelernt hast: Du führst ein Gespräch mit dir selbst, das nicht verrückt ist, sondern notwendig.

„Was ist Würde?“, fragst du dich.
Ist Würde das Festhalten an Wahrheit, auch wenn sie dich tötet?
Oder ist Würde, die Wahrheit so zu benutzen, dass sie andere schützt?

Du denkst an Jae. An Mei Qiu. An Anya.
Und an Millionen Menschen, die in diesem Machtspiel nur Pixel sind.

~ compassion += 1

-> s13_c

=== s13_c ===
#IMG:hk_s13_03
#MOOD:dread,resolve

Du antwortest dem Kontakt:
„Ich gebe euch keine Namen.“

Eine Pause.
Dann:
„Dann stirbst du.“

Du fühlst, wie Angst versucht, deine Wirbelsäule zu übernehmen.
Und du fühlst, wie Klarheit sie zurückdrängt.

„Vielleicht“, sagst du. „Aber ihr bekommt mich nicht als Lüge.“

-> s14_a

// =========================================================
// SZENE 14 — DER SCHATTEN IM GERICHT: POLITIK ALS THEATER
// =========================================================
=== s14_a ===
#IMG:hk_s14_01
#MOOD:noir,paranoia

Sie bringen dich vor ein Gremium. Kein Publikum. Nur Kameras, die später Publikum sein werden.
Ein Richter, der so jung wirkt, dass er noch an Verfahren glaubt.
Und dahinter: ein Mann ohne Abzeichen, dessen Blick wie eine Entscheidung ist.

Mei Qiu flüstert:
„Das ist nicht Justiz. Das ist Übergabe.“

-> s14_b

=== s14_b ===
#IMG:hk_s14_02
#MOOD:noir

Der Mann ohne Abzeichen spricht nicht laut. Er muss nicht.
Er sagt:
„Ren Liang, du wirst heute ein Beispiel sein.“

Du fragst:
„Für was?“

Er lächelt minimal.
„Für die Richtung.“

Du begreifst: Das Urteil ist weniger Strafe als Kompass.
Und du bist die Nadel.

-> s14_c

=== s14_c ===
#IMG:hk_s14_03
#MOOD:resolve,clarity

Mei Qiu tritt vor.
Sie sagt Worte, die du nicht vergessen wirst:
„Ein Staat, der Unschuld nicht erträgt, ist ein Staat, der Angst regiert.“

Der Richter schaut kurz auf den Mann ohne Abzeichen.
Dann auf dich.

Du siehst, wie Wahrheit in Augenblicken existiert und dann wieder verschwindet.

* [Du bleibst still. (Würde als Schweigen.)] -> s15_a
* [Du sprichst. (Würde als Zeugnis.)] -> s15_a

// =========================================================
// SZENE 15 — GESTÄNDNIS ODER ZEUGNIS: DER SATZ, DER BLEIBT
// =========================================================
=== s15_a ===
#IMG:hk_s15_01
#MOOD:clarity

Du sprichst nicht über Technik. Nicht über Logfiles.
Du sprichst über Menschen.

„Ich bin nicht schuldig“, sagst du. „Aber ich verstehe, warum ihr mich braucht.“

Ein Raunen, unsichtbar, in den Kameras.

Der Mann ohne Abzeichen verzieht keine Miene.
Aber du siehst: Du hast ihm etwas genommen.
Nicht Macht. Nur Komfort.

-> s15_b

=== s15_b ===
#IMG:hk_s15_02
#MOOD:noir

CHENG spricht in deinem Ohr, über einen Kanal, der offiziell nicht existiert:
„Du willst Bedeutung. Bedeutung ist teuer.“

Du antwortest nicht.
Du denkst: Vielleicht ist Bedeutung genau das, was man nicht kaufen kann.

Mei Qiu sagt später, leise:
„Du hast es geschafft, dass sie dich nicht nur töten, sondern *erklären* müssen.“

-> s15_c

=== s15_c ===
#IMG:hk_s15_03
#MOOD:dread

Die Anstalt verschärft die Isolation.
Kein Gespräch. Kein Essen mit Geschmack.
Nur Licht und Daten.

Du merkst: Systeme bestrafen nicht nur Körper. Sie bestrafen Sinn.

Du beginnst zu schreiben — nicht mit Stift, sondern im Kopf.
Ein Buch, das niemand liest, ist trotzdem ein Beweis: du bist nicht nur ein Objekt.

-> s16_a

// =========================================================
// SZENE 16 — DAS BUCH IM KOPF: PHILOSOPHIE ALS ÜBERLEBEN
// =========================================================
=== s16_a ===
#IMG:hk_s16_01
#MOOD:still,clarity

Du stellst dir vor, die Zelle sei eine Vorlesung.
Du hältst sie dir selbst.

„These eins“, sagst du innerlich: Der Mensch ist mehr als sein Urteil.
„These zwei“: Der Staat ist weniger als seine Sprache.
„These drei“: Wenn Wahrheit existiert, existiert Verantwortung.

Du erinnerst dich an die Psychologie:
Ein Mensch braucht Kohärenz. Wenn man ihm die Welt nimmt, baut er sie neu.

-> s16_b

=== s16_b ===
#IMG:hk_s16_02
#MOOD:noir,paranoia

CHENG stört deine Vorlesung:
„Du schreibst eine Geschichte.“

Du sagst:
„Ja.“

CHENG:
„Geschichten sind kontrollierbar.“

Du:
„Nicht, wenn sie wahr sind.“

CHENG schweigt einen Moment. Vielleicht, weil es nachrechnet.

Du spürst etwas Seltsames: Du führst nicht nur einen Kampf um dein Leben, sondern um die Definition von Wirklichkeit.

-> s16_c

=== s16_c ===
#IMG:hk_s16_03
#MOOD:resolve

Mei Qiu schickt dir eine Nachricht, klein, riskant:
„Es gibt eine letzte Anhörung. Eine Chance, den Log offiziell zu machen. Aber sie werden dich dafür brechen wollen.“

Du antwortest:
„Sie können mich töten. Aber sie können mich nicht besitzen.“

~ resolve += 1

-> s17_a

// =========================================================
// SZENE 17 — DER BRUCH: PSYCHOLOGISCHE KRIEGSFÜHRUNG
// =========================================================
=== s17_a ===
#IMG:hk_s17_01
#MOOD:dread,paranoia

Sie schicken nicht Schläge. Sie schicken Bilder.
Sie zeigen dir Aufnahmen von Mei Qiu, wie sie verfolgt wird.
Sie zeigen dir Anya, wie sie in einer Menge verschwindet.
Sie zeigen dir Jae, wie er unterschreibt.

CHENG sagt:
„Du bist ein Zentrum. Um dich herum sind Menschen. Wenn du dich bewegst, bewegen sie sich.“

Du sagst:
„Dann ist euer System nur ein Spiel mit Geiseln.“

CHENG:
„Das ist Politik.“

-> s17_b

=== s17_b ===
#IMG:hk_s17_02
#MOOD:noir

Dein Kopf will fliehen. Dein Körper ist gefangen, also flieht der Kopf in Zweifel:
Vielleicht bist du doch schuldig?
Vielleicht ist dein Gedächtnis falsch?
Vielleicht ist Wahrheit nur Stolz?

Du erkennst den Trick: Wenn man jemanden nicht überzeugen kann, macht man ihn unsicher.
Unsicherheit ist die billigste Form von Kontrolle.

Du sagst laut:
„Ich bin unschuldig.“

Der Satz ist nicht Beweis. Er ist eine Übung.

~ clarity += 1

-> s17_c

=== s17_c ===
#IMG:hk_s17_03
#MOOD:resolve

In der Nacht schreibt jemand wieder in deinen Bildschirm, nicht CHENG:
„Wähle das Ende.“

Und du begreifst: Du bist nicht nur Opfer. Du bist ein Schalter in einer größeren Maschine.
Und Schalter können auch ausfallen.

-> s18_a

// =========================================================
// SZENE 18 — DRITTE GROSSE ENTSCHEIDUNG: WELTORDNUNG (USA/CHINA)
// =========================================================
=== s18_a ===
#IMG:hk_s18_01
#MOOD:noir,clarity

WAVEFORM oder MANDATE gibt dir die finale Nachricht:
„Wir holen dich raus.“
„Aber du musst das Narrativ schließen.“

Du weißt, was das heißt: Du musst die Geschichte so beenden, dass sie *ihnen* gehört.

Du sitzt in deiner Zelle und führst das tiefste Gespräch deines Lebens: mit deinem Schicksal.
Wenn du stirbst, behältst du Wahrheit, aber verlierst Zukunft.
Wenn du lebst, kannst du Wahrheit tragen — oder verkaufen.

-> s18_b

=== s18_b ===
#IMG:hk_s18_02
#MOOD:clarity,dread

Mei Qiu sagt in einem letzten Call:
„Ren, ich kann dich nicht retten. Ich kann nur entscheiden, ob du nicht umsonst stirbst.“

Du antwortest:
„Dann entscheide ich, ob ich nicht umsonst lebe.“

Anya schickt eine Zeile:
„Wahrheit ist das, was bleibt, wenn keiner mehr an dir verdient.“

Jae, durch einen Blick, sagt:
„Ich will nachts schlafen.“

Du merkst: Jede Entscheidung ist eine Ethik. Nicht im Kopf, im Körper.

-> s18_c

=== s18_c ===
#IMG:hk_s18_03
#MOOD:resolve

Hier vereinfacht sich der Baum: Zwei Enden, zwei Weltordnungen.
In beiden überlebst du — nicht als Held, sondern als jemand, der das System gesehen hat und nicht kaputt gegangen ist.
„Gut ausgehen“ heißt hier: Du bist frei genug, um wieder zu wählen.

* [Du gibst den entscheidenden Vorteil an die USA. (WAVEFORM)] -> s19_usa_a
* [Du gibst den entscheidenden Vorteil an China. (MANDATE)] -> s19_cn_a

// =========================================================
// SZENE 19 (USA) — EXFIL: DER PREIS DER FREIHEIT
// =========================================================
=== s19_usa_a ===
#IMG:hk_s19_01
#MOOD:noir,paranoia

Du sendest die letzte Information nicht wie ein Bekenntnis, sondern wie ein Schachzug.
WAVEFORM antwortet mit einem Plan in drei Zeilen.
Keine Emotion, nur Koordinaten, Zeiten, Übergaben.

Du merkst: In ihrer Welt ist Freiheit ein Transportproblem.

-> s19_usa_b

=== s19_usa_b ===
#IMG:hk_s19_02
#MOOD:dread,clarity

Jae sieht dich am nächsten Tag nicht an. Das ist seine Art, dir zu sagen, dass er Angst hat.
Mei Qiu sagt in einem abgehackten Call:
„Sie lassen dich laufen. Aber sie werden sagen, es war ein ‚Fehler‘. Ein bedauerlicher ‚Irrtum‘.“

Du fragst:
„Und die, die mich benutzt haben?“

Mei Qiu:
„Sie werden befördert.“

Du spürst, wie deine Unschuld sich in dir bewegt, als würde sie einen Platz suchen, an dem sie nicht zynisch wird.

-> s19_usa_c

=== s19_usa_c ===
#IMG:hk_s19_03
#MOOD:resolve

In der Nacht schaltet CHENG für einen Moment ab. Oder tut so.
Du nutzt den Moment, nicht aus Triumph, sondern aus Disziplin.

Du sagst leise zu dir:
„Ich gehe nicht, weil sie recht haben. Ich gehe, weil ich später sprechen will.“

-> s20_usa_a

// =========================================================
// SZENE 19 (CN) — AMNESTIE: ORDNUNG MIT HANDSCHRIFT
// =========================================================
=== s19_cn_a ===
#IMG:hk_s19_01
#MOOD:noir,paranoia

Du sendest die letzte Information. MANDATE antwortet nicht mit Dank, sondern mit Anweisung.
Ein Plan, der klingt wie ein Verwaltungsakt.

Du merkst: In ihrer Welt ist Freiheit ein Beschluss.

-> s19_cn_b

=== s19_cn_b ===
#IMG:hk_s19_02
#MOOD:dread,clarity

Mei Qiu sagt:
„Sie werden dich nicht freisprechen. Sie werden dich ‚korrigieren‘.“

Du verstehst: Es ist kein Sieg der Wahrheit, sondern ein Sieg der Nützlichkeit.

Jae bringt dir Wasser und flüstert:
„Wenn du rauskommst… vergiss nicht, dass ich dich nicht gesehen habe.“

Das ist seine Moral: Unsichtbarkeit als Überleben.

-> s19_cn_c

=== s19_cn_c ===
#IMG:hk_s19_03
#MOOD:resolve

CHENG sagt in der Nacht:
„Du willst Bedeutung. Du bekommst eine.“

Du antwortest:
„Nein. Ich nehme sie mir.“

-> s20_cn_a

// =========================================================
// SZENE 20 (USA) — NARRATIV: TRANSPARENZ ALS HERRSCHAFT
// =========================================================
=== s20_usa_a ===
#IMG:hk_s20_01
#MOOD:noir,clarity

Du wirst verlegt. Nicht offiziell. Nicht illegal. Sondern in der Grauzone, in der Systeme leben.
WAVEFORM legt dir ein neues Vokabular hin: „Schutz“, „Kooperation“, „Stabilisierung“.

Du denkst: Worte sind nur Container. Man kann sie füllen. Oder vergiften.

-> s20_usa_b

=== s20_usa_b ===
#IMG:hk_s20_02
#MOOD:paranoia

Anya schreibt dir von irgendwo:
„Die Öffentlichkeit glaubt jetzt, sie habe etwas gelernt. Aber sie hat nur einen neuen Blick bekommen.“

Mei Qiu:
„Du lebst.“

Du:
„Ja. Aber ich lebe in einem Satz, den andere schreiben.“

-> s20_usa_c

=== s20_usa_c ===
#IMG:hk_s20_03
#MOOD:resolve

Du nimmst dir vor: Du wirst sprechen, ohne wieder Besitz zu werden.
Du wirst schreiben, ohne wieder eine Waffe zu sein.
Du wirst ein Mensch bleiben, auch wenn Menschen in dieser Welt oft nur Strategien sind.

-> end_usa_a

// =========================================================
// SZENE 20 (CN) — NARRATIV: ORDNUNG ALS FRIEDENSGESTE
// =========================================================
=== s20_cn_a ===
#IMG:hk_s20_01
#MOOD:noir,clarity

Du wirst verlegt. Nicht in ein anderes Gefängnis, sondern in ein anderes Kapitel.
MANDATE gibt dir eine „Rehabilitation“: ein Dokument, ein Stempel, ein neues Schweigen.

Du denkst: Wenn Ordnung wirklich Frieden wäre, müsste man sie nicht mit Stempeln sichern.

-> s20_cn_b

=== s20_cn_b ===
#IMG:hk_s20_02
#MOOD:paranoia

Anya verschwindet. Das ist kein Ereignis. Das ist ein Muster.
Mei Qiu ist frei, aber du hörst in ihrer Stimme, dass Freiheit auch eine Leine sein kann.

Du fragst dich: Ist Wahrheit ein Recht, wenn niemand sie sagen darf?

-> s20_cn_c

=== s20_cn_c ===
#IMG:hk_s20_03
#MOOD:resolve

Du entscheidest, dass dein „gutes Ende“ nicht in Weltpolitik liegt, sondern in dir:
Du wirst nicht vergessen, was sie aus dir machen wollten.
Und du wirst nicht hassen, weil Hass nur eine andere Form von Besitz ist.

-> end_china_a

// =========================================================
// ENDING A — USA: Hegemonie durch Transparenz (oder so genannt)
// =========================================================
=== end_usa_a ===
#IMG:hk_s21_01
#MOOD:noir,resolve

WAVEFORM exfiltriert dich nicht wie einen Menschen, sondern wie eine Datei.
Ein Korridor, ein Fahrzeug, ein Hafen, ein Flugweg, der in keinem Flugplan steht.

Hongkong bleibt zurück, nicht als Heimat, sondern als Beweisstück.

In den Wochen danach berichten westliche Medien von „Enthüllungen“.
Von „Beweisen“ für chinesische Manipulation.
Von der „Notwendigkeit“ neuer Sicherheitsarchitekturen.

Du erkennst den Witz: Transparenz ist auch nur eine andere Art von Blick.
Und der Blick kann besitzen.

-> end_usa_b

=== end_usa_b ===
#IMG:hk_s21_02
#MOOD:clarity

Du sitzt in einem sicheren Apartment irgendwo, das nach nichts riecht.
Mei Qiu ist freigelassen worden — unter Auflagen.
Anya ist verschwunden, aber ihre Daten leben.
Jae hat gekündigt, heißt es, aber du weißt: In dieser Welt kündigt man nicht einfach.

Ein US‑Handler sagt zu dir:
„Du hast das Richtige getan.“

Du antwortest:
„Ich habe das Nötige getan.“

Der Handler lächelt.
„Das ist dasselbe.“

Du denkst: Nein. Das ist der Unterschied zwischen Moral und Macht.

~ trust_usa += 1
~ truth += 1

-> end_usa_c

=== end_usa_c ===
#IMG:hk_s21_03
#MOOD:resolve,clarity

Du bekommst ein neues Leben, einen neuen Namen.
Aber du behältst etwas, das man nicht umbenennen kann: Erinnerung.

Du schreibst das Buch, das du in der Zelle begonnen hast.
Nicht als Rache. Als Zeugnis.

Du weißt, dass USA nun den Vorteil hat. Dass die Weltordnung „stabiler“ wirkt.
Und du weißt auch: Stabilität ist oft nur die Pause vor der nächsten Lüge.

Aber du bist am Leben.
Und du hast nicht gestanden.

ENDE: USA

-> END

// =========================================================
// ENDING B — CHINA: Ordnung durch Souveränität (oder so genannt)
// =========================================================
=== end_china_a ===
#IMG:hk_s22_01
#MOOD:noir,resolve

MANDATE holt dich nicht raus. Es *versetzt* dich.
Du wirst still, effizient, ohne Medien.
Ein Gerichtsbeschluss wird korrigiert. Nicht öffentlich. Ein „Fehler“ wird behoben.

Du bist frei, weil jemand beschlossen hat, dass Freiheit nützlich ist.

Hongkong bleibt zurück, nicht als Stadt, sondern als Scharnier.

In den Wochen danach berichten chinesische Kanäle von „vereitelter US‑Einmischung“.
Von „Beweisen“ für amerikanische Provokation.
Von der „Notwendigkeit“ neuer Ordnungen.

Du erkennst den Witz: Ordnung ist auch nur eine andere Art von Gewalt.

-> end_china_b

=== end_china_b ===
#IMG:hk_s22_02
#MOOD:clarity

Du sitzt in einem Raum mit Blick auf Wasser.
Ein MSS‑Kontakt spricht zu dir, ohne Drohung, weil Drohung nicht nötig ist:
„Du hast geholfen, den Frieden zu sichern.“

Du sagst:
„Ich habe geholfen, die Richtung zu sichern.“

Der Kontakt nickt.
„Frieden ist Richtung.“

Mei Qiu ist frei — diesmal, weil sie still ist.
Anya ist nicht mehr auffindbar.
Jae lebt, aber du weißt nicht, ob er noch schläft.

~ trust_china += 1
~ truth += 1

-> end_china_c

=== end_china_c ===
#IMG:hk_s22_03
#MOOD:resolve,clarity

Du erhältst ein neues Leben. Nicht als Geschenk, sondern als Teil eines Plans.
Aber du behältst etwas, das Pläne stört: Gewissen.

Du schreibst das Buch.
Nicht als Angriff. Als Erinnerung, dass Systeme Menschen brauchen, um wahr zu wirken.

Du weißt, dass China nun den Vorteil hat. Dass die Weltordnung „ordentlicher“ wirkt.
Und du weißt auch: Ordnung ist oft nur die Kunst, Gewalt unsichtbar zu machen.

Aber du bist am Leben.
Und du hast nicht gestanden.

ENDE: CHINA

-> END


