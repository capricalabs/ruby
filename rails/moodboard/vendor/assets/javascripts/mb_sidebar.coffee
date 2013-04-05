$ = jQuery

class MBSidebar

  init_photo_list_photo: (elem, idata) =>

    self = @

    $('<img />')
      .attr
        'src':    idata.thumb_url
        'class': 'mb-photo'
        'title':  idata.name
      .data
        'orig-width':   idata.orig_width
        'orig-height':  idata.orig_height
        'photo-id':     idata.photo_id
        'url':          idata.url
      .css
        width: 140
        height: (140 / idata.orig_width * idata.orig_height)
      .appendTo(elem)

  init_photo_list: (elem, data) =>

    self = @

    height = self.sidebar.height() - (elem.position().top - self.sidebar.position().top)

    elem
      .html('')
      .addClass('mb-photo-list')
      .height(height)

    self.init_photo_list_photo(elem, idata) for idata in data
    self.board.data('mb-editor').init_source_photos(elem)

    elem.jScrollPane()

  init_photo_cats: (elem, data) =>

    self = @

    sel = $('<select />')

    for cat, idx in data
      $('<option />')
        .val(idx)
        .text(cat.name)
        .appendTo(sel)

    $(elem)
      .html('')
      .append(sel)

    sel
      .selectmenu
        appendTo: self.sidebar
      .change ->

        me = $(this)
        key = me.val()
        parent = me.parent()

        this.child.remove() if this.child?
        this.child = $('<div/>').appendTo(parent)

        if data[key].photos.length
          self.init_photo_list(this.child, data[key].photos)
        else
          self.init_photo_cats(this.child, data[key].cats)

    sel.trigger('change')

  init_sidebar: =>

    self = @

    self.sidebar.css
      height: self.board.height()

  constructor: (elem, data) ->

    self = @

    self.board = $(data.board)
    self.sidebar = $(elem)
    self.data = data

    self.init_sidebar()
    self.init_photo_cats(self.sidebar, self.data.images.cats)


$.fn.MBSidebar = (data) ->
  @each -> new MBSidebar(this, data)
