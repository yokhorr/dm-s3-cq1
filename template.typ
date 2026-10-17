#let template(
  author: none, 
  teacher: none, 
  course: none, 
  subtitle: none,
  doc
) = {
  set text(lang: "ru")
  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2cm, left: 1.5cm, right: 1.5cm),
    header: 
      box(
        width: 100%,
        inset: 10pt,
        stroke: (bottom: 1pt + black),
        grid(
          columns: (1fr, 2fr, 1fr),
          align: (left, center, right),
          link("https://github.com/yokhorr/yokhor-notes", [*yokhor-notes*]),
          text(weight: "medium", course),
          teacher,
        )
      ),
    numbering: "1",
  )
  
  set heading(numbering: "1.")

  show link: content => {underline(text(blue, content))}

  set quote(block: true, quotes: true)
  show quote: set align(center)
  
  context {
    set page(header: none, footer: none, numbering: none)
    align(center + horizon, {
      text(20pt, weight: "bold", course)
      if subtitle != none {
        v(0.6cm)
        text(14pt, subtitle)
      }
    })
    if author != none {
      v(2cm)
      align(center, text(12pt)[Редактор: #author])
      v(1cm)
    }
  }
  pagebreak()
  outline()
  pagebreak()
  doc
}

#let statement(
  name: none,
  fill: none,
  frame: none,
  title: none,
  body: none,
  proof: none,
  stroke: none,
  qed: false,
  after: none
) = {
  block(
    width: 100%,
    fill: fill,
    
    stroke: (left: 2pt + frame),
    inset: 6pt,
    radius: 4pt,
    {
      text(weight: "bold", size: 1.15em, {
        underline({
          name
          if name != none [.]
        })
        if title != none [ #title]
      })
      if title != none or name != none {
        linebreak()
      }
      body
      if proof != none {
        v(0.5em)
        text(weight: "bold", size: 1.2em)[Доказательство:]
        linebreak()
      }
      proof
      if proof != none or qed {
        align(right)[*Q.E.D.*]
      }
      if after != none {
        v(0.5em)
      }
      after
    }
  )
}


#let theorem = statement.with(name: "Теорема", fill: rgb(245, 245, 255), frame: blue)
#let lemma = statement.with(name: "Лемма", fill: rgb(245, 245, 255), frame: green)
#let corollary = statement.with(name: "Следствие", fill: rgb(245, 255, 255), frame: aqua)
#let remark = statement.with(name: "Замечание", fill: rgb(250, 245, 255), frame: purple)
#let definition = statement.with(name: "Определение", fill: rgb("#E4EFFF"))
#let example = statement.with(name: "Пример", frame: black, fill: rgb("#F0F0FF"))
#let property = statement.with(name: "Свойство", fill:rgb("#F0F0FF"), frame: blue)
#let proof = statement.with(name: "Доказательство", fill: rgb(255, 245, 255), frame: fuchsia, qed: true)

#let divides = $med dots.v med$
 #let def(body) = [#underline[*#body*]]























#let statement_(
  name: none,
  fill: none,
  frame: none,
  title: none,
  body: none,
  proof: none,
  stroke: none,
  qed: false,
  after: none
) = {
  block(
    width: 100%,
    fill: fill,
    //stroke: (left: 2pt + frame),
    //inset: 4pt,
    radius: 4pt,
    {
      text(weight: "bold", size: 1.15em, {
        underline({
          name
          if name != none []
        })
        if title != none [ #title]
      })
      if title != none or name != none {
        linebreak()
      }
      body
      if proof != none {
        v(0.5em)
        text(weight: "bold", size: 1.2em)[Доказательство:]
        linebreak()
      }
      proof
      if proof != none or qed {
        align(right)[*Q.E.D.*]
      }
      if after != none {
        v(0.5em)
      }
      after
    }
  )
}

#let theorem_ = statement_.with(name: "Теорема", fill: rgb(245, 245, 255), frame: blue)
#let lemma_ = statement_.with(name: "Лемма", fill: rgb(245, 255, 245), frame: green)
#let corollary_ = statement_.with(name: "Следствие", fill: rgb(245, 255, 255), frame: aqua)
#let remark_ = statement_.with(name: "Замечание", frame: purple)

#let definition_ = statement_.with(name: "Определение.",  frame: black)
#let property_ = statement_.with(name: "Свойство:", frame: black)
#let example_ = statement_.with(name: "Пример.", frame: black)
#let proof_ = statement_.with(name: "Доказательство",  frame: fuchsia, qed: true)

#let exercise = statement.with(name: "Упражнение", fill: rgb("#FFF6E6"), frame: rgb("#D98A1F"))

#let neq(eq, tag) = grid(
  columns: (1fr, auto),
  align: (center + horizon, right + horizon),
  eq, tag
)

