err = "<%= @picture.errors.full_messages.join( ' ' ) %>"
if err
  alert( err )
else
  $('form.edit_company').prepend( '<input type="hidden" name="reload_only" value="1" />' ).submit()