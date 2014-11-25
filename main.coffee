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
    'footer'
  ])
  Util.realtime()

  ruffnote(13475, 'header')
  ruffnote(13477, 'footer')
  #ruffnote(17314, 'music_ranking')

  initSearch()
  initChatting()
  initDoing()
  initDone()
  initStart()
  # initRanking()
  initFixedStart()

initStart = () ->
  console.log 'initStart'
  text = "24分やり直しでも大丈夫ですか？"
  Util.beforeunload(text, 'env.is_doing')
  
  if Parse.User.current()
    $('#contents').append("<div class='countdown'></div>")
      
    text = '曲お任せで24分間集中する！'
    Util.addButton('start', $('#contents'), text, start_random)
    
    text = '無音で24分集中'
    Util.addButton('start', $('#contents'), text, start_nomusic)

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
  $('#select_rooms').html("""
  急に利用者が増えたので<br />
  超簡易版トークルーム機能付けてみました。<br />
  カッコ内は未読コメント数/全件数<br />
  ですが色々バグあるかもしれませんｗ<br /><br />
  <select></select>
  """)

  $('#select_rooms select').html('')
  $('#select_rooms select').append(
    "<option value=\"default:いつもの部屋\">いつもの部屋</option>"
  )

  ParseParse.all("Room", (rooms) ->
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
    for workload in workloads
      continue unless workload.attributes.user
      @addChatting(workload)
    initFixedStart()
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

    for workload in workloads
      continue unless workload.attributes.user
      @addDoing(workload)
    initFixedStart()
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

    date = ""
    for workload in workloads
      continue unless workload.attributes.user
      i = Util.monthDay(workload.createdAt)
      if date != i
        $("#done").append("<h2>#{i}</h2>")
      date = i
      disp = "#{Util.hourMin(workload.createdAt)}開始（#{workload.attributes.number}回目）"
      @addWorkload("#done", workload, disp)
    initFixedStart()
  , null, 10)
  
login = () ->
  console.log 'login'
  window.fbAsyncInit()

start_random = () ->
  console.log 'start_random'
  ParseParse.all("Music", (musics) ->
    n = Math.floor(Math.random() * musics.length)
    sc_id = musics[n].attributes.sc_id
    location.hash = "soundcloud:#{sc_id}"
    play("soundcloud:#{sc_id}")
  )
  
