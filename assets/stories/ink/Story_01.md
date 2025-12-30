// ---------------------------------------------
// FÜNF AKTE DER STILLE — Psychothriller (Ink)
// Tags: #BG:... #IMG:... #MOOD:... #SFX:...
// ---------------------------------------------

VAR guilt = 0
VAR dissociation = 0
VAR trust = 0
VAR name_known = false
VAR confession = false

-> act1

// =====================
// AKT I — DIE UHR
// =====================
=== act1 ===
#BG:act1_apartment
#IMG:act1_0217
#MOOD:still,eng
#SFX:rain,clock

02:17.

Der Regen schreibt dünne Linien an dein Fenster, als würde jemand von draußen *zählen*.  
Du sitzt auf dem Boden, Rücken an der Couch, als wärst du irgendwo gelandet statt nach Hause gekommen.

Die Uhr tickt zu laut.  
Nicht, weil sie kaputt ist — sondern weil du zu still bist.

* [Aufstehen. Licht an. Kontrolle zurückholen.] -> act1_light
* [Sitzen bleiben. Hinhören. Auf das, was du nicht hören willst.] -> act1_listen
* [Zur Haustür gehen und prüfen, ob sie wirklich abgeschlossen ist.] -> act1_door

=== act1_light ===
#IMG:act1_flicker

Das Licht flackert, als würde es sich erinnern, wie oft du es in den letzten Nächten eingeschaltet hast.  
Ein Schatten an der Wand — nicht groß, nicht klar. Eher eine *Lücke* im Licht.

~ dissociation += 1

Du schluckst. Dein Hals fühlt sich an wie Papier.

* [Zur Wand gehen. Hand auf den Putz.] -> act1_wall
* [Dich zwingen, zu atmen. Eins… zwei… drei…] -> act1_breathe

=== act1_listen ===
#IMG:act1_earwall

Du hältst den Atem an.  
Und dann hörst du es:

Ein leises Kratzen, als würde jemand einen Fingernagel über Tapete ziehen.  
Und eine Stimme, gedämpft, nah. Direkt hinter der Wand.

„Du hast mich nicht zurückgerufen.“

~ guilt += 1
~ trust += 1

* [Antworten: „Wer ist da?“] -> act1_answer
* [Flüstern: „Hör auf…“] -> act1_stop
* [Wegsehen. Als wäre es nie passiert.] -> act1_denial

=== act1_door ===
#IMG:act1_chain

Das Schloss ist zu. Die Kette hängt. Alles ist so, wie es sein soll.  
Und trotzdem legst du die Stirn an die Tür, als könntest du dadurch spüren, ob draußen jemand atmet.

In der Stille hörst du deinen Puls — und darunter etwas anderes.  
Ein *zweiter* Rhythmus. Von irgendwo in der Wand.

~ dissociation += 1

* [Zurück ins Zimmer. Der Wand folgen.] -> act1_wall
* [Bleiben. Lauschen an der Tür.] -> act1_listen

=== act1_breathe ===
Du atmest ein.  
Und beim Ausatmen spürst du: Deine Hände zittern nicht vor Angst.

Sie zittern vor… *Erinnerung.*

~ guilt += 1

* [Zur Wand.] -> act1_wall
* [Zum Handy greifen und jemanden anrufen.] -> act1_phone

=== act1_phone ===
#IMG:act1_phone_dark
#SFX:dialtone

Dein Handy ist kalt, als hättest du es im Kühlschrank aufbewahrt.  
Du siehst deine letzten Anrufe.

Einer ist markiert. Ein Name, der dich trifft wie ein Schlag, obwohl du nicht weißt, warum.

„MARA“

Der letzte Anruf: **vor 9 Tagen**.

~ name_known = true
~ guilt += 1

* [Mara anrufen.] -> act1_call_mara
* [Nummer löschen. So tun, als wäre sie nie da gewesen.] -> act1_denial
* [Handy weglegen. Zur Wand.] -> act1_wall

