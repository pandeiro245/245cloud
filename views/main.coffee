$ ->
  ParseParse.all("User", (users) ->
    for user in users
      img = user.get('icon_url')
      localStorage["icon_#{user.id}"] = img if img
      $(".icon_#{user.id}").attr('src', img)
  )

  ParseParse.addAccesslog()
  Util.scaffolds(['header', 'contents', 'select_rooms', 'chatting_title', 'chatting', 'doing_title', 'doing', 'done', 'playing', 'complete', 'ranking', 'search', 'music_ranking', 'footer'])
  Util.realtime()

  ruffnote(13475, 'header')
  ruffnote(13477, 'footer')
  ruffnote(17314, 'music_ranking')

  initSelectRooms()
  initChatting()
  initDoing()
  initDone()
  initStart()
  # initRanking()
  initFixedStart()

initStart = () ->
  console.log 'initStart'
  window.isDoing = false
  
  $(document).ready(() ->
    $(window).on("beforeunload", (e)->
      if window.isDoing
        return "24分やり直しでも大丈夫ですか？"
    )
  )
  
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

initSelectRooms = () ->
  console.log 'initSelectRooms'
  $('#select_rooms').html("""
  急に利用者が増えたので<br />
  超簡易版トークルーム機能付けてみました。<br />
  チェックした部屋は24分集中後に5分間だけ入れます。<br />
  チェックできる数はいずれ制限しますが今は無制限です！<br />
  （カッコ内は未読コメント数/全件数）<br /><br />
  <ul></ul>
  """)
  ParseParse.all("Room", (rooms) ->
    for room in rooms
      total_count = room.attributes.comments_count
      unread_count = getUnreadsCount(room.id, total_count)
      style = ""
      if !Parse.User.current().get('unreads')[room.id] # 1回入ったことがない部屋
        style = " style=\"color: #ccc;\""
      else if unread_count > 100
        style = " style=\"color: #000;\""
      else if unread_count > 10
        style = " style=\"color: #666;\""
      else if unread_count > 0 and unread_count < 10
        style = " style=\"color: #333;\""
      else
        style = " style=\"color: #ccc;\""

      $('#select_rooms ul').append(
        "<li#{style}><label><input name=\"select_rooms\" type=\"checkbox\" value=\"#{room.id}:#{room.attributes.title}\" />#{room.attributes.title} (#{unread_count}/#{total_count})</li></label>"
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
  cond = [["is_done", true]]
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
  )
  
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
  vals = []
  for room in $("input[name='select_rooms']:checked")
    vals.push($(room).val())
  if vals.length
    params.rooms = vals
  ParseParse.create("Workload", params, (workload) ->
    @workload = workload
    callback()
  )
  
start = () ->
  console.log 'start'
  $("#select_rooms").hide()
  $("#done").hide()
  $("input").hide()
  $(".fixed_start").hide()
  $("#music_ranking").hide()
  @isDoing = true
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
  @isDoing = false
  @isDone = true
  @syncWorkload('chatting')
  $("#playing").fadeOut()
  $("#playing").html('') # for stopping
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

  $track = $("<input />").attr('id', 'track').attr('placeholder', 'ここにアーティスト名や曲名を入れてね')
  $tracks = $("<div></div>").attr('id', 'tracks')

  $('#search').append("<hr /><h3>好きなパワーソングを探す</h3>")
  $('#search').append($track)
  $('#search').append($tracks)

  $('#track').keypress((e) ->
    if e.which == 13 #enter
      q = $('#track').val()
      url = "http://api.soundcloud.com/tracks.json?client_id=#{window.env.sc_client_id}&q=#{q}&duration[from]=#{19*60*1000}"
      $.get(url, (tracks) ->
        if tracks[0]
          for track in tracks
            artwork = ''
            if track.artwork_url
              artwork = "<img src=\"#{track.artwork_url}\" width=100px/>"

            $('#tracks').append("""
              <tr>
                <td><a href=\"#soundcloud:#{track.id}\">#{track.title}</a></td>
                <td>#{artwork}</td>
                <td>#{Util.time(track.duration)}</td>
              </tr>
            """)
        else
          alert "「#{q}」で24分前後の曲はまだ出てないようです...。他のキーワードで探してみてください！"
      )
  )
  Util.countDown(@env.chattime*60*1000, 'finish')

window.initComments = () ->
  if @workload.attributes.rooms
    for room in @workload.attributes.rooms
      params = room.split(':')
      id = params[0]
      title = params[1]
      initRoom(id, title)
  initRoom()


window.initRoom = (id = 'default', title='いつもの部屋') ->
  console.log 'initRoom'
  $room = $('<div></div>')
  $room.attr('id', "room_#{id}")
  $createComment = $('<input />').addClass('create_comment').attr('placeholder', title)
  $room.append($createComment)
  
  #$file = $('<input />').attr('type', 'file').attr('id', 'file')
  #$room.append($file)

  $comments = $("<table></table>").addClass('table comments')
  $room.append($comments)

  $('#complete').append($room)
  
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
  )

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

  if @isDoing
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
  if location.href.match(/245cloud-c9-pandeiro245.c9.io/)
    Ruffnote.fetch("pandeiro245/1269/#{id}", dom)
  else
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

