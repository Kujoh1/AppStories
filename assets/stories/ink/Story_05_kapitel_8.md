Hier ist das ausführliche Kapitel 8, geschrieben im Ink-Format, mit Fokus auf Atmosphäre, Charaktertiefe und den geforderten erzählerischen Elementen.

=== kapitel_8 ===

#IMG surface_escape
#MOOD noir

Der Wind ist kein Geräusch mehr. Er ist eine physische Gewalt, ein Hammer aus Eis, der gegen den Rumpf des Schneemobils schlägt.

Wir rasen über das weiße Nichts.

Hinter uns: Eine Säule aus Rauch und Feuer, die in den antarktischen Himmel steigt. Die Aurora-Station. Mein Zuhause der letzten Monate. Ein Grabmal aus Stahl und geplatzten Träumen.

Vor uns: Die endlose, tödliche Weite des Eisschildes.

„Status!", brülle ich in das Com-System. Der Helm dämpft meine Stimme, lässt sie blechern klingen, fremd.

„Treibstoff bei 40 Prozent", antwortet Marcus. Er fährt das zweite Mobil, seine Silhouette kaum mehr als ein dunkler Fleck im Schneegestöber. „Walker verliert Blut. Wir können dieses Tempo nicht ewig halten."

Ich werfe einen Blick nach hinten. Walker sitzt hinter mir, zusammengesunken. Sein Atem rasselt im Intercom. Die Wunde an seiner Seite – ein Streifschuss von einer von Ashfords Drohnen – ist provisorisch versorgt, aber bei minus vierzig Grad gefriert selbst die Hoffnung.

„Wir haben keine Wahl", sage ich, meine Hände fest um die Lenkstangen geklammert. „Ashfords Drohnen sind immer noch auf dem Radar. Wenn wir anhalten, sind wir tot."

ARIA schaltet sich ein. Ihre Stimme ist klar, ohne das Statikrauschen, das die menschlichen Frequenzen plagt.

„Dr. Vasquez. Ich registriere drei Signaturen, die sich von Südosten nähern. Schnelle Angriffsvektoren. Flugdrohnen, Klasse 'Hunter-Killer'."

Mein Herz hämmert gegen meine Rippen. Wir sind auf offenem Eis. Präsentierteller.

„Zeit bis zum Kontakt?"

„Drei Minuten."

Ich sehe mich um. Weiß. Überall Weiß. Aber in der Ferne, kaum sichtbar durch den Sturm, ragen zerklüftete Eisformationen auf. Ein Gletscherbruch. Gefährlich, instabil, voller Spalten. Aber unser einziger Schutz vor Angriffen aus der Luft.

„ARIA, berechne eine Route zum Gletscherfeld!"

„Das Risiko eines Absturzes im Gletscherfeld beträgt 68 Prozent, Dr. Vasquez."

„Und das Risiko hier draußen?"

„100 Prozent."

„Dann ist die Wahl einfach." Ich schalte auf den Gruppenkanal. „Marcus, Reyes! Wir ändern den Kurs. Ins Eisfeld. Jetzt!"

Wir reißen die Maschinen herum. Das Eis unter den Kufen kreischt.

Die Drohnen kommen näher. Ich kann ihr hohes Surren jetzt hören, ein mechanisches Insektengebrumm, das den Wind durchschneidet.

* [Den direkten Weg durch die Spalten nehmen (Schnell, aber riskant)]
    -> szene_8_1_spalten
    
* [Versuchen, die Drohnen in einen Hinterhalt zu locken (Taktisch, benötigt Koordination)]
    -> szene_8_1_hinterhalt
    
* [ARIA die Kontrolle über die Schlitten geben (Vertrauen in die KI)]
    -> szene_8_1_aria_drive

=== szene_8_1_spalten ===

#MOOD action

„Mir nach!", schreie ich.

Ich beschleunige. Der Motor heult auf, als ich das Schneemobil direkt auf die erste große Spalte zu lenke. Es ist Wahnsinn. Das Eis hier ist wie ein gefrorener Ozean im Sturm, Wellen aus blauem Stahl, die abrupt abbrechen.

„Lena, das ist Selbstmord!", ruft Marcus.

„Nein, das ist Physik!"

Ich reiße den Lenker nach links, weiche einem Eisblock aus, der groß wie ein Haus ist. Die erste Drohne feuert. Ein Laserstrahl verdampft das Eis, wo ich vor einer Sekunde war. Dampf explodiert, nimmt uns die Sicht.

