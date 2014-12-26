@env.is_doing = false

$ ->
  ParseParse.all("User", (users) ->
    for user in users
      img = user.get('icon_url')
      localStorage["icon_#{user.id}"] = img if img
      $(".icon_#{user.id}").attr('src', img)
  )
  ParseParse.addAccesslog()
  Util.scaffolds([
    'header'
    'otukare'
    'ad'
    'contents'
    'memo_title'
    'memo'
    'doing_title'
    'doing'
    'chatting_title'
    'chatting'
    'done'
    'ranking_title'
    'ranking'
    'search_title'
    'search'
    '8tracks_title'
    '8tracks'
    'playing'
    'complete'
    'select_rooms'
    'rooms'
    'kpi_title'
    'kpi3_title'
    'kpi3'
    'kpi2_title'
    'kpi2'
    'kpi1_title'
    'kpi1'
    ['whatis', {is_row: false}]
    'footer'
    'otukare_services'
    'hatopoppo'
  ])
  Util.realtime()

  $('#header').removeClass('row')
  ruffnote(13475, 'header', initStart)
  ruffnote(13477, 'footer')
  $('#otukare').hide()
  $('#otukare_services').hide()

  ruffnote(17758, 'search_title')
  ruffnote(17762, 'ranking_title')
  ruffnote(17498, 'otukare')

  window.services = [
    ['ingress', 'https://www.ingress.com/intel']
    ['togetter', 'http://togetter.com/']
    ['newspicks', 'https://newspicks.com/top-news']
    ['itoicom', 'http://www.1101.com/home.html']
  ]

  for service in window.services
    if location.href.match("#{service[0]}=")
      initService($('#otukare_services'), service[1])

  ruffnote(17661, 'music_ranking')

  initSearch()
  init8tracks()
  initChatting()
  initDoing()
  initDone()
  initRanking()
  initFixedStart()
  #initKpi()
  ParseBatch.repeat()
  initHatopoppo()
  initWhatis()
  initMemo() if location.href.match(/memo=/)

init8tracks = () ->
  ruffnote(17763, '8tracks_title')
  EightTracks.attrip($('#8tracks'))

initStart = () ->
  console.log 'initStart'
  $( "#header img" ).css('height', '320px')
  $( "#header img" ).animate({
    #opacity: 0.25,
    #left: "+=50",
    height: "340px"
  }, 5000, () ->
    console.log 'Animation complete.'
  )

  if location.href.match(/sparta/)
    Util.countDown(1*60*1000, start_unless_doing)

  text = "24分やり直しでも大丈夫ですか？"
  Util.beforeunload(text, 'env.is_doing')
  
  if Parse.User.current()
    $('#contents').append("<div class='countdown' ></div>")
      
    $('#contents').append("<br>")

    $('#contents').append("<div id='fixedstart_artwork'></div>")
    $('#contents').append("<div id='start_buttons'></div>")
    $('#contents .fixedstart_button').hide()

    #text = '曲お任せで24分間集中する！'
    text = [
      'https://ruffnote.com/attachments/24347'
      'https://ruffnote.com/attachments/24348'
    ]
    tooltip = '現在はSoundcloudの人気曲からランダム再生ですが今後もっと賢くなっていくはず'
    Util.addButton('start', $('#contents #start_buttons'), text, start_random, tooltip)
 
    $('#contents #start_buttons').append("<span id='fixedstart_button'></span>")
    $('#fixedstart_button').hide()

    #text = 'この曲で集中'
    text = [
      'https://ruffnote.com/attachments/24353'
      'https://ruffnote.com/attachments/24354'
    ]
    #tooltip = '無音ですが終了直前にはとぽっぽが鳴ります'
    Util.addButton('start', $('#fixedstart_button'), text, start_hash)

    id = location.hash.split(':')[1]
    if location.hash.match(/soundcloud/)
      Soundcloud.fetch(id, @env.sc_client_id, (track) ->
        artwork_url = artworkUrlWithNoimage(track['artwork_url'])
        text = "<h5>#{track['title']}</h5><img src='#{artwork_url}'>"
        $('#contents #fixedstart_artwork').append(text)
      )
      $('#contents #fixedstart_button').fadeIn()
    if location.hash.match(/youtube/)
      Youtube.fetch(id, (track) ->
        artwork_url = artworkUrlWithNoimage(track['entry']['media$group']['media$thumbnail'][3]['url'])
        text = "<h5>#{track['entry']['title']['$t']}</h5><img src='#{artwork_url}'>"
        $('#contents #fixedstart_artwork').append(text)
      )
      $('#contents #fixedstart_button').fadeIn()
    if location.hash.match(/mixcloud/)
      Mixcloud.fetch(id, (track) ->
        artwork_url = artworkUrlWithNoimage(track.track.pictures.medium)
        text = "<h5>#{track.name}</h5><img src='#{artwork_url}'>"
        $('#contents #fixedstart_artwork').append(text)
      )
      $('#contents #fixedstart_button').fadeIn()
    if location.hash.match(/8tracks/)
      EightTracks.fetch(id, @env.et_client_id, (track) ->
        artwork_url = artworkUrlWithNoimage(track.mix.cover_urls.sq100)
        text = "<h5>#{track.mix.name}</h5><img src='#{artwork_url}'>"
        $('#contents #fixedstart_artwork').append(text)
      )
      $('#contents #fixedstart_button').fadeIn()

    #text = '無音で24分集中'
    text = [
      'https://ruffnote.com/attachments/24349'
      'https://ruffnote.com/attachments/24350'
    ]
    tooltip = '無音ですが終了直前にはとぽっぽが鳴ります'
    Util.addButton('start', $('#contents #start_buttons'), text, start_nomusic, tooltip)

  else
    text = 'facebookログイン'
    Util.addButton('login', $('#contents'), text, login)

