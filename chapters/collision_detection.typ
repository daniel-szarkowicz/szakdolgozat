#import "@preview/cetz:0.2.2"
#import "../templ.typ": todo, todo_image

= Egyszerű gömb ütközés <sphere-collision>
A szimuláció eleinte csak gömböket támogatott, mert azokra a legegyszerűbb
kiszámolni, hogy ütköznek-e.

Két gömb akkor ütközik, ha a középpontjaik távolsága kisebb, mint a sugaraik
összege:
$
  |bold(c_1) - bold(c_2)| < r_1 + r_2
$
Ha ütköznek, akkor az ütközési normál:
$
  bold(n) = (bold(c_1) - bold(c_2))/(|bold(c_1) - bold(c_2)|)
$
és az ütközési pontok:
$
  bold(p_1) = bold(c_1) - r_1 bold(n)\
  bold(p_2) = bold(c_2) + r_2 bold(n)
$

#figure(
  cetz.canvas({
    import cetz.draw: *
    let angle = 45deg
    let radius = 2
    let normal = (calc.cos(angle), calc.sin(angle))
    let tangent = (normal.at(1), -normal.at(0))
    let contact = normal.map(it => radius * it)
    let c1 = (0, 0)
    let c2 = contact.map(it => 2 * it)
    let v1 = (0, 1.5)
    let v2 = (0, -1.5)
    circle(radius: radius, c1)
    circle(radius: radius, c2)
    line(
      contact,
      contact.zip(normal).map(((it1, it2)) => it1 + it2 * radius * 0.9),
      stroke: red,
      mark: (end: ">")
    )
    line(
      contact.zip(tangent).map(((it1, it2)) => it1 + it2 * radius * 1.9),
      contact.zip(tangent).map(((it1, it2)) => it1 - it2 * radius * 1.9),
      stroke: red
    )
    line(
      c1,
      c1.zip(v1).map(((it1, it2)) => it1 + it2),
      stroke: green, mark: (end: ">")
    )
    line(
      c2,
      c2.zip(v2).map(((it1, it2)) => it1 + it2),
      stroke: green, mark: (end: ">")
    )
    line(
      c1,
      c1.zip(v2.rev()).map(((it1, it2)) => it1 + it2),
      stroke: blue, mark: (end: ">")
    )
    line(
      c2,
      c2.zip(v1.rev()).map(((it1, it2)) => it1 + it2),
      stroke: blue, mark: (end: ">")
    )
  }),
  caption: [
    Két gömb ütközik, #text(red)[piros] az ütközési felület és normál,
    #text(green)[zöld] az ütközés előtti sebességek,
    #text(blue)[kék] az ütközés utáni sebességek
  ]
)

= GJK
Egy elterjedt ütközés detektálási algoritmus a Gilbert-Johnson-Keerthi @gjk
algoritmus, ami tetszőleges konvex testek távolságát tudja meghatározni, ha a
testekre definiálva van a support function. A support functionnek egy adott
irányban kell a test legtávolabbi pontját visszaadni.

