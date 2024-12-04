#import "@preview/cetz:0.2.2"
#import "@preview/suiji:0.3.0": *
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
  cetz.canvas({
    import cetz.draw: *
    rect((-5, -5), (5, 5), stroke: black)
    line((-4.5, -4.5), (-4.5, -1.5), (-1.5, -1.5), (-1.5, -4.5), close: true, stroke: red)
    circle((-3, -3), radius: 1.5)

    line((1, 0), (1, 4), (4, 4), (4, 0), close: true, stroke: red)
    line((1, 0), (2, 4), (4, 3), close: true)
    
    {
      let cnt = 5
      let rad = 1.7
      let points = ()
      for i in range(cnt) {
        let angle = 360deg / cnt * i + 50deg
        let x = calc.cos(angle) * rad + 2.2
        let y = calc.sin(angle) * rad - 3
        points.push((x, y))
      }
      let xs = points.map(((x, y)) => x)
      let ys = points.map(((x, y)) => y)
      let minx = calc.min(..xs)
      let miny = calc.min(..ys)
      let maxx = calc.max(..xs)
      let maxy = calc.max(..ys)
      line((minx, miny), (minx, maxy), (maxx, maxy), (maxx, miny), close: true, stroke: red)
      line(..points, close: true)
    }
    {
      let cnt = 7
      let rad1 = 2
      let rad2 = 0.8
      let points = ()
      for i in range(cnt*2) {
        let rad = if calc.rem(i, 2) == 0 {rad1} else {rad2}
        let angle = 360deg / 2 / cnt * i + 50deg
        let x = calc.cos(angle) * rad - 2.5
        let y = calc.sin(angle) * rad + 2
        points.push((x, y))
      }
      let xs = points.map(((x, y)) => x)
      let ys = points.map(((x, y)) => y)
      let minx = calc.min(..xs)
      let miny = calc.min(..ys)
      let maxx = calc.max(..xs)
      let maxy = calc.max(..ys)
      line((minx, miny), (minx, maxy), (maxx, maxy), (maxx, miny), close: true, stroke: red)
      line(..points, close: true)
    }
  }),
  caption: [
    Néhány különböző alaknak a minimális AABB-je.
  ]
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
      size: (10, 10),
      x-tick-step: none,
      y-tick-step: none,
      {
        plot.annotate({
          sas_circle(1, 1, 0.4)
          sas_circle(1.4, 3, 0.25)

          sas_circle(2, 2, 0.6)

          sas_circle(3, 5, 0.5)
          sas_circle(3.6, 4.4, 0.25)

          sas_circle(5, 1, 0.35)
          // sas_circle(5.05, 1.75, 0.25)
          sas_circle(5.4, 3.6, 0.25)
          // sas_circle(5, 3.25, 0.25)
          // sas_circle(4.9, 4, 0.25)
          sas_circle(5.5, 4.75, 0.25)
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

#let random_aabb(rng) = {
  let (rng, x) = uniform(rng, low: -4.5, high: 4.5)
  let (rng, y) = uniform(rng, low: -4.5, high: 4.5)
  let (rng, w2) = uniform(rng, low: 0.1, high: 0.5)
  let (rng, h2) = uniform(rng, low: 0.1, high: 0.5)
  (rng, (x - w2, y - h2, x + w2, y + h2))
}

#let random_aabbs(rng, n) = {
  let aabbs = ()
  for _ in range(0, n) {
    let (newrng, aabb) = random_aabb(rng)
    aabbs.push(aabb)
    rng = newrng
  }
  (rng, aabbs)
}

#let draw_aabb((minx, miny, maxx, maxy), index: none, stroke: black) = {
  cetz.draw.rect((minx, miny), (maxx, maxy), stroke: stroke)
  if index != none {
    cetz.draw.content((minx/2 + maxx/2, miny/2 + maxy/2), [#index])
  }
}

#let merge_aabbs(..aabbs) = {
  let aabbs = aabbs.pos()
  let minx = calc.min(..aabbs.map(aabb => aabb.at(0)))
  let miny = calc.min(..aabbs.map(aabb => aabb.at(1)))
  let maxx = calc.max(..aabbs.map(aabb => aabb.at(2)))
  let maxy = calc.max(..aabbs.map(aabb => aabb.at(3)))
  (minx, miny, maxx, maxy)
}
#figure(
  // todo_image("rtree_cropped.png", width: 6cm),
  cetz.canvas({
    import cetz.draw: *
    rect((-5, -5), (5, 5))

    let select(aabbs, ..indices) = {
      let res = ()
      for i in indices.pos() {
        res.push(aabbs.at(i))
      }
      res
    }

    let rng = gen-rng(10)
    let (_, aabbs) = random_aabbs(rng, 30)
    for (i, aabb) in aabbs.enumerate() {
      draw_aabb(aabb)
    }
    let layer1 = (
      select(aabbs, 14, 13, 1, 2),
      select(aabbs, 12, 6, 17, 20),
      select(aabbs, 4, 10, 9, 29),
      select(aabbs, 19, 25, 18, 24),
      select(aabbs, 26, 27, 28, 0),
      select(aabbs, 5, 21, 22, 23, 15),
      select(aabbs, 3, 7, 11, 16, 8)
    ).map(l => merge_aabbs(..l))
    for (i, aabbs) in layer1.enumerate() {
      draw_aabb(aabbs, stroke: red + 0.5pt)
    }
    let layer2 = (
      select(layer1, 1, 2, 5, 6),
      select(layer1, 0, 4, 3)
    ).map(l => merge_aabbs(..l))
    for aabbs in layer2 {
      draw_aabb(aabbs, stroke: blue)
    }
  }),
  caption: [
    Egy 2 szintű R-Tree. Látható, hogy néha átfedik egymást a csúcsok.
    Ezek az átfedések jelentősen csökkenthetik a lekérdezések sebességét.
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

#let omt(aabbs, max_node_size, smallroot: true, depth: 0) = {
  if aabbs.len() <= max_node_size {
    (
      aabb: merge_aabbs(..aabbs),
      children: aabbs
    )
  } else {
    if depth == 0 {
      aabbs = aabbs.sorted(key: aabb =>
        aabb.at(1)
        + aabb.at(3)
      )
    }
    let total_count = aabbs.len()

    let node_count = if smallroot {
      let height = calc.ceil(calc.log(total_count, base: max_node_size))
      calc.ceil(total_count / calc.pow(max_node_size, height - 1))
    } else {
      max_node_size
    }

    let small_node_size = calc.floor(total_count / node_count)
    let large_node_size = small_node_size + 1
    let large_node_count = total_count - (node_count * small_node_size)
    let small_node_count = node_count - large_node_count

    let slice_count = calc.ceil(calc.sqrt(node_count))
    let small_slice_size = calc.floor(node_count / slice_count)
    let large_slice_size = small_slice_size + 1
    let large_slice_count = node_count - (slice_count * small_slice_size)
    let small_slice_count = slice_count - large_slice_count

    let node_sizes = (small_node_size, large_node_size)
    let node_counts = (small_node_count, large_node_count)
    let slice_sizes = (small_slice_size, large_slice_size)
    let slice_counts = (small_slice_count, large_slice_count)

    let nodes = ()
    for i in range(2) {
      for k in range(slice_counts.at(i), 0, step: -1) {
        let counts = (0, 0)
        counts.at(1 - i) = calc.min(
          calc.ceil(node_counts.at(1 - i) / k),
          slice_sizes.at(i),
        )
        counts.at(i) = slice_sizes.at(i) - counts.at(1 - i)
        let size = counts.zip(node_sizes).map(((c, s)) => c * s).sum()
        let slice = aabbs
          .slice(0, size)
          .sorted(key: aabb =>
            aabb.at(0 + calc.rem-euclid(depth, 2))
            + aabb.at(2 + calc.rem-euclid(depth, 2))
          )
        aabbs = aabbs.slice(size)
        for j in range(2) {
          node_counts.at(j) -= counts.at(j)
          for _ in range(counts.at(j)) {
            nodes.push(slice.slice(0, node_sizes.at(j)))
            slice = slice.slice(node_sizes.at(j))
          }
        }
      }
    }

    let children = nodes.map(aabbs =>
      omt(aabbs, max_node_size, smallroot: smallroot, depth: depth + 1)
    )
    let aabb = merge_aabbs(..children.map(c => c.aabb))
    (
      aabb: aabb,
      children: children
    )
  }
}

// #let color(d) = if d == 2 {
//   red
// } else {
//   white
// }

#let draw_tree(tree, depth: -1) = {
  if depth != 0 {
    if type(tree) == dictionary {
      let stroke_width = if depth < 0 {
        1pt
      } else {
        // depth * 2pt
      }
      if depth == 2 {
        draw_aabb(tree.aabb, stroke: 0.5pt + red)
      }
      if depth == 3 {
        draw_aabb(tree.aabb, stroke: 1pt + blue)
      }
      for child in tree.children {
        draw_tree(child, depth: depth - 1)
      }
    } else {
      draw_aabb(tree)
    }
  }
}

