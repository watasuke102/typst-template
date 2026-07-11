/*
#import "@watasuke102/report:1.3.0": *
#show: doc => template("title", doc, kind: "report")
*/
#import "properties.typ": *

#let code(path, lang: none) = raw(block: true, lang: lang, read(path))
#let quote(t) = {
  set text(luma(35))
  rect(width: 100%, t)
}

// template
#let template(title, doc, kind: "report", lang: "ja") = {
  set text(font: "Rounded M+ 1c")
  show raw.where(block: true): s => {
    set text(font: "Moralerspace Krypton HWJPDOCNF")
    block(width: 100%, inset: 8pt, stroke: 1pt + luma(40), radius: 1pt, s)
  }
  show link: s => text(fill: blue, underline(s))
  show figure.where(kind: image): set figure(supplement: "図")
  show figure.where(kind: table): set figure(supplement: "表")
  show figure.where(kind: table): set figure.caption(position: top)
  set heading(numbering: "1.1.1.1.1.")
  set page(margin: (x: 1.8cm, y: 1.3cm))

  let col_dark = luma(40)
  let col_light = luma(240)
  set table(
    stroke: (x, y) => if y == 0 {
      col_dark
    },
    fill: (x, y) => if y == 0 {
      col_dark
    } else if calc.rem(y, 2) == 0 {
      col_light
    },
  )
  set table.vline(stroke: col_dark)
  set table.cell(align: horizon)
  show table.cell: it => if it.y == 0 {
    show text: s => text(fill: col_light, strong(s))
    align(center, it)
  } else {
    align(left, it)
  }

  if kind == "note" or title == "" {
    set page(height: auto)
    doc
  } else if kind == "report" {
    let sections = if lang == "en" {
      ("Submit Date", "Student ID", "Name", student_name_en)
    } else {
      ("提出日", "学籍番号", "名前", student_name)
    }
    [
      #align(center, text(size: 18pt, weight: "bold", title))

      #align(right, grid(
        columns: 2,
        gutter: 4pt,
        strong(sections.at(0)), datetime.today().display(),
        strong(sections.at(1)), student_id,
        strong(sections.at(2)), sections.at(3),
      ))
    ]
    doc
  } else {
    assert(false, "kind `" + kind + "` is not a valid value")
  }
}

