data = d3.tsv.parse ig.data.znacky, (row) ->
  for field, value of row
    continue if field == "znacka"
    row[field] = parseInt value, 10
  row.ratioPerCar = row.vaznych / row.automobilu
  row.ratioPerAccident = row.vaznych / row.nehod
  row

barScale = d3.scale.linear!
  ..range [0 100]

container = d3.select ig.containers.base
list = container.append \ul
  ..attr \class \ladder
listItems = list.selectAll \li .data data .enter!append \li
  ..append \span
    ..attr \class \name
    ..html (.znacka)
barContainers = listItems.append \div
  ..attr \class \bar-container
bars = barContainers.append \div
  ..attr \class \bar
barValues = bars.append \span
  ..attr \class \value
barLabels = null

drawMetric = (metric) ->
  data.sort (a, b) -> b[metric] - a[metric]
  for datum, index in data
    datum.index = index

  barScale.domain [0 data[0][metric]]
  bars.style \width -> "#{barScale it[metric]}%"
  listItems.style \top -> "#{it.index * 34}px"
  barLabels.remove! if barLabels
  barLabels := bars
    .filter ( -> it.index == 0)
    .append \span
      .attr \class \label
  switch metric
    | "ratioPerCar"
      barValues.html -> ig.utils.formatNumber it.ratioPerCar * 1e4, 1
      barLabels.html "vážných nehod na 10 000 aut"
    | "ratioPerAccident"
      barValues.html -> "#{ig.utils.formatNumber it.ratioPerAccident * 1e3} %"
      barLabels.html "% vážných nehod"


drawMetric "ratioPerCar"
