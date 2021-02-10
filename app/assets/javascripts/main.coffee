@env.is_doing = false
@env.is_done = false

$ ->
  $.post('/api/access_logs', {url: location.href})
  return unless $('#nc').length
  scaffolds = Util.scaffolds('''
  header:no_row&stay news otukare:hidden&stay
  topbar:init
  contents:stay
  heatmap:init start_buttons
  doing_title:stay doing:init&stay
  chatting_title:stay chatting:init:stay
  done_title done:init
  you_title you:init calendar_title calendar
  search_title search:init
  okyo_title okyo:init&track_item_group
  kimiya_title kimiya:init&track_item_group
  naotake_title naotake:init&track_item_group
  playing:stay complete:stay select_rooms:stay
  rooms_title:stay rooms:stay
  whatis_title whatis:no_row
  wantedly:stay footer hatopoppo:init&stay
  ''')
  window.initWhatis()
  for key in scaffolds.initials
    eval("#{key}()")
  window.stays = scaffolds.stays

  Util.realtime()
  ruffnote_contents = [
    [23854, 'header']
    [18004, 'news']
    [13477, 'footer']
    [17758, 'search_title']
    [17498, 'otukare']
  ]
  for content in ruffnote_contents
    ruffnote(content[0], content[1])

  initStart()
  initFixedStart()
  initFirebase()

initFirebase = () ->
  database = firebase.database()
  database.ref('workloads').on('child_added', (snapshot) ->
    i = snapshot.val()
    if i.created_at + @env.pomotime*60*1000 > (new Date()).getTime()
      if @env.is_doing == false
        if i.facebook_id == window.facebook_id
          start_hash()
          @env.is_doing = true
  )

initTopbar = () ->
  $topbar = $('#topbar')
  $topbar_content = $("""
    <div>
      <a href='#'><i class='fa fa-arrow-up'></i></a>
       | <a href='#search_title' class='to_search'><i class='fa fa-search'></i></a>
    </div>
  """)
  $topbar.html($topbar_content)
  $(document).on('click', '.to_search', (e) ->
    e.preventDefault() # location.hash の変更を阻止
    $('#search input#track').focus()
  )

initHeatmap = () ->
  return unless window.facebook_id
  cal = new CalHeatMap()
  now = new Date()
  startDate = new Date(now.getFullYear() - 1, now.getMonth() + 1)

  cal.init({
    itemSelector: '#heatmap'
    domain: 'month'
    start: startDate
    subDomain: 'day'
    subDomainDateFormat: (date) -> Util.yearMonthDay(date)
    subDomainTitleFormat:
      empty: '{date}<br>0 ぽも'
      filled: '{date}<br>{count} ぽも'
    cellSize: 15
    highlight: 'now'
    tooltip: true
    legend: [2, 4, 6, 8]
    displayLegend: false
    range: 12
    afterLoad: () ->
      pomos = {}
      $.get("/api/users/#{window.facebook_id}/workloads?type=dones&limit=99999", (workloads) ->
        pomos = {}
        for i in [0...workloads.length]
          pomos[+workloads[i].created_at / 1000] = 1
        cal.update(pomos)
        cal.options.data = pomos
      )
  })


initOkyo = () ->
  ruffnote(30556, 'okyo_title')
  setTimeout("Youtube.search('お経 作業BGM', $('#okyo'))", 1000)

initKimiya = () ->
  ruffnote(21800, 'kimiya_title')
  Mixcloud.search('kimiya310', $('#kimiya'))

initNaotake = () ->
  ruffnote(21799, 'naotake_title')
  Mixcloud.search('/naotake/', $('#naotake'))

