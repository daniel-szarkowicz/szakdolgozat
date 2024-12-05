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

= Gilbert-Johnson-Keerthi algoritmus
Egy elterjedt ütközés detektálási algoritmus a Gilbert-Johnson-Keerthi @gjk
algoritmus, ami tetszőleges konvex testek távolságát tudja meghatározni, ha a
testekre definiálva van a support function. A support functionnek egy adott
irányban kell a test legtávolabbi pontját visszaadni.

Az algoritmus két test Minkowski különbségéről vizsgálja meg, hogy benne van-e
az origó. Ha a különbségben benne van az origó, akkor ütközést talált, ha a
különbségben nincs benne az origó, akkor Minkowski különbség és az origó
távolsága a két test távolsága. A Minkowski különbség legközelebbi pontjából
ki lehet fejteni a két test legközelebbi pontját is.
#let minkowskidiff(
  triangle_position,
  square_position,
  drawline: false,
  e1: false, e2: false
) = {
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
        let epa1 = (
          alldiff.at(7),
          alldiff.at(8),
          alldiff.at(9),
        )
        let epa2 = (
          alldiff.at(4),
          alldiff.at(7),
          alldiff.at(9),
          alldiff.at(8),
        )
        plot.annotate({
          line(..triangle, close: true)
          line(..square, close: true)
          line(..minkowskidiff, close: true, stroke: green)
          if e1 { line(..epa1, close: true, stroke: red) }
          if e2 { line(..epa2, close: true, stroke: red) }
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
A Minkowski különbség összes pontján sok időbe telne végig iterálni,
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

// Az első implementáció baricentrikus koordinátákkal kereste meg a legközelebbi
// részszimplexet és a legközelebbi pontot. Sajnos a legközelebbi részszimplex
// keresésnél néha nem egyértelmű, hogy melyik részszimplex van közelebb és többet
// is meg kell vizsgálni, ami nem csak azért probléma, mert több számítást végez,
// de azért is, mert így másolni kell a szimplex adatait, amit nem lehet
// kioptimalizálni. #todo[erről bővebben?]

== Baricentrikus koordinátákkal
A GJK célja találni egy szimplexet, ami tartalmazza az origót, ha egy adott
szimplex nem tartalmazza az origót, akkor az origóhoz legközelebbi részszimplexét
fogjuk bővíteni. Az egyik módszer az origó tartalmazás és a legközelebbi
részszimplex kiszámításához baricentrikus koordinátákkal számol.

Egy $n$ dimenziós szimplex pontjait a következő pontokkal határozunk meg:
$S_1, S_2, ... S_n, S_(n+1)$

Egy $P$ pontot a szimplex terén a következő módon írhatunk fel baricentrikus
koordinátákkal:
$
  P = sum_(i=1)^(n+1) t_i dot A_i, quad sum_(i=1)^(n+1) t_i = 1\
  t_(n+1) = 1 - sum_(i=1)^n t_i\
  P = sum_(i=1)^n t_i dot A_i + (1 - sum_(i=1)^n t_i) dot A_(n+1) =
    A_(n+1) + sum_(i=1)^n t_i dot (A_i - A_(n+1))\
  "legyen" A'_i = A_i - A_(n+1)\
  P = A_(n+1) + sum_(i=1)^n t_i dot A'_i
$

Ez a pont akkor és csak akkor van a szimplexben, ha
$ limits(forall)_(i=1)^(n+1) t_i >= 0 $

A $P$ pont távolságának a négyzete az origótól:
$
  d^2 = P^2 = A_(n+1)^2 + 2 sum_(i=1)^n t_i dot A_(n+1) dot A'_i
    + sum_(i=1)^n sum_(j=1)^n t_i dot t_j dot A'_i dot A'_j
$

Tudjuk, hogy ennek a távolságnak pontosan egy minimuma van, hiszen egy
hipertérnek pontosan egy pontja lehet a legközelebb az origóhoz. A minimumot
megkaphatjük a távolságnégyzet gradienséből:
$
  (diff d^2)/(diff t_i) = 2 A_(n+1) dot A'_i
    + 2 sum_(j=1)^n t_j dot A'_j dot A'_j =& 0\
  sum_(j=1)^n t_j dot A'_i dot A'_j =&
    -A_(n+1) dot A'_i
$

Ezek az egyenletek egy $n+1$ változós lineáris egyenletrendszert alkotnak,
amit a következő módon írhatunk fel mátrixokkal:
$
  mat(
    A'_1 dot A'_1, A'_1 dot A'_2, dots.c   , A'_1 dot A'_n, 0;
    A'_2 dot A'_1, A'_2 dot A'_2, dots.c   , A'_2 dot A'_n, 0;
    dots.v       , dots.v       , dots.down, dots.v       , dots.v;
    A'_n dot A'_1, A'_n dot A'_2, dots.c   , A'_n dot A'_n, 0;
    1            , 1            , dots.c   , 1            , 1;
  ) dot mat(t_1; t_2; dots.v; t_n; t_(n+1)) =
  mat(
    -A_(n+1) dot A'_1;
    -A_(n+1) dot A'_2;
    dots.v           ;
    -A_(n+1) dot A'_n;
    1;
  )\
  mat(t_1; t_2; dots.v; t_n; t_(n+1)) = mat(
    A'_1 dot A'_1, A'_1 dot A'_2, dots.c   , A'_1 dot A'_n, 0;
    A'_2 dot A'_1, A'_2 dot A'_2, dots.c   , A'_2 dot A'_n, 0;
    dots.v       , dots.v       , dots.down, dots.v       , dots.v;
    A'_n dot A'_1, A'_n dot A'_2, dots.c   , A'_n dot A'_n, 0;
    1            , 1            , dots.c   , 1            , 1;
  )^(-1) dot mat(
    -A_(n+1) dot A'_1;
    -A_(n+1) dot A'_2;
    dots.v           ;
    -A_(n+1) dot A'_n;
    1;
  )
$

Ha a mátrix nem invertálható (általában akkor fordul elő, ha a pontok nem
alkottak szimplexet), akkor a szimplex minden részére rekurzívan futtatjuk az
algoritmust. Ha tudjuk, hogy a szimplexnek az utolsó pontja a legújabban
hozzáadott pont, akkor elég csak azt a pontot kitörölni és újrafuttatni.

Ha a kapott súlyokkal a pont a szimplexen kívülre esik, akkor a negatív
súlyokhoz tartozó pontokat egyesével kivesszük a szimplexből és minden így
kapott részre újra futtatjuk az algoritmust.

Az algoritmussal kapott szimplex az legközelebbi részszimplex az origóhoz.
Ha a szimplex $N$ dimenziós, akkor a szimplex tartalmazza az $N$ dimenziós
tér origóját, azaz befejezhetjük a GJK futtatását.

Ennek az algoritmusnak az előnye, hogy általános megoldást ad egy $N$ dimenziós
a legközelebbi részszimplex megtalására. Az algoritmus hátránya, hogy a mátrix
szorzás és a szétágazó rekurzió miatt lassú.

== Tér vágással
Ez az algoritmus a teret részszimplexek mentén félbe vágja és megnézi, hogy
az origó az részszimplexen belüli vagy kívüli oldalra esik-e. A könyvtárban
tetraéderekre lett implementálva, de az egyszerűség kedvéért itt csak
háromszögekre lesz bemutatva.

#let asdf(
  orig1: false,
  orig2: false,
  ab: 0,
  bc: 0,
  ca: 0,
  aba: 0,
  abb: 0,
  bcb: 0,
  bcc: 0,
  cac: 0,
  caa: 0,
  ) = {
    import cetz.draw
    draw.scale(73%)
    let add((x1, y1), (x2, y2)) = (x1 + x2, y1 + y2)
    let sub((x1, y1), (x2, y2)) = (x1 - x2, y1 - y2)
    let mul((x1, y1), scalar) = (x1 * scalar, y1 * scalar)
    let half_space(
      min,
      max,
      p,
      n,
      ..style
    ) = {
      let (minx, miny) = min
      let (maxx, maxy) = max
      let (px, py) = p
      let (nx, ny) = n
      let v = (-ny, nx)
      let (vx, vy) = v

      let edges = (
        (minx, miny),
        (minx, maxy),
        (maxx, maxy),
        (maxx, miny)
      )

      let a = (
        (maxx - px)/vx,
        (maxy - py)/vy,
        (minx - px)/vx,
        (miny - py)/vy,
      ).sorted()
      let a1 = a.at(1)
      let a2 = a.at(2)
      let corner = (
        if nx < 0 {minx} else {maxx},
        if ny < 0 {miny} else {maxy},
      )
      let p1 = add(p, mul(v, a1))
      let p2 = add(p, mul(v, a2))
      let t1 = if p1.at(0) == minx or p1.at(0) == maxx {
        (p1.at(0), corner.at(1))
      } else {
        (corner.at(0), p1.at(1))
      }
      let t2 = if p2.at(0) == minx or p2.at(0) == maxx {
        (p2.at(0), corner.at(1))
      } else {
        (corner.at(0), p2.at(1))
      }
      draw.line(p1, t1, corner, t2, p2, close: true, ..style)
    }
    let A = (-1, -3)
    let B = (2, 1)
    let C = (-2, 4)
    let vAB = sub(B, A)
    let nAB = mul((-vAB.at(1), vAB.at(0)), -1)
    let vAC = sub(C, A)
    let nAC = (-vAC.at(1), vAC.at(0))
    let vBC  = sub(C, B)
    let nBC = mul((-vBC.at(1), vBC.at(0)), -1)
    let stripedpattern(color, angle: 45deg, spacing: 10pt) = {
      let len = spacing / (calc.sin(angle) * calc.cos(angle))
      pattern(size: (calc.cos(angle) * len, calc.sin(angle) * len))[
        #line(end: (100%, 100%), stroke: color + 0.5pt)
      ]
    }
    if orig1 {
      draw.circle((0, 0), radius: 0.02, fill: black)
      draw.content((0, 0), anchor: "north-west")[O]
    }
    if orig2 {
      draw.circle((3, -3), radius: 0.02, fill: black)
      draw.content((3, -3), anchor: "north-west")[O]
    }
    let bounds = ((-5, -5), (5, 5))
    draw.rect(..bounds)
    let hs = half_space.with(..bounds, stroke: none)
    if ab != 0 { hs(A, mul(nAB, ab), fill: stripedpattern(green, angle: 35deg)) }
    if bc != 0 { hs(B, mul(nBC, bc), fill: stripedpattern(red, angle: 275deg)) }
    if ca != 0 { hs(A, mul(nAC, ca), fill: stripedpattern(blue, angle: 155deg)) }
    if aba != 0 { hs(A, mul(vAB, -aba), fill: stripedpattern(purple, angle: 75deg))}
    if abb != 0 { hs(B, mul(vAB, abb), fill: stripedpattern(orange, angle: 130deg))}

    draw.line(A, B, C, close: true, name: "tri")
    draw.content(A, anchor: "north-east")[A]
    draw.content(B, anchor: "west")[B]
    draw.content(C, anchor: "south-east")[C]
  }

*Az algoritmus menete:*

- Háromszög vizsgálat:
  + Vizsgáljuk meg, hogy az origó az $A B$ szakasz melyik oldalán van. Ha
    az origó a $C$ ponttól különböző oldalon van ($arrow(A O) dot
    [arrow(A B) times arrow(A C) times arrow(A B)] < 0$),
    akkor az origó biztosan nincs a háromszög  területén, ugrás a
    #link(<szakasz_vizsgalat>)[_Szakasz vizsgálatra_]
  + Vizsgáljuk meg az origót és a $B C$ szakaszt
  + Vizsgáljuk meg az origót és a $C A$ szakaszt
  + Ha minden vizsgálat sikeres volt, akkor az origó a háromszögben van

#figure(
  grid(columns: 2, column-gutter: 1fr,
    cetz.canvas({ asdf(ab: 1, bc: 0, ca: 0, orig1: true) }),
    cetz.canvas({ asdf(ab: 1, bc: 1, ca: 1, orig1: true) }),
  ),
  caption: [
    Bal oldal: az első vágás megállapította, hogy az origó az $A B$ oldalhoz
    képest belül van, ezért az $A B$ oldalon kívüli félteret kizárhatjuk.
    Jobb oldal: három vágással megállapítottuk, mindhárom oldalon belül van az
    origó, azaz a szimplex tartalmazza az origót.
  ]
)

- Szakasz vizsgálat <szakasz_vizsgalat>:
  Tegyük fel, hogy az $A B$ szakasz vizsgálatakor kiderült, hogy az origó
  a háromszög területén kívül esik.
  + Vizsgáljuk meg, hogy az origó az $A$ csúcs és az $arrow(B A)$ vektor
    által meghatározott síknak melyik oldalán van. Ha az origó nincs a
    $B$-vel egy oldalon ($arrow(A B) dot arrow(A O) < 0$), akkor az origó az
    $A$ ponthoz van a legközelebb.
  + Vizsgáljuk meg a $B$ csúcs és az $arrow(A B)$ síkot az előzőhöz
    hasonlóan.
  + Ha az origó mindkét síkon belül van, akkor az $A B$ szakasz van az
    origóhoz a legközelebb.

#figure(
  grid(columns: 2, column-gutter: 1fr,
    cetz.canvas({ asdf(ab: -1, aba: 1, abb: 0, orig2: true) }),
    cetz.canvas({ asdf(ab: -1, aba: 1, abb: 1, orig2: true) }),
  ),
  caption: [
    Az első lépésben meghatároztuk, hogy az origó az $A B$ oldalon kívülre
    esik. A második lépésben kizártuk az $A B$ oldal szerint az $A$-n túli
    félteret. Végül a harmadik lépésben kizártuk a $B$-n túli félteret is,
    az origóhoz legközelebbi részszimplex az $A B$ szakasz.
  ]
)

