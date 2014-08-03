class Util
  @minAgo: (min) ->
    new Date((new Date()).getTime() - min*60*1000)

  @scaffolds: (ids) ->
    $body = $('body')
    $body.html('') # remove contents for SEO
    for id in ids
      $item = $('<div></div>')
      $item.attr('id', id)
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
    if i < 10 then "0#{i}" else "#{i}"

  @countDown: (duration, callback='reload', started=null) ->
    unless started
      started = (new Date()).getTime()
    past = (new Date()).getTime() - started

    if duration > past # yet end
      $('title').html(Util.time(duration-past))
      if callback == 'reload'
        setTimeout("Util.countDown(#{duration}, null, #{started})", 1000)
      else
        setTimeout("Util.countDown(#{duration}, #{callback}, #{started})", 1000)
    else # end
      if callback == 'reload'
        location.reload()
      else
        callback()

  @parseHttp: (str) ->
    str.replace(/https?:\/\/[\w?=&.\/-;#~%-]+(?![\w\s?&.\/;#~%"=-]*>)/g, (http) ->
      text = http
      text = text.substring(0, 21) + "..." if text.length > 20

      "<a href=\"#{http}\" target=\"_blank\">#{text}</a>"
    )

  @addTwitterInfo: (params) ->
    $.extend(params,
      {
        twitter_id: localStorage['twitter_id']
        twitter_nickname: localStorage['twitter_nickname']
        twitter_image: localStorage['twitter_image']
      }
    )

window.Util = window.Util || Util
