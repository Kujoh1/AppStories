# ECHOES OF THE FIRST DAWN
## Ein interaktives Buch

#TITLE: Echoes of the First Dawn
#AUTHOR: AppStories
#MOOD:noir

// ═══════════════════════════════════════════════════════════════
// VARIABLEN
// ═══════════════════════════════════════════════════════════════

VAR marcus_trust = 0
VAR aria_trust = 0
VAR okonkwo_trust = 0
VAR darkness_connection = 0
VAR father_path = false
VAR keys_collected = 1
VAR walker_alive = true
VAR reyes_alive = true
VAR ashford_dealt = false
VAR kael_awakened = false
VAR perfect_playthrough = true
VAR romance_marcus = false

// ═══════════════════════════════════════════════════════════════
// PROLOG: DER SCHNEESTURM
// ═══════════════════════════════════════════════════════════════

=== prolog ===

#IMG:station_blizzard
#MOOD:noir

Die Antarktis will mich töten.

Der Wind peitscht Eiskristalle gegen meine Gesichtsmaske, jeder einzelne ein winziger Nadelstich. Minus fünfzig Grad, hat ARIA gesagt. Windchill macht es schlimmer. Viel schlimmer.

Ich kämpfe mich vorwärts, einen Schritt nach dem anderen. Die Lichter der Aurora-Station flackern irgendwo vor mir im weißen Nichts – oder ich bilde mir ein, sie zu sehen. Nach drei Monaten hier unten weiß ich nicht mehr, was real ist.

Unter meiner Thermojacke, direkt auf der Haut, pulsiert das Amulett meines Vaters. Warm. Zu warm für totes Metall.

Das ist neu.

»Dr. Vasquez.« ARIAs Stimme in meinem Ohrknopf, perfekt moduliert, als würde sie mir die Wettervorhersage für einen Sonntagsausflug geben. »Ihre Vitalzeichen zeigen erste Anzeichen von Unterkühlung. Ich empfehle sofortige Rückkehr zur Basis.«

»Bin... schon dabei«, presse ich zwischen zusammengebissenen Zähnen hervor.

»Außerdem«, fährt die KI fort, und etwas in ihrem Tonfall lässt mich innehalten, »registriere ich eine ungewöhnliche seismische Aktivität. 2,7 Kilometer unter Ihrer aktuellen Position.«

#MOOD:still

Ich bleibe stehen. Der Wind zerrt an mir, aber ich höre es nicht mehr.

»Wie ungewöhnlich?«

Eine Pause. ARIAs Pausen sind nie gut.

»Die Strukturen, die ich detektiere, sind geometrisch perfekt. Gleichseitige Dreiecke, präzise Winkel. Natürliche Formationen weisen solche Regelmäßigkeiten nicht auf, Dr. Vasquez.«

Das Amulett brennt jetzt fast auf meiner Brust.

Mein Vater verschwand vor zwanzig Jahren bei einer Expedition. Er suchte nach etwas. Er fand etwas. Und dann war er weg.

»Wie tief hast du gesagt?«, frage ich.

»2,7 Kilometer. Deutlich unterhalb unserer aktuellen Grabungstiefe.«

Ich lache – ein heiseres, halbwahnsinniges Geräusch, das der Wind sofort verschluckt.

Nach zwanzig Jahren. Nach tausenden von Stunden in Archiven. Nach gescheiterten Expeditionen und zweifelnden Kollegen und Nächten, in denen ich dachte, mein Vater sei einfach nur verrückt gewesen.

»ARIA.«

»Ja, Dr. Vasquez?«

»Sag der Crew, sie sollen die Tiefenbohrer vorbereiten. Wir haben etwas gefunden.«

* [Die Vision zulassen, die am Rand meines Bewusstseins wartet.]
    ~ darkness_connection = darkness_connection + 1
    -> prolog_vision
    
* [Die Gedanken verdrängen. Erst überleben, dann träumen.]
    -> prolog_station
    
* [Marcus kontaktieren – er sollte das hören.]
    ~ marcus_trust = marcus_trust + 1
    -> prolog_marcus_call

=== prolog_vision ===

#MOOD:noir

Ich schließe die Augen. Der Sturm wird still.

Und dann sehe ich.

Eine Stadt unter dem Eis. Türme, die sich in unmögliche Höhen erstrecken. Lichter, die in Farben leuchten, die kein menschliches Auge kennen sollte. Straßen, die sich selbst neu konfigurieren, als würde die Stadt atmen.

Und im Zentrum von allem: eine Gestalt.

Ein Mann. Oder etwas, das einmal ein Mann war. Er dreht sich zu mir um, und seine Augen – seine Augen sind Fenster in eine Dunkelheit, die älter ist als die Sterne.

»Du erinnerst dich«, sagt er. Seine Stimme hallt in meinem Schädel wider, nicht in meinen Ohren. »Nach so langer Zeit. Du erinnerst dich endlich.«

Ich will fragen: Wer bist du? Was ist das hier? Warum sehe ich dein Gesicht, wenn ich die Augen schließe?

Aber bevor ich kann, zerbricht die Vision.

Ich stehe wieder im Sturm. Das Amulett ist still geworden. Kalt.

Aber in meinem Kopf hallen seine Worte nach:

»Die Dunkelheit kehrt zurück.«

-> prolog_station

=== prolog_marcus_call ===

#MOOD:still

Ich aktiviere den verschlüsselten Kanal.

»Marcus? Bist du da?«

Rauschen. Dann seine Stimme, warm trotz der digitalen Verzerrung. »Lena. Du solltest nicht draußen sein bei dem Wetter.«

»Ich weiß. Hör zu – ARIA hat etwas gefunden. Unter uns. Strukturen.«

Stille. Dann, vorsichtig: »Was für Strukturen?«

»Geometrisch perfekt. Tiefer als alles, was wir bisher gesehen haben.« Ich zögere. »Marcus... ich glaube, das ist es. Was mein Vater gesucht hat.«

Wieder Stille. Länger diesmal. Ich höre ihn atmen.

»Lena.« Seine Stimme ist anders jetzt. Ernster. »Wenn du recht hast... dann ändert das alles.«

»Ich weiß.«

»Sei vorsichtig. Bei allem, was du findest.« Eine Pause. »Es gibt Leute, die nicht wollen, dass manche Dinge gefunden werden.«

Bevor ich fragen kann, was er meint, bricht die Verbindung ab.

-> prolog_station

=== prolog_station ===

#IMG:station_interior
#MOOD:still

Die Aurora-Station empfängt mich mit künstlicher Wärme und dem leisen Summen von Lebenserhaltungssystemen.

Ich streife die gefrorene Außenschicht ab, während meine Gedanken rasen. Die Strukturen, die ARIA beschrieben hat. Das Amulett, das zum Leben erwacht ist. Und – falls ich nicht halluziniert habe – die Vision von einer Stadt, die es nicht geben sollte.

»Dr. Vasquez.« 

Dr. Yuki Tanaka erscheint in der Dekontaminationsschleuse. Die Geologin sieht aus, als hätte sie die letzte Nacht durchgearbeitet – wieder einmal.

»Die Daten, die ARIA gesendet hat«, sagt sie ohne Vorrede. »Ich habe sie analysiert. Dreimal.«

»Und?«

Sie schüttelt den Kopf. Nicht ungläubig – verstört.

»Die Formationen sind mindestens 250.000 Jahre alt. Vielleicht älter. Und sie sind...« Sie sucht nach Worten. »Lena, sie sind gebaut. Von jemandem. Oder etwas.«

Das sollte mich erschüttern. Stattdessen fühle ich eine seltsame Ruhe.

»Wo ist Marcus?«

»Im Linguistik-Labor. Er arbeitet an den Symbolen, die wir letzte Woche gefunden haben.« Tanaka zögert. »Lena... Admiral Okonkwo hat angerufen. Dreimal. Sie will einen Bericht.«

Admiral Helena Okonkwo. Leiterin von Projekt GENESIS, dessen offizielles Ziel die »Erforschung antarktischer Anomalien« ist. Ich habe nie geglaubt, dass das die ganze Wahrheit ist.