=== act1_call_mara ===
#SFX:call_fail
Es klingelt nicht.  
Es *atmet*. Dann: „Diese Nummer ist nicht vergeben.“

Dein Magen kippt.  
Du starrst auf den Namen, als würdest du erwarten, dass er sich selbst erklärt.

~ dissociation += 1

-> act1_wall

=== act1_answer ===
„Wer ist da?“ fragst du.

Die Stimme lacht nicht. Sie bricht nur ganz leicht, wie ein Mensch, der versucht ruhig zu bleiben.

„Du weißt es. Du willst es nur nicht wissen.“

~ trust += 1
~ guilt += 1

-> act1_wall

=== act1_stop ===
„Hör auf…“ sagst du.

„Ich habe nie angefangen“, antwortet die Stimme.  
„Du hast mich nur irgendwann übertönt.“

~ dissociation += 1

-> act1_wall

=== act1_denial ===
Du wendest den Blick ab.

Der Raum bleibt gleich.  
Aber in dir verschiebt sich etwas, als wäre eine Tür zugefallen, die du offen lassen musstest.

~ dissociation += 2

-> act1_wall

=== act1_wall ===
#BG:act1_wall_close
#IMG:act1_wall_cracks
#MOOD:kalt,dicht

Deine Hand liegt auf dem Putz.  
Kalt. Zu kalt.

Du spürst darunter ein kaum merkliches Vibrieren — wie ein Herzschlag, der nicht deiner ist.

Dann: drei Klopfer.  
Wartend.

* [Zurückklopfen.] -> act1_knock
* [Flüstern: „Was willst du?“] -> act1_whatwant
* [Sofort weg. Abstand.] -> act2

=== act1_knock ===
Du klopfst zurück. Einmal. Zweimal. Dreimal.

Stille.

Dann klopft es exakt in deinem Rhythmus zurück — als hätte jemand auf dich gewartet.  
Als hätte jemand gelernt, du zu sein.

~ dissociation += 1
~ trust += 1

-> act2

=== act1_whatwant ===
#IMG:act1_shadowline

„Was willst du?“ fragst du.

Die Stimme ist plötzlich nah. Nicht hinter der Wand.  
*In deinem Ohr.*

„Dich.“

Und dann leiser:

„Und dass du mich endlich erinnerst.“

~ guilt += 2
~ dissociation += 1

-> act2


// =====================
// AKT II — DER FLUR
// =====================
=== act2 ===
#BG:act2_hallway
#IMG:act2_endless_hall
#MOOD:verloren,unwirklich
#SFX:hum

Du reißt die Wohnungstür auf.

Der Flur ist zu lang.  
Zu sauber.  
Zu *identisch.*

Türen links. Türen rechts. Jede gleich. Jeder Türspion wie ein Auge, das nicht blinzelt.

„Du kannst da nicht raus“, sagt die Stimme.

„Hier ist niemand mehr.“

~ dissociation += 1

* [Zur Treppe. Raus, runter, weg.] -> act2_stairs
* [Zur Nachbarstür. Hilfe holen.] -> act2_neighbor
* [Zurück in die Wohnung. Wenn das hier ein Fehler ist, gehört er dir.] -> act2_back

=== act2_stairs ===
#IMG:act2_stairs_down

Du rennst zur Treppe — doch nach der ersten Etage kommt wieder dieselbe Etage.  
Gleiche Fußmatte. Gleicher Fleck an der Wand. Gleiche Luft.

Du schluckst würgend.

„Du hast das schon mal versucht“, flüstert die Stimme.

~ dissociation += 2
~ guilt += 1

* [Weiter rennen. Trotz allem.] -> act2_loop
* [Anhalten. Hinsetzen. Zuhören.] -> act2_sit

=== act2_loop ===
Du rennst.

Die Stufen schlagen gegen deine Knie, bis sie sich anfühlen wie fremde Gelenke.  
Wieder dieselbe Etage. Wieder derselbe Fleck. Wieder derselbe Geruch.

Und diesmal liegt auf dem Boden ein kleiner, nasser Schlüssel.

