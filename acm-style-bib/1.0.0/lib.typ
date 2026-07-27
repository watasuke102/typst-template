// #show: acm_citation.with(type: "footnote")
#let acm_citation(type: "normal", doc) = {
  if type == "footnote" {
    set cite(style: "acm-footnote.csl")
    set bibliography(style: "acm-footnote.csl")
    doc
  } else {
    set cite(style: "acm.csl")
    set bibliography(style: "acm.csl")
    doc
  }
}
