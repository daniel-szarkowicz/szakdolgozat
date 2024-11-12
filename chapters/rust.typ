A Rust egy modern, nagy teljesítményű rendszerprogramozási nyelv, amely nagy
hangsúlyt helyez a program memóriabiztonságára és helyességére.
A memóriabiztonság garantálására fordítás (pl. RAII) és futtatás idejű
(pl. tömb méret indelxeléskor) ellenőrzéseket használ. A program helyességét
egy erős típus rendszer és a borrow checker garantálja. Néha teljesítményi
okokból olyan kódot írunk, amirő a fordító nem tudja belátni, hogy helyes,
ilyenkor az `unsafe` kulcsszóval tudunk olyan metódusokat (pl. `get_unckeched`)
és típusokat (pl. `UnsafeCell`) használni, amelyek nem garantálják a program
helyességét.

// A fizikai motor fejlesztéséhez például Data-oriented design-t használtam, így
// az objektumok független adatait külön tömbökben tárolom, a könyvtár viszont

A Rusthoz egy nagyon nagy ökoszisztéma is tartozik amelyekkel könnyen lehet
cross-platform alkalmazásokat feljeszteni. A kirajzoláshoz felhasznált `wgpu`
könyvtár például egy alacsony szintű absztrakciós réteget biztosít a különböző
grafikus API-k között, így a programot viszonylag egyszerű akár weben is
futtatni.