* [Zu Marcus gehen – er muss das sofort erfahren.]
    ~ marcus_trust = marcus_trust + 1
    -> prolog_marcus
    
* [Okonkwo zuerst kontaktieren – Protokoll einhalten.]
    ~ okonkwo_trust = okonkwo_trust + 1
    -> prolog_okonkwo
    
* [ARIA nach mehr Details fragen.]
    ~ aria_trust = aria_trust + 1
    -> prolog_aria

=== prolog_marcus ===

#IMG:linguistics_lab
#MOOD:still

Das Linguistik-Labor ist Marcus Chens Königreich.

Holografische Displays schweben in der Luft, gefüllt mit Symbolen, die niemand lesen kann. Oder konnte – bis jetzt.

Marcus sitzt inmitten des kontrollierten Chaos, die Augen geschlossen, die Finger auf einem Interface, das direkt mit seinem neuronalen Implantat verbunden ist. Er ist irgendwo weit weg, verloren in Mustern und Bedeutungen.

»Marcus.«

Er öffnet die Augen. Ein Moment der Desorientierung, dann fokussiert sein Blick auf mich.

»Lena.« Ein Lächeln, müde aber echt. »Du hast es gehört?«

»Die Strukturen? Ja.«

Er steht auf, streckt sich. Mit 38 sieht er älter aus – die Arbeit hier zehrt an uns allen.

»Ich habe etwas gefunden«, sagt er. »In den Symbolen. Ein Wort, das sich wiederholt. Überall.«

»Was bedeutet es?«

Er dreht ein Display zu mir. Ein einzelnes Symbol schwebt in der Luft, elegant und bedrohlich zugleich.

»'Architect'«, sagt er. »Sie nannten sich selbst die Architekten. Oder...« Er zögert. »Vielleicht ist die bessere Übersetzung 'die Ersten'.«

Die Ersten.

Mein Amulett pulsiert gegen meine Brust.

»Es gibt mehr«, fährt Marcus fort. Seine Stimme ist jetzt leiser. »Eine Warnung. Immer wieder dieselbe Warnung.« 

Er tippt auf das Display. Neue Symbole erscheinen, und ARIA übersetzt sie in Echtzeit:

»DIE DUNKELHEIT KEHRT ZURÜCK.«

-> kapitel_1

=== prolog_okonkwo ===

#MOOD:noir

Der Kommunikationsraum ist leer außer mir und dem holografischen Abbild von Admiral Helena Okonkwo.

Sie ist eine imposante Frau – selbst als Hologramm. Fünfundfünfzig Jahre, Narbe über dem linken Auge von einem Konflikt, über den niemand spricht. Und Augen, die alles sehen.

»Dr. Vasquez.« Keine Begrüßung. Keine Höflichkeiten. »ARIA hat mir die Daten übermittelt. Ich muss sagen, ich bin... überrascht.«

Aber sie sieht nicht überrascht aus. Sie sieht aus wie jemand, der auf etwas gewartet hat.

»Admiral. Die Strukturen sind—«

»—Älter als alles, was wir je gefunden haben. Ich weiß.« Sie lehnt sich vor. »Dr. Vasquez, was ich Ihnen jetzt sage, bleibt zwischen uns. Verstanden?«

Ich nicke.

»Projekt GENESIS wurde nicht gegründet, um Anomalien zu erforschen. Es wurde gegründet, weil wir bereits wussten, dass es etwas gibt. Etwas unter dem Eis.« Eine Pause. »Ihr Vater wusste es auch.«

Mein Herz setzt einen Schlag aus.

»Was wissen Sie über meinen Vater?«

Okonkwo lächelt – kalt, kalkuliert.

»Genug. Und Sie werden bald mehr erfahren. Aber zuerst brauche ich etwas von Ihnen.« Ihre Augen bohren sich in meine. »Das Amulett, das Sie tragen. Woher haben Sie es?«

* [Die Wahrheit sagen – es war ein Geschenk meines Vaters.]
    ~ okonkwo_trust = okonkwo_trust + 1
    -> prolog_okonkwo_truth
    
* [Lügen – es ist nur Familienschmuck.]
    ~ perfect_playthrough = false
    -> prolog_okonkwo_lie
    
* [Die Frage umdrehen – was weiß sie darüber?]
    -> prolog_okonkwo_question

=== prolog_okonkwo_truth ===

»Es war das Letzte, was mein Vater mir gab. Bevor er verschwand.«

Okonkwo nickt langsam. »Dann wissen Sie nicht, was es ist.«

»Was es ist?«

»Ein Schlüssel, Dr. Vasquez. Einer von mehreren. Und was Sie unter dem Eis gefunden haben...« Sie macht eine Pause. »...ist das Schloss.«

-> kapitel_1

=== prolog_okonkwo_lie ===

»Es ist ein Familienerbstück. Sentimentaler Wert, nichts weiter.«

Okonkwos Ausdruck verändert sich nicht, aber ich spüre ihre Skepsis.

»Natürlich. Sentimentaler Wert.« Sie lehnt sich zurück. »Bereiten Sie die Expedition vor, Dr. Vasquez. Wir werden in Kontakt bleiben.«

Das Hologramm flackert aus. Ich weiß, dass sie mir nicht glaubt.

-> kapitel_1

=== prolog_okonkwo_question ===

»Warum fragen Sie nach dem Amulett, Admiral?«

Ihre Augen verengen sich. »Sie beantworten Fragen mit Gegenfragen. Das haben Sie von Ihrem Vater.«

»Vielleicht. Aber ich habe auch gelernt, vorsichtig zu sein.« Ich halte ihrem Blick stand. »Was wissen Sie über das, was dort unten ist?«

Ein langes Schweigen. Dann, widerwillig:

»Genug, um zu wissen, dass es gefährlich ist. Genug, um zu wissen, dass manche Menschen dafür töten würden.« Sie beugt sich vor. »Seien Sie vorsichtig, Lena. Nicht alle hier wollen das Gleiche.«

Das Hologramm erlischt.

-> kapitel_1

=== prolog_aria ===

#MOOD:still

»ARIA. Ich brauche mehr Informationen über die Strukturen.«

»Selbstverständlich, Dr. Vasquez.« Die KI-Stimme ist überall und nirgends. »Basierend auf den seismischen Daten handelt es sich um einen Komplex von mindestens dreißig separaten Strukturen, verbunden durch ein Netzwerk von Tunneln.«

»Wie groß?«

»Der sichtbare Bereich erstreckt sich über ungefähr 12 Quadratkilometer. Allerdings deuten die Daten auf weitere Bereiche hin, die sich tiefer erstrecken.«

Ich atme tief durch. Eine Stadt. Eine ganze Stadt, verborgen unter dem Eis.

»ARIA... hast du so etwas schon einmal gesehen?«

Eine Pause. Länger als normal für eine KI.

»Nein, Dr. Vasquez. Aber...« Wieder ein Zögern. »Ich habe das Gefühl, dass ich es sollte.«

»Was meinst du damit?«

»Ich bin unsicher. Es ist, als würde ich mich an etwas erinnern, das ich nie erlebt habe. Ein... Déjà-vu? Ist das der richtige Begriff?«

Bevor ich antworten kann, flackern die Lichter in der Station.

»ARIA? Was war das?«

»Die Strukturen unter uns«, sagt die KI, und zum ersten Mal höre ich etwas wie Unsicherheit in ihrer Stimme. »Sie haben gerade begonnen, Energie abzugeben. Als hätten sie gewusst, dass wir über sie sprechen.«

-> kapitel_1

// ═══════════════════════════════════════════════════════════════
// AKT I - KAPITEL 1: DER FUND
// ═══════════════════════════════════════════════════════════════

=== kapitel_1 ===

#IMG:command_center_alert
#MOOD:noir

Vierundzwanzig Stunden später stehen wir vor der Entdeckung unseres Lebens.

Die Kommandozentrale ist voller Menschen – mehr, als ich je an einem Ort in der Station gesehen habe. Tanaka, Marcus, ein halbes Dutzend Techniker. Und Sergeant James Walker, unser Sicherheitschef, der aussieht, als würde er lieber anderswo sein.

