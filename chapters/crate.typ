#import "../templ.typ": todo

#set raw(lang: "rust")

= API dokumentáció
== World
A szimuláció fő objektuma, ez tárolja a szimuláció allapotát és ez felelős az
állapot frissítéséért.

=== Metódusok
`pub fn new(config: WorldConfig) -> Self`\
Létrehoz egy új `World` objektumot, amely adott `WorldConfig` szerint van
felkonfigurálva.

`pub fn get<'w, ID: ObjID<'w>>(&'w self, id: ID) -> Option<ID::Ref>`\
Visszaadja az `ID`-hoz tartozó objektum referenciáját, ha létezik.

// `pub fn get_mut<'w, ID: ObjID<'w>>(&'w mut self, id: ID) -> Option<ID::RefMut>`\
// Visszaadja az `ID`-hoz tartozó objektum mutábilis referenciáját, ha létezik

`pub fn add_staticbody(&mut self, shape: Shape) -> StaticbodyBuilder`\
Visszaad egy `StaticbodyBuilder`-t, aminek segítségével létre tudunk hozni
egy új statikus testet.

`pub fn staticbodies(&self) -> StaticbodyIter`\
Visszaad egy iterátort a tárolt statikus testek referenciái felett.

// `pub fn staticbodies_mut(&mut self) -> StaticbodyIterMut`\
// Visszaad egy iterátort a tárolt statikus testek mutábilis referenciái felett.

`pub fn add_rigidbody(&mut self, shape: Shape) -> RigidbodyBuilder`\
Visszaad egy `RigidbodyBuilder`-t, aminek segítségével létre tudunk hozni
egy új merev testet.

`pub fn rigidbodies(&self) -> RigidbodyIter`\
Visszaad egy iterátort a tárolt merev testek referenciái felett.

// `pub fn rigidbodies_mut(&mut self) -> RigidbodyIterMut`\
// Visszaad egy iterátort a tárolt merev testek mutábilis referenciái felett.

`pub fn contacts(&self) -> impl Iterator<Item = (Vec3, Vec3, Vec3)> + '_`\
Visszaad egy iterátort az érintkezési pontok felett.

`pub fn update(&mut self, delta: Float)`\
Lépteti a szimulációt `delta` idővel.

`pub fn aabbs(&self) -> impl Iterator<Item = (&AABB, usize)>`\
Visszaad egy iterátort az AABB-k felett.

== WoldConfig
Egy világ beállításait reperzentálja. Manuális létrehozás helyett a
`WorldBuilder` használata ajánlott.

=== Mezők
`pub gravity: Vec3`\
A gravitáció iránya.

`pub solver_steps: usize`\
Az iteratív megoldó által megtett lépések száma.

`pub rb_separation_force: Float`\
Az egymásba ragadt merev testek közötti taszító erő.

`pub sb_separation_force: Float`\
Az egymásba ragadt merev testek és a statikus testek közötti taszító erő.

`pub bounciness: Float`\
Az ütközések rugalmassági tényezője.

`pub friction: Float`\
Az ütközések súrlódási tényezője.

== WorldBuilder
Segít létrehozni egy új `World` objektumot.

=== Metódusok
`pub fn new() -> Self`\
Létrehoz egy új `WorldBuilder` objektumot.

`pub fn no_gravity(self) -> Self`\
Kikapcsolja a gravitációt.

`pub fn down_gravity(self, gravity: Float) -> Self`\
Lefele mutató (y irányban negatív) gravitációt állít be.

`pub fn gravity(mut self, gravity: Vec3) -> Self`\
Beállít egy tetszőleges gravitáció vektort.

`pub fn solver_steps(mut self, solver_steps: usize) -> Self`\
Beállítja, hogy hány lépést tegyen meg az iteratív solver.
Nem lehet 0.

`pub fn rb_separation_force(mut self, rb_separation_force: Float) -> Self`\
Beállítja, hogy mekkora erővel lökjék el egymást az egymásba ragadt
merev testek.

