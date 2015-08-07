data = d3.tsv.parse ig.data.znacky, (row) ->
  for field, value of row
    continue if field == "znacka"
    row[field] = parseInt value, 10
  row.ratioPerCar = row.vaznych / row.automobilu
  row.ratioPerAccident = row.vaznych / row.nehod
  row.histogram = for i in [0 to 20]
    row[i] / row.vaznych
  row.histogramMax = d3.max row.histogram
  row.histogram.parent = row
  row

data.sort (a, b) -> b['ratioPerAccident'] - a['ratioPerAccident']
for datum, index in data
    datum.index = index

histogramMax = d3.max data.map (.histogramMax)

barScale = d3.scale.linear!
  ..range [0 100]

container = d3.select ig.containers.base
list = container.append \ul
  ..attr \class \ladder
listItems = list.selectAll \li .data data .enter!append \li
  ..style \top -> "#{it.index * 34}px"
  ..append \span
    ..attr \class \name
    ..html (.znacka)
barContainers = listItems.append \div
  ..attr \class \bar-container
bars = barContainers.append \div
  ..attr \class \bar

barLabels = bars.append \span
  ..attr \class "label detail"

barValues = bars.append \span
  ..attr \class \value
barHelpLabel = null
colorDomain = ig.utils.divideToParts [0, 0.13], 9
colorDomain.push 1
colorScale = d3.scale.linear!
  ..domain colorDomain
  ..range ['rgb(255,255,204)','rgb(255,237,160)','rgb(254,217,118)','rgb(254,178,76)','rgb(253,141,60)','rgb(252,78,42)','rgb(227,26,28)','rgb(189,0,38)','rgb(128,0,38)','rgb(128,0,38)']

drawMetric = (metric) ->
  data.sort (a, b) -> b[metric] - a[metric]
  for datum, index in data
    datum.index = index

  barScale.domain [0 data[0][metric]]
  bars.style \width -> "#{barScale it[metric]}%"
  listItems.style \top -> "#{it.index * 34}px"
  barHelpLabel.remove! if barHelpLabel
  barHelpLabel := bars
    .filter ( -> it.index == 0)
    .append \span
      .attr \class \label
  switch metric
    | "ratioPerCar"
      barValues.html -> ig.utils.formatNumber it.ratioPerCar * 1e4, 1
      barHelpLabel.html "vážných nehod na 10 000 aut"
      barLabels.html -> "#{ig.utils.formatNumber it.vaznych} nehod, #{ig.utils.formatNumber it.automobilu} automobilů"
    | "ratioPerAccident"
      barValues.html -> "#{ig.utils.formatNumber it.ratioPerAccident * 1e2, 1} %"
      barLabels.html ->
        if it.ratioPerCar > 0.0030
          "#{ig.utils.formatNumber it.vaznych} vážných nehod z #{ig.utils.formatNumber it.nehod}"
        else
          "#{ig.utils.formatNumber it.vaznych} / #{ig.utils.formatNumber it.nehod}"
      barHelpLabel.html "% vážných nehod"

drawHistogram = ->
  new Tooltip!watchElements!
  listItems.append \div
    ..attr \class \histogram
    ..selectAll \div .data (.histogram) .enter!append \div
      ..style \background-color -> colorScale it
      ..attr \data-tooltip (d, i, ii) ->
        znacka = data[ii]
        years = switch
          | 1 < i < 5 => "#i roky"
          | i >= 5 => "#i let"
          | i == 1 => "1 rok"
          | otherwise => "méně než rok"

        "Auta #{znacka.znacka} stará <b>#years</b> způsobila <b>#{ig.utils.formatNumber d, 1} %</b> vážných nehod této značky<br><em>(#{ig.utils.formatNumber znacka[i]} z #{ig.utils.formatNumber znacka.vaznych})</em>"

switch window.location.hash
| '#perAccident'
  drawMetric "ratioPerAccident"
| '#histogram'
  drawHistogram!
| otherwise
  drawMetric "ratioPerCar"