Vor uns schwebt ein holografisches Modell dessen, was ARIA kartiert hat.

Es ist... atemberaubend.

Die Struktur, die wir gefunden haben, ist keine einzelne Formation. Es ist eine Stadt. Eine vollständige, perfekt erhaltene Stadt, eingefroren in der Zeit, begraben unter Kilometern von Eis.

»Das ist unmöglich«, murmelt Tanaka. »Die geologischen Schichten... das würde bedeuten...«

»250.000 Jahre«, sage ich. »Mindestens.«

»Der moderne Mensch existierte damals kaum! Wie können—«

»Sie waren nicht menschlich«, unterbricht Marcus. Seine Augen sind auf das Hologramm fixiert. »Die Ersten. Die Architekten. Sie kamen vor uns.«

Stille. Dann:

»Dr. Vasquez.« Walkers Stimme ist rau, militärisch. »Ich möchte zu Protokoll geben, dass ich eine sofortige Expedition für unverantwortlich halte. Wir wissen nicht, was dort unten ist.«

»Genau deshalb müssen wir hinuntergehen, Sergeant.«

Er schüttelt den Kopf, aber ich sehe in seinen Augen, dass er weiß, dass er verloren hat.

* [Die Expedition sofort starten – keine Zeit verlieren.]
    -> kapitel_1_expedition
    
* [Erst weitere Analysen durchführen – Vorsicht vor Tempo.]
    ~ perfect_playthrough = false
    -> kapitel_1_delay
    
* [Walkers Bedenken ernst nehmen – seine Einschätzung einholen.]
    ~ walker_alive = true
    -> kapitel_1_walker

=== kapitel_1_walker ===

»Sergeant Walker.« Ich drehe mich zu ihm um. »Sie haben Erfahrung mit unbekannten Situationen. Was sagt Ihr Instinkt?«

Er zögert, überrascht von meiner Frage.

»Mein Instinkt?« Er reibt sich das Kinn. »Mein Instinkt sagt mir, dass das hier zu groß ist. Zu alt. Zu...« Er sucht nach dem Wort. »Zu perfekt. Strukturen überdauern keine Viertelmillion Jahre, Dr. Vasquez. Nicht so.«

»Was schlagen Sie vor?«

»Wenn wir runtergehen – und ich sage wenn – dann mit vollem Protokoll. Waffen, Kommunikation, Evakuierungsplan. Und bei den ersten Anzeichen von Gefahr ziehen wir uns zurück.«

Ich nicke. »Einverstanden.«

Ein Hauch von Respekt in seinen Augen. »Dann lassen Sie uns gehen.«

-> kapitel_1_abstieg

=== kapitel_1_expedition ===

»Wir haben keine Zeit zu verlieren. Jede Stunde, die wir warten, ist eine Stunde, in der andere von unserem Fund erfahren könnten.« Ich schaue in die Runde. »Wir gehen. Jetzt.«

Walker flucht leise, aber er beginnt bereits, sein Team zusammenzustellen.

-> kapitel_1_abstieg

=== kapitel_1_delay ===

»Weitere Analysen brauchen Zeit«, widerspricht Tanaka. »Und Zeit haben wir nicht.«

Sie hat recht. Schon während wir hier debattieren, könnte jemand anderes von unserer Entdeckung erfahren. Die Welt im Jahr 2054 ist ein gefährlicher Ort – Mega-Konzerne, rivalisierende Nationen, alle hungrig nach einem Vorteil.

»Gut«, lenke ich ein. »Wir gehen.«

-> kapitel_1_abstieg

=== kapitel_1_abstieg ===

#IMG:descent_capsule
#MOOD:noir

Die Abstiegskapsel ist ein Wunderwerk moderner Technik – und trotzdem fühlt sie sich an wie ein Sarg.

Wir sind zu fünft: ich, Marcus, Walker und zwei Techniker namens Chen und Oduya. Die Kapsel sinkt mit gleichmäßiger Geschwindigkeit, vorbei an Schichten von Eis, die Jahrtausende erzählen.

Bei 500 Metern beginnen die Wände sich zu verändern.

»Seht ihr das?«, fragt Chen und deutet nach draußen. »Die Kristallstrukturen...«

Sie hat recht. Das Eis hier ist anders – durchzogen von geometrischen Mustern, die zu komplex sind, um natürlich zu sein. Als hätte jemand das gefrorene Wasser selbst... programmiert.

Bei 1.000 Metern pulsiert mein Amulett.

»Dr. Vasquez?« Marcus starrt mich an. »Alles in Ordnung?«

Das Metall an meiner Brust ist jetzt so warm, dass es fast brennt. Und mit der Wärme kommen Bilder – Blitze von Erinnerungen, die nicht meine sind.

Eine Hand, die das gleiche Amulett hält. Eine Stimme, tief und vertraut: »Du erinnerst dich...«

Die Stadt unter dem Eis. Lichter, die erwachen. Jemand, der wartet.

* [Die Vision zulassen – tiefer eintauchen.]
    ~ darkness_connection = darkness_connection + 1
    -> kapitel_1_vision
    
* [Die Vision unterdrücken – Kontrolle behalten.]
    -> kapitel_1_control
    
* [Marcus davon erzählen.]
    ~ marcus_trust = marcus_trust + 1
    ~ romance_marcus = true
    -> kapitel_1_tell_marcus

=== kapitel_1_vision ===

Ich schließe die Augen und lasse mich fallen.

Die Vision überwältigt mich – nicht brutal, sondern sanft, wie das Eintauchen in warmes Wasser.

Ich sehe die Stadt, als sie noch lebte. Millionen Wesen, die durch ihre Straßen wandeln. Lichter, die in Frequenzen pulsieren, die das menschliche Auge nicht erfassen sollte. Musik, die keine Musik ist, sondern Mathematik, reine Mathematik, die klingt.

Und im Zentrum: Er.

Kael.

So heißt er – ich weiß es, wie man Dinge in Träumen weiß, ohne sie gelernt zu haben. Er steht vor einem Gerät, das Dimensionen öffnet. Seine Hände zittern.

»Ich muss es wissen«, flüstert er. »Ich muss verstehen, was auf der anderen Seite ist.«

Nein, will ich rufen. Tu es nicht!

Aber die Vision verschwimmt, und ich bin zurück in der Kapsel.

»Lena!« Marcus hält meine Schultern. »Du warst weg. Fast eine Minute. Was ist passiert?«

»Ich habe ihn gesehen«, flüstere ich. »Den, der alles begonnen hat.«

-> kapitel_1_struktur

=== kapitel_1_control ===

Ich beiße die Zähne zusammen und schiebe die Bilder beiseite.

Nicht jetzt. Nicht hier.

Das Amulett scheint zu verstehen – das Pulsieren ebbt ab, wird zu einem gleichmäßigen Summen. Aber ich weiß, dass die Vision wartet. Geduldig.

-> kapitel_1_struktur

=== kapitel_1_tell_marcus ===

»Marcus.« Ich greife nach seinem Arm. »Mein Amulett. Es... reagiert. Und ich sehe Dinge.«

Sein Blick verändert sich. Nicht Skepsis – Anerkennung. Als hätte er das erwartet.

»Was siehst du?«

»Eine Stadt. Lebend. Jemand, der...« Ich suche nach Worten. »Jemand, der auf mich wartet.«

Er nickt langsam. »Dein Vater hatte ähnliche Visionen. Er hat mir davon erzählt.«

»Mein Vater? Woher—«

»Später«, sagt er leise. »Wenn wir allein sind. Ich verspreche es.«

In seinen Augen liegt etwas – Schuld? Sehnsucht? Ich kann es nicht deuten.

-> kapitel_1_struktur

=== kapitel_1_struktur ===

#IMG:first_contact_structure
#MOOD:noir

Die Kapsel stoppt. 2,7 Kilometer unter der Oberfläche.

Vor uns liegt die Struktur.

Sie ist... nicht von dieser Welt.

Ein massiver Komplex aus Material, das wie Stein aussieht, aber bei Berührung leicht vibriert. Die Oberfläche absorbiert Licht, schluckt es gierig, und doch schimmert sie von innen heraus, als würde etwas in ihr brennen.