window.start_hash = (key = null) ->
  console.log 'start_hash'
  unless key
    key = location.hash.replace(/#/, '')
  play(key)

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
  @env.is_doing = true
  @syncWorkload('doing')

  Util.countDown(@env.pomotime*60*1000, complete)

play = (key) ->
  console.log 'play'
  params = {}
  id = key.split(':')[1]
  if key.match(/^soundcloud/)
    Soundcloud.fetch(id, @env.sc_client_id, (track) ->
      params['sc_id'] = parseInt(id)
      for key in ['title', 'artwork_url']
        params[key] = track[key]
      createWorkload(params, start)

      localStorage['artwork_url'] = track.artwork_url
      Soundcloud.play(id, @env.sc_client_id, $("#playing"), !localStorage['is_dev'])
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
      else
        start_sec = 0
      Youtube.play(id, $("#playing"), !localStorage['is_dev'], start_sec)
    )
    
complete = () ->
  console.log 'complete'
  @env.is_doing = false
  @isDone = true
  @syncWorkload('chatting')
  $("#playing").fadeOut()
  $("#search").fadeOut()
  $("#playing").html('') # for stopping
  @initSelectRooms()
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

  $complete = $('#complete')
  $complete.html('24分おつかれさまでした！5分間交換ノートが見られます')

  initComments()

  Util.countDown(@env.chattime*60*1000, 'finish')

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
    html = """
      #{if w.artwork_url then '<img src=\"' + w.artwork_url + '\" />' else '<div class="noimage">no image</div>'}
      <img class='icon icon_#{user_id}' src='#{userIdToIconUrl(user_id)}' />
      #{disp}<br />
      #{w.title} <br />
      #{rooms}<br />
      <a href=\"#{href}\" class='fixed_start btn btn-default'>この曲で集中する</a>
      <hr />
    """
  else
    html = """
      <div class=\"noimage\">無音</div>
      <img class='icon icon_#{user_id}' src='#{userIdToIconUrl(user_id)}' />
      #{disp}<br />
      #{rooms}<br />
      無音
      <hr />
    """
  unless dom == '#done'
    $("#chatting .user_#{user_id}").remove()
    $("#doing .user_#{user_id}").remove()

  if (dom == '#doing' or dom == '#chatting') and $("#{dom} .user_#{user_id}").length

    $("#{dom} .user_#{user_id}").html(html)
  else
    $workload = $('<div></div>')
    $workload.addClass("user_#{user_id}")
    $workload.html(html)
    if workload.attributes
      $("#{dom}").append($workload)
    else
      $("#{dom}").prepend($workload)

  if @env.is_doing
    $(".fixed_start").hide()

  $("#{dom}").hide()
  $("#{dom}").fadeIn()

initFixedStart = () ->
  $('.fixed_start').click(() ->
    if Parse.User.current()
      play($(this).attr('href').replace(/^#/, ''))
    else
      alert 'Facebookログインをお願いします！'
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
    if @isDone 
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
        if user.get('facebook_id')
          href = "https://facebook.com/#{user.get('facebook_id')}"
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

  url = "http://gdata.youtube.com/feeds/api/videos?q=#{q}&filter=long&alt=json"
  $.get(url, (tracks) ->
    tracks = tracks.feed.entry
    if tracks[0]
      for track in tracks
        duration = parseInt(track['media$group']['yt$duration']['seconds']) * 1000
        continue if duration < 24 * 60 *1000

        tmp = track['id']['$t']
        id = tmp.split("/")[tmp.split("/").length - 1]
        url = "https://www.youtube.com/watch?v=#{id}"
        title = track['title']['$t']
        artwork_url = track['media$group']['media$thumbnail'][3]['url']
        duration = parseInt(track['media$group']['yt$duration']['seconds']) * 1000
        artwork = ''
        if artwork_url
          artwork = "<img src=\"#{artwork_url}\" width=100px/>"
        href = "youtube:#{id}"
        $('#tracks').append("""
          <hr />
          <div>
            <a href='#{url}' target='_blank'>#{title}</a>
            (#{Util.time(duration)})<br />
            <br />
            #{artwork}
            <a href=\"#{href}\" class='fixed_start btn btn-default'>この曲で集中</a>
            <a href=\"#\" class='add_playlist btn btn-default'>プレイリストに追加（準備中）</a>
          </div>
        """)
      initFixedStart()
    else
      $("#tracks").append("<div>「#{q}」YouTubeCloudにはで24分前後の曲はまだ出てないようです...。他のキーワードで探してみてください！</div>")
  )

  url = "http://api.soundcloud.com/tracks.json?client_id=#{window.env.sc_client_id}&q=#{q}&duration[from]=#{24*60*1000}"
  $.get(url, (tracks) ->
    if tracks[0]
      for track in tracks
        artwork = ''
        if track.artwork_url
          artwork = "<img src=\"#{track.artwork_url}\" width=100px/>"
        href = "soundcloud:#{track.id}"
        $('#tracks').append("""
          <hr />
          <div>
            <a href='#{track.permalink_url}' target='_blank'>#{track.title}</a>
            (#{Util.time(track.duration)})<br />
            <br />
            #{artwork}
            <a href=\"#{href}\" class='fixed_start btn btn-default'>この曲で集中</a>
            <a href=\"#\" class='add_playlist btn btn-default'>プレイリストに追加（準備中）</a>
          </div>
        """)
      initFixedStart()
    else
      $("#tracks").append("<div>「#{q}」SoundCloudにはで24分前後の曲はまだ出てないようです...。他のキーワードで探してみてください！</div>")
  )


