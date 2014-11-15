$ ->
  ParseParse.all("User", (users) ->
    for user in users
      img = user.get('icon_url')
      localStorage["icon_#{user.id}"] = img if img
      $(".icon_#{user.id}").attr('src', img)
  )

  ParseParse.addAccesslog()
  Util.scaffolds(['header', 'contents', 'chatting_title', 'chatting', 'doing_title', 'doing', 'done', 'playing', 'complete', 'comments', 'ranking', 'search', 'music_ranking', 'footer'])
  Util.realtime()

  ruffnote(13475, 'header')
  ruffnote(13477, 'footer')
  ruffnote(17314, 'music_ranking')

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

initChatting = () ->
  console.log 'initChatting'
  $("#chatting_title").html("<h2>NOW CHATTING</h2>")

  cond = [
    ["is_done", true]
    ["createdAt", '>', Util.minAgo(@env.pomotime + @env.chattime)]
    ["createdAt", '<', Util.minAgo(@env.pomotime)]
  ]
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
  params = {host: location.host}
  ParseParse.create("Workload", params, (workload) ->
    @workload = workload
    start()
  )
  
start = () ->
  console.log 'start'
  $("#done").hide()
  $("input").hide()
  $(".fixed_start").hide()
  $("#music_ranking").hide()
  @isDoing = true
  @syncWorkload('doing')

  Util.countDown(@env.pomotime*60*1000, complete)

play = (key) ->
  console.log 'play'
  id = key.split(':')[1]
  params = {host: location.host}

  if key.match(/^soundcloud/)
    Soundcloud.fetch(id, @env.sc_client_id, (track) ->
      params['sc_id'] = parseInt(id)
      for key in ['title', 'artwork_url']
        params[key] = track[key]
      ParseParse.create("Workload", params, (workload) ->
        @workload = workload
        start()
      )
      localStorage['artwork_url'] = track.artwork_url
      Soundcloud.play(id, @env.sc_client_id, $("#playing"), !localStorage['is_dev'])
    )
  else if key.match(/^youtube/)
    Youtube.fetch(id, (track) ->
      params['yt_id'] = id
      params['title'] = track['entry']['title']['$t']
      params['artwork_url'] = track['entry']['media$group']['media$thumbnail'][3]['url']
      ParseParse.create("Workload", params, (workload) ->
        @workload = workload
        start()
      )
      Youtube.play(id, $("#playing"), !localStorage['is_dev'])
    )
    
complete = () ->
  console.log 'complete'
  @isDoing = false
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

  $comment = $('<input />').attr('id', 'comment').attr('placeholder', 'ここに24分頑張った感想をかいてね')
  $('#complete').append($comment)
  
  $file = $('<input />').attr('type', 'file').attr('id', 'file')
  $('#complete').append($file)

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
  $recents = $('<table></table>').addClass('table recents')
  $comments = $("#comments")

  ParseParse.where("Comment", [], (comments) ->
    $('#comment').keypress((e) ->
      if e.which == 13 #enter
        window.comment()
    )
    $comments.html($recents)
    for comment in comments
      @addComment(comment)
    $('#comment').val('')
    $('#comment').focus()
  )

window.finish = () ->
  console.log 'finish'
  @syncWorkload('finish')
  location.reload()

window.comment = () ->
  console.log 'comment'
  $comment = $('#comment')
  $file = $("#file")
  
  body = $comment.val()

  $comment.val('')
  
  return if body.length < 1

  params = {body: body}

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
        syncComment(comment)
      )
    , (error) ->
      # error handling
    )
  else
    ParseParse.create('Comment', params, (comment)->
      syncComment(comment)
    )

initRanking = () ->
  $('#ranking').html('ここにランキング結果が入ります')

@addDoing = (workload) ->
  t = new Date(workload.createdAt)
  end_time = @env.pomotime*60*1000 + t.getTime()
  disp = "#{Util.hourMin(workload.createdAt)}開始（あと<span class='realtime' data-countdown='#{end_time}'></span>）"
  @addWorkload("#doing", workload, disp)

@addChatting = (workload) ->
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
      <a href=\"#{href}\" class='fixed_start btn btn-default'>この曲で集中する</a>
      <hr />
    """
  else
    html = """
      <div class=\"noimage\">無音</div>
      <img class='icon icon_#{user_id}' src='#{userIdToIconUrl(user_id)}' />
      #{disp}<br />
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

@addComment = (comment) ->
  $recents = $('.recents')
  if typeof(comment.attributes) != 'undefined'
    c = comment.attributes
  else
    c = comment
  user = c.user

  t = new Date(comment.createdAt)
  hour = t.getHours()
  min = t.getMinutes()

  if user && c.body
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
      $recents.append(html)
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
      $recents.prepend(html)

userIdToIconUrl = (userId) ->
  localStorage["icon_#{userId}"] || ""

@syncWorkload = (type) ->
  @socket.send({
    type: type
    workload: @workload
  })

syncComment = (comment) ->
  @socket.send({
    type: 'comment'
    comment: comment
  })

@stopUser = (user_id) ->
  $("#chatting .user_#{user_id}").remove()
  $("#doing .user_#{user_id}").remove()