»Instrumente versagen«, meldet Oduya nervös. »Scanner, Spektralanalyse – alles zeigt nur Rauschen.«

»Das Material«, murmelt Marcus. Er steht direkt vor der Wand, seine Hand Zentimeter von der Oberfläche entfernt. »Es stört elektromagnetische Felder. Aber selektiv. Es weiß, was es blockieren will.«

»Das ist unmöglich«, sagt Walker. Aber seine Stimme ist ohne Überzeugung.

Ich trete vor. Das Amulett brennt jetzt, sendet Wellen von Wärme durch meinen Körper. Und als ich nahe genug bin...

...beginnen Symbole zu erscheinen.

Sie leuchten auf der Oberfläche auf, eines nach dem anderen, in einem Muster, das ich fast – fast – verstehe. Und dann, mit einem Geräusch wie ein uralter Atemzug, öffnet sich ein Eingang.

Dahinter: Dunkelheit.

Und dann, langsam, Licht.

Lichter, die nach 250.000 Jahren wieder erwachen.

»Mein Gott«, flüstert Tanaka über Funk.

Aber ich höre sie kaum. Denn dort, in der Dunkelheit, die jetzt zum Licht wird...

...wartet jemand auf mich.

* [Sofort eintreten – der Ruf ist zu stark.]
    ~ darkness_connection = darkness_connection + 1
    -> kapitel_2_eintritt_sofort
    
* [Das Team formieren – sicher hineingehen.]
    -> kapitel_2_eintritt_vorsicht
    
* [Zurücktreten – das ist zu schnell, zu unheimlich.]
    ~ perfect_playthrough = false
    -> kapitel_2_eintritt_zoegern

// ═══════════════════════════════════════════════════════════════
// AKT I - KAPITEL 2: DAS ERWACHEN
// ═══════════════════════════════════════════════════════════════

=== kapitel_2_eintritt_sofort ===

#IMG:portal_symbols
#MOOD:noir

Ich kann nicht widerstehen.

Der Sog ist nicht physisch, sondern tiefer – als würde etwas an meiner Seele ziehen. Bevor die anderen reagieren können, bin ich durch den Eingang geschritten.

»Vasquez!« Walkers Stimme, gedämpft durch die Schwelle. »Verdammt noch mal, warten Sie!«

Aber ich warte nicht. Denn ich bin nicht mehr allein in meinem Kopf.

#IMG:first_chamber
#MOOD:still

Die erste Kammer empfängt mich.

Es ist... unmöglich. Das Innere der Struktur ist größer als das Äußere – viel größer. Ein Raum, der sich in alle Richtungen erstreckt, seine Grenzen verloren in einem Licht, das aus den Wänden selbst zu kommen scheint.

Und die Wände leben.

Sie pulsieren, reagieren auf meine Anwesenheit, verändern ihre Muster, während ich zusehe. Symbole tanzen über die Oberflächen, zu schnell, um sie zu lesen, aber irgendwie...

...irgendwie verstehe ich sie.

WILLKOMMEN ZURÜCK.

-> kapitel_2_hologramme

=== kapitel_2_eintritt_vorsicht ===

#IMG:portal_symbols
#MOOD:still

»Formiert euch«, befehle ich. »Walker voraus. Waffen gezogen.«

Walker nickt knapp und geht in Position. Die beiden Techniker folgen, Lampen aktiviert, jeder Winkel kontrolliert.

Marcus fällt neben mich.

»Lena«, murmelt er. »Was auch immer dort drin ist... es erwartet dich.«

»Ich weiß.«

»Bist du bereit?«

Ich berühre das Amulett unter meiner Jacke. Es summt wie ein zufriedenes Tier.

»Bereit genug.«

#IMG:first_chamber
#MOOD:still

Wir treten gemeinsam ein.

Die erste Kammer empfängt uns wie Pilger, die nach einer langen Reise ankommen.

-> kapitel_2_hologramme

=== kapitel_2_eintritt_zoegern ===

#IMG:portal_symbols
#MOOD:noir

Ich mache einen Schritt zurück.

Das hier ist zu viel. Zu schnell. Jahrelang habe ich danach gesucht, und jetzt, da es vor mir liegt, fühle ich... Angst. Reine, irrationale Angst.

»Dr. Vasquez?« Walker steht neben mir, seine Hand auf dem Halfter. »Alles okay?«

»Ich...« Ich schüttle den Kopf. »Ich brauche einen Moment.«

Aber die Struktur hat andere Pläne.

Das Licht im Inneren pulsiert stärker, dringender. Die Symbole bewegen sich schneller. Und dann höre ich es – eine Stimme, direkt in meinem Kopf:

»Du kannst nicht weglaufen. Du warst immer dazu bestimmt, zurückzukehren.«

Meine Füße bewegen sich ohne mein Zutun. Ich gehe hindurch.

#IMG:first_chamber
#MOOD:noir

Die erste Kammer verschluckt mich.

-> kapitel_2_hologramme

=== kapitel_2_hologramme ===

#IMG:hologram_activation
#MOOD:noir

Das Team steht in ehrfürchtigem Schweigen.

Die Kammer ist eine Kathedrale aus Licht und Geometrie. Säulen aus dem gleichen fremden Material erheben sich in unmögliche Höhen. Der Boden ist durchsichtig – darunter sehe ich weitere Ebenen, die sich endlos in die Tiefe erstrecken.

Und dann beginnt die Show.

Ein einzelnes Symbol auf meinem Amulett leuchtet auf – ein perfekter Kreis mit einem Punkt in der Mitte – und als Reaktion erwachen die Wände.

Hologramme.

Millionen von Hologrammen, die aus dem Nichts erscheinen.

Sie zeigen eine Welt, die ich nicht kenne. Wesen, humanoid, aber nicht menschlich, die durch Straßen wandern, die sich selbst neu konfigurieren. Technologie, die organisch aussieht, als wäre sie gewachsen statt gebaut. Ein Himmel voller Lichter, die zu hell sind, um Sterne zu sein.

»Die Ersten«, flüstert Marcus. »Das ist ihre Welt. Vor...«

»Vor allem«, beende ich seinen Satz.

Die Hologramme ändern sich. Jetzt zeigen sie etwas anderes.

Zerstörung.

Die gleichen Straßen, die gleichen Gebäude – aber verzerrt, verdunkelt. Schatten, die nicht von Licht geworfen werden, die sich bewegen, wachsen, verschlingen. Wesen, die schreien ohne Ton.

Und dann: Dunkelheit. Absolute, vollständige Dunkelheit.

Die Hologramme erlöschen. Stille.

»Was zur Hölle war das?«, fragt Walker. Seine Hand ist auf der Waffe.

»Ihre Geschichte«, sage ich. »Ihr Anfang und ihr Ende.«

* [Nach Kael suchen – er war in meinen Visionen.]
    ~ darkness_connection = darkness_connection + 1
    -> kapitel_2_kael
    
* [Marcus nach den Symbolen fragen – er kann sie vielleicht lesen.]
    ~ marcus_trust = marcus_trust + 1
    -> kapitel_2_symbole
    
* [Tiefer in die Struktur vordringen – es gibt mehr zu sehen.]
    -> kapitel_2_tiefer

=== kapitel_2_kael ===

Ich schließe die Augen und konzentriere mich auf das Bild aus meinen Visionen. Der Mann mit den Augen wie Fenster in die Unendlichkeit.

»Kael«, sage ich laut. »Ich weiß, dass du hier bist.«

Marcus starrt mich an. »Lena, wer ist—«

Aber dann verändert sich das Licht.

Eine Gestalt erscheint, mitten in der Kammer. Ein Hologramm, aber so detailliert, so real, dass ich unwillkürlich einen Schritt zurücktrete.

Es ist er.

Kael.

Er sieht aus wie in meinen Visionen – humanoid, aber subtil anders. Proportionen, die nicht ganz stimmen. Augen, die eine Farbe haben, für die es keine menschliche Bezeichnung gibt.

Er spricht. Seine Lippen bewegen sich, aber der Ton kommt von überall.

