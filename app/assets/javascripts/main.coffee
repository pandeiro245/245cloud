@env.is_doing = false
@env.is_done = false
window.workload = null

@nomusic_url = 'https://ruffnote.com/attachments/24985'

$ ->
  Util.realtime()
  ruffnote(17758, 'search_title')
  initSearch()
  initHatopoppo()
  #initYou()
 
  $('#selectRoomButton').hide()
  
init8tracks = () ->
  ruffnote(17763, '8tracks_title')
  EightTracks.attrip($('#8tracks'))

initKimiya = () ->
  ruffnote(21800, 'kimiya_title')
  Mixcloud.search('/kimiya-sato/', $('#kimiya'))

initNaotake = () ->
  ruffnote(21799, 'naotake_title')
  Mixcloud.search('/naotake/', $('#naotake'))

initStart = () ->
  text = "24分やり直しでも大丈夫ですか？"
  Util.beforeunload(text, 'env.is_doing')
initSearch = () ->
  $('#track').keypress((e) ->
    if e.which == 13 #enter
      searchMusics()
  )

createWorkload = (params = {}, callback) ->
  params.host = location.host

  if location.href.match('review=')
    if location.href.match('sparta=')
      review = prompt("今から24分間集中するにあたって一言（公開されます）", '24分間頑張るぞ！')
    else
      review = $('#input_review_before').val()

    if review.length
      params['review_before'] = review

  ParseParse.create("Workload", params, (workload) ->
    @workload = workload
    callback()
  )
  
start = () ->
  console.log 'start'
  $("#done").hide()
  $("#search").hide()
  $("input").hide()
  $(".fixed_start").hide()
  $("#music_ranking").hide()
  doms = [
    'kpi_title'
    'kpi3_title'
    'kpi3'
    'kpi2_title'
    'kpi2'
    'kpi1_title'
    'kpi1'
    'start_buttons'
    'fixedstart_artwork'
    '8tracks'
    '8tracks_title'
    'search_title'
    'ranking_title'
    'ranking'
    'whatis_title'
    'whatis'
    'you_title'
    'you'
    'news'
    'footer'
  ]
  for dom in doms
    $("##{dom}").hide()

  @env.is_doing = true
  @syncWorkload('doing')
  
  if @env.is_kakuhen
    initComments()
    @initSelectRooms()

  Util.countDown(@env.pomotime*60*1000, complete)

window.youtubeDurationSec = (key)  ->
  duration = key['contentDetails']['duration'].replace(/^PT/, '').replace(/S$/, '')
  hour = parseInt(duration.split('H')[0])
  min = parseInt(duration.split('H')[1].split('M')[0])
  sec = parseInt(duration.split('H')[1].split('M')[1])
  sec = hour*60*60+min*60+sec
  parseInt(sec)

window.play = (key) ->
  console.log 'play', key
  params = {}
  id = key.split(':')[1]
  if key.match(/^soundcloud/)
    Soundcloud.fetch(id, @env.sc_client_id, (track) ->
      params['sc_id'] = parseInt(id)
      for k in ['title', 'artwork_url']
        params[k] = track[k]
      createWorkload(params, start)
      window.play_repeat(key, track.duration)
    )
  else if key.match(/^youtube/)
    Youtube.fetch(id, (data) ->
      track = data['items'][0]['snippet']
      params['yt_id'] = id
      params['title'] = track['title']
      params['artwork_url'] = track['thumbnails']['default']['url']
      createWorkload(params, start)
      sec = youtubeDurationSec(data['items'][0])
      if sec > 24*60
        start_sec = sec - 24*60
        Youtube.play(id, $("#playing"), true, start_sec)
      else
        window.play_repeat(key, sec * 1000)
    )
  else if key.match(/^mixcloud/)
    Mixcloud.fetch(id, (track) ->
      params['mc_id'] = id
      params['title'] = track.name
      params['artwork_url'] = track.pictures.medium
      createWorkload(params, start)
      if track.audio_length > 24*60
        Mixcloud.play(id, $("#playing"), true)
      else
        window.play_repeat(key, track.audio_length * 1000)
    )
  else if key.match(/^nicovideo/)
    Nicovideo.fetch(id, (track) ->
      createWorkload(track, start)
    )
    Nicovideo.play(id, $("#playing"))
  if key.match(/^8tracks/)
    EightTracks.fetch(id, @env.et_client_id, (track) ->
      params['et_id'] = parseInt(id)
      params.title = track.mix.name
      params.artwork_url = track.mix.cover_urls.sq100
      createWorkload(params, start)
      window.play_repeat(key, track.mix.duration * 1000)
    )

