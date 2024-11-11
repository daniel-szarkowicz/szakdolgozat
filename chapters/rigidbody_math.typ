#let todo = text.with(red)
= Lineáris mozgás
Egy test mozgásának a leírásához a test pozíciójára és sebességére lesz szükség.
A pozícióra és a sebességre a következőt írhatjuk fel:
$
  v(t) = d/(d t) x(t)
$
A szimuláció állapota időben diszkrét módon frissül. Az új állapotot a következő
módon számolhatjuk ki az előző állapotból:
$
  x(t + Delta t) = x(t) + Delta t dot v(t)
$
Ezt a módszert Euler integrációnak hívjuk. Léteznek pontosabb számítási
módszerek is, például a Runge-Kutta metódus.

A szimuláció a test sebessége helyett a test lendületét tárolja, ez a következő
módon áll kapcsolatban a sebességgel:
$
  p(t) = m dot v(t)
$
Ennek az előnyeiről bővebben az #todo[ütközés] fejezetben fogok írni.

= Forgás
A testek forgása a test mozgásához hasonlóan kezelhető. A testnek van egy
elfordulása, amit egy forgatásmátrixban tárolunk és egy szögsebessége, amit
egy tengellyel és egy nagysággal jellemzünk, ez egy vektorban tárolható. 

A testnek az új elfordulása a következő módon számolható ki a régi elfordulásból
és a szögsebességből:
$
  R(t + Delta t) = (Delta t dot omega(t)^*) dot R(t),\
  #[ahol @baraff1 szerint] quad omega(t)^* = mat(
    0, -omega(t)_z, omega(t)_y;
    omega(t)_z, 0, -omega(t)_x;
    -omega(t)_y, omega(t)_x, 0
  )
$

Míg a mozgásnál a lendületmegmaradás általában megegyezik a
sebességmegmaradással, a forgásnál a perdületmegmaradás nem egyezik meg a
szögsebesség-megmaradással, mert a tehetetlenségi nyomaték nem konstans. A 
newtoni mechanika szerint perdületmegmaradás van, ezért a szimulációban érdemes
a szögsebesség helyett a perdületet tárolni. A perdület a következőképpen áll
kapcsolatban a szögsebességgel:
$
  L(t) = Theta(t) dot omega(t),\
  #[ahol @baraff1 szerint] quad Theta(t) = R(t) dot Theta dot R(t)^(-1)
$
Egy testnek az alap tehetetlenségi nyomatéka az alakjától és a súlyeloszlásától
függ. A szimulációban használt testek tehetetlenségi nyomatéka a következő:
$
  Theta_"gömb" &= 2/3 m dot r^2\
  Theta_"téglatest" &= m/12 dot mat(
    h^2 + d^2, 0, 0;
    0, d^2 + w^2, 0;
    0, 0, w^2 + h^2
  )
$
A szimulációban a tehetetlenségi nyomatéknak csak az inverzét használjuk, mert
mindig perdületből konvertálunk szögsebességbe, ezért a tehetetlenségi
nyomatéknak az inverzét tárolja.

= Ütközésválasz

== Impulzus és szögimpulzus
A szimulációban a testek nem deformálódhatnak és nem metszhetik egymást, ezért
az ütközésnek egy pillanatnyi eseménynek kell lennie. Mivel az erő és a
forgatónyomaték $0$ idő alatt nem tudnak változást elérni, ezért helyettük
impulzusokat és szögimpulzusokat kell használni.

A impulzus kifejezhető úgy, mint egy erő, ami egy kicsi idő alatt hat:
$
  J = F dot Delta t
$
Ha az impulzus egy $x_J$ pontban hat a testre, akkor a szögimpulzus:
$
  M = (x_J - x(t)) times F, quad "a forgatónyomaték"\
  Delta L = M dot Delta t = (x_F - x(t)) times F dot Delta t
    = (x_J - x(t)) times J
$

Tehát, ha egy testre egy $J$ impulzus hat egy $x_J$ pontban, akkor a test
lendülete és perdülete a következő módon változik meg:
$
  p'(t) = p(t) + J\
  L'(t) = L(t) + (x_J - x(t)) times J
