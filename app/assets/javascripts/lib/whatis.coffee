@ruffnoteAttachment = (id, id2=null) ->
  Ruffnote.attachment(id, id2)

window.initWhatis = () ->
  $("#whatis_title").html("<h2 class='status'><img src='#{@ruffnoteAttachment(24942)}' /></h2>")
  now = new Date()
  month = now.getMonth() + 1
  day = now.getDate()
  youbi = now.getDay()
  numbers = {}
  for i in [1..31]
    i2 = 24371 + i
    numbers[i] = @ruffnoteAttachment(i2)
  youbis = {}
  for i in [1..5]
    i2 = 24358 + i
    youbis[i] = @ruffnoteAttachment(i2)
  youbis[0] = @ruffnoteAttachment(24465) #日
  youbis[6] = @ruffnoteAttachment(24465) #土

  $kokuban = $('<div></div>')
  $kokuban.css('position', 'relative')
  imgurl = @ruffnoteAttachment(24501)
  $kokuban.css("background', 'url(#{imgurl})")
  $kokuban.css('width', '735px')
  $kokuban.css('height', '483px')
  $kokuban.css('margin', '0 auto')

  $month = $('<img />')
  $month.attr('src', numbers[month])
  $month.css('position', 'absolute')
  $month.css('right', '69px')
  $month.css('top', '36px')

  $day = $('<img />')
  $day.attr('src', numbers[day])
  $day.css('position', 'absolute')
  $day.css('right', '70px')
  $day.css('top', '88px')

  $youbi = $('<img />')
  $youbi.attr('src', youbis[youbi])
  $youbi.css('position', 'absolute')
  $youbi.css('right', '70px')
  $youbi.css('top', '138px')

  $kokuban.append($month)
  $kokuban.append($day)
  $kokuban.append($youbi)
  $('#whatis').css('text-align', 'center')
  $('#whatis').html($kokuban)


