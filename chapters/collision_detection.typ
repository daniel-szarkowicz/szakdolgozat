#import "@preview/cetz:0.2.2"
#let todo = text.with(red)

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
innentől a #todo[sphere-collision] fejezetben írt módon lehet kiszámolni, hogy a két
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

// #figure(
//   todo_image[EPA],
//   caption: [
//     Az EPA felfedte a Minkowski különbség egy részét, amíg megtalálta a
//     legközelebbi felszíni pontot.
//   ]
// )

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
#todo[Polygon vetítés + clipping] #todo[dyn4j-clipping]
