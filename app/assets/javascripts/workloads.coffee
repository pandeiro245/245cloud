$ ->
  if $('#remain').length
    remain = parseInt($('#remain').attr('data-remain'))
    Util.countDown(remain*1000, ()->
      location.reload()
    )
