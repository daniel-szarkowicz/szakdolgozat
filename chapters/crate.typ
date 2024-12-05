#import "../templ.typ": todo

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
```
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
```
]