„Walker, halt dich fest!"

Wir springen.

Für eine Sekunde sind wir schwerelos. Unter uns gähnt ein blauer Abgrund, tief genug, um die Welt zu verschlucken. Dann knallen die Kufen auf der anderen Seite auf das Eis. Der Aufprall jagt Schmerz durch meine Wirbelsäule. Walker stöhnt auf.

Marcus und Reyes folgen. Knapp. Zu knapp.

Die Drohnen sind nicht so wendig. Die erste kann nicht rechtzeitig hochziehen, zerschellt an einer Eiswand. Feuerball.

„Einer weniger!", ruft Reyes. Ihre Stimme ist kalt, kontrolliert.

Aber zwei sind noch da. Und der Weg wird enger.

~ marcus_trust = marcus_trust + 1
-> szene_8_2_bunker_approach

=== szene_8_1_hinterhalt ===

#MOOD action

„Reyes! Du hast das Scharfschützengewehr?"

„Positiv", kommt ihre Antwort sofort.

„Marcus, zieh das Feuer auf dich. Fahr Zickzack. Ich bringe Reyes in Position."

Es ist ein Glücksspiel. Ich bremse hart, lasse das Schneemobil hinter einem massiven Eisblock schlittern. Walker flucht leise.

„Reyes, absteigen! Jetzt!"

Sie springt vom zweiten Schlitten, rollt sich ab, das Gewehr bereits im Anschlag. Marcus beschleunigt, zieht eine weite Kurve auf dem offenen Eis.

Die Drohnen fallen darauf rein. Ihre Sensoren fixieren das bewegliche Ziel. Sie senken die Nase, bereit zum Feuern.

„Jetzt, Reyes!"

Der Schuss ist trocken, kaum hörbar im Wind.

Die führende Drohne taumelt. Funken sprühen. Sie trudelt, kracht in die zweite Drohne. Eine Kettenreaktion aus Metall und Feuer.

„Volltreffer", sagt Reyes. Sie rennt zu meinem Schlitten. „Wir müssen weiter. Das waren nur die Späher."

Wir haben Zeit gekauft. Aber nicht viel.

~ okonkwo_trust = okonkwo_trust + 1
-> szene_8_2_bunker_approach

=== szene_8_1_aria_drive ===

#MOOD sci-fi

„ARIA! Übernimm die Steuerung! Synchronisiere beide Fahrzeuge!"

„Bestätigt. Übernehme Interface-Kontrolle."

Das Lenkrad in meinen Händen wird starr. Ein Geist übernimmt die Maschine.

„Berechne optimale Evasionsroute."

Die Schneemobile bewegen sich plötzlich mit unheimlicher Präzision. Wir fahren nicht mehr wie Menschen – reaktiv, ängstlich. Wir fahren wie Mathematik. Perfekte Kurven, minimale Reibung.

Die Drohnen feuern.

ARIA lässt die Schlitten im exakt gleichen Moment ausscheren. Die Laserstrahlen kreuzen sich harmlos zwischen uns.

„Induziere Kollisionskurs für Verfolger", sagt ARIA ruhig.

Sie bremst meinen Schlitten abrupt ab, wirbelt Schnee auf, eine weiße Wand. Die Drohnen-Sensoren sind geblendet. Im gleichen Moment beschleunigt Marcus' Schlitten durch die Wolke, schneidet den Weg der Drohnen ab.

Die Turbulenz, kombiniert mit dem Blindflug, ist zu viel für die Maschinen. Sie krachen in das Eis, desorientiert durch ARIAs elektronische Gegenmaßnahmen.

„Bedrohung neutralisiert", meldet ARIA. „Fahrer-Vitalwerte erhöht, aber stabil."

Marcus atmet schwer im Funk. „Erinnere mich daran, nie wieder einer KI mein Leben anzuvertrauen. Das war... effizient, aber erschreckend."

„Überleben ist selten komfortabel, Dr. Chen."

~ darkness_connection = darkness_connection + 1
-> szene_8_2_bunker_approach

=== szene_8_2_bunker_approach ===

#IMG hidden_bunker
#MOOD noir

Wir fahren noch eine Stunde. Das Eis verändert sich, wird flacher, härter.

„Wir erreichen die Koordinaten", sagt ARIA.

