$ = jQuery

class MBEditor

  set_dirty: () =>

    self = @
    self.board.trigger('change')

  serialize_tile: (tile) =>

    self = @

    img = tile.find('.mb-tile-image img')

    data = {
      x:      tile.data('x')
      y:      tile.data('y')
      width:  tile.data('width')
      height: tile.data('height')
    }

    $.extend(data, {
      attributes:    self.serialize_saved_attributes(img)
      edit_width:    img.width()
      edit_height:   img.height()
      edit_x_offset: img.position().left
      edit_y_offset: img.position().top
    }) if img.length

    data

  serialize: =>

    self = @
    self.serialize_tile($(tile)) for tile in $('.mb-tile', self.board)

  serialize_saved_attributes: (img) =>

    self = @

    ret = {}

    for key in self.data.saved_attributes
      ret[key] = img.data(key) || ''

    ret

  add_image: (img, tile) =>

    self = @

    div = $('.mb-tile-image', tile).html('')

    img
      .appendTo(div)
      .draggable
        disabled: true
        start: -> self.set_dirty()

    self.reset_image(img)

    tile.addClass('mb-tile-filled')

  drop_image: (orig, tile) =>

    self = @

    data = {}

    for key, val of orig.data()
      if key in ['draggable', 'uiDraggable']
        continue

      key = key.replace(/[A-Z]/, (letter) ->
        '-' + letter.toLowerCase()
      )
      data[key] = val

    img = $('<img />')
      .attr('src', orig.data('url'))
      .data(data)

    self.add_image(img, tile)
    self.set_dirty()

  reset_image: (img) ->

    self = @

    tile = img.parents('.mb-tile')

    isize = [img.data('orig-width'), img.data('orig-height')]
    tsize = [tile.data('width'), tile.data('height')]

    iratio = isize[1] / isize[0]
    tratio = tsize[1] / tsize[0]

    if iratio > tratio
      # image more vertical than tile
      w = tsize[0]
      h = isize[1] * tsize[0] / isize[0]
      # center vertically
      x = 0
      y = - (h - tsize[1]) / 2
    else
      # image more horizontal than tile
      h = tsize[1]
      w = isize[0] * tsize[1] / isize[1]
      # center horizontally
      x = - (w - tsize[0]) / 2
      y = 0

    img
      .data
        'fit-width': w
        'fit-height': h
      .css
        width: w
        height: h
        left: x
        top: y

    self.update_tile_containment(tile)
    self.update_tile_slider(tile)

  update_tile_containment: (tile) =>

    self = @

    img = tile.find('.mb-tile-image img')

    isize = [img.width(), img.height()]
    tsize = [tile.data('width'), tile.data('height')]
    toffs = tile.find('.mb-tile-image').offset()

    cnt = [
      toffs.left + tsize[0] - isize[0],
      toffs.top + tsize[1] - isize[1],
      toffs.left,
      toffs.top
    ]

    img.draggable('option', 'containment', cnt)

  scale_image: (img, value) =>

    self = @

    minw = img.data('fit-width')
    maxw = img.data('orig-width')

    minh = img.data('fit-height')
    maxh = img.data('orig-height')

    w = Math.round(minw + (maxw - minw) * value / 100)
    w = Math.max(minw, Math.min(maxw, w))

    h = Math.round(minh + (maxh - minh) * value / 100)
    h = Math.max(minh, Math.min(maxh, h))

    tile = img.parents('.mb-tile')
    tsize = [tile.data('width'), tile.data('height')]

    minx = tsize[0] - w
    miny = tsize[1] - h

    center_x = (- self._scale_image_x + tsize[0] / 2) * w / self._scale_image_width
    center_y = (- self._scale_image_y + tsize[1] / 2) * h / self._scale_image_height
    x = tsize[0] / 2 - center_x
    y = tsize[1] / 2 - center_y

    img.css
      width: w
      height: h
      left: Math.round(Math.min(0, Math.max(minx, x)))
      top: Math.round(Math.min(0, Math.max(miny, y)))

    self.update_tile_containment(tile)
    self.set_dirty()

  scale_image_start: (img) =>

    self = @

    self._scale_image_width = img.width()
    self._scale_image_height = img.height()
    self._scale_image_x = img.position().left
    self._scale_image_y = img.position().top

  create_tile: =>

    tile_tpl = '
      <div class="mb-tile">
          <div class="mb-tile-text">drag image here</div>
          <div class="mb-tile-image"></div>
          <div class="mb-tile-menu">
              <div class="mb-tile-menu-base">
                  <a class="edit" href="#">edit</a> /
                  <a class="remove" href="#">remove</a>
              </div>
              <div class="mb-tile-menu-edit">
                  <div class="mb-tile-menu-slider"></div>
                  <a class="apply" href="#">apply</a> /
                  <a class="reset" href="#">reset</a>
              </div>
          </div>
      </div>
    '

    $(tile_tpl)

  update_tile_slider: (tile) =>

    self = @

    img = tile.find('.mb-tile-image img')

    curw = img.width()
    minw = img.data('fit-width')
    maxw = img.data('orig-width')

    value = 100 * (curw - minw) / (maxw - minw)

    tile
      .find('.mb-tile-menu-slider')
      .slider('value', value)

  init_tile_image: (tile, tdata) =>

    self = @

    img = $('<img />')
      .attr
        'src': tdata.orig_url
      .data
        'orig-width': tdata.orig_width
        'orig-height': tdata.orig_height

    for key, val of tdata.attributes
      img.data(key, val)

    self.add_image(img, tile)

    img.css
      left:     tdata.edit_x_offset
      top:      tdata.edit_y_offset
      width:    tdata.edit_width
      height:   tdata.edit_height

    self.update_tile_containment(tile)
    self.update_tile_slider(tile)

  init_tile: (tdata) =>

    self = @

    tile = self.create_tile()
      .css
        left: tdata.x - 1
        top: tdata.y - 1
        width: tdata.width
        height: tdata.height
      .data
        x: tdata.x
        y: tdata.y
        width: tdata.width
        height: tdata.height
      .appendTo(self.board)

    $('.mb-tile-image', tile).css
      width: tdata.width
      height: tdata.height

    $('.mb-tile-text', tile).css
      width: tdata.width
      height: tdata.height
      'line-height': (tdata.height - 2) + 'px'

    $('.mb-tile-menu-slider', tile).slider
      min: 0
      max: 100
      value: 0
      slide: (ev, ui) ->
        img = tile.find('.mb-tile-image img')
        self.scale_image(img, ui.value)
      start: (ev, ui) ->
        img = tile.find('.mb-tile-image img')
        self.scale_image_start(img)

    $('.mb-tile-image', tile).droppable
      accept: '.mb-photo'
      hoverClass: 'ui-state-hover'
      drop: (ev, ui) ->
        orig = $(ui.draggable)
        self.drop_image(orig, tile)

    self.init_tile_image(tile, tdata) if tdata.orig_url

  toggle_tile_mode: (tile, mode) =>

    self = @

    tile.toggleClass('mb-tile-editing', mode == 'edit')
    tile.find('.mb-tile-image').droppable(if mode == 'view' then 'enable' else 'disable')
    tile.find('.mb-tile-image img').draggable(if mode == 'edit' then 'enable' else 'disable')

    self.set_dirty()

  init_tile_menus: () =>

    self = @

    $('.mb-tile-menu-base .edit', self.board).click (ev) ->
      ev.preventDefault()
      tile = $(this).parents('.mb-tile')
      self.toggle_tile_mode(tile, 'edit')

    $('.mb-tile-menu-base .remove', self.board).click (ev) ->
      ev.preventDefault()
      tile = $(this).parents('.mb-tile')
      self.toggle_tile_mode(tile, 'view')
      tile.removeClass('mb-tile-filled')
      tile.find('.mb-tile-image img').remove()
      self.set_dirty()

    $('.mb-tile-menu-edit .apply', self.board).click (ev) ->
      ev.preventDefault()
      tile = $(this).parents('.mb-tile')
      self.toggle_tile_mode(tile, 'view')

    $('.mb-tile-menu-edit .reset', self.board).click (ev) ->
      ev.preventDefault()
      tile = $(this).parents('.mb-tile')
      img = tile.find('.mb-tile-image img')
      self.toggle_tile_mode(tile, 'view')
      self.reset_image(img)

  init_source_photos: (elem) =>

    self = @

    $('.mb-photo', $(elem)).draggable
      appendTo: self.board
      helper: 'clone'
      revert: 'invalid'
      zIndex: 9999

  init_board: () =>

    self = @

    self.board.css
      width: self.data.board.width
      height: self.data.board.height

    self.init_tile(tdata) for tdata in self.data.board.tiles
    self.init_tile_menus()

  constructor: (elem, data) ->

    self = @

    defaults =
      board: {}
      source_photos: ''
      saved_attributes: ['photo-id']

    data = $.extend({}, defaults, data)
    self.board = $(elem)
    self.board.data('mb-editor', self)
    self.data = data

    self.init_board()
    self.init_source_photos(data.source_photos)


$.fn.MBEditor = (data) ->
  @each -> new MBEditor(this, data)