`pub fn sb_separation_force(mut self, sb_separation_force: Float) -> Self`\
Beállítja, hogy mekkora erővel lökjék el egy statikus test a beleragadt merev
testet.

`pub fn no_bounce(self) -> Self`\
Tökéletesen rugalmatlan ütközést állít be.

`pub fn max_bounce(self) -> Self`\
Tökéleteset rugalmas ütközést állít be.

`pub fn bounciness(mut self, bounciness: Float) -> Self`\
Tetszőleges rugalmasságot állít be.

`pub fn no_friction(self) -> Self`\
Kikapcsolja a súrlódást.

`pub fn friction(mut self, friction: Float) -> Self`\
Tetszőleges súrlódási tényezőt állít be.

`pub fn build(self) -> World`\
Létrehozza a felkonfigurált `World` objektumot.

== RigidbodyRef
Egy merev test referenciát reprezentáló objektum. A `World` a merev testeket
_struct of arrays_ módon tárolja, ezért normális referneciákat nem lehet
használni.

=== Metódusok

`pub fn shape(&self) -> &Shape`\
Visszaadja a merev test alakját.

`pub fn inv_mass(&self) -> &Float`\
Visszaadja a merev test tömegének az inverzét. A szimuláció ilyen formában
tárolja a tömeget.

`pub fn mass(&self) -> Float`\
Visszaadja a merev test tömegét.

`pub fn inverse_inertia(&self) -> &Mat3`\
Visszaadja a merev test tehetetlenségi nyomatékának az inverzét. A
tehetetlenségi nyomaték függ a test elfordulásától, ez az érték csak a testek
léptetésekor frissül.

`pub fn position(&self) -> &Vec3`\
Visszaadja a merev test pozícióját.

`pub fn rotation(&self) -> &Quat`\
Visszaadja a merev test elfordulását.

`pub fn momentum(&self) -> &Vec3`\
Visszaadja a merev test lendületét.

`pub fn angular_momentum(&self) -> &Vec3`\
Visszaadja a merev test perdületét.

// `pub fn force(&self) -> &Vec3`\

// `pub fn torque(&self) -> &Vec3`\

`pub fn local_velocity(&self, position: Vec3) -> Vec3`\
Visszaadja a merev test lokális sebességét.

// `pub fn local_acceleration(&self, position: Vec3) -> Vec3`\

`pub fn impulse_effectivnes(&self, position: Vec3, direction: Vec3) -> Float`\
Kiszámolja, hogy egy adott pontban egy adott irányú impulzus milyen
hatékonysággal változtatná meg a lokális sebességet. Ez a test lokális
tehetetlenségeként is elképzelhető.

== StaticbodyRef
Egy statukis test referenciát reprezentáló objektum. A `World` a statikus
testeket _struct of arrays_ módon tárolja, ezért normális referenciákat nem
lehet használni.

=== Metódusok

`pub fn shape(&self) -> &Shape`\
Visszaadja a statikus test alakját.

`pub fn position(&self) -> &Vec3`\
Visszaadja a statikus test pozícióját.

`pub fn rotation(&self) -> &Quat`\
Visszaadja a statikus test elfordulását.

== RigidbodyBuilder
Segít létrehozni egy új merev testet a szimulációban.

=== Metódusok
`pub fn new(world: &'w mut World, shape: Shape) -> Self`\
Létrehoz egy új `RigidbodyBuilder`-t.

`pub fn mass(mut self, mass: Float) -> Self`\
Beállítja a merev test tömegét.

`pub fn position(mut self, position: Vec3) -> Self`\
Beállítja a merev test pozícióját.

`pub fn pos(self, x: Float, y: Float, z: Float) -> Self`\
Beállítja a merev test pozícióját. Sokszor rövidebb három számot megadni,
mint egy vektort.

`pub fn rotation(mut self, rotation: Quat) -> Self`\
Beállítja a merev test elfordulását.

`pub fn finish(self) -> RigidbodyId`\
Létrehoz egy merev testet a szimulációban. Ha ezt a metódust nem hívjuk meg,
akkor nem jön létre a test, hiába használtuk a `World::add_rigidbody`
metódust.