initStart = () ->
  text = "24分やり直しでも大丈夫ですか？"
  Util.beforeunload(text, 'env.is_doing')

  if window.facebook_id
    $('#contents').append("""
      <div class='countdown2' >
      <div class='countdown' ></div>
      </div>
    """)

    $('#contents').append("<br>")

    $('#start_buttons').html("""
      <div id='random' class='col-sm-2'></div>
      <div id='fixedstart' class='col-sm-2'></div>
      <div id='nomusic' class='col-sm-2'></div>
    """)

    text = [
      ImgURLs.button_play_omakase
      ImgURLs.button_play_omakase_hover
    ]
    tooltip = '現在はSoundcloudの人気曲からランダム再生ですが今後もっと賢くなっていくはず'
    $random = $('#start_buttons #random')
    $random.html("""<h5>おまかせ</h5>
      <img src="#{ImgURLs.track_omakase}" class='jacket'/>
    """)
    Util.addButton('start', $random, text, start_random)
    $random.addClass("col-sm-offset-#{getOffset(2)}")

    $('#fixedstart').hide()
    id = location.hash.split(':')[1]
    if location.hash.match(/soundcloud/)
      Soundcloud.fetch(id, @env.sc_client_id, (track) ->
        renderFixedStart(
          track.title,
          artworkUrlWithNoimage(track['artwork_url'])
        )
      )
    if location.hash.match(/mixcloud/)
      Mixcloud.fetch(id, (track) ->
        renderFixedStart(
          track.name,
          artworkUrlWithNoimage(track.pictures.medium)
        )
      )
    if location.hash.match(/nicovideo/)
      Nicovideo.fetch(id, (track) ->
        renderFixedStart(
          track.title,
          artworkUrlWithNoimage(track.artwork_url)
        )
      )
    text = [
      ImgURLs.button_paly_nomusic
      ImgURLs.button_paly_nomusic_hover
    ]
    tooltip = '無音ですが終了直前にはとぽっぽが鳴ります'
    $nomusic = $('#start_buttons #nomusic')

    $nomusic.html('<h5>無音</h5>')
    $nomusic.append(Util.tag('img', ImgURLs.track_nomusic, {class: 'jacket'}))
    Util.addButton('start', $nomusic, text, start_nomusic)

  else
    text = 'facebookログイン'
    Util.addButton('login', $('#contents'), text, login)

initSearch = () ->
  $track = $("<input />").attr('id', 'track').attr('placeholder', 'ここにアーティスト名や曲名を入れてね')
  title = localStorage['search_music_title']
  $track.val(title) if title

  $tracks = $("<div></div>").attr('id', 'tracks')

  $('#search').append($track)
  $('#search').append($tracks)

  services = '<div id=\'check_services\'>'
  for key, val of {yt: 'youtube', mc: 'mixcloud', sc: 'soundcloud', sm: 'nicovideo'}
    fa = val
    fa = 'television' if key == 'sm'
    checked = 'checked=\'checked\' '
    checked = '' if localStorage["search_#{key}"]  == 'false'
    services += """
    <label>
    <i class="fa fa-#{fa}" title='#{val}' data-toggle='tooltip' data-placement='top' style='display: inline;'></i>
    <input #{checked}type='checkbox' style='display: inline;' id='search_#{key}'  />
    </label>
    """
  services += '</div>'
  $('#search').append(services)

  $(document).on('click', '#check_services input', (e) ->
    searchMusics()
  )

  $('#search').append('<div class="results track_item_group"></div>')

  $('#search input').focus(() ->
    $(this).select()
  )
  $('#search input').focus()

  $('#track').keypress((e) ->
    if e.which == 13 #enter
      searchMusics()
  )

window.initSelectRooms = () ->
  console.log 'initSelectRooms'
  $('#rooms_title').html(Util.tag('h2', Util.tag('img', ImgURLs.title_comments), {class: 'status'}))
  $('#select_rooms').html(Util.tag('h2', Util.tag('img', ImgURLs.title_rooms), {class: 'status'}))
  $('#select_rooms').append(Util.tag('div', null, {class: 'imgs'}))

  $.get('/api/comments', (rooms) ->
    html = ''
    for room in rooms
      html += "<a style='margin: 5px;' href='#' class='room_link' data-values=\"#{room.id}:#{room.body}\">#{room.body}(#{room.num})</a>"
    html += "<a style='margin: 5px;' href='#' class='add_room'\">部屋追加</a>"
    $('#select_rooms').html(html)

    $(document).on('click', ".room_link", (e) ->
      e.preventDefault()

      $self = $(this)
      vals = $self.attr('data-values').split(':')
      initRoom(vals[0], vals[1])
    )
    $(document).on('click', ".add_room", (e) ->
      e.preventDefault()

      unless window.room_created
        name = prompt('部屋の名前を入力してください（例：「サッカーについて語る部屋」）', '')
      return if !name || name.length < 2
      window.room_created = true
      $.post('/api/comments', {body: name}, (comment) ->
        $('.add_room').fadeOut()
        window.initSelectRooms()
      )
    )
  )

initChatting = () ->
  console.log 'initChatting'
  ruffnote(22878, 'chatting_title')
  $("#chatting_title").hide()

  $.get('/api/workloads?type=chattings', (workloads) ->
    return unless workloads.length > 0
    $("#chatting_title").show()
    for workload in workloads
      window.addChatting(workload)
  )


