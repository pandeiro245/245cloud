class Util
  @minAgo: (min, date=null) ->
    date = new Date() unless date
    new Date(date.getTime() - min*60*1000)

  @scaffolds: (params) ->
    $body = $('#nc')
    $body.html('') # remove contents for SEO
    for param in params
      attrs = []
      $item = $('<div></div>')
      if typeof(param) == 'object'
        id = param[0]
        attrs = param[1]
      else # string
        id = param
        $item.addClass('row')
        $item.addClass('will_hide')
      $item.attr('id', id)
      for attr in attrs
        $item.addClass(attr)
      for key in ['row', 'will_hide']
        unless $item.hasClass("without-#{key}")
          $item.addClass(key)
      $body.append($item)

  @time: (mtime) ->
    if mtime < 24 * 3600 * 1000
      time = parseInt(mtime/1000)
      min = parseInt(time/60)
      if min > 60
        hour = parseInt(min/60)
        min = min - hour*60
        sec = time - hour*60*60 - min*60
      else
        sec = time - min*60
      if hour
        "#{Util.zero(hour)}:#{Util.zero(min)}:#{Util.zero(sec)}"
      else
        "#{Util.zero(min)}:#{Util.zero(sec)}"
    else
      time = new Date(mtime * 1000)
      month = time.getMonth() + 1
      day  = time.getDate()
      hour = time.getHours()
      min  = time.getMinutes()
      "#{Util.zero(month)}/#{Util.zero(day)} #{Util.zero(hour)}:#{Util.zero(min)}"

  @timeImg: (mtime) ->
    @time(mtime).split(':').map((str) ->
      str.split('').map((num) ->
        Util.int2img(num)
      ).join('')
    ).join('<img src="https://ruffnote.com/attachments/24965" />')

  @int2img: (int) ->
    int = parseInt(int)
    num = {
      0:  24953
      1:  24954
      2:  24955
      3:  24956
      4:  24958
      5:  24959
      6:  24960
      7:  24961
      8:  24962
      9:  24963
    }[int]
    return "<img src=\"https://ruffnote.com/attachments/#{num}\" />"

  @monthDay: (time) ->
    date = new Date(time)
    month = date.getMonth() + 1
    day  = date.getDate()
    "#{Util.zero(month)}月#{Util.zero(day)}日"

  @hourMin: (time, suffix='') ->
    now = new Date()
    date = new Date(time)
    if now.getDate() == date.getDate() # today
      hour = date.getHours()
      min  = date.getMinutes()
      "#{Util.zero(hour)}:#{Util.zero(min)}#{suffix}"
    else
      month = date.getMonth() + 1
      day  = date.getDate()
      "#{month}/#{day}"
  @zero: (i) ->
    return "00" if i < 0
    if i < 10 then "0#{i}" else "#{i}"

  @countDown: (duration, callback='reload', started=null, params={}) ->
    unless started
      started = (new Date()).getTime()
    past = (new Date()).getTime() - started

    $('.countdown2').show()

    if duration > past # yet end
      remain = duration-past
     
      if remain < 8 * 1000 && !window.is_hato
        audio = document.getElementById("hato")
        audio.play()
        window.is_hato = true

      remain2 = Util.time(remain)
      remain2_img = Util.timeImg(remain)
      if dom = params.dom
        $dom = $(dom)
      else
        $('title').html(remain2)
        $dom = $('.countdown')
      #$dom.html("あと#{remain2}")
      $dom.html("<img src='https://ruffnote.com/attachments/24966' />#{remain2_img}")

      if callback == 'reload'
        setTimeout("Util.countDown(#{duration}, null, #{started}, #{JSON.stringify(params)})", 1000)
      else
        setTimeout("Util.countDown(#{duration}, #{callback}, #{started}, #{JSON.stringify(params)})", 1000)
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
    str.replace(/https?:\/\/[\w?=&.\/-;#~%\-+]+(?![\w\s?&.\/;#~%"=\-]*>)/g, (http) ->
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

  @tag: (tagname, val=null, attrs=null) ->
    if tagname == 'img'
      $tag = $("<#{tagname} />")
      $tag.attr('src', val) if val
    else if tagname == 'input'
      $tag = $("<#{tagname} />")
      $tag.attr('placeholder', val) if val
    else
      $tag = $("<#{tagname}></#{tagname}>")
      if val
        $tag.html(val)

    if attrs
      for attr of attrs
        $tag.attr(attr, attrs[attr])

    return $tag

window.Util = window.Util || Util