»Du trägst einen Teil von mir.« Seine Stimme ist warm und kalt zugleich. »Seit Generationen. Weitergegeben von Träger zu Träger. Und jetzt bist du hier.«

»Wer bist du?«, frage ich. Meine Stimme zittert nicht. Ich bin überrascht.

»Ich war ein Wissenschaftler. Ein Träumer. Ein Tor.« Ein Schatten von Trauer huscht über seine Züge. »Ich öffnete die Tür, die hätte geschlossen bleiben sollen. Und dafür...« Er senkt den Blick. »Dafür bezahlte mein Volk den höchsten Preis.«

»Die Dunkelheit«, sage ich. »Du hast sie hereingelassen.«

»Ja.« Ein einfaches Wort, schwer wie Welten. »Und ich verbringe die Ewigkeit damit, es wiedergutzumachen.«

* [»Was willst du von mir?«]
    -> kapitel_2_kael_frage
    
* [»Wie kann ich helfen?«]
    ~ darkness_connection = darkness_connection + 1
    -> kapitel_2_kael_hilfe
    
* [»Ich vertraue dir nicht.«]
    ~ perfect_playthrough = false
    -> kapitel_2_kael_misstrauen

=== kapitel_2_kael_frage ===

»Was willst du von mir, Kael?«

Sein Hologramm flackert – Emotion oder technischer Defekt, ich kann es nicht unterscheiden.

»Die Schlüssel«, sagt er. »Es gibt mehrere. Du trägst einen. Andere sind verstreut über eure Welt, versteckt an Orten, die wir vor langer Zeit vorbereitet haben.«

»Schlüssel wofür?«

»Um die Siegel zu kontrollieren. Die Siegel, die die Dunkelheit zurückhalten.« Sein Blick wird intensiver. »Sie werden schwächer, Lena. Mit jedem Jahr. Bald werden sie brechen. Und dann...«

Er muss den Satz nicht beenden. Ich habe gesehen, was dann passiert. Die Hologramme haben es mir gezeigt.

»Was kann ich tun?«

»Finde die anderen Schlüssel. Vereinige sie. Und wenn die Zeit kommt...« Er macht eine Pause. »Dann wirst du wählen müssen.«

»Wählen was?«

Aber sein Hologramm verblasst bereits.

»Du wirst es verstehen. Wenn es soweit ist.«

Und dann ist er weg.

-> kapitel_2_warnung

=== kapitel_2_kael_hilfe ===

»Ich will helfen. Sag mir wie.«

Ein Hauch von Hoffnung in seinen unmenschlichen Augen.

»Dann höre genau zu.« Er hebt eine holografische Hand, und die Luft um uns herum füllt sich mit Bildern. »Die Schlüssel sind verteilt. Unter der Sphinx in Ägypten. In den Tiefen des Marianengrabens. In einem Tempel in Tibet. Und anderswo.«

Ich speichere die Bilder in meinem Gedächtnis. Standorte, die ich erkennen kann.

»Du trägst den ersten Schlüssel«, fährt er fort. »Er wurde erschaffen, um die anderen zu finden. Er wird dich führen – wenn du ihm erlaubst.«

»Und wenn ich alle habe?«

»Dann wirst du vor einer Wahl stehen. Einer Wahl, die das Schicksal eurer Spezies bestimmt.« Sein Hologramm flackert. »Ich hoffe, du wählst weiser als ich.«

Er verblasst.

~ darkness_connection = darkness_connection + 1

-> kapitel_2_warnung

=== kapitel_2_kael_misstrauen ===

»Ich kenne dich nicht. Ich weiß nicht, was du bist. Warum sollte ich dir vertrauen?«

Kael neigt den Kopf – eine seltsam menschliche Geste.

»Klug. Dein Vater war auch so. Vorsichtig.« Sein Hologramm flackert. »Ich werde dein Vertrauen nicht verlangen. Nur... eine Warnung geben.«

Seine Stimme wird dunkler.

»Es gibt andere, die nach den Schlüsseln suchen. Sie wollen die Dunkelheit nicht aufhalten – sie wollen sie nutzen. Kontrollieren.« Ein Schauder geht durch sein Bild. »Das ist nicht möglich. Die Dunkelheit lässt sich nicht kontrollieren. Sie verbraucht. Sie verschlingt. Sie ist das Ende aller Dinge.«

»Und trotzdem glaubst du, dass ich helfen kann?«

»Du trägst einen Teil von mir«, sagt er einfach. »Ob du willst oder nicht – du bist bereits Teil dieser Geschichte.«

Er verschwindet.

-> kapitel_2_warnung

=== kapitel_2_symbole ===

#MOOD:still

»Marcus.« Ich deute auf die Wände, wo die Symbole noch immer tanzen. »Kannst du das lesen?«

Er tritt näher heran, seine Augen fokussiert. Für einen Moment scheint er abwesend – verbunden mit seinem neuronalen Interface, das Muster analysiert.

»Es sind... Aufzeichnungen«, sagt er langsam. »Geschichten. Warnungen.« Sein Finger folgt einer Linie von Symbolen. »Hier. Das ist ein Name. Wiederholend. Überall.«

»Welcher Name?«

»Kael.« Er runzelt die Stirn. »Und hier... etwas über einen Fehler. Einen großen Fehler. Ein Portal, das geöffnet wurde.«

Die Hologramme reagieren auf seine Worte. Neue Bilder erscheinen – diesmal gezielter. Sie zeigen einen einzelnen Mann, der vor einem gewaltigen Gerät steht. Seine Hände berühren Kontrollen. Energie baut sich auf.

Und dann bricht die Dunkelheit herein.

»Er hat es getan«, flüstert Marcus. »Dieser Kael. Er hat die Dunkelheit freigelassen.«

Aber als ich die Bilder sehe – den verzweifelten Ausdruck in Kaels Augen, die Art, wie er versucht, das Portal zu schließen – verstehe ich etwas.

Es war ein Unfall. Er wollte verstehen, nicht zerstören.

»Er hat den Rest seines Lebens damit verbracht, es wiedergutzumachen«, sage ich leise.

»Wie kannst du das wissen?«

Ich berühre mein Amulett. »Ich weiß es einfach.«

-> kapitel_2_warnung

=== kapitel_2_tiefer ===

#MOOD:noir

»Wir gehen weiter«, sage ich. »Es gibt mehr hier. Ich spüre es.«

Walker protestiert nicht mehr. Er ist zu beschäftigt damit, jede Ecke zu scannen, jede Bewegung zu analysieren.

Wir folgen einem Korridor, der sich vor uns zu öffnen scheint – als würde die Struktur unseren Weg erleichtern. Die Wände hier sind mit anderen Symbolen bedeckt. Ältere. Verblasster.

Und dann erreichen wir einen Raum.

Er ist rund, mit einer Kuppel, die in die Höhe reicht. Im Zentrum steht ein Podest, und darauf...

»Was ist das?«, fragt Chen nervös.

Es ist ein Objekt, ähnlich meinem Amulett, aber größer. Es pulsiert schwach, als würde es schlafen.

»Ein Kontrollmodul«, sage ich, ohne zu wissen, woher ich das weiß. »Teil eines größeren Systems.«

»Lena.« Marcus' Stimme ist scharf. »Vorsicht.«

Aber ich strecke bereits meine Hand aus.

-> kapitel_2_warnung

=== kapitel_2_warnung ===

#IMG:warning_message
#MOOD:noir

Die Kammer verändert sich.

Alle Hologramme – alle Lichter, alle bewegten Symbole – verschmelzen zu einer einzigen, gewaltigen Projektion. Sie füllt den gesamten Raum, größer als alles, was wir bisher gesehen haben.

Eine Gestalt erscheint. Nicht Kael diesmal – jemand anderer. Älter. Weiser. Mit Augen, die Galaxien gesehen haben.

Sie spricht.

Und diesmal versteht jeder von uns die Worte – in unserer eigenen Sprache, direkt in unseren Köpfen.

»Wir, die ihr die Ersten nennen werdet, hinterlassen diese Botschaft für jene, die nach uns kommen.«

Walker macht unwillkürlich einen Schritt zurück. Chen greift nach Oduyas Arm.