Az algoritmus két test Minkowski különbségéről vizsgálja meg, hogy benne van-e
az origó. Ha a különbségben benne van az origó, akkor ütközést talált, ha a
különbségben nincs benne az origó, akkor Minkowski különbség és az origó
távolsága a két test távolsága. A Minkowski különbség legközelebbi pontjából
ki lehet fejteni a két test legközelebbi pontját is.
#let minkowskidiff(triangle_position, square_position, drawline: false) = {
  cetz.canvas({
    import cetz.draw: *
    import cetz.plot

    plot.plot(
      size: (6, 6),
      axis-style: "school-book",
      x-tick-step: none,
      y-tick-step: none,
      {
        let (tx, ty) = triangle_position
        let (sx, sy) = square_position
        let triangle = (
          (-1 + tx, -1 + ty),
          ( 0 + tx,  1 + ty),
          ( 1 + tx, -1 + ty)
        )
        let square = (
          (-0.75 + sx, -0.75 + sy),
          (-0.75 + sx,  0.75 + sy),
          ( 0.75 + sx,  0.75 + sy),
          ( 0.75 + sx, -0.75 + sy),
        )
        let alldiff = triangle.map(((tx, ty)) => {
          square.map(((sx, sy)) => {
            return (tx - sx, ty - sy)
          })
        }).flatten().chunks(2)
        let minkowskidiff = (
          alldiff.at(2),
          alldiff.at(3),
          alldiff.at(7),
          alldiff.at(4),
          alldiff.at(8),
          alldiff.at(9),
        )
        plot.annotate({
          line(..triangle, close: true)
          line(..square, close: true)
          line(..minkowskidiff, close: true, stroke: green)
          if drawline {
            line(triangle.at(1), square.at(0), stroke: red)
            line((0, 0), minkowskidiff.at(3), stroke: red)
          }
        })
        plot.add(((6, 6), (6, 6)))
        plot.add(((-6, -6), (-6, -6)))
      }
    )
  })
}

#figure(
  grid(columns: 2, gutter: 10pt,
    minkowskidiff((-3, 3.7), (-2, 4)),
    minkowskidiff((-3, 1.7), (-2, 4), drawline: true),
  ),
  caption: [
    Egy háromszög és egy négyzet Minkowski különbsége. Az első képen a két
    test ütközik, a Minkowski különbségük tartalmazza az origót. A második képen
    a két test nem ütközik, a távolságuk megegyezik a Minkowski különbség és az
    origó távolságával.
  ]
)
A Minkowski különbség összes pontján egy kicsit sok időbe telne végig iterálni,
de a különbséget felépítő szimplexeken (2 dimenzióban háromszög, 3 dimenzióban
tetraéder) már lehetséges. Ehhez a Minkowski különbség support functionjére lesz
szükség, amit a következő módon számíthatunk ki egy $A$ és egy $B$ test support
functionjéből:
$
  s(bold(d)) = s_A (bold(d)) - s_B (-bold(d))
$
Tehát az algoritmus a Minkowski különbség szimplexein iterál végig. Ezekkel a
szimplexekkel egyre közelíteni szeretnénk az origót, míg vagy a szimplex
tartalmazza az origót, vagy nem sikerült közelebb jutnunk az origóhoz. Az
origóhoz úgy lehet közelíteni, hogy a szimplexnek vesszük az origóhoz a
legközelebbi részszimplexét és a legközelebbi pontját, és a legközelebbi
ponttal ellentétes irányba kérünk a support functiontől egy új pontot, amit
hozzáadunk a szimplexhez.

Az algoritmus kétféleképpen került implementációra.

Az első implementáció baricentrikus koordinátákkal kereste meg a legközelebbi
részszimplexet és a legközelebbi pontot. Sajnos a legközelebbi részszimplex
keresésnél néha nem egyértelmű, hogy melyik részszimplex van közelebb és többet
is meg kell vizsgálni, ami nem csak azért probléma, mert több számítást végez,
de azért is, mert így másolni kell a szimplex adatait, amit nem lehet
kioptimalizálni.

A második implementáció a teret részszimplexenként két részre osztja és
megnézi, hogy a részszimplexen belül vagy kívül esik-e az origó. Előbb vagy
utóbb egy néhány részszimplex vagy körbe fogja az origót, és akkor tudjuk, hogy
a részszimplexek által alkotott szimplex tartalmazza az origóhoz a legközelebbi
pontot, vagy egy ponton (0 dimenziós szimplex) kívül esik az origó, és akkor
tudjuk, hogy a pont a legközelebbi pont (és részszimplex) az origóhoz. A
szimuláció @dyn4j-gjk által bemutatott 2 dimenziós algoritmusnak egy 3 dimenziós
generalizációját használja.

