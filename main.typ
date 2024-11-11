#import "@preview/cetz:0.2.2"
#import "templ.typ": template, todo, todo_image, chapter

#show: template.with(
  title: [Fizikai motor fejlesztése Rust nyelven],
  subtitle: [Szakdolgozat],
  author: [Szarkowicz Dániel],
  consulent: [Fridvalszky András],
  digital: true
)

#chapter(numbering: none)[Bevezetés]
#include "chapters/introduction.typ"

#chapter[Fizikai motorok]
#include "chapters/engines.typ"

#chapter[Rust]
#include "chapters/rust.typ"

#chapter[Merevtest-szimuláció matematikája]
#include "chapters/rigidbody_math.typ"

#chapter[Ütközés detektálás]
#include "chapters/collision_detection.typ"

#chapter[Ütközés detektálás gyorsítása]
#include "chapters/broad_phase.typ"

#chapter[Nyugalmi érintkezés]
#include "chapters/resting_contact.typ"

#chapter[Fizikai könyvtár]
#include "chapters/crate.typ"

#chapter[Eredmények]
#include "chapters/results.typ"

#set heading(offset: 0)
#bibliography("references.yml")