initSearch = () ->
  $track = $("<input />").attr('id', 'track').attr('placeholder', 'ここにアーティスト名や曲名を入れてね')
  localStorage['search_music_title'] = '作業BGM' unless localStorage['search_music_title']
  #if localStorage['search_music_title'].length > 1
  #  $track.attr('value', localStorage['search_music_title'])

  $tracks = $("<div></div>").attr('id', 'tracks')

  $('#search').append($track)
  $('#search').append($tracks)

  $('#search input').focus(() ->
    $(this).select()
  )
  $('#search input').focus()
  #searchMusics()

  $('#track').keypress((e) ->
    if e.which == 13 #enter
      searchMusics()
  )

@initSelectRooms = () ->
  console.log 'initSelectRooms'
  $('#select_rooms').html("<select></select>")

  ParseParse.all("Room", (rooms) ->
    $('#select_rooms select').html('')
    $('#select_rooms select').append(
      "<option value=\"default:いつもの部屋\">いつもの部屋</option>"
    )
    for room in rooms
      total_count = room.attributes.comments_count
      unread_count = getUnreadsCount(room.id, total_count)
      style = ""
      user = Parse.User.current()
      $('#select_rooms select').append(
        "<option value=\"#{room.id}:#{room.attributes.title}\">#{room.attributes.title} (#{unread_count}/#{total_count})</option>"
      )
    $("#select_rooms select").change(() ->
      vals = $(this).val().split(':')
      initRoom(vals[0], vals[1])
    )
  )

initChatting = () ->
  console.log 'initChatting'
  $("#chatting_title").html("<h2 class='status'><img src='https://ruffnote.com/attachments/24306' /></h2>")

  cond = [
    ["is_done", true]
    ["createdAt", '>', Util.minAgo(@env.pomotime + @env.chattime)]
    ["createdAt", '<', Util.minAgo(@env.pomotime)]
  ]
  $("#chatting_title").hide()
  ParseParse.where("Workload", cond, (workloads) ->
    return unless workloads.length > 0
    $("#chatting_title").show()
    for workload, i in workloads
      continue unless workload.attributes.user

      @addChatting(workload)
    renderWorkloads('#chatting')
    renderWorkloads('#doing')
  )

initDoing = () ->
  console.log 'initDoing'
  $("#doing_title").html("<h2 class='status'><img src='https://ruffnote.com/attachments/24310' /></h2>")
  $("#doing_title").hide()

  cond = [
    ["is_done", null]
    ["createdAt", '>', Util.minAgo(@env.pomotime)]
  ]
  ParseParse.where("Workload", cond, (workloads) ->
    return unless workloads.length > 0
    $("#doing_title").show()
    user_keys = {}
    user_count = 0
    for workload, i in workloads
      continue unless workload.attributes.user
      unless user_keys[workload.attributes.user.id]
        @addDoing(workload)
        user_keys[workload.attributes.user.id] = true
    renderWorkloads('#doing')
  )

