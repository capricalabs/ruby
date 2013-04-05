$ = jQuery

class MBViewer

  init_tile: (data) =>

    self = @

    tile = $('<div />')
      .addClass('.mb-tile')
      .css
        left: data.x - 1
        top: data.y - 1
        width: data.width
        height: data.height
        position: 'absolute'
        border: '1px solid #808080'
        background: '#ececec'
      .appendTo(self.board)

    if data.url
      elem = $('<img />').attr
        src: data.url
        title: data.title

      if data.anchor
        a = $('<a />').attr
          href: data.anchor
          target: '_blank'
        elem.appendTo(a)
        elem = a

      elem.appendTo(tile)

  init_board: =>

    self = @

    self.board
      .addClass('.mb-board')
      .css
        position: 'relative'
        width: self.data.width
        height: self.data.height

    self.init_tile(tile) for tile in self.data.tiles


  constructor: (elem, data) ->

    self = @

    self.board = $(elem)
    self.data = data
    self.init_board()


$.fn.MBViewer = (data) ->
  @each -> new MBViewer(this, data)
