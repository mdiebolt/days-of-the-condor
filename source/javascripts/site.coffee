#= require ./jquery-2.1.4

toggleSlide = ->
  if $("body").is("[s-slide-out]")
    $("body").removeAttr("s-slide-out")
  else
    $("body").attr("s-slide-out", "")

$nav = $(".blog-information--recent-article-navigation")
$nav.on("click", toggleSlide)

$(window).on "resize", ->
  if window.innerWidth > 640
    $("body").removeAttr("s-slide-out")

if ($stars = $("[js-bootstrap-stars]")).length
  $.getJSON "https://api.github.com/repos/twbs/bootstrap", (data) ->
    $stars.text(data.stargazers_count.toLocaleString())
