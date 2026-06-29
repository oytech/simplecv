#import "@preview/fontawesome:0.6.1": *

#set page("a4")

#set page(
    margin: (x: 210mm * 0.15 * 0.5, y:  297mm * 0.15 * 0.5)
)

#set text(
  font: "CMU Sans Serif",
  size: 10pt
)

#set heading(numbering: none)

#show heading: set text(weight: "regular", size: 20pt)

#show link: set text(fill: rgb("#0067a5"))

#let cols(hints, main, hints-align: right) = {
  grid(
    columns: (3fr, 11fr),
    stroke: none,
    align: (hints-align, left),
    gutter: 15pt,
    hints,
    main,
  )
}

#let cvhints(content) = {
    cols(content, [])
}

#let cvmain(content) = {
    cols([], content)
}

#let cvfooter(content) = {

}

$body$
