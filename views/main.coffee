$ ->
  ParseParse.addAccesslog()
  Util.scaffolds(['header', 'contents', 'doing', 'done', 'playing', 'complete', 'comments', 'ranking', 'search', 'music_ranking', 'footer'])
  # Ruffnoteがslugに対応してくれればここの分岐は不要になるはず
  if location.href.match(/245cloud-c9-pandeiro245.c9.io/)
    ruffnote(17011, 'header')
    ruffnote(17013, 'footer')
    ruffnote(17315, 'music_ranking')
  else
    ruffnote(13475, 'header')
    ruffnote(13477, 'footer')
    ruffnote(17314, 'music_ranking')

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

initDoing = () ->
  console.log 'initDoing'
  cond = [
    ["is_done", null]
    ["createdAt", '>', Util.minAgo(@env.pomotime)]
  ]
  ParseParse.where("Workload", cond, (workloads) ->
    return unless workloads.length > 0
    $("#doing").append("<h2>NOW DOING</h2>")

    for workload in workloads
      continue unless workload.attributes.user
      t = new Date(workload.createdAt)
      i = Util.monthDay(workload.createdAt)
      now = new Date()
      diff = @env.pomotime*60*1000 + t.getTime() - now.getTime()

      disp = "#{Util.hourMin(workload.createdAt)}開始（あと#{Util.time(diff)}）"
      addWorkload("#doing", workload, disp)
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
      disp = "#{workload.attributes.number}回目@#{Util.hourMin(workload.createdAt)}"
      addWorkload("#done", workload, disp)
    initFixedStart()
  )
  
login = () ->
  console.log 'login'
  window.fbAsyncInit()

start_random = () ->
  console.log 'start_random'
  start()
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
  start()

start_nomusic = () ->
  console.log 'start_nomusic'
  params = {host: location.host}
  ParseParse.create("Workload", params, (workload) ->
    @workload = workload
  )
  start()
  
start = () ->
  console.log 'start'
  $("#done").hide()
  $("#doing").hide()
  $("input").hide()
  $("#music_ranking").hide()
  @isDoing = true
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
      )
      Youtube.play(id, $("#playing"), !localStorage['is_dev'])
    )
    
complete = () ->
  console.log 'complete'
  @isDoing = false
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
  if localStorage['is_dev']
    #Util.countDown(10*1000, 'finish')
    Util.countDown(5*60*1000, 'finish')
  else
    Util.countDown(5*60*1000, 'finish')

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
      ParseParse.create('Comment', params, ()->
        $file.val(null)
        comment['icon_url'] = Parse.User.current().attributes.icon_url
        @socket.send(comment)
      )
    , (error) ->
      # error handling
    )
  else
    ParseParse.create('Comment', params, (comment)->
      icon_url = Parse.User.current().attributes.icon_url
      @socket.send({
        type: 'comment'
        comment: comment
        icon_url: icon_url
      })
    )

initRanking = () ->
  $('#ranking').html('ここにランキング結果が入ります')

addWorkload = (dom, workload, disp) ->
  w = workload.attributes
  if w.title
    href = '#'
    if w.sc_id
      href += "soundcloud:#{w.sc_id}"
    if w.yt_id
      href += "youtube:#{w.yt_id}"
    
    $("#{dom}").append("""
      #{if w.artwork_url then '<img src=\"' + w.artwork_url + '\" />' else '<div class="noimage">no image</div>'}
      <img class='icon icon_#{w.user.id}' />
      #{disp}<br />
      #{w.title} <br />
      <a href=\"#{href}\" class='fixed_start btn btn-default'>この曲で集中する</a>
      <hr />
    """)
  else
    $("#{dom}").append("""
      <div class=\"noimage\">無音</div>
      <img class='icon icon_#{w.user.id}' />
      #{disp}<br />
      無音
      <hr />
    """)

    # FIXME
    ParseParse.fetch("user", workload, (workload, user) ->
      img = user.get('icon_url') || user.get('icon')._url
      $(".icon_#{user.id}").attr('src', img)
    )

initFixedStart = () ->
  $('.fixed_start').click(() ->
    if Parse.User.current()
      start()
      play($(this).attr('href').replace(/^#/, ''))
    else
      alert 'Facebookログインをお願いします！'
  )

ruffnote = (id, dom) ->
  if location.href.match(/245cloud-c9-pandeiro245.c9.io/)
    Ruffnote.fetch("pandeiro245/1269/#{id}", dom)
  else
    Ruffnote.fetch("pandeiro245/245cloud/#{id}", dom)

@addComment = (comment, icon_url = null) ->
  console.log comment

  $recents = $('.recents')
  if typeof(comment.attributes) != 'undefined'
    c = comment.attributes
    src = ''
  else
    c = comment
    src = "src ='#{icon_url}'"
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
    <img class='icon icon_#{user.id}' #{src} />
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