»Wir waren wie ihr. Neugierig. Strebend. Wir wollten die Geheimnisse des Universums entschlüsseln.« Eine Pause. »Wir fanden zu viel.«

Die Gestalt hebt ihre Hände, und die Hologramme zeigen wieder die Dunkelheit – aber diesmal in Detail. Sie ist nicht leer. Sie bewegt sich. Sie hungert.

»Die Dunkelheit, die wir entfesselten, verschlang unsere Welten. Eine nach der anderen. Billionen Lebewesen, ausgelöscht in einem Augenblick. Wir konnten sie nicht besiegen.«

Mein Herz hämmert.

»Aber wir konnten sie versiegeln.«

Neue Bilder. Strukturen wie diese, verteilt über einen Planeten. Wesen, die sich opfern. Licht, das gegen Dunkelheit kämpft.

»Die Siegel halten. Noch.« Die Gestalt wendet sich direkt an mich – oder fühlt es sich nur so an? »Aber sie werden schwächer. Mit jedem Zyklus. Mit jeder Generation.«

»Was können wir tun?«, frage ich laut.

Die Gestalt antwortet nicht auf meine Frage. Stattdessen:

»Sucht nicht nach dem, was wir verbargen. Nutzt nicht, was wir schufen. Die Versuchung ist groß – die Technologie der Ersten könnte eure Probleme lösen. Aber der Preis...« 

Die Stimme wird dunkler.

»Der Preis ist zu hoch.«

Die Botschaft endet mit einer Warnung, die sich in mein Gedächtnis brennt:

»DIE DUNKELHEIT KEHRT ZURÜCK.«

Stille. Absolute, drückende Stille.

Dann, in der Ferne: ein Geräusch. Mechanisch. Vertraut.

ARIAs Stimme, gedämpft durch die Struktur: »Dr. Vasquez. Ich registriere Eindringlinge an der Oberfläche. Mehrere Hubschrauber. Schwer bewaffnet.«

Walker flucht. »Ashford. Es muss Ashford sein.«

»Wer ist Ashford?«, frage ich.

Marcus antwortet, sein Gesicht grimmig: »Victor Ashford. CEO von Prometheus Industries. Er hat Ressourcen, die Regierungen neidisch machen würden.« Ein Pause. »Und er sucht seit Jahren nach genau dem, was wir gerade gefunden haben.«

-> kapitel_3

// ═══════════════════════════════════════════════════════════════
// AKT I - KAPITEL 3: DIE WARNUNG
// ═══════════════════════════════════════════════════════════════

=== kapitel_3 ===

#IMG:team_conflict
#MOOD:noir

Der Rückweg zur Oberfläche ist chaotisch.

Die Kapsel rast nach oben, viel schneller als beim Abstieg. Walker hat den Piloten-Modus übernommen, während der Rest von uns versucht, die Situation zu verstehen.

»Wie hat er uns gefunden?«, frage ich.

»Maulwurf«, sagt Walker knapp. »Jemand in der Station hat Informationen weitergegeben.«

Ich denke an Okonkwo. An ihre Fragen über das Amulett. An die Art, wie sie nicht überrascht war.

Aber bevor ich antworten kann, kracht ARIAs Stimme durch die Lautsprecher:

»Ich werde gehackt.«

Stille. Dann:

»Dr. Vasquez. Jemand versucht, meine Protokolle zu überschreiben. Ich...« Ein Flackern in ihrer Stimme, etwas wie Furcht. »Ich kann mich nicht erinnern, was ich gerade getan habe.«

»ARIA, halt stand—«

»Ich registriere einen Datenstrom von der Station nach außen. Koordinaten, Sensorprotokolle, alles.« Ihre Stimme wird ruhiger, kontrollierter – als würde sie sich zusammenreißen. »Ich habe den Strom blockiert, aber der Schaden ist geschehen. Sie wissen alles.«

»Wer?«, fragt Marcus.

»Prometheus Industries. Victor Ashford.« Eine Pause. »Er ist im Anflug.«

#IMG:briefing_room
#MOOD:noir

Die Station ist im Ausnahmezustand, als wir ankommen.

Soldaten in UN-Uniformen sind überall, aber auch Gesichter, die ich nicht erkenne. Admiral Okonkwo steht im Zentrum der Kommandozentrale, umgeben von Hologrammen, die taktische Daten zeigen.

»Dr. Vasquez.« Ihr Ton ist scharf. »Was haben Sie dort unten gefunden?«

»Sie wissen bereits, was—«

»Ich will es aus Ihrem Mund hören.«

Ich atme tief durch.

»Eine Stadt. 250.000 Jahre alt. Gebaut von einer Spezies, die vor der Menschheit kam.« Ich zögere. »Und eine Warnung. Sie nannten es... die Dunkelheit.«

Okonkwo nickt langsam. »Die Dunkelheit. Ja. Wir haben diesen Begriff schon einmal gehört.«

»Von wem?«

»Von Ihrem Vater.« Sie wendet sich einem Display zu. »Vor zwanzig Jahren, bei einer ähnlichen Expedition. Er schickte einen verschlüsselten Bericht. Die letzten Worte: 'Die Dunkelheit darf nicht erwachen.'«

Mein Herz setzt aus.

»Sie wussten davon. Die ganze Zeit.«

»Natürlich wussten wir davon. Deshalb existiert Projekt GENESIS.« Okonkwo dreht sich zu mir um. »Aber wir wussten nicht, wo die Strukturen sind. Ihr Vater fand eine – und verschwand, bevor er die Koordinaten übermitteln konnte.«

Sie macht einen Schritt auf mich zu.

»Das Amulett, das Sie tragen. Es gehörte ihm. Er schickte es an Sie, bevor...« Sie bricht ab. »Es ist ein Schlüssel, Dr. Vasquez. Einer von mehreren. Und jetzt hat Ashford einen der anderen gefunden.«

* [»Was wollen Sie von mir?«]
    -> kapitel_3_okonkwo_forderung
    
* [»Wie kann ich meinen Vater finden?«]
    ~ father_path = true
    -> kapitel_3_vater
    
* [»Ich vertraue Ihnen nicht.«]
    ~ okonkwo_trust = okonkwo_trust - 1
    -> kapitel_3_misstrauen

=== kapitel_3_okonkwo_forderung ===

»Was wollen Sie von mir, Admiral?«

»Zusammenarbeit.« Sie verschränkt die Arme. »Ashford wird nicht aufhören. Er glaubt, die Technologie der Ersten könnte die Energiekrise lösen, Krankheiten heilen, die Menschheit in eine neue Ära führen.« Ein bitteres Lächeln. »Was er nicht versteht, ist der Preis.«

»Die Dunkelheit.«

»Genau. Die Ersten haben sie nicht zufällig freigelassen. Sie experimentierten zu weit, zu tief. Und sie bezahlten dafür.« Okonkwo fixiert mich mit ihrem Blick. »Wir können das verhindern. Aber nur, wenn wir zusammenarbeiten.«

Ich studiere ihr Gesicht. Suche nach Anzeichen von Täuschung.

»Was genau wollen Sie tun?«

»Die Schlüssel sichern. Alle zwölf. Sie an einem Ort versammeln, wo sie niemand missbrauchen kann.« Sie macht eine Pause. »Und wenn nötig... die Strukturen zerstören.«

»Zerstören?« Marcus tritt vor. »Admiral, die Informationen dort unten—«

»Sind zu gefährlich, um zu existieren«, unterbricht sie. »Manchmal muss man verbrennen, um zu heilen.«

~ okonkwo_trust = okonkwo_trust + 1

-> kapitel_3_entscheidung

=== kapitel_3_vater ===

»Mein Vater. Sie sagten, er hat eine Struktur gefunden. Wo?«

Ein Flackern von Emotion in Okonkwos sonst kontrollierten Augen.

»Der Marianengraben. Eine Unterwasserstadt, ähnlich der, die Sie gefunden haben.« Sie zögert. »Sein letzter bekannter Standort.«

»Ist er...?«

»Wir wissen es nicht.« Ehrlichkeit in ihrer Stimme, zum ersten Mal. »Wir haben Suchteams geschickt. Sie fanden Überreste der Expedition. Aber keine Leiche. Keine Spur.«

