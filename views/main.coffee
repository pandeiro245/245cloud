$ ->
  ParseParse.addAccesslog()
  Util.scaffolds(['header', 'contents', 'doing', 'done', 'playing', 'complete', 'comments', 'search', 'footer'])
  ruffnote(13475, 'header')
  ruffnote(13477, 'footer')
  initDoing()
  initDone()
  initStart()
  

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
  cond = [
    ["is_done", null]
    ["createdAt", '>', Util.minAgo(@env.pomotime)]
  ]
  ParseParse.where("Workload", cond, (workloads) ->
    if workloads.length > 0
      $("#doing").append("<h2>NOW DOING</h2>")

      for workload in workloads
        continue unless workload.attributes.user
        w = workload.attributes
        t = new Date(workload.createdAt)
        i = Util.monthDay(workload.createdAt)
        now = new Date()
        diff = @env.pomotime*60*1000 + t.getTime() - now.getTime()
        
        if w.title
          href = '#'
          if w.sc_id
            href += "soundcloud:#{w.sc_id}"
          if w.yt_id
            href += "youtube:#{w.yt_id}"
          $("#doing").append("""
            #{if w.artwork_url then '<img src=\"' + w.artwork_url + '\" />' else '<div class=\"noimage\">no image</div>'}
            <img class='icon icon_#{w.user.id}' />
            @#{Util.hourMin(workload.createdAt)}（あと#{Util.time(diff)}）<br />
            #{w.title} <br />
            <a href=\"#{href}\" class='fixed_start btn btn-default'>この曲で集中する</a>
            <hr />
          """)
        else
          $("#doing").append("""
            <div class=\"noimage\">無音</div>
            <img class='icon icon_#{w.user.id}' />
            @#{Util.hourMin(workload.createdAt)}（あと#{Util.time(diff)}）<br />
            無音
            <hr />
          """)
        ParseParse.fetch("user", workload, (workload, user) ->
          img = user.get('icon_url') || user.get('icon')._url
          $(".icon_#{user.id}").attr('src', img)
        )
    )

initDone = () ->
  console.log 'initDone'
  $("#done").append("<hr />")
  $("#done").append("<h2>DONE</h2>")
  cond = [["is_done", true]]
  ParseParse.where("Workload", cond, (workloads) ->
    date = ""
    for workload in workloads
      continue unless workload.attributes.user
      w = workload.attributes
      i = Util.monthDay(workload.createdAt)
      if date != i
        $("#done").append("<h2>#{i}</h2>")
      date = i
      
      if w.title
        href = '#'
        if w.sc_id
          href += "soundcloud:#{w.sc_id}"
        if w.yt_id
          href += "youtube:#{w.yt_id}"
        
        $("#done").append("""
          #{if w.artwork_url then '<img src=\"' + w.artwork_url + '\" />' else '<div class="noimage">no image</div>'}
          <img class='icon icon_#{w.user.id}' />
          <span id=\"workload_#{workload.id}\">#{w.number}</span>回目@#{Util.hourMin(workload.createdAt)}<br />
          #{w.title} <br />
          <a href=\"#{href}\" class='fixed_start btn btn-default'>この曲で集中する</a>
          <hr />
        """)
      else
        $("#done").append("""
          <div class=\"noimage\">無音</div>
          <img class='icon icon_#{w.user.id}' />
          <span id=\"workload_#{workload.id}\">#{w.number}</span>回目@#{Util.hourMin(workload.createdAt)}<br />
          無音
          <hr />
        """)        

      ParseParse.fetch("user", workload, (workload, user) ->
        img = user.get('icon_url') || user.get('icon')._url
        $(".icon_#{user.id}").attr('src', img)
      )

    $('.fixed_start').click(() ->
      if Parse.User.current()
        start()
        play($(this).attr('href').replace(/^#/, ''))
      else
        alert 'Facebookログインをお願いします！'
    )
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
  
start_hash = () ->
  console.log 'start_hash'
  play(location.hash.replace(/#/, ''))
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
  $("input").hide()
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
    Util.countDown(10*1000, 'finish')
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
    for comment in comments
      c = comment.attributes
      t = new Date(comment.createdAt)
      hour = t.getHours()
      min = t.getMinutes()

      if c.user && c.body
        if c.file
          console.log c.file
          file = "<img src=\"#{c.file._url}\" style='max-width: 500px;'/>"
        else
          file = "" 
        $recents.append("""
        <tr>
        <td>
        <a class='facebook_#{c.user.id}' target='_blank'>
        <img class='icon icon_#{c.user.id}' />
        <div class='facebook_name_#{c.user.id}'></div>
        </a>
        <td>
        <td>#{Util.parseHttp(c.body)}#{file}</td>
        <td>#{hour}時#{min}分</td>
        </tr>
        """)

        ParseParse.fetch("user", comment, (comment, user) ->
          img = user.get('icon_url') || user.get('icon')._url
          $(".icon_#{user.id}").attr('src', img)
          href = "https://facebook.com/#{user.get('authData').facebook.id}"
          $(".facebook_#{user.id}").attr('href', href)
          name = user.get('name')
          $(".facebook_name_#{user.id}").html(name)
        )
    $comments.html($recents)
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
        initComments()
      )
    , (error) ->
      # error handling
    )
  else
    ParseParse.create('Comment', params, ()->
      initComments()
    )

ruffnote = (id, dom) ->
  Ruffnote.fetch("pandeiro245/245cloud/#{id}", dom)
