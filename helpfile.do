cls // clear console

use http://www.mydofilesforstata.com, clear

**** Aufgabenblatt 6

** Schönere grafische Darstellung 

ssc install schemepack
set scheme tab3

** Erstellung der AV

cap drop eigenheim
gen eigenheim = aq01
recode eigenheim (1 2 3 4 5 = 0) (6 7 = 1) (8 =.)

** 9.4

logit eigenheim i.gs01 age // logarithmierte Chance

logistic eigenheim i.gs01 age // Odds

** 10.2

logit eigenheim age i.gs01 i.eastwest

** durchschnittliche Wahrscheinlichkeiten

margins, at( age=(18 (5) 88) eastwest=(1 2) )
marginsplot 

** Wahrscheinlichkeiten am Durchschnitt

margins, at( age=(18 (5) 88) eastwest=(1 2) ) atmeans
marginsplot

** 10.2.1

margins, at( age=(32) eastwest=(1))

** 10.3

quietly logit eigenheim age i.gs01 i.eastwest hinc

sum hinc if e(sample) // mean = 3501.10 ; Std. dev. 2440.88

margins, at(hinc = 3501.10)

dis 3501.10 + 2440.88

margins, at(hinc = 5941.98)


** 10.4.1

margins, at(hinc=(0 (500) 15000) eastwest=(1 2))
marginsplot

** 10.4.2 (explizieter Interkationseffekt)

logit eigenheim age i.gs01 i.eastwest##c.hinc
margins, at(hinc=(0 (500) 15000) eastwest=(1 2))
marginsplot


** 11.2.

clonevar gender = sex
recode gender (3 =.)
fre gender

clonevar beziehungsstatus = mstat
recode beziehungsstatus (6 = 1) (7 = 2) (8 = 3) (9 = 4)
fre beziehungsstatus

**11.2.1

quietly logit eigenheim age i.gs01 i.eastwest##c.hinc i.gender ib5.beziehungsstatus
est store full

logit eigenheim if e(sample)
est store null

lrtest full null

** 11.2.3

logit eigenheim ib2.eastwest i.gs01 age i.gender hinc ib5.beziehungsstatus

margins, at(eastwest=(1 2))

** 11.2.4

quietly logit eigenheim ib2.eastwest i.gs01 age i.gender hinc ib5.beziehungsstatus
est store full

quietly logit eigenheim ib2.eastwest i.gs01 i.gender hinc if e(sample)
est store reduced

lrtest full reduced
lrtest reduced full

**11.3 // ACHTUNG: hhinc! Kat.Var.

fre dh04
logit eigenheim dh04 ib2.eastwest i.gs01 age i.gender hhinc ib5.beziehungsstatus
logistic eigenheim dh04 ib2.eastwest i.gs01 age i.gender hhinc ib5.beziehungsstatus

*11.4

search spost13

fitstat

dis 1-( -2096.719 / -2802.330 )

estat class

*11.5

quietly logistic eigenheim dh04 ib2.eastwest i.gs01 age i.gender hhinc ib5.beziehungsstatus
fitstat



**** Modellgüte


lfit // Pearson Chiquadrat Test (Residuen zwischen empirischen und modellimplizierten Werten) -> je kleiner, desto besser: Wir wollen keine signifikanten Ergebnisse!

lfit, group(10) // Wenn Konstellationen der UVs annährend Fallzahl (m=n) Peasons Chi nicht aussagekräftig. Hosmer-Lemeshow-Test: Einteilung der Fälle in 10 Gruppen (je Dezil)

* Ausreißer / Leverage

quietly logistic eigenheim dh04 ib2.eastwest i.gs01 age i.gender hinc ib5.beziehungsstatus

predict leverage, hat
predict residuum, res
twoway (scatter leverage residuum, mlabel(respid) xline(0))


list respid eigenheim dh04 eastwest gs01 age gender hhinc beziehungsstatus if respid==1923 // Haus auf dem Land aber kein Eigenheim, verheiratet und getrennt lebend -> ggf. Auszug und zur Miete für Zeit der Scheidung?
list respid eigenheim dh04 eastwest gs01 age gender hhinc beziehungsstatus if respid==837 // sehr interessant! Kein Wohneigentum,33 J. lebt mit 10 weiteren Haushaltsmitgliedern auf dem Land, hochgebildet, Staatsexamen, Netto Inc von 3400 EUR und sehr hohes hinc von 13000EUR. Vermute große Wohngemeinschaft, Kommune.

**** Änderungsraten der Wahrscheinlichkeit

** 12.4.1

quietly logistic eigenheim dh04 ib2.eastwest i.gs01 age i.gender hinc ib5.beziehungsstatus
quietly margins i.eastwest, at(hinc=(0(500)20000)) atmeans
marginsplot

** 12.5

margins , dydx(*) atmeans // Marginal Effects at Means (MEM): Änderungsrate wird bei Mittelwert von X ermittelt, während alle anderen Variablen auf Mittelwert konstant gehalten werden (conditional margins)

margins , dydx(*) // Average Partial (Marginal) Effects (APE/AME): Für alle Beobachtungen in der Stichprobe werden Marginals vorhergesagt und dann gemittelt (predictive margins)

margins , dydx(*) at(xvar=(...)) // Marginal Effects at representative values (MER)


cap drop hinc1000
gen hinc1000 = hinc/1000

quietly logistic eigenheim hinc1000 i.gender dh04 i.gs01 ib5.beziehungsstatus ib2.eastwest
fitstat
margins, dydx(*) atmeans
est store m1, title("No Age Variable")

quietly logistic eigenheim hinc1000 age i.gender dh04 i.gs01 ib5.beziehungsstatus ib2.eastwest if e(sample)
fitstat
margins, dydx(*) atmeans
est store m2, title("Full Modell")

estout m1 m2, cells(b(star fmt(3))) legend label varlabels(_cons constant)

**** Modellvergleich

** 13.1 // KHB-Methode (Karlson/Holm/Breen 2010)

findit khb
khb logit ...