$

== Lokális sebesség és lokális tehetetlenség
Az ütközési számításokhoz szükséges lesz a testek lokális sebességére egy adott
$x_J$ pontban. Ez a sebességből és a szögsebességből származó kerületi sebesség
összege:
$
  v_l = v(t) + omega(t) times (x_J - x(t)) =
    p(t) / m + (Theta^(-1)(t) dot L(t)) times (x_J - x(t))
$

Szükség lesz még a testek lokális tehetetlenségére. Ez a test tömegéből és
tehetetlenségi nyomatékából származó ellenállás a lokális sebesség adott irányú
változására. Ennek az inverzét így számoljuk ki @baraff2 egy adott irányban az
$x_J$ pontban:

#let big(x) = $lr(size: #150%, #x)$

$
  T^(-1)(hat(u)) = hat(u) dot big([
    hat(u) / m +
    big((Theta^(-1)(t) dot big([(x_J - x(t)) times hat(u)])))
    times (x_J - x(t))
  ])
$

== Normál irányú impulzus
#let vlr = $v_(l r)$
#let vlr2 = $v'_(l r)$
#let dvlrn = $Delta v_(l r,n)$

Két test ütközésekor a testek lokális relatív sebességével (#vlr) kell számolni.
$
  vlr = v_(1,l) - v_(2,l)
$
Jelölje az ütközés utáni lokális relatív sebességet #vlr2.

Ha két test tökéletesen rugalmasan ütközik, akkor #vlr2 normál irányú
komponense #vlr normál irányú komponensének a negáltja lesz:
$
  vlr2 = vlr - 2 hat(n) dot (hat(n) dot vlr)
$
Ha két test tökéletesen rugalmatlanul ütközik, akkor #vlr2 normál irányú
komponense $0$ lesz:
$
  vlr2 = vlr - hat(n) dot (hat(n) dot vlr)
$
Jelölje $epsilon$ az ütközés rugalmasságát. Ha $epsilon = 1$, akkor az ütközés
tökéletesen rugalmas, ha $0$ akkor tökéletesen rugalmatlan. Így a normál irányú
sebességnek a változása a következő:
$
  dvlrn = -(1 + epsilon) dot (hat(n) dot vlr)
$
Ezt a sebességváltozást a lendületmegmaradás törvénye értelmében egy azonos
nagyságú, ellentétes irányú impulzus fogja kiváltani a két testen. Az impulzus
nagysága a testek normál irányú lokális tehetetlenségéből jön ki @baraff2:
$
  |J_n| = dvlrn / (T_1^(-1)(hat(n)) + T_2^(-1)(hat(n)))
$

== Nem normál irányú (súrlódási) impulzus
Két test ütközése során nem csak normál irányú erők (impulzusok) hatnak a
testekre, mert a testek súrlódnak is egymáson. A súrlódás "célja" az, hogy a
testek $vlr$-ének a nem normál irányú komponenseit $0$ felé közelítse.

A súrlódási impulzus nagyságának maximuma a normál irányú impulzus nagyságától
és a súrlódási együtthatótól függ:
$
  |J_s| <= |J_n| dot mu
$
A súrlódási impulzus irányához és nagyságához kelleni fog a $vlr$ nem normál
irányú komponense:
$
  v_(l r, s) = vlr - hat(n) dot (hat(n) dot vlr)
$
A sebesség $0$-ra állításához szükséges impulzus nagyságát a következő módon
kaphatjuk meg:
$
  |J_s^+| = (-|v_(l r, s)|)/(T_1^(-1)(hat(v)_(l r, s)) + T_2^(-1)(hat(v)_(l r, s)))
$
Tehát a súrlódási impulzus:
$
  J_s = min(|J_s^+|, |J_n| dot mu) dot hat(v)_(l r, s)
$

A súrlódást külön lehet bontani tapadási és csúszási súrlódásra. Ilyenkor ha
$|J_s^*|$ nagyobb, mint a tapadási súrlódás maximális nagysága, akkor a csúszási
súrlódás nagyságát használjuk a súrlódási impulzus nagyságaként.
