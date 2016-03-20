window.initWhatis = () ->
  $("#whatis_title").html("<h2 class='status'><img src='#{ImgURLs.visual_whatis245cloud}' /></h2>")
  now = new Date()
  month = now.getMonth() + 1
  day = now.getDate()
  youbi = now.getDay()

  youbis = {}
  month_img_url = ImgURLs.generate_number_img(month)
  day_img_url   = ImgURLs.generate_number_img(day)
  youbi_img_url = ImgURLs.youbi_map[youbi]

  $kokuban = $('<div></div>')
  $kokuban.css('position', 'relative')
  $kokuban.css('background', "url(#{ImgURLs.visual_whatis})")
  $kokuban.css('width', '735px')
  $kokuban.css('height', '483px')
  $kokuban.css('margin', '0 auto')

  $month = $('<img />')
  $month.attr('src', month_img_url)
  $month.css('position', 'absolute')
  $month.css('right', '69px')
  $month.css('top', '36px')

  $day = $('<img />')
  $day.attr('src', day_img_url)
  $day.css('position', 'absolute')
  $day.css('right', '70px')
  $day.css('top', '88px')

  $youbi = $('<img />')
  $youbi.attr('src', youbi_img_url)
  $youbi.css('position', 'absolute')
  $youbi.css('right', '70px')
  $youbi.css('top', '138px')

  $kokuban.append($month)
  $kokuban.append($day)
  $kokuban.append($youbi)
  $('#whatis').css('text-align', 'center')
  $('#whatis').html($kokuban)


