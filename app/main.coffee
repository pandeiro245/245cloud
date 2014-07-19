$ ->
  init()

init = () ->
  console.log 'init'
  if location.href.match(/^http:\/\/245cloud.com/)
    app_id  = "8QzCMkUbx7TyEApZjDRlhpLQ2OUj0sQWTnkEExod"
    key = "gzlnFfIOoLFQzQ08bU4mxkhAHcSqEok3rox0PBOM"
  else
    app_id  = "FbrNkMgFmJ5QXas2RyRvpg82MakbIA1Bz7C8XXX5"
    key = "yYO5mVgOdcCSiGMyog7vDp2PzTHqukuFGYnZU9wU"
  Parse.initialize(app_id, key)
  localStorage['client_id'] = '2b9312964a1619d99082a76ad2d6d8c6'
  addAccesslog()
  $body = $('body')
  $body.attr(style: 'text-align:center;')

  $body.html('')
  for id in ['header', 'contents', 'doing', 'logs', 'footer']
    $item = $('<div></div>')
    $item.attr('id', id)
    $body.append($item)

  ruffnote(13475, 'header')
  ruffnote(13477, 'footer')

  $("#doing").append("<h2>NOW DOING</h2>")

  ParseParse.all("Twitter", (res) ->
    twitters = {}
    for twitter in res
      twitters[twitter.attributes.twitter_id] = twitter.attributes
    t = new Date((new Date()).getTime() - 24*60*1000)
    cond = [
      ["is_done", null],
      ['host', '245cloud.com'],
      ["createdAt", t, 'greaterThan']
    ]
    ParseParse.where("Workload", cond, (workloads) ->
      for workload in workloads
        w = workload.attributes
        t = new Date(workload.createdAt)
        hour = Util.zero(t.getHours())
        min = Util.zero(t.getMinutes())
        now = new Date()
        diff = 24*60*1000 + t.getTime() - now.getTime()
        $("#doing").append("""
          #{if w.artwork_url then '<img src=\"' + w.artwork_url + '\" />' else '<div style=\"display:inline; border: 1px solid #000; padding:20px; text-align:center; vertical-align:middle;\">no image</div>'}
          <img src=\"#{twitters[w.twitter_id].twitter_image}\" />@#{hour}時#{min}分（あと#{Util.time(diff)}）<br />
          #{w.title} <br />
          <a href=\"##{w.sc_id}\" class='fixed_start btn btn-default'>この曲で集中する</a>
          <hr />
        """)
      $('.fixed_start').click(() ->
        start()
      )
    )
  )

  $("#logs").append("<hr />")
  $("#logs").append("<h2>DONE</h2>")
  ParseParse.all("Twitter", (res) ->
    twitters = {}
    for twitter in res
      twitters[twitter.attributes.twitter_id] = twitter.attributes
    ParseParse.where("Workload", [["is_done", true], ['host', '245cloud.com']], (workloads) ->
      for workload in workloads
        w = workload.attributes
        t = new Date(workload.createdAt)
        hour = Util.zero(t.getHours())
        min = Util.zero(t.getMinutes())
        $("#logs").append("""
          #{if w.artwork_url then '<img src=\"' + w.artwork_url + '\" />' else '<div style=\"display:inline; border: 1px solid #000; padding:20px; text-align:center; vertical-align:middle;\">no image</div>'}
          <img src=\"#{twitters[w.twitter_id].twitter_image}\" />@#{hour}:#{min}<br />
          #{w.title} <br />
          <a href=\"##{w.sc_id}\" class='fixed_start btn btn-default'>この曲で集中する</a>
          <hr />
        """)
      $('.fixed_start').click(() ->
        start()
      )
    )
  )

  if localStorage['twitter_id']
    $start = $('<input>').attr('type', 'submit')
    $start.attr('id', 'start').attr('value', '曲お任せで24分間集中する！！').attr('type', 'submit')
  else
    $start = $('<a></a>').html('Twitterログイン')
    $start.attr('href', '/auth/twitter')
  $start.attr('class', 'btn btn-default')
  $('#contents').html($start)
  $('#start').click(() ->
    start()
  )

