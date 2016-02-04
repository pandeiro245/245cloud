class Util
  @minAgo: (min, date=null) ->
    date = new Date() unless date
    new Date(date.getTime() - min*60*1000)

  @scaffolds: (params, key='nc') ->
    $body = $("##{key}")
    $body.html('') # remove contents for SEO
    for param in params
      attr = null
      if typeof(param) == 'object'
        id = param[0]
        attr = param[1]
      else
        id = param
      $item = $('<div></div>')
      $item.attr('id', id)
      unless (attr && attr.is_row == false)
        $item.addClass('row')
      if attr && attr.is_hide == true
        $item.hide()
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

  TIMER_IMG_NUM_MAP =
    ':': 24965
    '0': 24953
    '1': 24954
    '2': 24955
    '3': 24956
    '4': 24958
    '5': 24959
    '6': 24960
    '7': 24961
    '8': 24962
    '9': 24963

  @preloadImg: ->
    # FIXME: dom上に一時的にでも埋め込まない方法に変更したい
    #   $("<img src = '#{Util.charToImgURL(char)}'/>")だけではcompleteのときに
    #   プリローディングすることができなかった
    # NOTE: 待ち時間が短すぎるとぷりローディングされない
    #       表示に影響のないようにstyleで画面外に配置
    waitRemove = 5000
    for char of TIMER_IMG_NUM_MAP
      $el = $("<img src='#{Util.charToImgURL(char)}' style='position:absolute; top: -9999px;'/>")
      $('body').append($el)
      setTimeout(do($el) =>
        -> $el.remove()
      , waitRemove)

  @timeImg: (mtime) ->
    @time(mtime).replace(/[0-9:]/g, (char) ->
      url = Util.charToImgURL(char)
      className = if char == ':' then "colon" else 'num'
      "<img src='#{url}' class='#{className}' />"
    )

  @charToImgURL: (char) ->
    num = TIMER_IMG_NUM_MAP[char]
    "https://ruffnote.com/attachments/#{num}"

  @monthDay: (time) ->
    date = new Date(time)
    month = date.getMonth() + 1
    day  = date.getDate()
    "#{Util.zero(month)}月#{Util.zero(day)}日"
    
  @yearMonthDay: (time) ->
    date = new Date(time)
    
    "#{date.getFullYear()}年#{Util.monthDay(date)}"

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

  @calendar: (key) ->
    now = new Date()
    switch key
      when 'thismonth'
        year = now.getFullYear()
        month = now.getMonth() + 1
        date = now.getDate()
      when 'previous'
        backMDate = new Date(@dValue - 24 * 60 * 60 * 1000 * 1)
        if backMDate.getMonth() is now.getMonth() and backMDate.getFullYear() is now.getFullYear()
          year = now.getFullYear()
          month = now.getMonth() + 1
          date = now.getDate()
        else
          year = backMDate.getFullYear()
          month = backMDate.getMonth() + 1
          date = -1
      when 'next'
        nextMDate = new Date(@dValue + 24 * 60 * 60 * 1000 * 31)
        if nextMDate.getMonth() is now.getMonth() and nextMDate.getFullYear() is now.getFullYear()
          year = now.getFullYear()
          month = now.getMonth() + 1
          date = now.getDate()
        else
          year = nextMDate.getFullYear()
          month = nextMDate.getMonth() + 1
          date = -1
    @dValue = (new Date(year, month - 1, 1)).getTime()
    last_date = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
    editMsg = undefined
    last_date[1] = 29  unless (year % 100 is 0) and (year % 400 isnt 0)  if year % 4 is 0  if month is 2

    $('.thismonth').html("#{year}年#{month}月")

    editMsg = "<TABLE class='table table-borderd' style='width:100%;'>"
    editMsg += "<TR>" + defTD("日", "red") + defTD("月", "black") + defTD("火", "black") + defTD("水", "black") + defTD("木", "black") + defTD("金", "black") + defTD("土", "blue") + "</TR>"
    editMsg += "<TR>"
    dayIndex = 0
    while dayIndex < (new Date(year, month - 1, 1)).getDay()
      editMsg += defTD("&nbsp;", "white")
      dayIndex++
    i = 1
    while i <= last_date[month - 1]
      editMsg += "<TR>"  if i isnt 1 and dayIndex is 0
      if i is date
        editMsg += defTD(i, "orange")
      else
        switch dayIndex
          when 0
            editMsg += defTD(i, "red", @dValue)
          when 6
            editMsg += defTD(i, "blue", @dValue)
          else
            editMsg += defTD(i, "black", @dValue)
      editMsg += "</TR>\n"  if dayIndex is 6
      dayIndex++
      dayIndex %= 7
      i++
    editMsg += "</TR>\n"  unless dayIndex is 7
    editMsg += "</TABLE>\n"
    document.getElementById("carenda").innerHTML = editMsg

defTD = (str, iro, dvalue) ->
  res = "<TD align='center'><span style='color:#{iro};'>#{str}</span>"
  if parseInt(str) > 0
    res +="<br /><img class=\"icon icon_eAYx93GzJ8 img-thumbnail\" src=\"#{window.current_user.get('icon_url')}\">"

    target = new Date(dvalue)
    year = target.getFullYear()
    month = target.getMonth() + 1
    key = "#{year}-#{Util.zero(month)}-#{Util.zero(str)}"
    console.log key
    if val = window.current_user.get('daily_workloads')[key]
      res += "<br />(#{val})"
    else
      res += "<br />(0)"
  res += "</TD>"
  return res

window.Util = window.Util || Util