A GJK könnyen használható gömbileg kiterjesztett testekre, például egy gömbre
vagy kapszulára, hiszen a két test legközelebbi pontja adott és sugara adott,
innentől a @sphere-collision fejezetben írt módon lehet kiszámolni, hogy a két
test ütközik-e, és ha igen, akkor mik az ütközési paramétereik.

= EPA
A GJK egyik hiányossága, hogy ha két test ütközik, akkor csak annyit mond, hogy
ütköznek, nem ad nekünk használható ütközési paramétereket. Az EPA úgy segít,
hogy a GJK-ból kapott szimplexet iteratívan bővíti újabb pontokkal, amíg
megtalálja az átfedő terület szélességét. Az EPA a GJK-ban használt legközelebbi
pont algoritmust használja, de nem az egész politópon futtatja, hanem csak a
politóp oldalait alkotó szimplexeken.

Az EPA a Minkowski különbségnek az origóhoz legközelebbi felszíni pontját keresi
meg. Ezt úgy éri el, hogy a politóp legközelebbi pontjának irányában kér egy új
pontot a különbség support functionjétől, ha talált távolabbi pontot, akkor
kiegészíti a politópot az új ponttal, ha nem talált távolabbi pontot, akkor
megtaláltuk a Minkowski különbség legközelebbi felszíni pontját.

#figure(
  todo_image[EPA],
  caption: [
    Az EPA felfedte a Minkowski különbség egy részét, amíg megtalálta a
    legközelebbi felszíni pontot.
  ]
)

A politóp bővítése nem egy könnyű feladat, ugyanis ha hozzáadunk egy új pontot
a politóphoz, akkor ki kell számolni, hogy milyen régi oldalakat kell kitörölni,
és hogy milyen új oldalakat kell felvenni. Azokat a régi oldalakat kell törölni,
amelyek az új pont "alatt" vannak, azaz az egyik oldalukon az új pont van, a
másik oldalukon pedig az origó. Az új oldalakat úgy kell hozzáadni, hogy a régi
oldalak azon széleit, amelyeket csak az egyik oldalról határolt kitörölt oldal
összekötjük az új ponttal. Ez a bővítés elképzelhető egy konvex burok iteratív
felépítéseként is.

A szimuláció @dyn4j-epa által bemutatott 2 dimenziós algoritmusnak egy 3
dimenziós generalizációját használja.

= Ütközési pontok kiszámítása
A GJK és az EPA csak egy ütközési pontot adnak, amely pillanatnyi érintkezésnél
elfogadható, de #todo[Nyugalmi érintkezés]-nél nem.

Több ütközési pontot úgy kaphatunk, hogy az ütközési normál mentén lekérjük
a ütköző testeknek "legjobb" oldalait, ezeknek az oldalakna vesszük a
meteszetét az ütközési normál szerint és a metszet pontjaiból választunk
néhányat az ütközési pontoknak.

== Oldalak kiszámítása
A "legjobb" oldalak kiszámítása a test alakjától függ.

Egy gömbnek a legjobb oldala a gömb középpontjából és sugarából könnyen
kiszámolható.

Egy kocka legjobb oldalához ki kell számolni minden oldal normálvektorának
a szögét az ütközési normállal, kiválasztjuk a legkisebb szöget és a hozzá
tartozó oldalt adjuk vissza.

== Oldalak metszete

Az oldalak metszetéhez egy közös síkra kell vetíteni az oldalakat, utána egy 2
dimenziós algoritmussal vesszük az oldalak metszetét, végül a normál vektor
mentén visszavetítjük az oldalakat a saját síkjukra.

Normál vektor síkjára vetítés:
$ p_n = p + (p_0 - p) dot hat(n) dot hat(n) $

Eredeti síkra vetítés a normál vektor mentén:
$ p' = p'_n - ((p'_n - p'_0) dot hat(n')) / (hat(n) dot hat(n')) dot hat(n) $

Az oldalak metszetének kiszámolásához a #todo[clipper2]-t használtam.
