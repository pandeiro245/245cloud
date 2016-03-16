@ruffnoteAttachment = (id, id2=null) ->
  Ruffnote.attachment(id, id2)

@env.is_doing = false
@env.is_done = false
@nomusic_url = @ruffnoteAttachment(24985)

$ ->
  $.post('/api/access_logs', {url: location.href})
  return unless $('#nc').length
  scaffolds = Util.scaffolds('''
  header:no_row&stay news otukare:hidden&stay
  ad:stay contents:stay
  settings:init
  timecrowd toggl nortification heatmap:init start_buttons
  doing_title:stay doing:init&stay
  chatting_title:stay chatting:init:stay
  done_title done:init
  you_title you:init calendar_title calendar
  search_title search:init
  playing:stay complete:stay select_rooms:stay
  rooms_title:stay rooms:stay
  whatis_title whatis:no_row
  wantedly:stay footer hatopoppo:init&stay
  ''')
  #ranking_title ranking:init
  #8tracks_title 8tracks:init
  #kimiya_title kimiya:init
  #naotake_title naotake:init
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
  initTimecrowd() if window.settings.timecrowd
  initToggl() if location.href.match(/toggl=/)
  initNortification() if location.href.match(/notification=/)
  initFixedStart()
 
initSettings = () ->
  for key of window.settings
    continue unless key in ['alert', 'timecrowd']
    $('#settings').append("<div><a href='/?cancel=#{key}'>#{key}をやめる</a></div>")

