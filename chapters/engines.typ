= Box2D
A Box2D @box2d egy 2 dimenziós fizikai motor, amelyet a C programozási nyelvben írtak.\
A motor sok féle szimulációt támogat:
- ütközés
- tapadási és csúszási súrlódás
- jointok
- ragdollok
- ray casting

A motor egy iteratív megoldást használ a korlátok megoldására, és így is
jó minőségű stabil szimulációkat tud produkálni. Sok objektumot képes
valós időben szimulálni, így számos videojáték használja.\
Néhány híres videojáték:
- Angry Birds
- Happy Wheels
- Limbo
- Showel Knight

A Box2D-t egy egyszerű C API-n keresztül lehet használni, számos nyelvhez
készültek hozzá binding-ok és a legtöbb játékmotorban is használható beépítve
vagy egy bővítményként.

= Rapier
A Rapier @rapier egy 2 és 3 dimenziós fizikai motor, amelyet a Rust programozási nyelven
írtak. A motor hasonló funkciókat támogat, mint a Box2D. Nagy hangsúlyt
helyez a determinizmusra, akár különböző architektúrájú platformokon is.

A Rapier-t egy egyszerű Rust API-n keresztül lehet használni és számos modern
játékmotorban használható.
