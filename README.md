# Data Visualisation with `ggplot2`

A thematic **book** of Arthur Katossky's data-visualisation course. Each chapter is
written as prose followed by its exercises; the matching **slide deck is generated
from the same source**, so book and slides never drift apart.

## Structure

```
chapters/<theme>/
  _body.qmd     # the teaching content (single source of truth)
  index.qmd     # book chapter  = front matter + include _body.qmd
  slides.qmd    # slide deck     = revealjs front matter + include _body.qmd
shared/         # images, data and styles referenced by chapters
tests/          # regression test pinning the book/slides split mechanism
```

Content shared by both outputs lives in `_body.qmd`. To target one output only:

- book-only prose: `::: {.content-hidden when-format="revealjs"}`
- slide-only bullets: `::: {.content-visible when-format="revealjs"}`

(`when-format="html"` is **not** slide-safe: revealjs derives from html. The test in
`tests/test-slides.sh` guards this.)

## Build

```bash
quarto render                       # build the book into _book/
quarto render chapters/<t>/slides.qmd   # build one slide deck
./tests/test-slides.sh              # check the slide mechanism still holds
```

## Chapters

Foundations: intro · grammar · perception · color
Beyond the basics: uncertainty · high-dimension · cartography · networks
Communicating: dashboards · reception · animation
