$ = jQuery

class MBAutoSave

  set_dirty: (dirty) =>

    self = @

    self.dirty = dirty
    self.set_status('')

  set_status: (status) =>

    self = @

    self.status = status if status

    elem = self.elem.find('.mb-status')

    if self.status == 'saving'
      elem.text('saving')
    else if self.status == 'save error'
      elem.text('modified (save error)')
    else if self.dirty
      elem.text('modified')
    else
      elem.text('saved')

  serialize: =>

    self = @

    data =
      name: $('input[name=mb-name]', self.elem).val()
      desc: $('textarea[name=mb-desc]', self.elem).val()
      status: $('input[name=mb-status]:checked', self.elem).val()
      tiles: self.board.data('mb-editor').serialize()

    data

  save: () =>

    self = @

    return unless self.dirty
    return if self.status == 'saving'

    data = self.serialize()
    data = { json: JSON.stringify(data) }

    self.set_status('saving')
    self.set_dirty(false)

    $.post(self.url, data, ->
      self.set_status('saved')
    ).error ->
      self.set_status('save_error')
      self.set_dirty(true)

  init_actions: =>

    self = @

    $('.mb-save-link', self.elem).click (ev) ->
      ev.preventDefault()
      self.save()

    setInterval(self.save, self.interval * 1000)

    $(window).bind('beforeunload', -> 'You have unsaved changes.' if self.dirty)
    self.board.bind('change', -> self.set_dirty(true))
    $(':input', self.elem).change -> self.set_dirty(true)

  constructor: (elem, data) ->

    self = @

    self.elem = $(elem)
    self.board = $(data.board)
    self.url = data.url
    self.interval = data.interval || 10

    self.init_actions()

    self.set_dirty(false)

$.fn.MBAutoSave = (data) ->
  @each -> new MBAutoSave(this, data)