#let mathring(x) = math.circle(x)

// ---------------------------------------------------------------------------
// Рисование небольших графов без внешних пакетов.
//   nodes: словарь  "имя": (x, y)  или  "имя": (x, y, заливка)
//          имя вычисляется как математика (например "v_1", "B_2"); x, y — длины
//          от левого верхнего угла рисунка (ось y направлена вниз).
//   edges: массив  ("имя1", "имя2")  или  ("имя1", "имя2", штрих)
//          или ("имя1", "имя2", штрих, сдвиг);  штрих — например 2pt + red;
//          сдвиг — длина: ребро смещается вбок (нужен, чтобы развести
//          противоположные дуги a->b и b->a). Ребро ("a", "a") рисуется петлёй.
//   directed: true — рисовать стрелки (от первого имени ко второму).
#let draw-graph(nodes, edges, width: 5cm, height: 3cm, r: 0.28cm, directed: false) = {
  box(width: width, height: height, {
    for e in edges {
      let a = nodes.at(e.at(0))
      let b = nodes.at(e.at(1))
      let st = if e.len() > 2 { e.at(2) } else { 0.8pt + black }
      let s = if e.len() > 3 { e.at(3) } else { 0cm }
      if e.at(0) == e.at(1) {
        place(top + left, dx: a.at(0) - 0.2cm, dy: a.at(1) - r - 0.36cm,
          circle(radius: 0.2cm, stroke: st))
      } else {
        let dx = (b.at(0) - a.at(0)) / 1cm
        let dy = (b.at(1) - a.at(1)) / 1cm
        let d = calc.sqrt(dx * dx + dy * dy)
        let ux = dx / d
        let uy = dy / d
        let x1 = a.at(0) - s * uy
        let y1 = a.at(1) + s * ux
        let x2 = b.at(0) - s * uy
        let y2 = b.at(1) + s * ux
        place(top + left, line(start: (x1, y1), end: (x2, y2), stroke: st))
        if directed {
          let tx = x2 - (r - 0.03cm) * ux
          let ty = y2 - (r - 0.03cm) * uy
          let bx = tx - 0.3cm * ux
          let by = ty - 0.3cm * uy
          place(top + left, polygon(fill: black, stroke: none,
            (tx, ty), (bx - 0.1cm * uy, by + 0.1cm * ux), (bx + 0.1cm * uy, by - 0.1cm * ux)))
        }
      }
    }
    for (name, n) in nodes {
      let fl = if n.len() > 2 { n.at(2) } else { white }
      place(top + left, dx: n.at(0) - r, dy: n.at(1) - r,
        box(width: 2 * r, height: 2 * r, radius: r, fill: fl, stroke: 0.8pt + black, inset: 0pt,
          align(center + horizon, text(size: 0.8em, eval(name, mode: "math")))))
    }
  })
}


// ---------------------------------------------------------------------------
// Добавлено для конспекта: русские обозначения функций и блоки для задач.
#let arctg = math.op("arctg")
#let tg = math.op("tg")
#let grad = math.op("grad")
#let dd(x) = math.upright("d") + x   // дифференциал: dd(x) -> dx, dd(f)(1, 1) -> df(1, 1)

// Значение выражения в точке:  #at(body, sub)  ->  ( body ) |_{sub}
#let at(body, sub) = $lr(#body |)_(#sub)$

#let task(num, body) = block(
  width: 100%,
  breakable: false,
  sticky: true,
  fill: rgb("#FFF8E7"),
  stroke: (left: 2pt + rgb("#D98A1F")),
  inset: 6pt,
  radius: 4pt,
  above: 1.4em,
  below: 0.8em,
  {
    text(weight: "bold", size: 1.1em, underline[Задача #num.])
    [ ]
    body
  }
)

// Блок решения: оформлен так же, как остальные блоки (statement).
// Можно вызывать и как #solution[...], и как #solution(body: [...]),
// а также с заголовком: #solution(title: [(способ 2)], body: [...]).
#let solution(..args) = statement(
  name: "Решение",
  fill: rgb("#F6F6F6"),
  frame: rgb("#6B6B6B"),
  title: args.named().at("title", default: none),
  body: if args.pos().len() > 0 { args.pos().at(0) } else { args.named().at("body", default: none) },
)

#let answer(body) = block(
  width: 100%,
  breakable: false,
  fill: rgb("#EAF7EA"),
  stroke: (left: 2pt + rgb("#3A9A3A")),
  inset: 6pt,
  radius: 4pt,
  [*Ответ.* #body]
)