start = () ->
  console.log 'start'
  $("#logs").hide()
  $start = $('<div></div>').attr('id', 'playing')
  $('#contents').html($start)
  if localStorage['sc_id'] == location.hash.replace(/#/, '') || location.hash.length < 1
    ParseParse.all("Music", (musics) ->
      n = Math.floor(Math.random() * musics.length)
      sc_id = musics[n].attributes.sc_id
      location.hash = sc_id
      play()
    )
  else
    play()

play = () ->
  console.log 'play'
  localStorage['sc_id'] = location.hash.replace(/#/, '')

  Soundcloud.fetch(localStorage['sc_id'], localStorage['client_id'], (track) ->
    params = {}
    for key in ['sc_id', 'twitter_id']
      params[key] = localStorage[key]
    for key in ['title', 'artwork_url']
      params[key] = track[key]
    params['host'] = location.host
    ParseParse.create("Workload", params, (workload) ->
      window.workload = workload
    )

    localStorage['artwork_url'] = track.artwork_url

    if localStorage['is_dev']
      Util.countDown(3000, complete)
      #Util.countDown(24*60*1000, complete)
    else
      #Util.countDown(track.duration, complete)
      Util.countDown(24*60*1000, complete)

    ap = if localStorage['is_dev'] then 'false' else 'true'
    $("#playing").html("""
    <iframe width="100%" height="400" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?visual=true&url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F#{localStorage['sc_id']}&show_artwork=true&client_id=#{localStorage['client_id']}&auto_play=#{ap}"></iframe>
    """)
  )

complete = () ->
  console.log 'complete'
  window.workload.set('is_done', true)
  window.workload.save()
  localStorage['nishiko_end'] = (new Date()).getTime()

  $note = $('<table></table').attr('id', 'note').addClass('table').attr('style', 'width: 500px; margin: 0 auto;')
  $note.html('24分おつかれさまでした！5分間交換ノートが見られます')

  $recents = $('<div></div>').attr('class', 'recents')
  $note.append($recents)

  Comment = Parse.Object.extend("Comment")
  query = new Parse.Query(Comment)
  query.descending("createdAt")
  query.find({
    success: (comments) ->
      $comment = $('<input />').attr('id', 'comment').attr('style', 'width:100%; display: block;')
      $('#note').append($comment)

      $('#comment').keypress((e) ->
        if e.which == 13 #enter
          body = $('#comment').val()
          window.comment(body)
      )

      for c in comments
        t = new Date(c.createdAt)
        hour = t.getHours()
        min = t.getMinutes()
        $recents.append("<tr>")
        img = c.attributes.twitter_image ||  ""
        $recents.append("<td><img src='#{img}' /><td>")
        $recents.append("<td>#{Util.parseHttp(c.attributes.body)}</td>")
        $recents.append("<td>#{hour}時#{min}分</td>")
        $recents.append("</tr>")
      $('#note').append($recents)
  })

  $('#contents').attr(style: 'text-align:center;')
  $('#contents').html($note)

  $track = $("<input />").attr('id', 'track')
  $tracks = $("<div></div>").attr('id', 'tracks')

  $('#contents').append("<hr /><h3>好きなパワーソングを探す</h3>")
  $('#contents').append($track)
  $('#contents').append($tracks)

  $('#track').keypress((e) ->
    if e.which == 13 #enter
      q = $('#track').val()
      url = "http://api.soundcloud.com/tracks.json?client_id=#{localStorage['client_id']}&q=#{q}&duration[from]=#{19*60*1000}&duration[to]=#{24*60*1000}"
      $.get(url, (tracks) ->
        if tracks[0]
          for track in tracks
            artwork = ''
            if track.artwork_url
              artwork = "<img src=\"#{track.artwork_url}\" width=100px/>"

            $('#tracks').append("""
              <tr>
                <td><a href=\"##{track.id}\">#{track.title}</a></td>
                <td>#{artwork}</td>
                <td>#{Util.time(track.duration)}</td>
              </tr>
            """)
        else
          alert "「#{q}」で24分前後の曲はまだ出てないようです...。他のキーワードで探してみてください！"
      )
  )

  Util.countDown(5*60*1000, 'finish')

window.finish = () ->
  console.log 'finish'
  localStorage.removeItem('nishiko_end')
  location.reload()

window.comment = (body) ->
  console.log 'comment'
  params = {body: body}
  for key in ['twitter_id', 'twitter_nickname', 'twitter_image', 'sc_id', 'artwork_url']
    params[key] = localStorage[key]
  ParseParse.create('Comment', params)
  $recents = $('#note .recents')
  t = new Date()
  hour = t.getHours()
  min = t.getMinutes()

  $tr = $('<tr></tr>')

  img = localStorage['twitter_image']
  $tr.append("<td><img src='#{img}' /><td>")
  $tr.append("<td>#{Util.parseHttp(body)}</td>")
  $tr.append("<td>#{hour}時#{min}分</td>")

  $recents.prepend($tr)

  $('#comment').val('')

ruffnote = (id, dom) ->
  console.log 'ruffnote'
  Ruffnote.fetch("pandeiro245/245cloud/#{id}", dom)

addAccesslog = () ->
  console.log 'addAccesslog'
  ParseParse.create('Accesslog',
    Util.addTwitterInfo({
      url: location.href
    })
  )