== StaticbodyBuilder
Segít létrehozni egy új merev testet a szimulációban.

=== Metódusok
`pub fn new(world: &'w mut World, shape: Shape) -> Self`\
Létrehoz egy új `StaticbodyBuilder`-t.

`pub fn position(mut self, position: Vec3) -> Self`\
Beállítja a statikus test pozícióját.

`pub fn pos(self, x: Float, y: Float, z: Float) -> Self`\
Beállítja a statikus test pozícióját. Sokszor rövidebb három számot megadni,
mint egy vektort.

`pub fn rotation(mut self, rotation: Quat) -> Self`\
Beállítja a statikus test elfordulását.

`pub fn finish(self) -> RigidbodyId`\
Létrehoz egy statikus testet a szimulációban. Ha ezt a metódust nem hívjuk meg,
akkor nem jön létre a test, hiába használtuk a `World::add_staticbody`
metódust.

= Külső könyvtárak

Az elkészített könyvtár kettő külső könyvtártól függ közvetlenül.

Az első könyvtár a nalgebra @nalgebra. A nalgebra egy általános lineáris
algebra könyvtár amely a vektor, mátrix és kvaternió típusokat szolgáltatja.

A második könyvtár a clipper2 @clipper2. A clipper2 könyvtár számolja az
ütközési pontoknál a síkidomok metszetét.

= Példa kód
A könyvtárban egy `World` típusú objektum reprezentálja a fizikai világot, ezt
a következő módon hozhatjuk létre:
```rust
let mut world = WorldBuilder::new()
  .down_gravity(10.0) // 10 egység erősségű gravitáció, lefelé mutat
  .bounciness(0.9) // az ütközések nagyon rugalmasak
  .friction(0.1) // kicsi súrlódási tényező
  .build();
```
Az `add_staticbody` és `add_rigidbody` metódusok segítségével hozhatunk létre
objektumokat:
```rust
world
  .add_staticbody(Shape::new_box(10.0, 1.0, 10.0))
  .pos(0.0, -5.0, 0.0)
  .finish();
let ball_id = world
  .add_rigidbody(Shape::new_sphere(1.0))
  .finish(); // RigidBodyId alapján lekérdezhetjük az objektumot
```
Az `update` metódus segítségével frissíthetjük a világot:
```rust
let time_step = 1.0 / 100.0;
let mut time = 0.0;
while time < 20.0 {
  time += time_step;
  world.update(time_step);
  let ball = world.get(ball_id).unwrap();
  if world.contacts().count() > 0 {
    println!(
      "floor hit at time {time:05.2}, new y momentum: {:.5}",
      ball.momentum().y
    );
  }
}
```
Kimenet:
#box[
#raw(lang: none, block: true, ```
floor hit at time 00.90, new y momentum: 4.26564
floor hit at time 02.54, new y momentum: 3.91772
floor hit at time 04.05, new y momentum: 3.63313
floor hit at time 05.45, new y momentum: 3.37763
floor hit at time 06.75, new y momentum: 3.13593
floor hit at time 07.95, new y momentum: 2.85678
floor hit at time 09.05, new y momentum: 2.63047
floor hit at time 10.07, new y momentum: 2.47649
floor hit at time 11.02, new y momentum: 2.26403
floor hit at time 11.90, new y momentum: 2.14356
floor hit at time 12.73, new y momentum: 2.01920
floor hit at time 13.51, new y momentum: 1.89271
floor hit at time 14.24, new y momentum: 1.76392
floor hit at time 14.92, new y momentum: 1.63219
floor hit at time 15.56, new y momentum: 1.57970
floor hit at time 16.17, new y momentum: 1.47846
floor hit at time 16.75, new y momentum: 1.43818
floor hit at time 17.30, new y momentum: 1.31296
floor hit at time 17.82, new y momentum: 1.30229
floor hit at time 18.32, new y momentum: 1.20360
floor hit at time 18.79, new y momentum: 1.15167
floor hit at time 19.24, new y momentum: 1.10437
floor hit at time 19.67, new y momentum: 1.04832
```.text)
]