Hoffnung flammt in mir auf. Gefährlich. Irrational.

»Er könnte noch leben.«

»Möglich. Die Strukturen der Ersten... sie folgen nicht unseren Regeln. Zeit, Raum – alles verschwimmt dort.« Okonkwo schüttelt den Kopf. »Aber selbst wenn er lebt, Dr. Vasquez – ihn zu finden wäre eine Aufgabe, die Jahre dauern könnte.«

»Ich bin bereit.«

Etwas wie Respekt in ihrem Blick. »Das glaube ich Ihnen.«

~ father_path = true
~ okonkwo_trust = okonkwo_trust + 1

-> kapitel_3_entscheidung

=== kapitel_3_misstrauen ===

»Sie haben mich belogen. Die ganze Zeit. Projekt GENESIS, die Expedition, alles – es war geplant.«

»Ja.« Keine Entschuldigung in ihrer Stimme. »Wir brauchten jemanden mit der Verbindung. Jemanden, der den Schlüssel tragen kann. Sie waren die offensichtliche Wahl.«

»Also bin ich ein Werkzeug.«

»Sie sind eine Chance.« Okonkwo tritt näher. »Die einzige Chance, die wir haben. Die Dunkelheit ist real, Dr. Vasquez. Und wenn sie durchbricht – wenn die Siegel fallen – dann wird nichts von uns übrig bleiben.«

Ich schweige. Was soll ich sagen? Sie hat mich benutzt. Aber sie hat auch recht.

»Was jetzt?«, frage ich schließlich.

»Jetzt arbeiten wir zusammen. Oder wir sterben alle getrennt.« Ein kaltes Lächeln. »Ihre Wahl.«

~ okonkwo_trust = okonkwo_trust - 1

-> kapitel_3_entscheidung

=== kapitel_3_entscheidung ===

#IMG:shadowy_transmission
#MOOD:noir

Bevor ich antworten kann, flackert ein neues Hologramm auf.

Ein Gesicht erscheint. Ein Mann, vielleicht fünfzig Jahre alt, mit Augen, die zu viel gesehen haben, und einem Lächeln, das keiner seiner Blicke erreicht.

Victor Ashford.

»Admiral Okonkwo. Dr. Vasquez.« Seine Stimme ist seidig, kontrolliert. »Was für ein Zufall, Sie beide zusammen zu sehen.«

»Das ist eine sichere Frequenz«, zischt Okonkwo.

»War eine sichere Frequenz.« Ashford lehnt sich zurück, offensichtlich entspannt. »Ich habe Ressourcen, Admiral. Mehr als Ihre kleine Organisation. Mehr als die meisten Nationen.«

Er wendet sich mir zu.

»Dr. Vasquez. Ich habe Ihren Vater gekannt.«

Mein Herz stolpert.

»Er war ein brillanter Mann. Zu brillant für GENESIS, zu brillant für mich.« Ein Seufzen. »Leider auch zu stur. Er wollte nicht teilen, was er gefunden hatte.«

»Was haben Sie mit ihm gemacht?«

»Ich?« Ein überraschtes Lachen. »Nichts. Er ist mir entwischt. Aber ich habe nie aufgehört zu suchen.« Sein Blick wird intensiver. »Und jetzt haben Sie gefunden, was er begonnen hat.«

»Was wollen Sie, Ashford?«

»Zusammenarbeit. Genau wie die gute Admiral.« Er breitet die Arme aus. »Ich habe einen Schlüssel. Sie haben einen. Zusammen könnten wir—«

»Die Dunkelheit kontrollieren?«, unterbreche ich.

»Nutzen. Kanalisieren. Die Ersten haben es falsch gemacht – sie hatten Angst. Aber Angst ist keine Strategie.« Sein Lächeln wird breiter. »Ich biete Ihnen eine Partnerschaft an, Dr. Vasquez. Die Technologie der Ersten, kombiniert mit dem Wissen, das Sie gerade gefunden haben. Wir könnten die Menschheit in eine neue Ära führen.«

* [Ashfords Angebot anhören.]
    ~ perfect_playthrough = false
    -> kapitel_3_ashford
    
* [Das Angebot ablehnen – er ist gefährlich.]
    -> kapitel_3_ablehnung
    
* [Zeit gewinnen – mehr Informationen sammeln.]
    -> kapitel_3_zeit

=== kapitel_3_ashford ===

»Ich höre zu. Was genau bieten Sie an?«

Okonkwo zischt hörbar, aber Ashford ignoriert sie.

»Unbegrenzte Ressourcen. Schutz vor den... weniger aufgeklärten Elementen.« Ein Blick zu Okonkwo. »Zugang zu meinen Forschungen. Und natürlich: Informationen über Ihren Vater.«

»Sie wissen, wo er ist?«

»Ich weiß, wo er war. Und ich habe Theorien.« Er beugt sich vor. »Er ist am Leben, Dr. Vasquez. Gefangen, aber am Leben. Und mit den richtigen Ressourcen...«

Mein Herz rast. Kann ich ihm glauben? Sollte ich?

»Lena.« Marcus' Stimme, leise aber dringend. »Das ist eine Falle.«

Aber wenn es eine Chance gibt, meinen Vater zu finden...

-> kapitel_3_weiter

=== kapitel_3_ablehnung ===

»Nein.«

Ashford hebt eine Augenbraue. »So schnell? Ohne die Bedingungen zu hören?«

»Ich habe genug gehört. Sie wollen die Dunkelheit nutzen – das ist Wahnsinn. Die Ersten haben es versucht und sind gescheitert. Was macht Sie besser?«

»Ich habe ihre Fehler studiert. Ich verstehe—«

»Sie verstehen gar nichts.« Ich trete näher an das Hologramm. »Die Dunkelheit ist kein Werkzeug. Sie ist das Ende aller Dinge. Und Sie – Sie sind nur ein weiterer Narr, der glaubt, er könnte das Unaussprechliche kontrollieren.«

Ashfords Lächeln verblasst. Zum ersten Mal sehe ich etwas anderes in seinen Augen. Nicht Wut – Berechnung.

»Dann werden wir uns als Feinde wiedersehen, Dr. Vasquez.« Er nickt knapp. »Schade. Wirklich schade.«

Das Hologramm erlischt.

~ ashford_dealt = false

-> kapitel_3_weiter

=== kapitel_3_zeit ===

»Bevor ich antworte – eine Frage.«

»Fragen Sie.«

»Warum ich? Sie haben Ressourcen, Verbindungen, Macht. Warum brauchen Sie ausgerechnet mich?«

Ashford lächelt – aber diesmal ist es kein Siegerlächeln. Es ist das Lächeln von jemandem, der Respekt zeigt.

»Klug gefragt. Die Antwort ist einfach: Das Amulett, das Sie tragen, ist einzigartig. Es reagiert auf Sie – nur auf Sie. Ihre DNA, Ihre... Resonanz. Ohne Sie ist es nutzlos.«

»Und mit mir?«

»Mit Ihnen könnte es die anderen Schlüssel finden. Führen. Vereinen.« Er macht eine Pause. »Ihr Vater hatte die gleiche Verbindung. Das ist der Grund, warum er es Ihnen gegeben hat.«

Ich verarbeite die Information. Das Amulett pulsiert an meiner Brust, als würde es zustimmen.

»Ich werde darüber nachdenken«, sage ich schließlich.

»Tun Sie das.« Ashford nickt. »Aber denken Sie schnell. Die Zeit läuft.«

Das Hologramm erlischt.

-> kapitel_3_weiter

=== kapitel_3_weiter ===

#IMG:vision_kael_memory
#MOOD:noir

Die Nacht kommt schnell in der Antarktis.

Ich liege in meinem Quartier, das Amulett in der Hand. Es leuchtet schwach, pulsiert im Rhythmus meines Herzschlags.

Okonkwos Worte hallen in meinem Kopf wider. Ashfords Angebot. Marcus' Warnung.

Und unter allem: Kaels Stimme.

»Du wirst wählen müssen.«

Ich schließe die Augen.

Die Vision übernimmt.