initDone = () ->
  console.log 'initDone'
  cond = [
    ["is_done", true]
    ["createdAt", '<', Util.minAgo(@env.pomotime + @env.chattime)]
  ]
  ParseParse.where("Workload", cond, (workloads) ->
    return unless workloads.length > 0
    $("#done").append("<h2 class='status'><img src='https://ruffnote.com/attachments/24305' /></h2>")
    for workload in workloads
      continue unless workload.attributes.user
      disp = "#{Util.hourMin(workload.createdAt)}開始（#{workload.attributes.number}回目）"
      @addWorkload("#done", workload, disp)
  , null, 12)
 
initKpi = () ->
  ruffnote(17548, 'kpi_title')
  $('#kpi3').css('height', '300px')
  $('#kpi2').css('height', '300px')
  $('#kpi1').css('height', '300px')
  $('#kpi3_title').html('<h2>直近50回分</h2>')
  $('#kpi2_title').html('<h2>直近300回分</h2>')
  $('#kpi1_title').html("<h2 style='margin-top: 30px;'>直近1000回分</h2>")

  cond = [
    ['is_done', true]
  ]
  ParseParse.where('Workload', cond, (workloads) ->
    chart1 = {}
    chart_viewer1 = {}
    chart2 = {}
    chart_viewer2 = {}
    chart3 = {}
    chart_viewer3 = {}
    for workload, i in workloads
      continue unless workload.get('synchro_start')
      key_start = workload.createdAt
      val_start = workload.get('synchro_start')
      key_end = Util.minAgo(-1 * @env.pomotime, workload.createdAt)
      val_end = workload.get('synchro_end')

      # kPI1: 1000
      if workload.get('user') && Parse.User.current() && workload.get('user').id == Parse.User.current().id
        chart_viewer1[key_start] = val_start
        chart_viewer1[key_end] = val_end
      chart1[key_start] = val_start
      chart1[key_end] = val_end

      continue if i > 300

      # KPI2: 300
      if workload.get('user') && Parse.User.current() && workload.get('user').id == Parse.User.current().id
        chart_viewer2[key_start] = val_start
        chart_viewer2[key_end] = val_end
      chart2[key_start] = val_start
      chart2[key_end] = val_end

      continue if i > 50

      # KPI3: 50
      if workload.get('user') && Parse.User.current() && workload.get('user').id == Parse.User.current().id
        chart_viewer3[key_start] = val_start
        chart_viewer3[key_end] = val_end
      chart3[key_start] = val_start
      chart3[key_end] = val_end
 
    data1 = [
      {name: '全体', data: chart1},
      {name: 'あなた', data: chart_viewer1}
    ]
    new Chartkick.LineChart("kpi1", data1)
 
    data2 = [
      {name: '全体', data: chart2},
      {name: 'あなた', data: chart_viewer2}
    ]
    new Chartkick.LineChart("kpi2", data2)
   
    data3 = [
      {name: '全体', data: chart3},
      {name: 'あなた', data: chart_viewer3}
    ]
    new Chartkick.LineChart("kpi3", data3)
  , null, 1000)

login = () ->
  console.log 'login'
  window.fbAsyncInit()

