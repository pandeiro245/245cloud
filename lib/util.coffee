class Util
  @minAgo: (min, date=null) ->
    date = new Date() unless date
    new Date(date.getTime() - min*60*1000)

  @scaffolds: (ids) ->
    $body = $('#nc')
    $body.html('') # remove contents for SEO
    for id in ids
      $item = $('<div></div>')
      $item.attr('id', id)
      $item.addClass('row')
      $body.append($item)

  @time: (mtime) ->
    if mtime < 24 * 3600 * 1000
      time = parseInt(mtime/1000)
      min = parseInt(time/60)
      sec = time - min*60
      "#{Util.zero(min)}:#{Util.zero(sec)}"
    else
      time = new Date(mtime * 1000)
      month = time.getMonth() + 1
      day  = time.getDate()
      hour = time.getHours()
      min  = time.getMinutes()
      "#{Util.zero(month)}/#{Util.zero(day)} #{Util.zero(hour)}:#{Util.zero(min)}"

  @monthDay: (time) ->
    date = new Date(time)
    month = date.getMonth() + 1
    day  = date.getDate()
    "#{Util.zero(month)}月#{Util.zero(day)}日"

  @hourMin: (time) ->
    date = new Date(time)
    hour = date.getHours()
    min  = date.getMinutes()
    "#{Util.zero(hour)}:#{Util.zero(min)}"

  @zero: (i) ->
    return "00" if i < 0
    if i < 10 then "0#{i}" else "#{i}"

  @countDown: (duration, callback='reload', started=null) ->
    unless started
      started = (new Date()).getTime()
    past = (new Date()).getTime() - started

    if duration > past # yet end
      remain = duration-past
     
      if remain < 8 * 1000 && remain >= 7 * 1000
        $audio = $('<audio></audio>')
        $audio.attr('id', 'audio')
        # thanks for http://musicisvfr.com/free/se/clock01.html
        $audio.attr('src', '/audio/Zihou01-4.mp3')
        $('body').append($audio)
        audio = document.getElementById("audio")
        audio.play()

      remain2 = Util.time(remain)
      $('title').html(remain2)
      $('.countdown').html("あと#{remain2}")
      if callback == 'reload'
        setTimeout("Util.countDown(#{duration}, null, #{started})", 1000)
      else
        setTimeout("Util.countDown(#{duration}, #{callback}, #{started})", 1000)
    else # end
      if callback == 'reload'
        location.reload()
      else
        callback()

  @realtime: () ->
    setTimeout("Util.realtime()", 1000)
    for dom in $('.realtime')
      $dom = $(dom)
      diff = parseInt($dom.attr('data-countdown')) - (new Date()).getTime()
      disp = Util.time(diff)
      $(dom).html(disp)

  @parseHttp: (str) ->
    str.replace(/https?:\/\/[\w?=&.\/-;#~%-]+(?![\w\s?&.\/;#~%"=-]*>)/g, (http) ->
      text = http
      text = text.substring(0, 21) + "..." if text.length > 20

      "<a href=\"#{http}\" target=\"_blank\">#{text}</a>"
    )

  @addButton: (id, $dom, text, callback, tooltip=null) ->
    $button = $('<input>')
    if typeof(text) == 'string'
      $button.attr('type', 'submit')
      $button.attr('value', text)
      $button.addClass('btn-default')
    else
      $button.attr('type', 'image')
      $button.attr('src', text[0])
      $button.css('border', 'none')
      $button.attr('onmouseover', "this.src='#{text[1]}'") if text[1]
      $button.attr('onmouseout', "this.src='#{text[0]}'")
    $button.addClass('btn')

    $button.attr('id', id)
    if tooltip
      $button.tooltip({title: tooltip})
    $dom.append($button)
    $button.click(() ->
      callback()
    )
  @beforeunload: (text, flag) ->
    $(window).on("beforeunload", (e)->
      if flag && eval(flag)
        return text
    )

window.Util = window.Util || Util
