#import "@preview/cetz:0.2.2"
#import "../templ.typ": todo, todo_image

Az összes pár megvizsgálása $O(n^2)$ lenne, ami nagyon lassú. Szerencsére
a legtöbb test nem ütközik, ezért egy megfelelő heurisztikával sokat lehet
spórolni. A szimuláció gyorsításához kell egy algoritmus, ami gyorsan eldobja
a teszteknek egy jelentős részét és így csak a párok egy kis hányadát kell
megvizsgálni. Ezek az algoritmusok általában csak egyszerű alakzatokon tudnak
dolgozni, a következő algoritmusok axis-aligned bounding boxokat (AABB)
használnak. Az AABB-k olyan téglatestek, amik tartalmazzák az az egész testet és
az oldalai párhuzamosak a koordináta-rendszer tengelyeivel.

#figure(
  todo_image("sphere_aabb_cropped.png", width: 6cm),
  caption: [Egy gömbnek az AABB-je.]
)

= Sort-and-Sweep
A sort and sweep @baraff2 egy egyszerű algoritmus az ellenőrzött párok
csökkentésére. Az algoritmus az egyik tengely szerint intervallumokként kezeli
az AABB-ket és átfedő intervallumokat keres. Ezt úgy éri el, hogy egy listába
kigyűjti minden AABB-nek az elejét és a végét a kiválasztott tengely szerint,
rendezi a listát, majd egyszer végig iterál a listán és kigyűjti az átfedő
intervallumokat. Az átfedő intervallumok listája tartalmazza a potenciális
ütközéseket, ezt a listát érdemes szűrni az AABB-k másik két tengelye szerint,
mielőtt a tényleges ütközés detektálás algoritmust futtatnánk. Az algoritmusnál
sokat számíthat a megfelelő tengely kiválasztása, rossz tengely megválasztásakor
lehet, hogy csak a pároknak egy kis részét dobjuk el.
#figure(
  cetz.canvas({
    import cetz.draw: *
    import cetz.plot

    let sas_circle(x, y, r) = {
      circle(radius: 1 * r, (1 * x, 1 * y))
      line(
        (x - r, 6),
        (x - r, 0),
        (x + r, 0),
        (x + r, 6),
        stroke: (
          paint: red,
          dash: "solid",
        ),
        close: true
      )
      line(
        (x - r, y - r),
        (x - r, y + r),
        (x + r, y + r),
        (x + r, y - r),
        stroke: (
          paint: green,
        ),
        close: true
      )
    }

    plot.plot(
      size: (6, 6),
      x-tick-step: none,
      y-tick-step: none,
      {
        plot.annotate({
          sas_circle(1, 1, 0.25)
          sas_circle(1.2, 3, 0.25)

          sas_circle(3, 5, 0.25)
          sas_circle(3.2, 4.8, 0.25)

          sas_circle(4.95, 1, 0.25)
          sas_circle(5.05, 1.75, 0.25)
          sas_circle(5.1, 2.5, 0.25)
          sas_circle(5, 3.25, 0.25)
          sas_circle(4.9, 4, 0.25)
          sas_circle(5.15, 4.75, 0.25)
        })
        plot.add(((6, 6), (6, 6)))
      }
    )
  }),
  caption: [
    A sort and sweep algoritmus intervallumai az $x$ tengely szering. A jobb
    oldalon látható, hogy ha rossz tengelyt választunk, akkor nem segít sokat az
    algoritmus.
  ]
)

= R-Tree
A szimulációban használt broad phase algoritmus (adatstruktúra) az R-Tree.
Az R-Tree a B-Tree-nek egy kibővített változata, ami több dimenzió szerint
rendezhető adatokra tud hatékony keresést biztosítani.

A R-Tree minimal bounding box-okból épül fel. Ezek olyan AABB-k, amiknél kisebb
AABB nem lenne képes bennfoglalni a tartalmazott elemeit. Az R-Tree-be
felépítésekor egyesével illesztjük be az AABB-ket. Az R-Tree-nék két fontos
algoritmus van: legjobb csúcs kiválasztása a beillesztéshez, és legjobb vágás
kiszámítása, ha egy csúcs megtelt. A szimuláció a beillesztéshez a legkisebb
térfogat növekedést választja, a vágáshoz a Quadratic split-et @rstar használ.

#figure(
  todo_image("rtree_cropped.png", width: 6cm),
  caption: [
    Egy 3 dimenziós R-Tree kettő szintje. Látható, hogy néha átfedik egymást
    a csomópontok (piros AABB-k). Az átfedéseket érdemes minimalizálni.
  ]
)

Az R-Tree-k felépítéséhez és karbantartásához számos algoritmus jött létre.

Az R\*-Tree @rstar optimálisabb csúcsválasztást és optimálisabb vágást
használ és ha a vágás után egy elem nagyon nem illik be egyik csoportba sem,
akkor újra beilleszti a fába, hátha talál jobb helyet.

Az STR @str és az OMT @omt nem egyesével építi fel a fát, hanem egyszerre
dolgozik az összes adattal, így közel tökéletes fákat tudnak felépíteni.

= OMT
Az Overlap Minimizing R-Tree egy bulk-loading algoritmus, amely az eredeti
R-Tree felépítésével ellentétben nem egyesével építi fel a fát, hanem egyszerre.

Ezzel a módszerrel hatékonyabb keresőfát tudunk felépíteni, ugyanis az
algoritmus törekszik minimalizálni a részei között az átfedést.

== Az algoritmus

Az algoritmus egy lépés ismétel addig, amíg a legalsó csúcshoz tartozó levelek
száma kisebb, mint egy határ érték. Ez a lépés a csúcs leveleit a következő
módon bontja $N$ egyenlő részre:
+ vágások kiszámítása mindhárom dimenzió szerint (@omt_split függelék)
+ rendezés az első dimenzió szerint
+ vágás az első dimenzió szerint
+ vágások rendezése a második dimenzió szerint
+ vágás a második dimenzió szerint
+ vágások rendezése a harmadik dimenzió szerint
+ vágás a harmadik dimenzió szerint

#figure(
  todo_image[OMT],
  caption: [
    Az Overlap Minimizing R-Tree. Látható, hogy sokkal kevesebb az átfedés,
    mint az R-Tree-ben.
  ]
)

Az OMT-vel generált fát az összes többi R-Tree algoritmussal használhatjuk
tovább. A fizikai motor csak a keresést használja az R-Tree-ből, mert jelenleg
minden ciklusban újraépíti a fát.