start_random = () ->
  console.log 'start_random'
  ParseParse.all("Music", (musics) ->
    n = Math.floor(Math.random() * musics.length)
    sc_id = musics[n].attributes.sc_id
    location.hash = "soundcloud:#{sc_id}"
    window.play("soundcloud:#{sc_id}")
  )
  
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
  params.host = location.host

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
  ]
  for dom in doms
    $("##{dom}").hide()

  @env.is_doing = true
  @syncWorkload('doing')

  Util.countDown(@env.pomotime*60*1000, complete)

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
    Youtube.fetch(id, (track) ->
      params['yt_id'] = id
      params['title'] = track['entry']['title']['$t']
      params['artwork_url'] = track['entry']['media$group']['media$thumbnail'][3]['url']
      createWorkload(params, start)
      sec = track['entry']['media$group']['yt$duration']['seconds']
      sec = parseInt(sec)
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
  setTimeout("play_repeat\(\"#{key}\"\, #{duration})", duration)

complete = () ->
  console.log 'complete'
  @syncWorkload('chatting')
  Util.countDown(@env.chattime*60*1000, 'finish')
  $('#header').hide()
  $('#otukare').fadeIn()
  $("#otukare_services").fadeIn()
  $("#playing").fadeOut()
  $("#search").fadeOut()
  $("#playing").html('') # for stopping
  @initSelectRooms()

  alert '24分間お疲れ様でした！5分間交換日記ができます☆' if location.href.match('alert') unless @env.is_done

  @env.is_doing = false
  @env.is_done = true

  if location.href.match("ad=") and !$('#ad iframe').length
    ParseParse.all("Ad", (ads) ->
      n = Math.floor(Math.random() * ads.length)
      ad = ads[n].attributes
      $('#ad').html(
        """
        <h2><a href=\"#{ad.click_url}?from=245cloud.com\" target=\"_blank\">#{ad.name}</a></h2>
        <iframe width=\"560\" height=\"315\" src=\"#{ad.movie_url}\" frameborder=\"0\" allowfullscreen></iframe>
        """
      )
    )

  workload = @workload
  w = workload.attributes
  first = new Date(workload.createdAt)
  first = first.getTime() - first.getHours()*60*60*1000 - first.getMinutes()*60*1000 - first.getSeconds() * 1000
  first = new Date(first)
  cond = [
    ["is_done", true]
    ['user', w.user]
    ["createdAt", '<', workload.createdAt]
    ["createdAt", '>', first]
  ]
  ParseParse.where("Workload", cond, (workload, data) ->
    workload.set('number', data.length + 1)
    workload.set('is_done', true)
    workload.save()
  , workload)

  # 開始29分前〜開始時間
  cond = [
    ['createdAt', '>', Util.minAgo(@env.pomotime, workload.createdAt)]
    ['createdAt', '<', workload.createdAt]
  ]
  ParseParse.where('Workload', cond, (workload, workloads2) ->
    workload.set('synchro_start', workloads2.length + 1)
    workload.save()
  , workload, 99999)

  # 終了29分前〜終了時間
  cond = [
    ['createdAt', '>', workload.createdAt]
    ['createdAt', '<', Util.minAgo(-1 * @env.pomotime, workload.createdAt)]
  ]
  ParseParse.where('Workload', cond, (workload, workloads3) ->
    workload.set('synchro_end', workloads3.length + 0)
    workload.set('point', 3)
    workload.save()
  , workload, 9999)

  $complete = $('#complete')
  $complete.html('24分おつかれさまでした！5分間交換ノートが見られます')

  initComments()


window.initComments = () ->
  initRoom()

window.initRoom = (id = 'default', title='いつもの部屋') ->
  console.log 'initRoom'

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
    
    if id == 'default'
      search_id = null
      limit = 100
    else
      search_id = id
      limit = 10000

    ParseParse.where("Comment", [['room_id', search_id]], (comments) ->
      $("#room_#{id} .create_comment").keypress((e) ->
        if e.which == 13 #enter
          window.createComment(id)
      )
      for comment in comments
        @addComment(id, comment)
      unreads = Parse.User.current().get("unreads")
      unreads = {} unless unreads
      unreads[search_id] = comments.length
      Parse.User.current().set("unreads", unreads)
      Parse.User.current().save()
    , null, limit)

window.finish = () ->
  console.log 'finish'
  @syncWorkload('finish')
  location.reload()

window.createComment = (room_id) ->
  console.log 'createComment'
  console.log 'room_id', room_id
  $createComment = $("#room_#{room_id} .create_comment")
  
  #$file = $("#file")
  
  body = $createComment.val()

  $createComment.val('')
  
  return if body.length < 1

  params = {body: body}

  if room_id != 'default'
    params.room_id = room_id

  ###
  fileUploadControl = $file[0]
  if fileUploadControl.files.length > 0
    file = fileUploadControl.files[0]
    #FIXME
    filename = 'commentfile' + file.name.split(/./).pop()

    parseFile = new Parse.File(filename, file)
    parseFile.save((file) ->
      console.log file
      params['file'] = file
      ParseParse.create('Comment', params, (comment)->
        $file.val(null)
        syncComment(room_id, comment)
      )
    , (error) ->
      # error handling
    )
  else
    ParseParse.create('Comment', params, (comment)->
      syncComment(room_id, comment)
    )
  ###
  ParseParse.create('Comment', params, (comment)->
    syncComment(room_id, comment, true)
  )

initRanking = () ->
  $('#ranking').html('ここにランキング結果が入る予定')

@addDoing = (workload) ->
  $("#doing_title").show()
  t = new Date(workload.createdAt)
  end_time = @env.pomotime*60*1000 + t.getTime()
  disp = "#{Util.hourMin(workload.createdAt)}開始（あと<span class='realtime' data-countdown='#{end_time}'></span>）"
  @addWorkload("#doing", workload, disp)

@addChatting = (workload) ->
  $("#chatting_title").show()
  t = new Date(workload.createdAt)
  end_time = @env.pomotime*60*1000 + @env.chattime*60*1000 + t.getTime()
  disp = "#{Util.hourMin(workload.createdAt)}開始（あと<span class='realtime' data-countdown='#{end_time}'></span>）"
  @addWorkload("#chatting", workload, disp)

@addWorkload = (dom, workload, disp) ->
  if workload.attributes
    w = workload.attributes
    user_id = w.user.id
  else
    w = workload
    user_id = w.user.objectId

  rooms = ""
  if w.rooms
    for room in w.rooms
      rooms += "<span class=\"tag\">#{room.split(':')[1]}</span>"

  if w.title
    href = '#'
    if w.sc_id
      href += "soundcloud:#{w.sc_id}"
    if w.yt_id
      href += "youtube:#{w.yt_id}"
    if w.mc_id
      href += "mixcloud:#{w.mc_id}"
    if w.et_id
      href += "8tracks:#{w.et_id}"
    fixed = "<a href=\"#{href}\" class='fixed_start'><img src='https://ruffnote.com/attachments/24327' /></a>"
    jacket = "#{if w.artwork_url then '<img src=\"' + w.artwork_url + '\" />' else '<img src=\"https://ruffnote.com/attachments/24162\" />'}"
    title = w.title
  else
    title = '無音'
    fixed = "<a href=\"#\" class='fixed_start'><img src='https://ruffnote.com/attachments/24333' /></a>"
    jacket = "<img src=\"https://ruffnote.com/attachments/24163\" />"
  user_img = "<img class='icon icon_#{user_id} img-thumbnail' src='#{userIdToIconUrl(user_id)}' />"

  $item = $("""
   <h5>#{title} </h5>
   <div>#{jacket}</div>
   <div style='margin: 8px 0 5px;'>#{user_img}</div>
   <div>#{disp}</div>
   <div>#{rooms}</div>
   #{fixed}<br />
  """)

  unless dom == '#done'
    $("#chatting .user_#{user_id}").remove()
    $("#doing .user_#{user_id}").remove()
  if (dom == '#doing' or dom == '#chatting') and $("#{dom} .user_#{user_id}").length
    $("#{dom} .user_#{user_id}").html($item)
  else
    $workload = $('<div></div>')
    $workload.addClass("user_#{user_id}")
    $workload.addClass("workload")
    $workload.addClass("col-sm-2")
    $workload.css("min-height", '280px')
    $workload.html($item)
    if workload.attributes # init
      $("#{dom}").append($workload)
    else # with PubNub
      $("#{dom}").prepend($workload)
      renderWorkloads('#doing')
      renderWorkloads('#chatting')

  if @env.is_doing
    $(".fixed_start").hide()

  $("#{dom}").hide()
  $("#{dom}").fadeIn()

initFixedStart = () ->
  $(document).on('click', '.fixed_start', () ->
    mixpanel.track("fixed_start")
    if Parse.User.current()
      hash = $(this).attr('href').replace(/^#/, '')
      location.hash = hash
      start_hash()
    else
      alert 'Facebookログインをお願いします！'
  )
  $(document).on('click', '.add_playlist', () ->
    alert 'プレイリストに追加する機能は現在開発中です。。。'
  )


ruffnote = (id, dom, callback=null) ->
  Ruffnote.fetch("pandeiro245/245cloud/#{id}", dom, callback)

initService = ($dom, url) ->
  $dom.append("<iframe src='#{url}' width='85%' height='900px'></iframe>")

@addComment = (id, comment, is_countup=false) ->
  $comments = $("#room_#{id} .comments")
  if typeof(comment.attributes) != 'undefined'
    c = comment.attributes
  else
    c = comment
  user = c.user

  t = new Date(comment.createdAt)
  hour = t.getHours()
  min = t.getMinutes()

  if user && c.body

    # FIXME
    if @env.is_done 
      unreads = Parse.User.current().get("unreads")
      unless unreads
        unreads = {}
        unreads[id] = 0
      unreads[id] += 1
      Parse.User.current().set("unreads", unreads)
      Parse.User.current().save()

    if c.file
      console.log c.file
      file = "<img src=\"#{c.file._url}\" style='max-width: 500px;'/>"
    else
      file = ""
    html = """
    <tr>
    <td>
    <a class='facebook_#{user.id}' target='_blank'>
    <img class='icon icon_#{user.id}' src='#{userIdToIconUrl(c.user.objectId)}' />
    <div class='facebook_name_#{user.id}'></div>
    </a>
    <td>
    <td>#{Util.parseHttp(c.body)}#{file}</td>
    <td>#{hour}時#{min}分</td>
    </tr>
    """
    if typeof(comment.attributes) != 'undefined'
      $comments.append(html)
      ParseParse.fetch("user", comment, (ent, user) ->
        img = user.get('icon_url') || user.get('icon')._url
        $(".icon_#{user.id}").attr('src', img)
        if user.get('facebook_id_str')
          href = "https://facebook.com/#{user.get('facebook_id_str')}"
          $(".facebook_#{user.id}").attr('href', href)
        if name = user.get('name')
          $(".facebook_name_#{user.id}").html(name)
      )
    else
      $comments.prepend(html)

userIdToIconUrl = (userId) ->
  localStorage["icon_#{userId}"] || ""

getUnreadsCount = (room_id, total_count) ->
  return total_count unless Parse.User.current()
  return total_count unless Parse.User.current().get("unreads")
  if count = Parse.User.current().get("unreads")[room_id]
    res = total_count - count
    if res < 0 then 0  else res
  else
    return total_count

@syncWorkload = (type) ->
  @socket.send({
    type: type
    workload: @workload
  })

syncComment = (id, comment, is_countup=false) ->
  @socket.send({
    type: 'comment'
    comment: comment
    id: id
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
  Soundcloud.search(q, @env.sc_client_id, $tracks)
  Mixcloud.search(q, $tracks)
  #EightTracks.search(q, $tracks)


initHatopoppo = () ->
  $('#hatopoppo').css('width', '1px')
  $audio = $('<audio></audio>')
  $audio.attr('id', 'hato')
  # thanks for http://musicisvfr.com/free/se/clock01.html
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
  console.log 'renderWorkloads'
  $dom = $("#{dom}")
  $items = $("#{dom} .workload")
  $first = $("#{dom} .workload:first")
  $items.removeClass('col-sm-offset-2')
  $items.removeClass('col-sm-offset-3')
  $items.removeClass('col-sm-offset-4')
  $items.removeClass('col-sm-offset-5')
  $first.addClass("col-sm-offset-#{getOffset($items.length)}")

start_unless_doing = ()->
  unless @env.is_doing
    start_hash()

artworkUrlWithNoimage = (artwork_url) ->
  artwork_url || 'https://ruffnote.com/attachments/24162'

initWhatis = () ->
  now = new Date()
  month = now.getMonth() + 1
  day = now.getDate()
  youbi = now.getDay()
  numbers = {}
  for i in [1..31]
    i2 = 24371 + i
    numbers[i] = "https://ruffnote.com/attachments/#{i2}"
  youbis = {}
  for i in [1..5]
    i2 = 24358 + i
    youbis[i] = "https://ruffnote.com/attachments/#{i2}"
  youbis[0] = "https://ruffnote.com/attachments/24465" #日曜日
  youbis[6] = "https://ruffnote.com/attachments/24464" #土曜日

  $kokuban = $('<div></div>')
  $kokuban.css('position', 'relative')
  $kokuban.css('background', 'url(https://ruffnote.com/attachments/24501)')
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

initMemo = () ->
  $('#memo_title').html("""
    <h2>MEMO</h2>
    ここに入力した内容は作者（西小倉宏信）も見れてしまうので機密情報は書かないようにしてください<br />
    例：山田商事への提案書を作る→企画書を作る
  """)
  $textarea = $('<textarea></textarea>')
  $textarea.html(localStorage['memo'])
  $textarea.css('width', '500px')
  $('#memo').html($textarea)
  $(document).on('keypress', '#memo textarea', () ->
    localStorage['memo'] = $('#memo textarea').val()
  )

