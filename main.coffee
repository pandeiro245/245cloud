@env.is_doing = false

$ ->
  ParseParse.addAccesslog()
  Util.scaffolds([
    'header'
    'otukare'
    'ad'
    'contents'
    'doing_title'
    'doing'
    'chatting_title'
    'chatting'
    'done'
    'search'
    'playing'
    'complete'
    'select_rooms'
    'rooms'
    #'ranking'
    #'music_ranking'
    'kpi_title'
    'kpi3_title'
    'kpi3'
    'kpi2_title'
    'kpi2'
    'kpi1_title'
    'kpi1'
    'footer'
  ])
  Util.realtime()

  $('#header').removeClass('row')
  ruffnote(13475, 'header')
  ruffnote(13477, 'footer')

  $('#otukare').hide()
  ruffnote(17498, 'otukare')
  #ruffnote(17314, 'music_ranking')

  initSearch()
  initChatting()
  initDoing()
  initDone()
  initStart()
  # initRanking()
  initFixedStart()
  initKpi()
  ParseBatch.repeat()

initStart = () ->
  console.log 'initStart'
  text = "24分やり直しでも大丈夫ですか？"
  Util.beforeunload(text, 'env.is_doing')
  
  if Parse.User.current()
    $('#contents').append("<div class='countdown' ></div>")
      
    text = '曲お任せで24分間集中する！'
    tooltip = '現在はSoundcloudの人気曲からランダム再生ですが今後もっと賢くなっていくはず'
    Util.addButton('start', $('#contents'), text, start_random, tooltip)
    
    text = '無音で24分集中'
    tooltip = '無音ですが終了直前にはとぽっぽが鳴ります'
    Util.addButton('start', $('#contents'), text, start_nomusic, tooltip)

    id = location.hash.split(':')[1]
    if location.hash.match(/soundcloud/)
      Soundcloud.fetch(id, @env.sc_client_id, (track) ->
        text = "「#{track['title']}」で24分集中"
        Util.addButton('start', $('#contents'), text, start_hash)
      )
    if location.hash.match(/youtube/)
      Youtube.fetch(id, (track) ->
        text = "「#{track['entry']['title']['$t']}」で24分集中"
        Util.addButton('start', $('#contents'), text, start_hash)
      )
    if location.hash.match(/mixcloud/)
      Mixcloud.fetch(id, (track) ->
        text = "「#{track.name}」で24分集中"
        Util.addButton('start', $('#contents'), text, start_hash)
      )
    if location.hash.match(/8tracks/)
      EightTracks.fetch(id, @env.et_client_id, (track) ->
        text = "「#{track.mix.name}」で24分集中"
        Util.addButton('start', $('#contents'), text, start_hash)
      )

  else
    text = 'facebookログイン'
    Util.addButton('login', $('#contents'), text, login)

initSearch = () ->
  $track = $("<input />").attr('id', 'track').attr('placeholder', 'ここにアーティスト名や曲名を入れてね')
  localStorage['search_music_title'] = '作業BGM' unless localStorage['search_music_title']
  if localStorage['search_music_title'].length > 1
    $track.attr('value', localStorage['search_music_title'])

  $tracks = $("<div></div>").attr('id', 'tracks')

  $('#search').append("<hr /><h3>好きなパワーソングを探す</h3>")
  $('#search').append($track)
  $('#search').append($tracks)

  $('#search input').focus(() ->
    $(this).select()
  )
  $('#search input').focus()
  searchMusics()

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
  $("#chatting_title").html("<h2>NOW CHATTING</h2>")

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
    initFixedStart()
    renderWorkloads('#chatting')
    renderWorkloads('#doing')
  )

initDoing = () ->
  console.log 'initDoing'
  $("#doing_title").html("<h2>NOW DOING</h2>")
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
    initFixedStart()
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
    $("#done").append("<h2>DONE</h2>")
    for workload in workloads
      continue unless workload.attributes.user
      disp = "#{Util.hourMin(workload.createdAt)}開始（#{workload.attributes.number}回目）"
      @addWorkload("#done", workload, disp)
    initFixedStart()
  , null, 100)
 
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
  window.play(key)

start_nomusic = () ->
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
  $("#playing").fadeOut()
  $("#search").fadeOut()
  $("#playing").html('') # for stopping
  @initSelectRooms()

  alert '完了！' if location.href.match('alert') unless @env.is_done

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
  $('#ranking').html('ここにランキング結果が入ります')

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
    #fixed = "<a href=\"#{href}\" class='fixed_start btn btn-default'>再生</a><a href=\"#\" class='btn btn-default add_playlist'>追加</a>"
    fixed = "<a href=\"#{href}\" class='fixed_start btn btn-default'>再生</a>"
    jacket = "#{if w.artwork_url then '<img src=\"' + w.artwork_url + '\" />' else '<img src=\"https://ruffnote.com/attachments/24162\" />'}"
    title = w.title
  else
    title = '無音'
    fixed = ""
    jacket = "<img src=\"https://ruffnote.com/attachments/24163\" />"
  user_img = "<img class='icon icon_#{user_id} img-thumbnail' src='https://graph.facebook.com/1266278030/picture?type=square' />"

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
  $('.fixed_start').click(() ->
    mixpanel.track("fixed_start")
    if Parse.User.current()
      hash = $(this).attr('href').replace(/^#/, '')
      location.hash = hash
      window.play(hash)
    else
      alert 'Facebookログインをお願いします！'
  )
  $('.add_playlist').click(() ->
    alert 'プレイリストに追加する機能は現在開発中です。。。'
  )


ruffnote = (id, dom) ->
  Ruffnote.fetch("pandeiro245/245cloud/#{id}", dom)

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
    <img class='icon icon_#{user.id}' src='https://graph.facebook.com/1266278030/picture?type=square' />
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
        img = "https://graph.facebook.com/#{user.get('facebook_id')}/picture?type=square"
        $(".icon_#{user.id}").attr('src', img)
        href = "https://facebook.com/#{user.get('facebook_id')}"
        $(".facebook_#{user.id}").attr('href', href)
        if name = user.get('name')
          $(".facebook_name_#{user.id}").html(name)
        else
          $(".facebook_name_#{user.id}").html("※利用者名取得中...")
      )
    else
      $comments.prepend(html)

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
  Youtube.search(q, $tracks, initFixedStart)
  Soundcloud.search(q, @env.sc_client_id, $tracks, initFixedStart)
  Mixcloud.search(q, $tracks, initFixedStart)
  #EightTracks.search(q, $tracks, initFixedStart)

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