„Dort ist nichts", sagt Walker schwach. „Nur Schnee."

„Genau das ist der Punkt."

Ich stoppe das Schneemobil. Vor uns ragt ein unscheinbarer Felsrücken aus dem Eis. Nichts deutet auf Technologie hin. Keine Lichter, keine Antennen.

Dann, als ich absteige und das Amulett berühre, verändert sich die Luft. Ein Hologramm flackert auf – eine Tarnvorrichtung, die deaktiviert wird.

Der Fels teilt sich. Ein massives Stahlschott, markiert mit dem UN-Emblem und einem Symbol, das ich nicht kenne: Ein stilisierter DNA-Strang, der sich um eine Weltkugel windet.

Projekt GENESIS.

„Willkommen in der Hölle", murmelt Reyes. Sie klingt seltsam angespannt.

Das Tor öffnet sich mit einem tiefen Grollen. Bewaffnete Soldaten in weißen Tarnanzügen kommen heraus. Keine normalen UN-Truppen. Diese hier bewegen sich anders. Schneller. Tödlicher.

Und vor ihnen: Admiral Helena Okonkwo.

Sie trägt keinen Parka, nur ihre Uniform, als würde ihr die Kälte nichts anhaben. Ihr Gesicht ist eine Maske aus Stein.

„Dr. Vasquez", sagt sie. Ihre Stimme schneidet durch den Wind. „Sie sind spät."

„Wir hatten... Gesellschaft."

„Ich weiß. Wir haben den Absturz der Drohnen auf dem Satelliten verfolgt." Sie deutet auf Walker. „Sanitäter! Bringen Sie den Mann auf die Med-Bay. Sofort."

Zwei Soldaten eilen herbei, heben Walker vom Schlitten. Er wehrt sich schwach.

„Ich lasse mein Team nicht..."

„Halt den Mund, Sergeant", sage ich sanft. „Lass dich flicken. Das ist ein Befehl."

Walker nickt, lässt sich wegtragen.

Marcus stellt sich neben mich. Reyes sichert nach hinten.

„Wir müssen reden, Admiral", sage ich. „Über das, was auf der Aurora passiert ist. Über Ashford. Über alles."

Okonkwo mustert mich. Ihre Augen bleiben an dem Amulett hängen, dann an meiner Tasche, in der die anderen Schlüssel liegen.

„Nicht hier draußen. Kommen Sie rein. Bevor Prometheus den Rest seiner Spielzeuge schickt."

* [Misstrauisch bleiben – Waffe griffbereit halten.]
    -> szene_8_3_misstrauen
    
* [Kooperativ zeigen – wir brauchen ihre Hilfe.]
    -> szene_8_3_kooperation
    
