#= require jquery
#= require jquery_ujs
#= require jquery.remotipart
#= require twitter/bootstrap
#= require tinymce-jquery
#= require jquery.ba-bbq.min
#= require_self
#= require_tree

$.fn.placeCursorAtEnd = ->
  @.each ->
    $(@).focus();
    if @.setSelectionRange
      len = $(@).val().length * 2
      @.setSelectionRange(len, len)
    else
      $(@).val($(@).val())

class window.ApplicationHelper
  @.populateElementFromAjax = (element, url, params) ->
    $element = $(element)

    # ignore topsearch and other spotlights
    if element.match 'spotlight'
      ApplicationHelper.doPopulateElementFromAjax element, url, params
      return

    # save ajax url and element as hash to allow back button to work
    id = $element.attr 'id'
    state = {}
    state[id] = $.param.querystring( url, params )
    $.bbq.pushState state

  @.doPopulateElementFromAjax = (element,url,params) ->
    $element = $(element)
    $.ajax url,
      data: params
      async: true
      dataType: "text"
      beforeSend: ->
        $element.html "<div class='ajax-spinner'></div>"
      success: (response) ->
        $struct = $(response)
        if $struct.attr("id")? and $element.attr("id")? and $struct.attr("id") is $element.attr("id")
          $struct = $struct.html()
        $element.html $struct
        $element.show()

  @.livesearchReset = (livesearch) ->
    if livesearch?
      for field, value of livesearch
        $('#livesearch_'+field).val value
    else
      $('input[id^=livesearch_],select[id^=livesearch_]').val ''

window.ajax_hashes =
  'product-list': '/products/livesearch'
  'company-list': '/companies/livesearch'
  'user-list': '/users/livesearch'
  'comment-list': '/comments/livesearch'

$(document).ready ->
  $(window).bind 'hashchange', (e, type) ->

    # go through all defined hashes
    for id, default_url of window.ajax_hashes

      $element = $('#'+id)

      # check if the hash exist on page
      continue if $element.length is 0

      # get hash state from url if available
      url = $.bbq.getState id

      # check if we are loading the page without this hash but not initially - e.g. when coming back to url like /products
      unless url? or type is 'initial'
        url = default_url

      continue unless url?

      params = $.param.querystring url
      ApplicationHelper.doPopulateElementFromAjax '#'+id, url, params

      params = $.deparam.querystring url
      # perform a reset on the livesearch form, so its input fields might be populated with current values from hashes
      ApplicationHelper.livesearchReset params.livesearch

  $(window).trigger 'hashchange', 'initial';