window.play_repeat = (key, duration) ->
  console.log 'play_repeat'
  return false if @env.is_done
  id = key.split(':')[1]
  if key.match(/^soundcloud/)
    Soundcloud.play(id, @env.sc_client_id, $("#playing"))
  else if key.match(/^youtube/)
    Youtube.play(id, $("#playing"))
  else if key.match(/^mixcloud/)
    Mixcloud.play(id, $("#playing"),)
  else if key.match(/^8tracks/)
    EightTracks.play(id, $("#playing"))
  else if key.match(/^nicovideo/)
    Nicovideo.play(id, $("#playing"))
  setTimeout("play_repeat\(\"#{key}\"\, #{duration})", duration)

@addDoing = (workload) ->
  $("#doing_title").show()
  t = new Date(workload.created_at)
  end_time = @env.pomotime*60*1000 + t.getTime()
  disp = "#{Util.hourMin(workload.created_at, '開始')}（あと<span class='realtime' data-countdown='#{end_time}'></span>）"
  @addWorkload("#doing", workload, disp)

@addChatting = (workload) ->
  $("#chatting_title").show()
  t = new Date(workload.created_at)
  end_time = @env.pomotime*60*1000 + @env.chattime*60*1000 + t.getTime()
  disp = "#{Util.hourMin(workload.created_at, '開始')}（あと<span class='realtime' data-countdown='#{end_time}'></span>）"
  @addWorkload("#chatting", workload, disp)

@addWorkload = (dom, workload, disp) ->
  w = workload
  if w.title
    href = '#'
    if w.key
      href += w.key
    fixed = "<a href=\"#{href}\" class='fixed_start'><img src='https://ruffnote.com/attachments/24921' /></a>"
    jacket = "<a href=\"/musics/#{w.music_id}\">#{if w.artwork_url then '<img src=\"' + w.artwork_url + '\" class=\"jacket\" />' else "<img src=\"#{@nomusic_url}\" class=\"jacket\" />"}</a>"
    title = w.title
  else
    title = '無音'
    if location.href.match(/offline=/)
      fixed = "<a href=\"#\" class='fixed_start'>無音で集中</a>"
    else
      fixed = "<a href=\"#\" class='fixed_start'><img src='https://ruffnote.com/attachments/24926' /></a>"
    jacket = "<img src=\"https://ruffnote.com/attachments/24981\" class='jacket'/>"
  user_img = "<img class='icon img-thumbnail' src='#{workload.icon_url}' />"

  $item = Util.tag('div', null, {class: 'inborder'})
  $item.css("border", '4px solid #eadba0')
  $item.css("border-radius", '18px')
  $item.css("background", '#fff')
  $item.css("margin", '10px 5px 3px')
  $item.css("padding", '0 0 6px')
  $item.css("color", '#b2b2b2')

  $item.html("""
   <h5>#{title} </h5>
   <span>#{jacket}</span>
   <span><a href='/#{workload.user_id}'>#{user_img}</a></span>
   <div class='disp'>#{disp}</div>
   <div>#{fixed}</div>
  """)

  unless dom == '#done'
    $("#chatting .user_#{user_id}").remove()
    $("#doing .user_#{user_id}").remove()
  if (dom == '#doing' or dom == '#chatting') and $("#{dom} .user_#{user_id}").length
    $("#{dom} .user_#{user_id}").html($item)
  else
    $workload = $('<div></div>')
    $workload.addClass("workload")
    $workload.addClass("col-sm-2")
    $workload.css("min-height", '180px')
    $workload.html($item)
    $("#{dom}").append($workload)
    renderWorkloads('#doing')
    renderWorkloads('#chatting')

  if @env.is_doing || @env.is_done
    $(".fixed_start").hide()

  $("#{dom}").hide()
  $("#{dom}").fadeIn()

