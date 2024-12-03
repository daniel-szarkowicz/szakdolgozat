#import "templ.typ": template, todo, todo_image, chapter

#show: template.with(
  title: [Fizikai motor fejlesztése\ Rust nyelven],
  subtitle: [Szakdolgozat],
  author: [Szarkowicz Dániel],
  consulent: [Fridvalszky András],
  digital: true
)

#chapter(numbering: none)[Kivonat]
#include "chapters/abstract.typ"

#chapter[Bevezetés]
#include "chapters/introduction.typ"

#chapter[Fizikai motorok]
#include "chapters/engines.typ"

#chapter[Rust]
#include "chapters/rust.typ"

#chapter[Merevtestek matematikája]
#include "chapters/rigidbody_math.typ"

#chapter[Ütközés detektálás]
#include "chapters/collision_detection.typ"

#chapter[Ütközés detektálás gyorsítása] <broad_phase>
#include "chapters/broad_phase.typ"

#chapter[Nyugalmi érintkezés]
#include "chapters/resting_contact.typ"

#chapter[Fizikai könyvtár]
#include "chapters/crate.typ"

#chapter[Eredmények]
#include "chapters/results.typ"

#let appendix(body) = {
  heading(level: 1, numbering: none)[Függelék]
  set heading(numbering: (..numbers) => {
    let nums = numbers.pos()
    let _ = nums.remove(0)
    numbering("A.", ..nums)
  })
  body
}

#show: appendix
#include "chapters/appendix.typ"

#set heading(offset: 0)
#bibliography("references.yml")