#IMG:act2_key

* [Schlüssel aufheben.] -> act2_take_key
* [Nicht anfassen. Nicht schon wieder. Weiter.] -> act2_sit

=== act2_take_key ===
Du hebst ihn auf.

Er ist warm.  
Als hätte ihn gerade jemand in der Faust gehalten.

Auf dem Anhänger: **„MARA“**

~ name_known = true
~ guilt += 2
~ trust += 1

-> act2_sit

=== act2_sit ===
#IMG:act2_floor_sit
Du setzt dich auf den kalten Boden.

Die Kälte zieht nicht in deine Haut — sie zieht in deine Gedanken.

„Ich war da“, sagt die Stimme.  
„Ich habe dich gesehen.“

* [„Was habe ich getan?“] -> act2_whatdidido
* [„Du lügst.“] -> act2_liar
* [„Wenn du Mara bist… warum bist du hier?“] -> act2_if_mara

=== act2_whatdidido ===
Die Stimme atmet ein, als würde sie Schmerzen schlucken.

„Du hast mich gebeten, still zu sein.“  
„Und ich war still.“  
„So still, dass niemand gekommen ist.“

Ein Bild sticht durch deinen Kopf: Blaulicht, verschwommen.  
Deine Hände. Rot.  
Nicht viel. Nur genug, um sich nie wieder sauber anzufühlen.

~ guilt += 3

-> act3

=== act2_liar ===
„Du lügst“, sagst du.

„Vielleicht“, sagt die Stimme.  
„Aber du weißt, dass deine Wahrheit auch nur eine Version ist.“

Für einen Moment ist dir schlecht, weil du plötzlich nicht sicher bist, ob du heute schon gegessen hast.  
Oder ob „heute“ überhaupt existiert.

~ dissociation += 2

-> act3

=== act2_if_mara ===
Wenn du den Namen aussprichst, brennt er.

„Mara“, sagst du.  
„Bist du… Mara?“

Die Stimme wird sehr leise.

„Ich war Mara, bevor du beschlossen hast, dass du ohne mich leichter atmen kannst.“

~ guilt += 2
~ trust += 2

-> act3

=== act2_neighbor ===
#IMG:act2_neighbor_door

Du hämmerst an die Nachbarstür.

Nichts.

Noch einmal.

Nichts.

Dann hörst du hinter der Tür ganz leise… dein eigenes Klopfen.  
Als Echo. Als Kopie. Als Spott.

~ dissociation += 2

-> act2_sit

=== act2_back ===
Du gehst zurück.

Die Wohnungstür ist zu.  
Du bist dir nicht sicher, ob du sie geschlossen hast.

Als du die Klinke drückst, fühlst du kurz Widerstand — als hielte jemand von innen dagegen.

~ trust += 1
~ dissociation += 1

-> act3


// =====================
// AKT III — DIE ERINNERUNG
// =====================
=== act3 ===
#BG:act3_memory_room
#IMG:act3_blue_light
#MOOD:schuld,driftend
#SFX:police_distant

Du blinzelst — und der Flur ist weg.

Du stehst in deinem Wohnzimmer. Aber anders:  
Die Luft ist schwerer. Die Farben sind flacher.  
Wie in einer Erinnerung, die du zu oft bearbeitet hast.

Auf dem Couchtisch liegt ein Notizbuch.

Es ist offen.  
Die Handschrift ist deine. Nur… nicht wie du *heute* schreibst.

Da steht:

„WENN ICH ES VERGESSE, IST ES DANN PASSIERT?“

* [Notizbuch lesen.] -> act3_read
* [Notizbuch zuklappen. Nicht heute.] -> act3_close
* [Nach der Stimme rufen.] -> act3_call_voice

=== act3_read ===
#IMG:act3_notebook

Seite für Seite.

Du findest Listen:  
„Sachen, die mich beruhigen.“  
„Sachen, die mich zerstören.“  
„Sachen, die Mara gesagt hat, bevor…“

