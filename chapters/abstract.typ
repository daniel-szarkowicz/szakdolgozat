A realisztikus, valós idejű szimulációknak egyre fontosabb szerepe van a
számítógépes grafika terén.
Az szimulációk új lehetőségeket nyitnak a videójátékok, animációk és
tervezőprogramok területén.

// A merevtest-szimulációnak a célja a mindennapi fizikai objektumok egymásra
// hatásának szimulációja. Ehhez először fel kell építeni a fizikai modellt, ami
// szerint viselkedni fog a rendszer, majd be kell vezetni egy algoritmust, amely
// megmondja, hogy két test milyen kapcsolatban áll egymással. Végül optimalizálási
// algoritmusokkal kell gyorsítani a szimulációt, hogy akár több ezer testnek az
// interakcióit tudjuk egyszerre szimulálni.

Ebben a dolgozatban megismerkedünk néhány elterjedt fizikai motorral, a
merevtestek mozgásának matematikájával, a Gilbert-Johnson-Keerthi algoritmussal
és bővítéseivel, majd megvizsgálunk néhány gyorsítási módszert, amiknek
köszönhetően akár több ezer testet szimulálhatunk.

A dolgozat végén implementálunk egy fizikai motort a Rust programozási nyelven,
amelyet néhány egyszerű példával mutatunk be.
