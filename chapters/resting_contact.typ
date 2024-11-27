#import "../templ.typ": todo_image

Ha a testekre erők is hatnak (nem csak impulzusok), akkor könnyen előfordulhat,
hogy a testek hosszabb ideig érintkeznek.
Ezeknél az érintkezéseknél külön oda kell figyelni, hogy a testek ne csússzanak
egymásba, de itt nem használhatunk nagy erőket a testek szétválasztásához, mert
akkor a szimuláció nem lenne élethű.

#figure(
  todo_image[resting_contact.png],
  caption: [
    Nyugalmi érintkezéskor a testek relatív sebessége 0, oda kell figyelni, hogy
    a relatív sebesség ne csökkenjen.
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