Der Satz bricht ab. Immer.  
Jede Seite endet dort, wo es weh tut.

~ guilt += 2

* [Weiterblättern bis zum Ende.] -> act3_endpage
* [Aufhören. Du brauchst Luft.] -> act3_call_voice

=== act3_endpage ===
Auf der letzten Seite klebt ein Foto.

Du und eine Frau.  
Mara. (Du weißt es, ohne es zu wissen.)

Ihr lächelt nicht.  
Ihr schaut beide so, als würdet ihr versuchen, etwas auszuhalten, das gleich passiert.

Auf der Rückseite steht:

„DU HAST MIR VERSPROCHEN, NICHT WEGZUSEHEN.“

~ name_known = true
~ guilt += 3

-> act3_call_voice

=== act3_close ===
Du klappst das Notizbuch zu.

Das Geräusch ist zu laut.  
Als würde etwas in deinem Kopf zuschnappen.

~ dissociation += 1

-> act3_call_voice

=== act3_call_voice ===
#IMG:act3_wall_ear_again

„Was willst du von mir?“ fragst du in die Stille.

Die Stimme ist nicht triumphierend. Sie ist müde.

„Dass du mich ansiehst.“  
„Dass du *bleibst*, wenn es schwer wird.“

Du merkst, dass du weinst — nicht dramatisch, nicht schön.  
Eher wie ein Körper, der endlich aufhört, sich zu verstellen.

* [„Ich kann nicht.“] -> act3_cant
* [„Ich will es wissen. Alles.“] -> act3_all
* [„Wenn du Mara bist… sag mir, was ich ihr angetan habe.“] -> act3_what_i_did

=== act3_cant ===
„Ich kann nicht“, sagst du.

„Doch“, sagt die Stimme.  
„Du hast es nur geübt, es *nicht* zu können.“

~ dissociation += 1

-> act4

=== act3_all ===
„Ich will alles“, sagst du.

„Dann hör auf zu verhandeln“, sagt die Stimme.  
„Du hast schon bezahlt.“

~ trust += 1
~ guilt += 1

-> act4

=== act3_what_i_did ===
Die Stimme wird ganz still.

Dann: „Du hast sie nicht gestoßen.“  
„Du hast sie nicht geschlagen.“

„Du hast nur… *weggeguckt*.“  
„Und als sie dich gebraucht hat, hast du beschlossen, dass es leichter ist, wenn es sie nicht gibt.“

Ein Schrei in deiner Erinnerung. Kurz. Abgeschnitten.  
Und deine Hände, die das Handy nicht wählen.

~ guilt += 4

-> act4


// =====================
// AKT IV — DER SPIEGEL
// =====================
=== act4 ===
#BG:act4_bathroom
#IMG:act4_mirror
#MOOD:konfrontation,nackt
#SFX:drip

Du stehst im Bad.

Der Spiegel ist beschlagen, obwohl du nicht geduscht hast.  
Du wischst ihn frei.

Dein Gesicht ist deins.  
Und doch wirkt es wie eine Maske, die zu lange getragen wurde.

Hinter dir — im Spiegel — steht jemand.  
Nicht klar. Nicht fest. Aber da.

„Mara“, flüsterst du, und dein Mund formt den Namen so, als wäre er eine Entschuldigung.

* [Umdrehen.] -> act4_turn
* [Im Spiegel bleiben. In die Augen sehen.] -> act4_stare
* [Den Spiegel abdecken. Schluss damit.] -> act4_cover

=== act4_turn ===
Du drehst dich um.

Da ist niemand.

Aber du fühlst etwas an deinem Rücken — nicht eine Hand, sondern die Erinnerung an eine Hand.

„Ich bin hier“, sagt die Stimme.  
„So wie du immer hier warst, auch wenn du so getan hast, als wärst du weg.“

~ trust += 1

* [„Ich habe Angst.“] -> act4_fear
* [„Ich verdiene das.“] -> act4_deserve
* [„Sag mir, wie ich es beende.“] -> act4_endit

