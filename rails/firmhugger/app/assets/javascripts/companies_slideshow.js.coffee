# add image to slideshow
$.fn.companySlideshow = ->
  $a = @
  $input = $("#slideshow_picture_picture")
  
  $a.click ->
    $input.val ''
    $input.click()
  
  $input.change ->
    $input.closest( "form" ).submit()

# display slideshow on the profile page
$(document).ready ->
  $('#slides').slides(
    preload: true
    preloadImage: '/assets/slidesjs/loading.gif'
    play: 5000
    pause: 2500
    hoverPause: true
    paginationClass: 'slide_pagination'
    animationStart: (current) ->
      $('.caption').animate(
        bottom: -35
      100)
    animationComplete: (current) ->
      $('.caption').animate(
        bottom:0
      200)
    slidesLoaded: ->
      $('.caption').animate(
        bottom:0
      200)
  )