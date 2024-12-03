= Gyorsítási módszerek összehasonlítása

A @broad_phase fejezetben bemutatott módszerek közül választani kellett egyet 
a könyvtár implementációjában. A @broad_phase_comparison táblázatban látható
adatok szerint valós idejű szimulációkhoz a Sort-and-Sweep a legalkalmasabb
algoritmus, hiszen nagy elemszámokra egyik algoritmus sem képes a megfelelő
sebességgel szimulálni. Az eredmények ellenére a könyvtár jelenleg az OMT-t
használja, mert valós idejű szimulációknál a különbség elhanyagolható,
lassabb szimulációknál viszont jobban teljesít.

#figure(
  [
    #let us = {sym.mu; [s]}
    #table(
      columns: (2fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      align: (start, end, end, end, end, end),
      table.header(
      [AABB-k száma]    , [10]     , [100]     , [1000]    , [10000]  , [100000]), table.hline(stroke: 2pt),
      [Minden mindennel], [102 ns] , [6.83 #us], [2100 #us], [252 ms] , [DNF]    ,
      [Sort-and-sweep]  , [483 ns] , [7.04 #us], [261 #us] , [19 ms]  , [1830 ms],
      [Sort-and-sweep 3], [1611 ns], [29 #us]  , [1829 #us], [210 ms] , [DNF]    ,
      [R-Tree]          , [557 ns] , [39 #us]  , [941 #us] , [21 ms]  , [708 ms] ,
      [R-Tree (split)]  , [444 ns] , [24 #us]  , [771 #us] , [14 ms]  , [486 ms] ,
      [OMT]             , [468 ns] , [17 #us]  , [505 #us] , [8.65 ms], [164 ms] ,
      [OMT (split)]     , [455 ns] , [15 #us]  , [453 #us] , [7.98 ms], [146 ms] ,
    )
  ],
  caption: [
    Gyorsítási módszerek összehasonlítása. A (split) sorokban az elemeket két
    struktúrába lettek elhelyezve és csak az elemek felével történt ütközés
    vizsgálat. A (split) eredmények közelebb vannak a valós helyzetekhez, ahol
    az elemek jelentős része nem mozoghat.
  ]
) <broad_phase_comparison>
// #text(size: 0.5em)[
//   A mérés `cargo +nightly bench`-el egy AMD Ryzen 5 4500U processzoron
//   készült, a mérési hiba #{sym.plus.minus}5%.
// ]