initDoing = () ->
  console.log 'initDoing'
  ruffnote(22877, 'doing_title')
  $("#doing_title").hide()

  $.get('/api/workloads?type=playings', (workloads) ->
    return unless workloads.length > 0
    $("#doing_title").show()
    _is_doing = false
    for workload in workloads
      if workload.facebook_id == window.facebook_id
        _is_doing = true
      window.addDoing(workload)
    if _is_doing
      window.start_hash()
      $(".fixed_start").hide()
  )

initDone = () ->
  console.log 'initDone'
  $.get('/api/workloads?type=dones', (workloads) ->
    ruffnote(17769, 'done_title')
    for workload in workloads
      disp = "#{Util.hourMin(workload.created_at, '')} #{workload.number}回目(週#{workload.weekly_number}回)"
      window.addWorkload("#done", workload, disp)
  )

login = () ->
  location.href = '/auth/facebook'

start_random = () ->
  console.log 'start_random'
  sc_ids = [116992736, 21049964, 23093230, 142822858, 130298202, 96907547, 141157287]
  n = Math.floor(Math.random() * sc_ids.length)
  sc_id = sc_ids[n]
  location.hash = "soundcloud:#{sc_id}"
  window.play("soundcloud:#{sc_id}")

window.start_hash = (key = null) ->
  console.log 'start_hash'
  unless key
    key = location.hash.replace(/#/, '')
  if key
     window.play(key)
   else
     start_nomusic()

window.start_nomusic = () ->
  console.log 'start_nomusic'
  createWorkload({}, start)

createWorkload = (params = {}, callback) ->
  $.post('/api/workloads', params, (workload) ->
    window.workload = workload
    database = firebase.database()
    database.ref('workloads').push({
      facebook_id: window.facebook_id
      created_at: workload.created_at
    })
    callback()
  )

start = () ->
  $('#topbar').hide()
  console.log 'start'
  for div in $("#nc div.scaffold")
    $(div).hide() unless $(div).attr('id') in window.stays
  $("input").hide()

  @env.is_doing = true

  end_time = window.workload.created_at + @env.pomotime*60*1000
  Util.countDown(end_time, complete)

window.youtubeDurationSec = (key)  ->
  duration = key['contentDetails']['duration'];            # Ex) "PT43M22S", "PT43M"
  duration = duration.replace(/^PT/, '').replace(/S$/, '') # Ex) "43M22", "43M"

  console.log duration
  if duration.match(/H/)
    hour = parseInt(duration.split('H')[0])
    d2 = duration.split('H')[1]
  else
    hour = 0
    d2 = duration
  min = parseInt(d2.split('M')[0]) || 0
  sec = parseInt(d2.split('M')[1]) || 0
  sec = hour*60*60+min*60+sec
  parseInt(sec)

window.play = (key) ->
  console.log 'play', key
  params = {}
  id = key.split(':')[1]
  if key.match(/^soundcloud/)
    Soundcloud.fetch(id, @env.sc_client_id, (track) ->
      params['music_key'] = "soundcloud:#{id}"
      for k in ['title', 'artwork_url']
        params[k] = track[k]
      createWorkload(params, start)
      window.play_repeat(key, track.duration)
    )
  else if key.match(/^youtube/)
    Youtube.fetch(id, (data) ->
      track = data['items'][0]['snippet']
      params['music_key'] = "youtube:#{id}"
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
      params['music_key'] = "mixcloud:#{id}"
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
      params = track
      params['music_key'] = "nicovideo:#{id}"
      createWorkload(params, start)
    )
    Nicovideo.play(id, $("#playing"))
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
  else if key.match(/^nicovideo/)
    Nicovideo.play(id, $("#playing"))
  setTimeout("play_repeat\(\"#{key}\"\, #{duration})", duration)

complete = () ->
  console.log 'complete'
  window.is_hato = false
  end_time = window.workload.created_at + @env.pomotime*60*1000 + @env.chattime*60*1000
  Util.countDown(end_time, 'reload')
  $('#header').hide()
  $('#topbar').hide()
  $('#otukare').fadeIn()
  $("#playing").fadeOut()
  $("#search").fadeOut()
  $("#playing").html('') # for stopping

  @env.is_doing = false
  @env.is_done = true

  $.get('/api/complete')

  $complete = $('#complete')
  $complete.html('')
  initComments()

window.initComments = () ->
  initRoom()

window.initRoom = (id = '1', title='いつもの部屋') ->
  console.log "initRoom: #{id}, #{title}"

  $(".room").hide()

  $room = $("#room_#{id}")

  if $room.length
    $room.show()
  else
    $room = $('<div></div>')
    $room.addClass('room')
    $room.attr('id', "room_#{id}")
    $createComment = $('<input />').addClass('create_comment').attr('placeholder', "「#{title}」に書き込む")
    $room.append($createComment)

    $comments = $("<table></table>").addClass('table comments')
    $room.append($comments)

    $('#rooms').append($room)

    search_id = if id == '1' then null else id
    limit = if id == '1' then 100 else 10000

    $.get("/api/comments?parent_id=#{id}", (comments) ->
      $("#room_#{id} .create_comment").keypress((e) ->
        if e.which == 13 #enter
          if parseInt(id) > 0
            window.createComment(id)
          else
            initRoom(1)
      )
      for comment in comments
        window.addComment(id, comment)
    )

window.finish = () ->
  console.log 'finish'
  location.reload()

window.createComment = (room_id) ->
  console.log 'createComment'
  $createComment = $("#room_#{room_id} .create_comment")

  body = $createComment.val()

  $createComment.val('')

  return if body.length < 1

  params = {body: body}

  params.room_id = room_id

  $.post('/api/comments', params, (comment) ->
    window.addComment(room_id, comment)
  )

window.addDoing = (workload) ->
  $("#doing_title").show()
  t = new Date(workload.created_at)
  end_time = @env.pomotime*60*1000 + t.getTime()
  disp = "#{Util.hourMin(workload.created_at, '開始')}（あと<span class='realtime' data-countdown='#{end_time}'></span>）"
  @addWorkload("#doing", workload, disp)

window.addChatting = (workload) ->
  $("#chatting_title").show()
  t = new Date(workload.created_at)
  end_time = @env.pomotime*60*1000 + @env.chattime*60*1000 + t.getTime()
  disp = "#{Util.hourMin(workload.created_at, '開始')}（あと<span class='realtime' data-countdown='#{end_time}'></span>）"
  @addWorkload("#chatting", workload, disp)

@addWorkload = (dom, workload, disp) ->
  console.log dom
  provider_icon = ''
  w = workload
  facebook_id = w.facebook_id
  if w.music_key
    title = w.title
    href = "##{workload.music_key}"
    fixed = "<a href=\"#{href}\" class='fixed_start'><img src='#{ImgURLs.button_play_this}' /></a>"
    jacket = "#{if w.artwork_url then '<img src=\"' + w.artwork_url + '\" class=\"jacket\" />' else "<img src=\"#{ImgURLs.track_noimage_hover}\" class=\"jacket\" />"}"
    jacket = "<a href='/musics/#{w.music_key.replace(':', '/')}'>#{jacket}</a>" if w.music_key
    provider = w.music_key.split(':')[0]
    icon_name = if provider == 'nicovideo' then 'television'  else provider
  else
    title = '無音'
    fixed = "<a href=\"#\" class='fixed_start'><img src='#{ImgURLs.button_paly_nomusic}' /></a>"
    jacket = "<img src='#{ImgURLs.track_nomusic}' class='jacket'/>"
  user_img = "<a href='/#{workload.facebook_id}'><img class='icon img-thumbnail' src='/images/profile/#{workload.facebook_id}.jpg' /></a>"
  # user_img = "<a href='/#{workload.facebook_id}'><img class='icon img-thumbnail' src='https://graph.facebook.com/#{workload.facebook_id}/picture?height=40&width=40' /></a>"

  $item = Util.tag('div', null, {class: 'inborder'})
  $item.css("border", '4px solid #eadba0')
  $item.css("border-radius", '18px')
  $item.css("background", '#fff')
  $item.css("margin", '10px 5px 3px')
  $item.css("padding", '0 0 6px')
  $item.css("color", '#b2b2b2')

  $item.html("""
   <h5>
   #{provider_icon}
   <span title='#{title}' data-toggle='tooltip' data-placement='top'>
   #{title}
   </span>
   </h5>
   <span>#{jacket}</a></span>
   <span>#{user_img}</span>
   <div class='disp'>#{disp}</div>
   <div>#{fixed}</div>
  """)
  $('[data-toggle="tooltip"]').tooltip()

  # dones以外は１ユーザにつき１つしか表示しないので他の$itemは消去
  # unless dom == '#done'
  #   $("#chatting .facebook_#{facebook_id}").remove()
  #   $("#doing .facebook_#{facebook_id}").remove()

  $workload = $('<div></div>')
  $workload.addClass("workload")
  $workload.addClass("facebook_#{facebook_id}")
  $workload.addClass("col-sm-2")
  $workload.css("min-height", '180px')
  $workload.html($item)

  $("#{dom}").prepend($workload)

  # 活動中に追加される$itemには集中ボタンは不要
  if @env.is_doing || @env.is_done
    $(".fixed_start").hide()

  renderWorkloads('#chatting')
  renderWorkloads('#doing')