initNortification = () ->
  if window.facebook_id
    if !Notify.needsPermission || Notify.isSupported()
      $('#nortification').html("""
        <input id="show-nortification" type="checkbox" style="display:inline">
        <label for="show-nortification"> デスクトップ通知を利用する</label>
      """)
      
      # チェック時に通知の許可要求
      $('#show-nortification').on('change', () ->
        if $(this).prop('checked') && Notify.needsPermission
          Notify.requestPermission(() ->
            # 成功時(何もしない)
            console.log('nortification permitted')
          , () ->
            # 失敗時はcheckboxを元に戻す
            $(this).prop('checked', false)
          )
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

initTimecrowd = () ->
  console.log 'initTimecrowd'
  $('#timecrowd').html("""
  <h2>TimeCrowd</h2>
  <div style='display:none; width:100%; text-align:center;'><input placeholder='タスク追加' style='width:100%;' id='timecrowd_add_task'/></div>
  <ul><li class='loading'>ローディング中。。。<br>（タスクが多いと時間がかかるかもです…。）</li></ul>
  <table class='table table-bordered table-hover' id='timecrowd_select_task'>
  </table>
  """)
  $('#timecrowd_add_task').keypress((e) ->
    if e.which == 13 #enter
      alert $('#timecrowd_add_task').val()
  )
  $.get('/timecrowd/recents', (data) ->
    console.log 'GET /timecrowd/recents', data
    $('.loading').remove()
    if data.status == 'ng'
      $('#timecrowd ul').html("""
      <a href='/auth/timecrowd'>ログイン</a>
      """)
    else
      task_ids = {}
      if data.is_working
        working_entry = data.entries[0]
        task_ids[working_entry.task.id] = true
        $('#timecrowd table').append(entryItem(working_entry))
      for entry in data.entries
        continue if working_entry && entry.id == working_entry.id
        continue if task_ids[entry.task.id]
        task_ids[entry.task.id] = true
        $('#timecrowd table').append(entryItem(entry))

      $('#timecrowd table tr:first input').attr('checked', 'checked')
      $('#timecrowd table tr').click((e) ->
        console.log e
        $('#timecrowd table input').removeAttr('checked')
        $(e.currentTarget).find('input').prop('checked', true)
      )
  )

initToggl = () ->
  console.log 'initToggl'
  $('#toggl').html("""
  <h2>Toggl</h2>
  <div id='toggl_description'></div>
  """)
  ruffnote(24715, 'toggl_description')

entryItem = (entry) ->
  """
    <tr>
      <label>
      <td><input type='radio' name='timecrowd_task' data-team-id='#{entry.task.team_id}' value='#{entry.task.id}' /></td>
      <td><a href='#{entry.task.url}' target='_blank'>#{entry.task.title}</a></td>
      <td>#{Util.time(entry.started_at)}</td>
      </label>
    </tr>
  """


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
  if location.href.match(/sparta/)
    Util.countDown(1*60*1000, start_unless_doing)
  if location.href.match(/auto_start=/)
    start_unless_doing()

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

    text = @ruffnoteAttachment(24919, 24920)
    tooltip = '現在はSoundcloudの人気曲からランダム再生ですが今後もっと賢くなっていくはず'
    $random = $('#start_buttons #random')
    imgurl = @ruffnoteAttachment(24982)
    $random.html("""<h5>おまかせ</h5>
      <img src=\"#{imgurl}\" class='jacket'/>
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
    if location.hash.match(/8tracks/)
      EightTracks.fetch(id, @env.et_client_id, (track) ->
        renderFixedStart(
          track.mix.name,
          artworkUrlWithNoimage(track.mix.cover_urls.sq100)
        )
      )

    text = @ruffnoteAttachment(24926, 24927)
    tooltip = '無音ですが終了直前にはとぽっぽが鳴ります'
    $nomusic = $('#start_buttons #nomusic')

    $nomusic.html('<h5>無音</h5>')
    imgurl = @ruffnoteAttachment(24981)
    $nomusic.append(Util.tag('img', imgurl, {class: 'jacket'}))
    Util.addButton('start', $nomusic, text, start_nomusic)

  else
    text = 'facebookログイン'
    Util.addButton('login', $('#contents'), text, login)

initSearch = () ->
  $track = $("<input />").attr('id', 'track').attr('placeholder', 'ここにアーティスト名や曲名を入れてね')
  localStorage['search_music_title'] = '作業BGM' unless localStorage['search_music_title']

  $tracks = $("<div></div>").attr('id', 'tracks')

  $('#search').append($track)
  $('#search').append($tracks)

  $('#search input').focus(() ->
    $(this).select()
  )
  $('#search input').focus()

  $('#track').keypress((e) ->
    if e.which == 13 #enter
      searchMusics()
  )

@initSelectRooms = () ->
  console.log 'initSelectRooms'
  imgurl = @ruffnoteAttachment(24968)
  $('#rooms_title').html(Util.tag('h2', Util.tag('img', imgurl), {class: 'status'}))
  imgurl = @ruffnoteAttachment(24967)
  $('#select_rooms').html(Util.tag('h2', Util.tag('img', imgurl), {class: 'status'}))
  $('#select_rooms').append(Util.tag('div', null, {class: 'imgs'}))

  $.get('/api/comments', (rooms) ->
    for room in rooms
      link = "<a style='margin: 5px;' href='#' class='room_link' data-values=\"#{room.id}:#{room.body}\">#{room.body}</a>"
      $('#select_rooms').append(link)

    $(document).on('click', ".room_link", (e) ->
      e.preventDefault()
      
      $self = $(this)
      vals = $self.attr('data-values').split(':')
      initRoom(vals[0], vals[1])
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
    for workload in workloads
      window.addDoing(workload)
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
  $.post('/api/workloads', params, (workload) ->
    window.workload = workload
    callback()
  )

start = () ->
  console.log 'start'
  if window.settings.timecrowd
    task_id = $("input[name='timecrowd_task']:checked").val()
    team_id = $("input[name='timecrowd_task']:checked").attr('data-team-id')
    params = {
      team_id: team_id
      task_id: task_id
    }
    $.post('/timecrowd/start', params)
  if location.href.match(/toggl=/)
    postWithToken('/toggl/start', 'toggl_token')

  for div in $("#nc div.scaffold")
    $(div).hide() unless $(div).attr('id') in window.stays
  $("input").hide()

  @env.is_doing = true
  @syncWorkload('doing')
  
  if @env.is_kakuhen
    initComments()
    @initSelectRooms()

  Util.countDown(@env.pomotime*60*1000, complete)

window.youtubeDurationSec = (key)  ->
  duration = key['contentDetails']['duration'].replace(/^PT/, '').replace(/S$/, '')

  console.log duration
  if duration.match(/H/)
    hour = parseInt(duration.split('H')[0])
    d2 = duration.split('H')[1]
  else
    hour = 0
    d2 = duration
  min = parseInt(d2.split('M')[0])
  sec = parseInt(d2.split('M')[1])
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
  if key.match(/^8tracks/)
    EightTracks.fetch(id, @env.et_client_id, (track) ->
      params['music_key'] = "8tracks:#{id}"
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


postWithToken = (url, key, is_again=false) ->
  console.log 'is_again', is_again
  if is_again
    token = prompt('Toggl API keyが無効のようです。再度入力してください', '')
    localStorage[key] = token
  unless token = localStorage[key]
    token = prompt('TogglのAPI keyを入力してください', '')
    localStorage[key] = token
  $.post(url, {token: token}).done((data)->
    console.log(data) 
  ).fail(()->
    postWithToken(url, key, true)
  )

complete = () ->
  console.log 'complete'
  if window.settings.timecrowd
    $.post('/timecrowd/stop')
  if location.href.match(/toggl=/)
    postWithToken('/toggl/stop', 'toggl_token')

  @syncWorkload('chatting')
  window.is_hato = false
  Util.countDown(@env.chattime*60*1000, 'finish')
  $('#header').hide()
  $('#otukare').fadeIn()
  $("#playing").fadeOut()
  $("#search").fadeOut()
  $("#playing").html('') # for stopping
  initWantedly()
  unless @env.is_kakuhen
    @initSelectRooms()

  alert '24分間お疲れ様でした！5分間交換日記ができます☆' if window.settings.alert unless @env.is_done

  @env.is_doing = false
  @env.is_done = true

  if location.href.match("gohobi_youtube=") and !$('#ad iframe').length
    url = "https://www.youtube.com/embed/#{location.href.split('gohobi_youtube=')[1].replace(/&.*$/,'').replace(/#.*$/,'')}?autoplay=1"
    $('#ad').html(
      """
      <h2>ご褒美動画です☆</h2>
      <iframe width=\"560\" height=\"315\" src=\"#{url}\" frameborder=\"0\" allowfullscreen></iframe>
      """
    )
  else if location.href.match("ad=") and !$('#ad iframe').length
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

  $.get('/api/complete')

  $complete = $('#complete')
  $complete.html('')
  initComments()
  
  # nortification
  if $('#show-nortification').prop('checked')
    new Notify('作業時間が終了しました！', {
      body: '245cloud'
      icon: '//placehold.jp/100x100.png'
    }).show()

window.initWantedly = () ->
  companies = [
    [
      '245cloud mix作者のkimiyaさんをはじめ、コアユーザの菊本さん、瀬川さん等々が率いる技術者集団'
      33589
      'スタテク'
      'H77rEIjYFdS8X0dyRnohdA'
      'https://i.gyazo.com/e33c7a589df67ea5e68a5b9dec74df3d.png'
    ]
    [
      '245cloudを作っている西小倉が働く'
      29075
      'ラフノート'
      'b3umDS_P10Avjbmwv-1ldA'
      'https://i.gyazo.com/e72ff20360920ff26dab3dde6155bb1c.png'
    ]
    [
      'この245cloudはホトスタの香月さんと西小倉の2人でポモドーロする会からスタートしました。社長のハッシーもコアユーザ'
      6683
      'ホトスタ'
      'CJm45IwYynMvPdaLRvUESg'
      'https://i.gyazo.com/8218576144d00615a898433f3a61f9f3.png'
    ]
    [
      '累計ポモ数ダントツ１位のはらぱんさんのRubyアジャイルな会社'
      20027
      'mofmof'
      'r0P3mUnqLLLrOnFazuo1aQ'
      'https://i.gyazo.com/b33f22cfe8b883a5d8b1cbc2f691ee3a.png'
    ]
    [
      'エンジニアの今さんも伊藤さんも245cloudユーザ☆'
      27659
      'ベストティーチャー'
      '_6Z51YeGo0gOplv7iHbimw'
      'https://i.gyazo.com/ea0a709fb5a6215021809e04eb147dcd.png'

    ]
  ]
  n = Math.floor(Math.random() * companies.length)
  company = companies[n]
  $('#wantedly').html("""
  【試験的宣伝】<br/>
  正常動作しない場合は<a href='https://www.facebook.com/pandeiro245' target='_blank'>西小倉</a>までご連絡ください！<br>
  <a href='https://github.com/pandeiro245/245cloud/issues/138' target='_blank'>ここから</a>貼り付けコードを発行して共有頂ければ西小倉による紹介文付きで追加させて頂きます！<br>
  （もちろん無料っすけど誰かに怒られたりしたら突然消えますｗ）<br/><br/>
  <img src='#{company[4]}' width='500px'/>
  <br/>
  #{company[0]}<br>
  「<a href='https://www.wantedly.com/projects/#{company[1]}' target='_blank'>#{company[2]}</a>」の話を聞いてみませんか？<br />
  <div class="wantedly-visit-button" data-visit-button-id="#{company[3]}" data-width="270" data-height="60"></div>
  </div>
  """)
 
  d = document
  s = 'script'
  id = 'wantedly-visit-buttons-wjs'
  fjs = d.getElementsByTagName(s)[0]
  if d.getElementById(id)
    return
  js = d.createElement(s)
  js.id = id
  js.src = 'https://platform.wantedly.com/visit_buttons/script.js'
  fjs.parentNode.insertBefore js, fjs

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
          window.createComment(id)
      )
      for comment in comments
        window.addComment(id, comment)
    )

window.finish = () ->
  console.log 'finish'
  @syncWorkload('finish')
  
  # nortification
  if $('#show-nortification').prop('checked')
    new Notify('休憩時間が終了しました！', {
      body: '245cloud'
      icon: '//placehold.jp/100x100.png'
    }).show()
  
  if location.href.match(/auto_close=/)
    window.open(location, '_self', '')
    window.close()
  else
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
    syncComment(room_id, comment)
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
  provider_icon = ''
  w = workload
  facebook_id = w.facebook_id
  if w.music_key
    title = w.title
    href = "##{workload.music_key}"
    imgurl = @ruffnoteAttachment(24921)
    fixed = "<a href=\"#{href}\" class='fixed_start'><img src='#{imgurl}' /></a>"
    icon = w.artwork_url
    jacket = "#{if icon then '<img src=\"' + icon + '\" class=\"jacket\" />' else "<img src=\"#{@nomusic_url}\" class=\"jacket\" />"}"
    jacket = "<a href='/musics/#{w.music_key.replace(':', '/')}'>#{jacket}</a>" if w.music_key
    provider = w.music_key.split(':')[0]
    icon_name = if provider == 'nicovideo' then 'television'  else provider
    unless provider == '8tracks'
      provider_icon = "<i class='fa fa-#{icon_name}' title='#{provider}' data-toggle='tooltip' data-placement='top' ></i>"
  else
    title = '無音'
    imgurl = @ruffnoteAttachment(24926)
    fixed = "<a href=\"#\" class='fixed_start'><img src='#{imgurl}' /></a>"
    imgurl = @ruffnoteAttachment(24981)
    jacket = "<img src=\"#{imgurl}\" class='jacket'/>"
  user_img = "<a href='/#{workload.facebook_id}'><img class='icon img-thumbnail' src='#{facebookIcon(workload.facebook_id)}' /></a>"

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
  unless dom == '#done'
    $("#chatting .facebook_#{facebook_id}").remove()
    $("#doing .facebook_#{facebook_id}").remove()

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
      window.fbAsyncInit()
  )
  $(document).on('click', '.add_playlist', () ->
    alert 'プレイリストに追加する機能は現在開発中です。。。'
  )


window.ruffnote = (id, dom, callback=null) ->
  Ruffnote.fetch("pandeiro245/245cloud/#{id}", dom, callback)

initService = ($dom, url) ->
  $dom.append("<iframe src='#{url}' width='85%' height='900px'></iframe>")

@addComment = (room_id, comment) ->
  $comments = $("#room_#{room_id} .comments")
  c = comment

  if c.body
    img = facebookIcon(c.facebook_id)
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

@syncWorkload = (type) ->
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

@stopUser = (facebook_id) ->
  $("#chatting .user_#{facebook_id}").remove()
  if $("#chatting div").length < 1
    $("#chatting_title").hide()
  $("#doing .user_#{facebook_id}").remove()
  if $("#doing div").length < 1
    $("#doing_title").hide()

searchMusics = () ->
  q = $('#track').val()
  return if q.length < 1
  $('#tracks').html('')
  localStorage['search_music_title'] = q

  $tracks = $('#tracks')
 

  Youtube.search(q, $tracks, initTooltip)
  Nicovideo.search(q, $tracks, initTooltip)
  Soundcloud.search(q, @env.sc_client_id, $tracks, initTooltip)
  Mixcloud.search(q, $tracks, initTooltip)
  #EightTracks.search(q, $tracks)

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

start_unless_doing = ()->
  unless ( @env.is_doing or @env.is_done)
    start_hash()

artworkUrlWithNoimage = (artwork_url) ->
  artwork_url || @nomusic_url

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
  fixed_text = @ruffnoteAttachment(24921, 24922)
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

facebookIcon = (facebook_id) ->
  if false
    "https://graph.facebook.com/#{facebook_id}/picture?height=40&width=40"
  else
    "/ruffnotes?facebook_id=#{facebook_id}"