=== act4_stare ===
Du bleibst.

Du zwingst dich, nicht zu blinzeln.  
Nicht zu fliehen.

Und langsam erkennst du:  
Die Gestalt im Spiegel ist nicht *hinter* dir.

Sie ist in deinem Blick. In deinem Ausdruck. In dem Teil von dir, den du abgespalten hast, um weiter zu funktionieren.

~ dissociation += 2
~ trust += 1

* [„Bist du ich?“] -> act4_am_i
* [„Bist du Mara?“] -> act4_is_she
* [„Was ist damals passiert?“] -> act4_what_happened

=== act4_cover ===
Du hängst ein Handtuch über den Spiegel.

Dunkel.

Erleichterung — für genau zwei Sekunden.  
Dann spürst du, wie das Handtuch sich *bewegt*, als atmete darunter etwas.

~ dissociation += 2
~ guilt += 1

-> act4_endit

=== act4_fear ===
„Ich habe Angst“, sagst du.

„Ich auch“, sagt die Stimme.  
Und das ist das Schlimmste daran — dass sie ehrlich klingt.

~ trust += 2

-> act4_endit

=== act4_deserve ===
„Ich verdiene das“, sagst du.

„Das ist bequem“, antwortet die Stimme.  
„Wenn du dich selbst verurteilst, musst du dich nicht verändern.“

~ guilt += 1

-> act4_endit

=== act4_endit ===
#IMG:act4_sink_hands
Du starrst auf deine Hände im Waschbecken.

Sie sind sauber.  
Aber sie fühlen sich nicht so an.

„Es gibt zwei Wege“, sagt die Stimme.  
„Einer ist leicht.“  
„Einer ist wahr.“

* [Den leichten Weg wählen: vergessen. Zurück in die Stille.] -> act5_forget
* [Den wahren Weg wählen: erinnern. Aussprechen.] -> act5_confess
* [Etwas Drittes versuchen: Mara anrufen, egal ob die Nummer existiert.] -> act5_call

=== act4_am_i ===
„Bist du ich?“

Die Stimme lächelt in deiner Kehle.

„Ich bin der Teil, der geblieben ist.“  
„Du hast mich eingemauert, damit du schlafen kannst.“

~ dissociation += 1
-> act4_endit

=== act4_is_she ===
„Bist du Mara?“

„Ich bin, was von ihr in dir übrig ist“, sagt die Stimme.  
„Und was von dir übrig bleibt, wenn du aufhörst zu lügen.“

~ guilt += 1
~ trust += 1
-> act4_endit

=== act4_what_happened ===
„Was ist passiert?“

„Sie hat dich angerufen“, sagt die Stimme.  
„Und du hast nicht abgehoben.“  
„Du hast zugesehen, wie das Display dunkler wurde.“

~ guilt += 2
-> act4_endit


// =====================
// AKT V — DIE ENTSCHEIDUNG
// =====================
=== act5_forget ===
#BG:act5_bedroom
#IMG:act5_dark_bed
#MOOD:taub,ruhig
#SFX:blanket

Du legst dich ins Bett.

Du atmest so, wie du es geübt hast: flach, leise, unauffällig.  
Wie jemand, der niemanden stören will — nicht einmal die Wahrheit.

Die Stimme wird leiser.  
Und noch leiser.

Bis du glaubst, sie sei weg.

Am Morgen ist alles normal.  
Fast.

Auf deinem Nachttisch liegt ein Schlüsselanhänger.

„MARA“.

~ confession = false

-> ending_check

=== act5_confess ===
#BG:act5_kitchen_morning
#IMG:act5_note_and_light
#MOOD:schmerz,auflosung
#SFX:breath,pen

Du setzt dich an den Tisch.  
Nimmst das Notizbuch. Einen Stift.

Die Hand zittert, aber du schreibst trotzdem.

„Ich habe nicht abgehoben.“

Ein Satz.  
So klein.  
Und schwer wie ein Körper.

„Ich habe dich allein gelassen.“