window.addWorkload = @addWorkload

initFixedStart = () ->
  $(document).on('click', '.fixed_start', () ->
    if window.facebook_id
      hash = $(this).attr('href').replace(/^#/, '')
      location.hash = hash
      start_hash()
    else
      alert 'Facebookログインをお願いします！'
      $('html,body').animate({scrollTop:$('#login').offset().top - 40}) # Scroll to the login button position.
      window.fbAsyncInit()
  )

window.ruffnote = (id, dom, callback=null) ->
  Ruffnote.fetch("pandeiro245/245cloud/#{id}", dom, callback)

initService = ($dom, url) ->
  $dom.append("<iframe src='#{url}' width='85%' height='900px'></iframe>")

@addComment = (room_id, comment) ->
  window.initSelectRooms()
  $comments = $("#room_#{room_id} .comments")
  c = comment

  if c.body
    img = "https://graph.facebook.com/#{c.facebook_id}/picture?height=40&width=40"
    # img = "/images/profile/#{c.facebook_id}.jpg"
    html = """
    <tr>
    <td>
    <a href='https://facebook.com/#{c.facebook_id}' target='_blank'>
    <img class='icon' src='#{img}' />
    </a>
    <td>
    <td>#{Util.parseHttp(c.body)}</td>
    <td>#{Util.hourMin(c.created_at)}</td>
    </tr>
    """
    $comments.prepend(html)

window.addComment = @addComment

searchMusics = () ->
  q = $('#track').val()

  search_yt = $("#search_yt").prop('checked')
  search_mc = $("#search_mc").prop('checked')
  search_sc = $("#search_sc").prop('checked')
  search_sm = $("#search_sm").prop('checked')

  is_none = false
  if !search_yt && !search_mc && !search_sc && !search_sm
    is_none =true

  localStorage['search_yt'] = search_yt
  localStorage['search_mc'] = search_mc
  localStorage['search_sc'] = search_sc
  localStorage['search_sm'] = search_sm

  return if q.length < 1
  $tracks = $('#search .results')
  $tracks.html('')
  localStorage['search_music_title'] = q

  if is_none || search_yt
    Youtube.search(q, $tracks, initTooltip)
  if is_none || search_mc
    Mixcloud.search(q, $tracks, initTooltip)
  if is_none || search_sc
    Soundcloud.search(q, @env.sc_client_id, $tracks, initTooltip)
  if is_none || search_sm
    Nicovideo.search(q, $tracks, initTooltip)

initTooltip = () ->
  $('[data-toggle="tooltip"]').tooltip()

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
  $dom = $("#{dom}")
  $items = $("#{dom} .workload")
  $first = $("#{dom} .workload:first")
  $items.removeClass('col-sm-offset-2')
  $items.removeClass('col-sm-offset-3')
  $items.removeClass('col-sm-offset-4')
  $items.removeClass('col-sm-offset-5')
  $first.addClass("col-sm-offset-#{getOffset($items.length)}")

artworkUrlWithNoimage = (artwork_url) ->
  artwork_url || ImgURLs.track_noimage_hover

initYou = () ->
  console.log 'initYou'
  return unless window.facebook_id
  if location.href.match(/best=/)
    $.get("/api/users/#{window.facebook_id}/workloads?best=1", (workloads) ->
      ruffnote(22876, 'you_title')
      for workload in workloads
        disp = "累計#{workload.music_key_count}回"
        window.addWorkload("#you", workload, disp)
    )
  else
    $.get("/api/users/#{window.facebook_id}/workloads", (workloads) ->
      ruffnote(22876, 'you_title')
      for workload in workloads
        disp = "#{Util.hourMin(workload.created_at, '')} #{workload.number}回目(週#{workload.weekly_number}回)"
        window.addWorkload("#you", workload, disp)
    )

renderFixedStart = (title, icon) ->
  fixed_text = [
    ImgURLs.button_play_this
    ImgURLs.button_play_this_hover
  ]
  $('#fixedstart').append(txt)
  txt = "<h5 title='#{title}' data-toggle='tooltip' data-placement='top'>#{title}</h5>"
  $('#fixedstart').append(txt)
  txt = "<img src='#{icon}' class='jacket'>"
  $('#fixedstart').append(txt)
  Util.addButton('start', $('#fixedstart'), fixed_text, start_hash)
  $('#fixedstart').fadeIn()
  $('#random').removeClass("col-sm-offset-#{getOffset(2)}")
  $('#random').addClass("col-sm-offset-#{getOffset(3)}")
  $('[data-toggle="tooltip"]').tooltip()
