/*
#import "@watasuke102/slide:1.1.0": *
#show: slides.with()
*/
#import "@preview/itemize:0.2.0" as el
#let gray0 = luma(98%)
#let gray1 = luma(80%)
#let gray2 = luma(65%)
#let gray3 = luma(50%)
#let gray4 = luma(35%)
#let white = gray0
#let gray = gray2
#let black = rgb("#282c34")
#let green = rgb("#98c379")
#let red = rgb("#e06c75")
#let yellow = rgb("#e5c07b")
#let blue = rgb("#61afef")
#let purple = rgb("#c678dd")
#let cyan = rgb("#56b6c2")

#let main_margin = (x: 1.1cm, y: 1.0cm)
#let primary_font_size = 26pt
#let slides(aspect_ratio: "16-9", page_number: "current-only", doc) = {
  show: el.default-list.with(label-baseline: "center")

  set page(
    paper: "presentation-" + aspect_ratio,
    header-ascent: -5mm,
    margin: main_margin,
    fill: black,
    numbering: "1 / 1",
    number-align: top + right,
    header: if page_number != "none" {
      context place(
        top + right,
        dx: here().position().x,
        box(
          inset: (top: 0.6cm, right: 0.6cm, bottom: 3mm, left: 2mm),
          fill: rgb("#282c34aa"),
          align(horizon, text(
            size: 22pt,
            fill: gray2,
            weight: 600,
            [#here().page()]
              + if page_number == "both" {
                text(weight: "regular", size: 0.7em)[ \/ #counter(page).final().at(0)]
              } else [],
          )),
        ),
      )
    },
  )
  set text(font: "Rounded M+ 1c", size: primary_font_size, fill: gray0)
  set underline(stroke: 2pt)
  set list(
    tight: false,
    spacing: 1.0em,
    marker: (
      circle(fill: white, radius: 0.29em),
      circle(stroke: 2pt + white, radius: 0.23em),
      box(fill: white, width: 0.2em, height: 0.2em),
    ),
  )
  show list: it => {
    // FIXME: this collapses when the font size is too big (> 36pt?)
    // without this adjustment, list marker looks not aligned (but what is this magic number?)
    set text(baseline: -0.49mm)
    it
  }
  set enum(
    tight: false,
    spacing: 1.0em,
  )
  show heading.where(level: 1): set text(weight: "bold", size: 50pt)
  show heading.where(level: 2): set text(weight: "extrabold")
  show figure.where(kind: image): set figure(supplement: "図")
  show figure.where(kind: table): set figure(supplement: "表")
  show figure.where(kind: table): set figure.caption(position: top)
  show strong: set text(weight: 600)
  show link: underline

  set raw(theme: "/onedark.tmtheme")
  show raw: set text(font: "Moralerspace Krypton HWJPDOCNF", size: primary_font_size)
  show raw.where(block: true): set block(
    width: 100%,
    inset: 8pt,
    outset: 8pt,
    stroke: 1pt + gray1,
    radius: 2pt,
  )

  set footnote.entry(
    clearance: 5mm,
    gap: 1.5mm,
    separator: line(length: 100%, stroke: 1pt + white),
    indent: 0pt,
  )
  show footnote.entry: it => {
    set text(size: 0.7em)
    // stack() may exceeds the page margin
    grid(
      columns: (auto, 1fr),
      column-gutter: 0.3em,
      // use counter() directly to avoid using super()
      text(fill: gray1, counter(footnote).display(at: it.note.location())), it.note.body,
    )
    v(0.2em, weak: true) // do not add space if this entry is the end
  }
  // https://forum.typst.app/t/how-to-prevent-a-page-break-within-a-bibliography-entry/5712
  show bibliography: set grid.cell(breakable: false)

  doc
}

#let section_counter = counter("section_counter")
#let template_title_lt(title, right_contents, lower) = {
  set page(fill: green, header: [])
  set text(fill: black)
  grid(
    columns: 100%,
    rows: (1fr, auto, 1fr),
    row-gutter: 1cm,
    [],
    {
      set align(center)
      set text(font: "M PLUS 1")
      set par(leading: 0.3em, spacing: 0pt)
      heading(level: 1, title)
    },
    {
      set text(size: primary_font_size - 4pt)
      set par(leading: 0.3em, spacing: 0.6em)
      // table() alignment cannot be bottom because
      // it affects the alignment of right_contents
      v(1fr)
      align(center, table(
        rows: (auto, auto),
        columns: (1fr, auto, auto, 1fr),
        stroke: none,
        column-gutter: 8pt,
        [],
        image("icon.jpg", width: 100pt),
        align(left, right_contents),
        [],
        table.cell(colspan: 4, text(fill: gray4, lower)),
      ))
    },
  )
}
#let template_title_main(title, lower) = {
  grid(
    rows: (1fr, auto, 1fr),
    row-gutter: 1cm,
    [],
    {
      set align(bottom)
      set text(font: "M PLUS 1")
      set par(leading: 0.3em, spacing: 0pt)
      heading(level: 1, title)
    },
    {
      set text(size: 22pt, fill: gray2)
      set par(leading: 0.4em, spacing: 0.7em)
      lower
    },
  )
}
#let template_bio(icon_size: 10cm, body) = {
  pagebreak(weak: true)
  set page(fill: green)
  set text(fill: black)
  set list(
    spacing: 0.7em,
    marker: (
      circle(fill: black, radius: 0.29em),
      circle(stroke: 2pt + black, radius: 0.23em),
    ).map(e => box(height: primary_font_size, align(horizon + center, e))),
  )
  align(horizon + center, grid(
    columns: (1fr, 1fr),
    image("icon.jpg", height: icon_size),
    align(left, box(width: 100%)[
      #set par(spacing: 10pt)
      #move(dx: -4pt, text(size: 52pt, weight: "bold")[わたすけ])

      #text(size: 28pt, weight: "bold", fill: gray4)[watasuke]
      #set par(spacing: 0.7em)
      #line(stroke: 2pt + black, length: 85%)
      #body
    ]),
  ))
}
#let template_section(name) = {
  pagebreak(weak: true)
  section_counter.step()
  context {
    if name != "" {
      place(hide([= #name <section_header>]))
    }

    show table.cell: set text(size: 32pt)

    // `enum()` cannot change the text color for both the numbered marker and text contents
    table(
      stroke: none,
      // define absolute width for the first column to avoid layout shift
      // when one of the section heading become bold, the layout shift occured
      columns: (1.7em, 1fr),
      row-gutter: 0.5em,
      ..(
        // show heading as a row to avoid layout shift
        (table.cell(colspan: 2, heading(level: 2, outlined: false, [目次])),)
          + query(<section_header>)
            .enumerate()
            .map(e => {
              // change 1-indexed
              let i = e.at(0) + 1
              // counter is already incremented, so decrement here
              let current = section_counter.get().at(0) - 1
              let appearance = it => it
              // If this is NOT the first call, show normal ToC
              if current > 0 {
                if i < current {
                  // finished section
                  appearance = text.with(fill: gray2)
                } else if i == current {
                  // current section
                  appearance = text.with(fill: green, weight: "bold")
                }
              }
              (
                appearance(table.cell[#i.]),
                appearance(table.cell(e.at(1).body)),
              )
            })
            .flatten()
      ),
    )
  }
}
#let template_two_column(
  left_inset: true,
  right_inset: true,
  left_size: 50%,
  right_size: 50%,
  left,
  right,
) = {
  pagebreak(weak: true)
  set page(margin: 0pt)
  grid(
    rows: 100%,
    columns: (left_size, right_size),
    gutter: 0pt,
    box(
      width: 100%,
      height: 100%,
      inset: if left_inset { (left: main_margin.x, right: 0.3cm, y: main_margin.y) } else { 0pt },
      left,
    ),
    box(
      width: 100%,
      height: 100%,
      inset: if right_inset { (left: 0.6cm, right: main_margin.x, y: main_margin.y) } else { 0pt },
      right,
    ),
  )
}
// FIXME: contents may overlay footnotes
// because `1fr` in `rows` property does not take footnote contents into account
#let template_center(center_contents, upper: none, caption: none) = {
  pagebreak(weak: true)
  grid(
    columns: 1fr,
    rows: (auto, 1fr, auto),
    row-gutter: 0.4cm,
    upper,
    align(center + horizon, center_contents),
    align(center + bottom, caption),
  )
}
#let template_basic(body) = {
  pagebreak(weak: true)
  body
}

