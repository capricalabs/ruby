$ = jQuery

$ ->

  $('a[data-confirm]').click -> confirm($(this).data('confirm'))
