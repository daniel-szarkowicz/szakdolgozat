#set raw(lang: "rust")

A Rust @rust egy modern, nagy teljesítményű rendszerprogramozási nyelv, amely nagy
hangsúlyt helyez a memóriabiztonságra és a helyességére.
A memóriabiztonságot fordítási időben a Borrow Checkerrel és a RAII elvvel,
futtatási időben referenciaszámlálással és határellenőrzéssel garantálja.
A program helyességét egy erős típus rendszer biztosítja, amellyel
(jobb esetben) lehetetlen invalid állapotot létrehozni.
// A memóriabiztonság garantálására fordítási (pl. RAII) és futtatási idejű
// (pl. tömb méret indelxeléskor) ellenőrzéseket használ. A program helyességét
// egy erős típus rendszer és a borrow checker garantálja.

// Néha teljesítményi okokból olyan kódot írunk, amirő a fordító nem tudja
// belátni, hogy helyes, ilyenkor az `unsafe` kulcsszóval tudunk olyan metódusokat
// (pl. `get_unckeched`) és típusokat (pl. `UnsafeCell`) használni, amelyek nem
// garantálják a program helyességét.
Néha teljesítményi okokból olyan kódra van szükség, emelyről a fordító nem
képes belátni a program helyességét. Ilyenkor az `unsafe` kulcsszó segítségével
lehet olyan metódusokat és típusokat használni, amelyeknél a memóriabiztonság
és a helyesség nem garantált.

// A fizikai motor fejlesztéséhez például Data-oriented design-t használtam, így
// az objektumok független adatait külön tömbökben tárolom, a könyvtár viszont

// A Rusthoz egy nagyon nagy ökoszisztéma is tartozik amelyekkel könnyen lehet
// cross-platform alkalmazásokat feljeszteni. A kirajzoláshoz felhasznált `wgpu`
// könyvtár például egy alacsony szintű absztrakciós réteget biztosít a különböző
// grafikus API-k között, így a programot viszonylag egyszerű akár weben is
// futtatni.

A Rusthoz több, mint 150000 könyvtár @cratesio tartozik, amelyekkel könnyen lehet
cross-platform alkalmazásokat feljeszteni. A kirajzoláshoz használt wgpu @wgpu
könyvtár például alacsony szintű absztrakciót biztosít különböző grafikus API-k
fölött, így a programot akár a weben, böngészőből is futtathatjuk.