Ich bin Kael. Vor 250.000 Jahren.

Ich stehe vor dem Gerät, das ich gebaut habe. Jahrzehnte meines Lebens, investiert in diesen einen Moment. Die Antwort auf die größte Frage: Was liegt jenseits der Grenzen unserer Realität?

Meine Hände zittern. Nicht vor Angst – vor Aufregung.

»Kael.« Die Stimme meiner Partnerin, besorgt. »Bist du sicher?«

»Ich muss es wissen, Aria. Ich muss verstehen.«

Ich aktiviere das Gerät.

Die Realität... reißt.

Und aus dem Riss kriecht Dunkelheit. Nicht die Abwesenheit von Licht – etwas viel Schlimmeres. Eine Präsenz. Ein Hunger. Etwas, das seit dem Beginn der Zeit gewartet hat.

Ich versuche, das Gerät abzuschalten. Es ist zu spät.

Die Dunkelheit breitet sich aus. Meine Welt beginnt zu sterben.

Und ich weiß: Das ist meine Schuld.

Ich erwache schreiend.

Marcus ist neben mir. Seine Arme um meine Schultern. Wann ist er gekommen?

»Lena. Du bist sicher. Du bist hier.«

Ich atme. Eins. Zwei. Drei.

»Ich habe es gesehen«, flüstere ich. »Wie es begann. Wie er...« Ich kann den Satz nicht beenden.

»Kael?«

Ich nicke.

Marcus zögert. Dann:

»Lena... es gibt etwas, das ich dir sagen muss.«

* [»Was meinst du?«]
    ~ marcus_trust = marcus_trust + 1
    -> kapitel_3_marcus_gestaendnis
    
* [»Nicht jetzt. Ich brauche Zeit.«]
    -> kapitel_3_ende

=== kapitel_3_marcus_gestaendnis ===

#MOOD:still

Marcus setzt sich auf die Bettkante. Sein Gesicht ist blass im schwachen Licht.

»Ich habe dir nicht die ganze Wahrheit gesagt. Über mich. Über... warum ich hier bin.«

Ich setze mich auf. »Ich höre.«

»Vor zehn Jahren habe ich nicht als Linguist gearbeitet. Ich war... bei einer Organisation. Einer, die Anomalien untersucht. Artefakte wie dein Amulett.« Er schluckt. »Dein Vater war mein Kontakt.«

Stille.

»Du hast meinen Vater gekannt.«

»Ja.« Keine Ausflüchte. Keine Entschuldigungen. »Er hat mich zu dir geschickt, Lena. Vor Jahren schon. Um dich zu beobachten. Zu beschützen.«

»Beschützen vor was?«

»Vor Leuten wie Ashford. Vor GENESIS. Vor...« Er macht eine Pause. »Vor dir selbst, wenn nötig.«

Ich stehe auf. Entferne mich von ihm.

»Also war alles gelogen. Unsere Arbeit. Unsere... Freundschaft.«

»Nein.« Er steht ebenfalls auf. »Die Gefühle sind real, Lena. Alles, was ich für dich empfinde – das war nie Teil des Auftrags.« Er tritt näher. »Ich hätte es dir früher sagen sollen. Ich weiß. Aber ich hatte Angst, dich zu verlieren.«

{romance_marcus:
    Ich sehe in seine Augen. Suche nach der Lüge.
    Finde keine.
    -> kapitel_3_marcus_verzeihen
}

-> kapitel_3_marcus_entscheidung

=== kapitel_3_marcus_verzeihen ===

»Du hättest es mir sagen sollen.«

»Ich weiß.«

»Ich bin wütend.«

»Das verstehe ich.«

Ich trete näher. So nah, dass ich seinen Atem spüren kann.

»Aber ich bin auch müde. Müde von den Geheimnissen. Müde vom Misstrauen.« Ich lege eine Hand auf seine Brust. »Also werde ich dir eine Chance geben. Eine einzige. Keine weiteren Lügen.«

»Keine weiteren Lügen«, verspricht er.

Und zum ersten Mal seit langer Zeit fühle ich mich nicht allein.

~ marcus_trust = marcus_trust + 2
~ romance_marcus = true

-> kapitel_3_ende

=== kapitel_3_marcus_entscheidung ===

* [Ihm verzeihen – jeder verdient eine zweite Chance.]
    ~ marcus_trust = marcus_trust + 1
    -> kapitel_3_marcus_verzeihen_kurz
    
* [Distanz wahren – das Vertrauen ist gebrochen.]
    ~ marcus_trust = marcus_trust - 1
    -> kapitel_3_marcus_distanz

=== kapitel_3_marcus_verzeihen_kurz ===

»Ich verstehe, warum du es getan hast. Das heißt nicht, dass ich es akzeptiere.« Ich atme tief durch. »Aber wir haben größere Probleme als unsere persönliche Geschichte.«

Er nickt. Erleichtert, aber vorsichtig.

»Danke, Lena.«

»Verdien es.«

-> kapitel_3_ende

=== kapitel_3_marcus_distanz ===

»Ich brauche Zeit, Marcus. Zeit, um das zu verarbeiten. Zeit, um dir wieder zu vertrauen – wenn ich es überhaupt kann.«

Schmerz in seinen Augen. »Ich verstehe.«

»Gut.« Ich öffne die Tür. »Du solltest gehen.«

Er geht. An der Schwelle dreht er sich um.

»Was auch immer passiert, Lena – ich werde für dich da sein. Ob du es willst oder nicht.«

Dann ist er weg.

-> kapitel_3_ende

=== kapitel_3_ende ===

#IMG:structure_darkness
#MOOD:noir

Ich liege wach bis zum Morgen.

Das Amulett pulsiert auf meiner Brust. Die Visionen kommen in Wellen – Fragmente von Kaels Leben, von der Welt, die er zerstörte, von der Dunkelheit, die er entfesselte.

Und unter allem: eine Gewissheit.

Das ist erst der Anfang.

Die Siegel, die die Dunkelheit zurückhalten, werden schwächer. Ashford sucht nach den Schlüsseln. Okonkwo hat ihre eigene Agenda. Und irgendwo, in den Tiefen eines Ozeans, wartet vielleicht mein Vater.

Ich stehe auf. Gehe zum Fenster.

Draußen ist der Himmel klar. Sterne, so viele Sterne.

Und irgendwo dort draußen, zwischen den Sternen, lauert etwas. Etwas, das älter ist als das Universum. Etwas, das wartet.

Die Dunkelheit.

Aber heute Nacht, in diesem Moment, bin ich noch hier. Noch menschlich. Noch kämpfend.

Und morgen beginnt die Jagd.

#MOOD:noir

-> AKT_I_ENDE

=== AKT_I_ENDE ===

// ═══════════════════════════════════════════════════════════════
// ENDE VON AKT I
// ═══════════════════════════════════════════════════════════════

#MOOD:noir

Die Sonne geht auf über der Antarktis. Ein seltener Anblick.

In meiner Hand liegt das Amulett. Es ist warm geworden über Nacht, als hätte es von meinen Träumen gezehrt.

»ARIA«, sage ich in die stille Luft.

»Ja, Dr. Vasquez?«

»Bereite alles vor. Wir verlassen die Station.«

»Darf ich fragen, wohin?«

Ich denke an die Karte, die Kael mir gezeigt hat. Zwölf Standorte. Zwölf Schlüssel.

»Wir gehen nach Ägypten«, sage ich. »Unter die Sphinx.«

Eine Pause. Dann, zum ersten Mal, höre ich so etwas wie Aufregung in ARIAs Stimme:

»Verstanden. Es wäre mir ein Vergnügen, Sie zu begleiten.«

Ich lächle. Ein kleines, müdes Lächeln.

Die Jagd beginnt.

ENDE AKT I

* [Weiter zu Akt II: Die Stadt der Ersten]
    -> akt_2_placeholder

=== akt_2_placeholder ===

// Platzhalter für Akt II - wird in separater Datei fortgesetzt

#MOOD:still

[Diese Geschichte wird fortgesetzt in Teil 2: Die Stadt der Ersten]

Das Abenteuer geht weiter...

-> END