// A második implementáció a teret részszimplexenként két részre osztja és
// megnézi, hogy a részszimplexen belül vagy kívül esik-e az origó. Előbb vagy
// utóbb egy néhány részszimplex vagy körbe fogja az origót, és akkor tudjuk, hogy
// a részszimplexek által alkotott szimplex tartalmazza az origóhoz a legközelebbi
// pontot, vagy egy ponton (0 dimenziós szimplex) kívül esik az origó, és akkor
// tudjuk, hogy a pont a legközelebbi pont (és részszimplex) az origóhoz. A
// szimuláció @dyn4j-gjk által bemutatott 2 dimenziós algoritmusnak egy 3 dimenziós
// generalizációját használja. #todo[erről bővebben?]

A GJK könnyen használható gömbileg kiterjesztett testekre, például egy gömbre
vagy kapszulára, hiszen a két test legközelebbi pontja és sugara adott,
innentől a @sphere-collision fejezetben írt módon lehet kiszámolni, hogy a két
test ütközik-e, és ha igen, akkor mik az ütközési paramétereik.

= Expanding Polytope Algorithm
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
  grid(columns: 2, gutter: 10pt,
    minkowskidiff((-3, 3.7), (-2, 4), e1: true),
    minkowskidiff((-3, 3.7), (-2, 4), e2: true),
  ),
  caption: [
    Bal oldal: az EPA egy lehetséges kezdő állapota. Jobb oldal: az EPA
    megtalálta az origóhoz legközelebbi oldalt, hiszen a legközelebbi oldal
    irányába nem tud messzebb menni.
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
elfogadható (bár nem helyes), de nyugalmi érintkezésnél nem.

Több ütközési pontot úgy kaphatunk, hogy az ütközési normál mentén lekérjük
a ütköző testeknek "legjobb" oldalait, ezeknek az oldalakna vesszük a
meteszetét az ütközési normál szerint és a metszet pontjaiból választunk
néhányat az ütközési pontoknak.

== Oldalak kiszámítása
A "legjobb" oldalak kiszámítása a test alakjától függ.

Egy gömbnek a legjobb oldala a gömb középpontjából és sugarából könnyen
kiszámolható.

Egy kockánál azt az oldalt választjuk ki, amelynek a normálja a legkisebb
szöget zárna be az ütközési normállal.

== Oldalak metszete

Az oldalak metszetéhez egy közös síkra kell vetíteni az oldalakat, utána egy 2
dimenziós algoritmussal vesszük az oldalak metszetét, végül a normál vektor
mentén visszavetítjük az oldalakat a saját síkjukra.

Normál vektor síkjára vetítés:
$ p_n = p + (p_0 - p) dot hat(n) dot hat(n) $

Eredeti síkra vetítés a normál vektor mentén:
$ p' = p'_n - ((p'_n - p'_0) dot hat(n')) / (hat(n) dot hat(n')) dot hat(n) $

Az oldalak metszetének kiszámolásához a clipper2 @clipper2 könyvtárat
használtam.