#figure(
  [#cetz.canvas({
    import cetz.draw: *
    rect((-5, -5), (5, 5))

    let rng = gen-rng(10)
    let (_, aabbs) = random_aabbs(rng, 30)

    draw_tree(omt(aabbs, 5, smallroot: true), depth: 4)
  })

  // #cetz.canvas({
  //   import cetz.draw: *
  //   rect((-5, -5), (5, 5))

  //   let select(aabbs, ..indices) = {
  //     let res = ()
  //     for i in indices.pos() {
  //       res.push(aabbs.at(i))
  //     }
  //     res
  //   }

  //   let rng = gen-rng(10)
  //   let (_, aabbs) = random_aabbs(rng, 30)
  //   for (i, aabb) in aabbs.enumerate() {
  //     draw_aabb(aabb, index: i)
  //   }
  //   let layer1 = (
  //     // select(aabbs, 14, 13, 2, 12),
  //     // select(aabbs, 1, 20, 10, 29, 4),
  //     // select(aabbs, 9, 8, 17, 6, 22),
  //     // select(aabbs, 19, 25, 18, 5),
  //     // select(aabbs, 26, 27, 28, 0),
  //     // select(aabbs, 24, 21, 7, 11),
  //     // select(aabbs, 15, 23, 3, 16),
  //     select(aabbs, 26, 27, 28, 19),
  //     select(aabbs, 25, 18, 0, 5, 24),
  //     select(aabbs, 14, 13, 2, 12, 6),
  //     select(aabbs, 1, 10, 20, 4, 29),
  //     select(aabbs, 17, 9, 8, 22),
  //     select(aabbs, 21, 7, 11),
  //     select(aabbs, 15, 23, 3, 16)
  //   ).map(l => merge_aabbs(..l))
  //   for (i, aabbs) in layer1.enumerate() {
  //     draw_aabb(aabbs, stroke: red)
  //   }
  //   // let layer2 = (
  //   //   select(layer1, 1, 2, 5, 6),
  //   //   select(layer1, 0, 4, 3)
  //   // ).map(l => merge_aabbs(..l))
  //   // for aabbs in layer2 {
  //   //   draw_aabb(aabbs, stroke: blue)
  //   // }
  // })
  ],
  caption: [
    Az Overlap Minimizing R-Tree. Látható, hogy kevesebb az átfedés a csúcsok
    között, mint az R-Treeben. Az OMT-ben a csúcsok kapacitásának kihasználtsága
    is jobb.
  ]
)

Az OMT-vel generált fát az összes többi R-Tree algoritmussal használhatjuk
tovább. A fizikai motor csak a keresést használja az R-Tree-ből, mert jelenleg
minden ciklusban újraépíti a fát.
