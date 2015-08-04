data = d3.tsv.parse ig.data.znacky, (row) ->
  for field, value of row
    continue if field == "znacka"
    row[field] = parseInt value, 10
  row.ratioPerCar = row.vaznych / row.automobilu
  row

data.sort (a, b) -> b.ratioPerCar - a.ratioPerCar
barScale = d3.scale.linear!
  ..domain [0 data.0.ratioPerCar]
  ..range [0 100]
container = d3.select ig.containers.base
container.append \ul .selectAll \li .data data .enter!append \li
  ..append \span
    ..attr \class \name
    ..html (.znacka)
  ..append \div
    ..attr \class \bar-container
    ..append \div
      ..attr \class \bar
      ..style \width -> "#{barScale it.ratioPerCar}%"
      ..append \span
        ..attr \class \value
        ..html (it, i) -> ig.utils.formatNumber it.ratioPerCar * 1e4, 1
      ..filter ((d, i) -> i == 0)
        ..append \span
          ..attr \class \popisek
          ..html "vážných nehod na 10 000 aut"