* [Okonkwo direkt konfrontieren – „Wussten Sie von dem Angriff?"]
    -> szene_8_3_konfrontation

=== szene_8_3_misstrauen ===

#MOOD noir

Ich lasse meine Hand demonstrativ in der Nähe meiner Pistole. Marcus tut es mir gleich.

„Wir kommen rein", sage ich. „Aber unter unseren Bedingungen. Meine Leute bleiben bewaffnet."

Die Soldaten heben ihre Gewehre. Ein Dutzend Laserzielpunkte tanzen auf meiner Brust.

Okonkwo hebt eine Hand. Die Soldaten senken die Waffen sofort. Absolute Disziplin.

„Sie haben Mut, Lena. Das muss man Ihnen lassen. Aber Sie sind hier nicht in der Position, Bedingungen zu stellen. Sie sind Flüchtlinge. Ich biete Asyl."

„Asyl in einem Bunker, der offiziell nicht existiert?"

„Genau deshalb ist es das sicherste Asyl, das Sie finden werden." Sie dreht sich um. „Kommen Sie. Oder erfrieren Sie. Es ist Ihre Wahl."

Wir folgen ihr. Aber ich entsichere den Holster.

-> szene_8_4_briefing

=== szene_8_3_kooperation ===

#MOOD still

Ich nicke. „Danke, Admiral. Wir brauchen Vorräte, medizinische Hilfe und eine sichere Leitung."

„Sie bekommen alles." Ihr Gesicht wird eine Spur weicher. „Ich bin froh, dass Sie leben, Lena. Ich... ich kannte Ihren Vater gut. Ich wollte nicht, dass seine Tochter im Eis endet."

„Mein Vater lebt", sage ich leise.

Okonkwo bleibt stehen. Ihr Rücken versteift sich. Sie dreht sich langsam um.

„Was haben Sie gesagt?"

„Er war in Stasis. Im Marianengraben. Wir haben ihn gefunden."

Ein Ausdruck huscht über ihr Gesicht, den ich nicht deuten kann. Schock? Erleichterung? Oder Furcht?

„Dann", sagt sie schließlich, ihre Stimme kontrolliert, „haben wir noch viel mehr zu besprechen, als ich dachte."

~ okonkwo_trust = okonkwo_trust + 1
-> szene_8_4_briefing

=== szene_8_3_konfrontation ===

#MOOD noir

„Wussten Sie es?", frage ich, ohne mich zu bewegen. „Wussten Sie, dass Ashford die Station angreifen würde?"

Okonkwo sieht mich kalt an.

„Ich wusste, dass Ashford einen Zug machen würde. Sobald Sie den zweiten Schlüssel gefunden hatten, war es unvermeidlich."

„Sie haben uns als Köder benutzt."

„Ich habe Sie als Katalysator benutzt, Dr. Vasquez. Es gibt einen Unterschied."

„Menschen sind gestorben! Meine Freunde!"

„Menschen sterben jeden Tag. Für weniger wichtige Dinge als das Schicksal unserer Spezies." Sie tritt einen Schritt näher, ihre Präsenz ist erdrückend. „Werden Sie erwachsen, Lena. Wir spielen hier nicht Archäologie. Wir spielen Krieg. Und im Krieg opfert man Bauern, um die Königin zu schützen."

„Ich bin nicht Ihre Königin."

„Nein", sagt sie leise. „Sie sind das Schachbrett."

-> szene_8_4_briefing

=== szene_8_4_briefing ===

#IMG genesis_briefing
#MOOD noir

Das Innere des Bunkers ist ein Labyrinth aus grauem Beton und modernster Technologie. Es riecht nach Ozon und gefilterter Luft. Wir erreichen einen Konferenzraum. Eine Wand ist komplett aus Glas und zeigt einen Serverraum, in dem Quantencomputer in flüssigem Stickstoff baden.

Okonkwo setzt sich an das Kopfende des Tisches. Reyes bleibt an der Tür stehen, verschränkt die Arme. Marcus setzt sich neben mich.

„Projekt GENESIS", beginnt Okonkwo ohne Umschweife. „Gegründet 2004. Fünfzig Jahre Geheimhaltung. Unser Mandat: Die Überwachung und Sicherung von Artefakten nicht-menschlichen Ursprungs."

„Sie wussten es also", sagt Marcus. „All die Jahre. Dass wir nicht allein sind."

„Wir wussten, dass *etwas* hier war. Wir nannten sie 'Die Architekten'. Ihr nennt sie 'Die Ersten'. Semantik."

Sie aktiviert ein Hologramm auf dem Tisch. Es zeigt die Erde, durchzogen von einem Netz aus Linien. Ley-Linien? Energie?

„Ashford will die Technologie", fahre ich fort. „Er will die Dunkelheit kontrollieren."

„Ashford ist ein Narr", spuckt Okonkwo aus. „Er denkt wie ein CEO. Profit. Macht. Kontrolle. Aber man kann Entropie nicht kontrollieren. Man kann sie nur... eindämmen."

Sie tippt auf die Karte. Zwölf Punkte leuchten auf.

„Wir haben zwei Schlüssel", sagt sie. „Ashford hat drei. Sie haben jetzt..." Sie blickt auf meine Tasche.

„Vier", sage ich. „Plus den, den mein Vater trägt. Das macht fünf auf unserer Seite."

„Fünf zu drei. Das klingt gut. Aber es gibt noch vier weitere da draußen."

Das Hologramm zoomt auf Tibet. Dann auf den Amazonas. Dann Sibirien.

„Es ist ein Wettlauf", sagt Okonkwo. „Aber es gibt noch einen dritten Spieler."

Ich runzle die Stirn. „Wer?"

„Der Rat."

Reyes, an der Tür, bewegt sich kaum merklich.

„Eine Splittergruppe", erklärt Okonkwo. „Fanatiker innerhalb der UN und anderer Regierungen. Sie glauben, dass die Technologie der Ersten eine Sünde ist. Dass sie vernichtet werden muss. Um jeden Preis."

„Vernichtet?", fragt Marcus. „Das würde bedeuten..."

„Das Siegel zu brechen, ohne es kontrollieren zu können", beendet Okonkwo den Satz. „Wenn sie Erfolg haben, öffnen sie die Tür zur Dunkelheit sperrangelweit, nur um das Schloss zu zerstören."

Sie sieht mich eindringlich an.

„Ich mag rücksichtslos sein, Dr. Vasquez. Aber ich will, dass die Menschheit überlebt. GENESIS will die Siegel verstärken. Ashford will sie nutzen. Der Rat will sie zerstören. Sie müssen sich entscheiden, auf welcher Seite Sie stehen."

Plötzlich flackert das Licht.

Ein Alarm heult auf – nicht der schrille Ton eines Feueralarms, sondern ein tiefes, pulsierendes Dröhnen.

„Systemwarnung", meldet die KI des Bunkers. „Unautorisierter Datentransfer detektiert. Verschlüsselungsebene Alpha durchbrochen."

Okonkwo springt auf. „Was? Wer?"

„Quelle des Signals: Innerhalb dieses Raumes."

Alle Augen richten sich auf Reyes.

Sie steht an der Tür, ein kleines Gerät in der Hand. Ihr Gesicht ist ruhig. Zu ruhig.

„Es tut mir leid, Lena", sagt sie.

* [„Reyes, was tust du da?"]
    -> szene_8_5_verrat
    
* [Sofort angreifen – keine Zeit für Fragen.]
    -> szene_8_5_angriff
    
* [ARIA befehlen, das Signal zu blockieren.]
    -> szene_8_5_blockade

=== szene_8_5_verrat ===

#IMG mole_revealed
#MOOD noir

„Reyes... warum?"

Sie sieht mich an, und in ihren Augen liegt eine Traurigkeit, die echt wirkt.

„Weil es enden muss, Lena. Das alles. Ashford, GENESIS, die Ersten... es ist Gift. Die Menschheit ist nicht bereit. Wir werden es nie sein."

„Du arbeitest für den Rat."

„Ich arbeite für die Stille. Für eine Welt, in der wir nicht schlafen gehen und Angst haben müssen, dass Schatten aus den Wänden kriechen."

Sie tippt auf ihr Gerät.

„Der Standort ist übermittelt. Nicht an Ashford. An eine orbitale Plattform des Rates. Eine kinetische Lanze ist unterwegs. Einschlag in 90 Sekunden."

„Du tötest uns alle", flüstert Marcus.

„Ich säubere die Wunde."

-> szene_8_6_flucht

=== szene_8_5_angriff ===

#MOOD action

Ich zögere nicht. Meine Hand reißt die Pistole hoch.

Reyes ist schnell. Schneller als ich. Sie weicht aus, tritt mir die Waffe aus der Hand. Aber das gibt Okonkwo Zeit.

Der Admiral wirft sich über den Tisch, rammt Reyes gegen die Wand. Das Gerät in Reyes' Hand fällt zu Boden, schlittert über den Boden.

„Signal... gesendet", keucht Reyes, während Okonkwo ihren Arm auf den Rücken dreht. Ein hässliches Knacken.

„Verdammt!", brüllt Okonkwo. „Sie hat unsere Koordinaten gesendet. Kinetischer Schlag. Wir haben weniger als zwei Minuten!"

-> szene_8_6_flucht

=== szene_8_5_blockade ===

#MOOD sci-fi

„ARIA! Jammer-Protokoll! Blockier das Signal!"

„Verstanden. Initiiere elektronische Gegenmaßnahmen."

Die Lichter im Raum flackern wild. Reyes starrt auf ihr Gerät.

„Fehler", liest sie. „Übertragung unvollständig."

Sie sieht mich an, Wut in den Augen. Sie zieht ihre Waffe.

„Dann mache ich es manuell."

Bevor sie feuern kann, trifft sie ein Schuss. Okonkwo steht da, ihre Dienstwaffe rauchend. Reyes sackt zusammen, hält sich die Schulter.

„Das Signal ist teilweise raus", meldet ARIA. „Sie haben den Sektor, aber nicht die exakten Koordinaten. Der Schlagradius wird groß sein."

„Wir müssen hier raus", sagt Marcus. „Sofort."

-> szene_8_6_flucht

=== szene_8_6_flucht ===

#IMG bunker_chaos
#MOOD action

Chaos bricht aus.

Der Alarm wechselt zu einer Evakuierungssirene.

„Alle Mann zu den Hangars!", brüllt Okonkwo in ihr Com-Link. Sie packt Reyes – die blutet, aber bei Bewusstsein ist – am Kragen. „Du kommst mit. Ich bin noch nicht fertig mit dir."

„Lass sie hier!", rufe ich. „Sie hat uns verraten!"

„Sie hat Informationen über den Rat. Sie ist wertvoll." Okonkwo ist eiskalt.

Wir rennen durch die Gänge. Rote Warnleuchten tauchen alles in blutiges Licht.

„ARIA, wo ist mein Vater? Wo ist Walker?"

„Sergeant Walker und Dr. Vasquez Senior wurden bereits zum Transport Alpha verlegt. Ich habe die Evakuierung priorisiert."

„Gutes Mädchen."

Der Boden bebt. Der erste Einschlag. Weit weg, aber stark genug, um Staub von der Decke rieseln zu lassen.

„Das war ein Warnschuss", keucht Marcus. „Die kalibrieren noch."

Wir erreichen den Hangar. Ein schweres Transportflugzeug, ein VTOL-Modell, die Triebwerke bereits warmgelaufen.

„Rein da!", schreit Okonkwo.

Wir stürmen die Rampe hoch. Drinnen sehe ich Walker auf einer Trage, bleich aber lebendig. Und meinen Vater, der ängstlich zur Luke blickt.

„Lena!", ruft er.

„Wir sind da!"

Ich helfe Marcus rein. Okonkwo stößt Reyes vor sich her, wirft sie in einen Sitz und fesselt sie mit Kabelbindern.

Dann, als ich den Fuß auf die Rampe setze, passiert es.

Ein Volltreffer.

Die Decke des Hangars bricht ein. Tonnen von Eis und Beton stürzen herab. Die Druckwelle schleudert mich gegen die Bordwand.

Dunkelheit.

Dann Licht. Die Schlüssel. Sie glühen. Ein Schild?

„Starten!", höre ich Okonkwo schreien.

„Wir können Lena nicht zurücklassen!", das ist Marcus.

„Ich bin hier!", keuche ich und ziehe mich hoch. Mein Kopf dröhnt. Blut läuft mir in die Augen.

Das Flugzeug hebt ab, schießt durch das zerberstende Dach des Hangars in den Sturm hinaus.

Hinter uns implodiert der Bunker. Eine Säule aus Feuer und Eis.

Wir steigen. Höher. Über den Sturm.

Im Laderaum ist es still. Nur das Dröhnen der Motoren und das schwere Atmen der Überlebenden.

Okonkwo steht über Reyes.

„Du wirst mir alles erzählen", sagt der Admiral leise. „Jeden Namen. Jeden Code."

Reyes spuckt Blut. „Es spielt keine Rolle. Sie wissen, wo ihr hinwollt."

Ich trete vor, wische mir das Blut aus dem Gesicht.

„Wo wollen wir hin?", frage ich.

Okonkwo dreht sich zu mir. Sie aktiviert eine Karte an der Wand des Transporters.

„Wir haben den Bunker verloren. Die Aurora ist weg. Wir brauchen einen Ort, den weder Ashford noch der Rat auf dem Schirm haben."

Sie deutet auf Südamerika. Die südlichste Spitze.

„Patagonien. Dort gibt es alte Verbündete."

„Die Wächter", sagt mein Vater leise.

Okonkwo nickt. „Ja. Die Wächter."

Ich sehe aus dem Fenster. Unter uns liegt die Antarktis, weiß und unschuldig, als hätte sie nicht gerade versucht, uns zu töten.

Wir haben überlebt. Aber der Krieg hat gerade erst begonnen.

„ARIA", sage ich leise. „Status der Schlüssel."

„Vier Schlüssel an Bord, Dr. Vasquez. Alle aktiv. Und..."

„Und was?"

„Sie singen, Dr. Vasquez. Sie rufen nach den anderen."

Ich umklammere das Amulett. Ich kann es spüren. Ein Ziehen. Ein Hunger.

Die Dunkelheit weiß, dass wir kommen.

~ keys_collected = 5
~ darkness_connection = darkness_connection + 1

-> kapitel_9

=== kapitel_9 ===
// Platzhalter für das nächste Kapitel
...

-> END