initFixedStart = () ->
  $(document).on('click', '.fixed_start', () ->
    if true
      hash = $(this).attr('href').replace(/^#/, '')
      location.hash = hash
      start_hash()
    else
      alert 'Facebookログインをお願いします！'
      window.fbAsyncInit()
  )

ruffnote = (id, dom, callback=null) ->
  Ruffnote.fetch("pandeiro245/245cloud/#{id}", dom, callback)

window.addComment = (room_id, comment, is_countup=false, is_prepend=true) ->
  $comments = $("#room_#{room_id} .comments")
  c = comment
  t = new Date()
  hour = t.getHours()
  min = t.getMinutes()

  html = """
  <tr>
  <td>
  <a target='_blank'>
  <img src='#{c.user_img}' />
  <div class='facebook_name_#{c.user_id}'></div>
  </a>
  <td>
  <td>#{Util.parseHttp(c.content)}</td>
  <td>#{Util.hourMin(c.created_at)}</td>
  </tr>
  """
  if is_prepend
    $comments.prepend(html)
  else
    $comments.append(html)

userIdToIconUrl = (userId) ->
  localStorage["icon_#{userId}"] || ""

@syncWorkload = (type) ->
  return if location.href.match(/offline=/)
  @socket.push({
    type: type
    workload: window.workload
  })

syncComment = (room_id, comment, is_countup=false) ->
  console.log 'syncComment'
  @socket.push({
    type: 'comment'
    comment: comment
    room_id: room_id
    is_countup: is_countup
  })

@stopUser = (user_id) ->
  $("#chatting .user_#{user_id}").remove()
  if $("#chatting div").length < 1
    $("#chatting_title").hide()
  $("#doing .user_#{user_id}").remove()
  if $("#doing div").length < 1
    $("#doing_title").hide()

searchMusics = () ->
  q = $('#track').val()
  return if q.length < 1
  $('#tracks').html('')
  localStorage['search_music_title'] = q

  $tracks = $('#tracks')
  Youtube.search(q, $tracks)
  Nicovideo.search(q, $tracks)
  Soundcloud.search(q, @env.sc_client_id, $tracks)
  Mixcloud.search(q, $tracks)
  #EightTracks.search(q, $tracks)


initHatopoppo = () ->
  $('#hatopoppo').css('width', '1px')
  $audio = $('<audio></audio>')
  $audio.attr('id', 'hato')
  $audio.attr('src', '/audio/Zihou01-4.mp3')
  $('#hatopoppo').append($audio)

getOffset = (all_count) ->
  return 0 if all_count >= 5
  data = {
    1: 5
    2: 4
    3: 3
    4: 2
  }
  data[all_count]

renderWorkloads = (dom) ->
  #console.log 'renderWorkloads'
  $dom = $("#{dom}")
  $items = $("#{dom} .workload")
  $first = $("#{dom} .workload:first")
  $items.removeClass('col-sm-offset-2')
  $items.removeClass('col-sm-offset-3')
  $items.removeClass('col-sm-offset-4')
  $items.removeClass('col-sm-offset-5')
  $first.addClass("col-sm-offset-#{getOffset($items.length)}")

start_unless_doing = ()->
  unless ( @env.is_doing or @env.is_done)
    start_hash()

artworkUrlWithNoimage = (artwork_url) ->
  artwork_url || @nomusic_url

