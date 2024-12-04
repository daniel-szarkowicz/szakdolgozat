#import "@preview/cetz:0.2.2"
#import "../templ.typ": todo_image

Ha a testekre erők is hatnak (nem csak impulzusok), akkor könnyen előfordulhat,
hogy a testek hosszabb ideig érintkeznek.
Ezeknél az érintkezéseknél külön oda kell figyelni, hogy a testek ne csússzanak
egymásba, de itt nem használhatunk nagy erőket a testek szétválasztásához, mert
akkor a szimuláció nem lenne élethű.

#figure(
  cetz.canvas({
    import cetz.draw: *
    rect((-5, -5), (5, 5))

    let lerp((x1, y1), (x2, y2), t) = (
      x1 * (1 - t) + x2 * t,
      y1 * (1 - t) + y2 * t
    )

    let c1 = (2, -1)
    let c2 = (-2, -1)
    let c3 = (0, calc.sqrt(3)*2-1)

    circle(c1, radius: 2)
    circle(c2, radius: 2)
    circle(c3, radius: 2)

    line(c1, (c1.at(0), c1.at(1)-0.8), mark: (end: ">"), stroke: red)
    line(c2, (c2.at(0), c2.at(1)-0.8), mark: (end: ">"), stroke: red)
    line(c3, (c3.at(0), c3.at(1)-0.8), mark: (end: ">"), stroke: red)

    line(lerp(c1, c3, 0.375), lerp(c1, c3, 0.625), mark: (start: ">", end: ">"), stroke: green)
    line(lerp(c2, c3, 0.375), lerp(c2, c3, 0.625), mark: (start: ">", end: ">"), stroke: green)

    let t1 = (c1.at(0), -3)
    let t2 = (c2.at(0), -3)
    line(t1, lerp(t1, c1, 0.55), mark: (end: ">"), stroke: blue)
    line(t2, lerp(t2, c2, 0.55), mark: (end: ">"), stroke: blue)

    line((-5, -3), (5, -3))
    for i in range(-20, 20) {
      line((i/4, -3), (i/4+0.2, -3.2))
    }
  }),
  caption: [
    Nyugalmi érintkezéskor a testek normál irányú relatív sebessége 0. Erők
    viszont továbbra is hathatnak a testekre. Fontos hogy akkora erőket
    szimuláljunk az érintkező testek között, hogy ne gyorsuljanak egymás felé,
    de pusztán ezektől az erőktől nem válhatnak el a testek.
  ]
)

Ebben a dolgozatban két megoldást fogunk megvizsgálni.

= Analitikus megoldás
Az analitikus megoldásban egyszerre számoljuk ki az összes érintkezési pontban
az erőket, így tökéletes megoldást kaphatunk.
Az analitikus megoldásban az ütközési pontban a relatív gyorsulásnak
nemnegatívnak kell lennie, úgy ahogy a @ütközésválasz fejezetben a relatív
sebességnek.
Az erők kiszámításához egy egyenlőtlenség-rendszert kell megoldani, amely
@baraff2 szerint egy Quadratic programming probléma, ez nem került
implementációra.
A megoldáshoz egy $k times k$ mátrixszal kéne számolni, a $k$ az ütközési
pontok száma, ez a mátrix sok ütközés esetén nagyon nagy lehet és a szimulációt
jelentősen lassíthatja.

= Iteratív megoldás
Az iteratív megoldás egy sokkal egyszerűbb elven alapszik: az @ütközésválasz
fejezetben leírtakat megismételjük egy párszor és reménykedünk, hogy egyik
ütközési pontban sem akarnak a testek egymás felé mozogni.
Bár ez a megoldás nem lesz soha tökéletes, elég jó közelítést ad a nyugalmi
érintkezéshez is.
Az közelítés pontosságát több módon lehet javítani, például ha az ütközési
pontokat minden iterációban más sorrendben vizsgáljuk, vagy az első iterációkban
nagyobb erőket engedünk, akkor a sebességek gyorsabban kiegyenlítődhetnek.