Du weinst wieder. Nicht um dich.  
Um den Menschen, den du nicht gehalten hast.

~ confession = true
~ guilt += 1
~ trust += 2

Die Stimme atmet auf — als würde sie endlich nicht mehr gegen Beton sprechen.

„Danke“, sagt sie.  
Und diesmal klingt es nicht wie ein Sieg.

-> ending_check

=== act5_call ===
#BG:act5_phone_close
#IMG:act5_dial
#MOOD:panik,hoffnung
#SFX:ring

Du wählst die Nummer.

Es klingelt einmal.  
Zweimal.

Dann hebt jemand ab.

Und du hörst — nicht Mara, nicht eine Fremde — sondern dich selbst.  
Deine eigene Stimme, müde, ruhig:

„Du bist spät.“

~ dissociation += 2
~ trust += 1

* [„Wer bist du?“] -> act5_who
* [„Es tut mir leid.“] -> act5_sorry
* [Auflegen.] -> act5_hang

=== act5_who ===
„Wer bist du?“

„Ich bin die Version, die abgehoben hätte“, sagt die Stimme.  
„Und ich bin müde, dich zu tragen.“

~ guilt += 2
-> ending_check

=== act5_sorry ===
„Es tut mir leid.“

Stille. Dann ein Schlucken am anderen Ende.

„Sag ihren Namen“, sagt die Stimme.  
„Nicht als Gespenst. Als Mensch.“

Wenn du es tust, reißt etwas in dir auf — und darunter ist Luft.

~ confession = true
~ trust += 2

-> ending_check

=== act5_hang ===
Du legst auf.

Und sofort klingelt das Handy wieder.

Nicht dein Handy.  
Dein *Kopf*.

~ dissociation += 2
-> ending_check


// =====================
// ENDE-CHECK (mehrere Enden)
// =====================
=== ending_check ===
{confession:
    -> ending_truth
- else:
    {dissociation >= 5:
        -> ending_split
    - else:
        {guilt >= 6:
            -> ending_wall
        - else:
            -> ending_open
        }
    }
}

=== ending_truth ===
#BG:end_truth
#IMG:end_truth_window
#MOOD:schmerz,heilung

Du öffnest das Fenster.

Der Regen riecht plötzlich nach etwas Echtem.  
Nicht nach Strafe. Nicht nach Erinnerung.  
Nur nach Welt.

Die Stimme ist noch da — aber sie ist nicht mehr hinter der Wand.  
Sie ist ein Teil von dir, der sprechen darf.

Und du weißt:  
Das ist nicht „gut“.  
Aber es ist wahr.

**ENDE: WAHRHEIT**

-> END

=== ending_split ===
#BG:end_split
#IMG:end_split_mirrorfracture
#MOOD:zerfall,stille

Der Spiegel im Bad ist wieder frei.

Diesmal siehst du zwei Gesichter.  
Beide deins.

Eines blinzelt.  
Eines nicht.

Und du begreifst:  
Du hast die Wand nicht gebaut, um Mara auszusperren.

Du hast sie gebaut, um dich selbst nicht hören zu müssen.

**ENDE: SPALTUNG**

-> END

=== ending_wall ===
#BG:end_wall
#IMG:end_wall_breathing
#MOOD:gefangen,schuld
#SFX:knock

Du stehst vor der Wand.

Sie pulsiert. Ganz leicht.  
Als wäre dahinter jemand, der immer noch wartet.

Und du wartest auch.  
Auf den Moment, in dem Vergessen endlich so wirkt wie Vergebung.

Er kommt nicht.

**ENDE: DIE WAND**

-> END

=== ending_open ===
#BG:end_open
#IMG:end_open_note
#MOOD:zweifel,weiter

Am Morgen ist es still.

Du findest einen Zettel auf dem Tisch, in deiner Handschrift:

„Wenn du das liest, war es wieder Nacht.“

Darunter ein zweiter Satz — nicht in deiner Handschrift:

„Und ich war wieder wach.“

**ENDE: OFFEN**

-> END
