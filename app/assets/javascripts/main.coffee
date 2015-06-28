@env.is_doing = false
@env.is_done = false
window.workload = null

@nomusic_url = 'https://ruffnote.com/attachments/24985'

$ ->
  Util.scaffolds([
    ['header', {is_row: false}]
    'news'
    ['otukare', {is_hide: true}]
    'ad'
    'contents'
    'timecrowd'
    'heatmap'
    'start_buttons'
    'doing_title'
    'doing'
    'chatting_title'
    'chatting'
    'done'
    'you_title'
    'you'
    'search_title'
    'search'
    'ranking_title'
    'ranking'
    '8tracks_title'
    '8tracks'
    'kimiya_title'
    'kimiya'
    'naotake_title'
    'naotake'
    'playing'
    'complete'
    'select_rooms'
    'rooms_title'
    'rooms'
    'whatis_title'
    ['whatis', {is_row: false}]
    'wantedly'
    'footer'
    'hatopoppo'
  ])
  Util.realtime()
  #ruffnote(13475, 'header')
  ruffnote(23854, 'header')
  ruffnote(18004, 'news')
  ruffnote(13477, 'footer')
  ruffnote(17758, 'search_title')
  #ruffnote(17762, 'ranking_title')
  ruffnote(17498, 'otukare')
  ruffnote(17762, 'ranking_title')
  initSearch()
  init8tracks()
  initTimecrowd() if location.href.match(/timecrowd=/)
  initHeatmap()
  #initChatting()
  initStart()
  initFixedStart()
  initHatopoppo()
  #initYou()
 
  $('#selectRoomButton').hide()
  
initHeatmap = () ->
  return unless Parse.User.current()
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
      ParseParse.where('Workload', [
        ['is_done', true]
        ['user', Parse.User.current()]
        ['createdAt', '>', startDate]
      ], (workloads) ->
        pomos = {}
        for i in [0...workloads.length]
          pomos[+workloads[i].createdAt / 1000] = 1
        cal.update(pomos)
        cal.options.data = pomos
      , null, 99999)
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
        continue if !entry.task.url.match(/github.com/) and !entry.task.url.match(/trello.com/) and !entry.task.url.match(/cybozu.com/) 
        task_ids[entry.task.id] = true
        $('#timecrowd table').append(entryItem(entry))

      $('#timecrowd table tr:first input').attr('checked', 'checked')
      $('#timecrowd table tr').click((e) ->
        console.log e
        $('#timecrowd table input').removeAttr('checked')
        $(e.currentTarget).find('input').prop('checked', true)
      )
  )

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
  if location.href.match(/auto_start=/)
    start_unless_doing()

  text = "24分やり直しでも大丈夫ですか？"
  Util.beforeunload(text, 'env.is_doing')
initSearch = () ->
  $('#track').keypress((e) ->
    if e.which == 13 #enter
      searchMusics()
  )

@initSelectRooms = () ->
  console.log 'initSelectRooms'
  $('#rooms_title').html(Util.tag('h2', Util.tag('img', 'https://ruffnote.com/attachments/24968'), {class: 'status'}))
  $('#select_rooms').html(Util.tag('h2', Util.tag('img', 'https://ruffnote.com/attachments/24967'), {class: 'status'}))
  $('#select_rooms').append(Util.tag('div', null, {class: 'imgs'}))

  $.get('/rooms.json', (rooms) ->
    $('#select_rooms .imgs').html('')

    # いつも部屋
    on2= 'https://ruffnote.com/attachments/24831'
    off2= 'https://ruffnote.com/attachments/24832'
    $img = Util.tag('img', on2)
    $img.attr('data-values', "0:いつもの部屋")
    $img.tooltip({title: 'いつもの部屋はログが流れやすいよ', placement: 'bottom'})
    $img.addClass('col-sm-2 room_icon room_link')
    $img.addClass('on')
    $img.css('cursor', 'pointer')
    $img.attr('data-on', "#{on2}")
    $img.attr('data-off', "#{off2}")
    $('#select_rooms .imgs').append($img)

    $('.modal-body').html('')

    # DB部屋
    unread_count = 0 #TODO
    for room in rooms
      r = room
      room_id = room.id
      total_count = r.comments_count
      if r.img_on
        on2= r.img_on
        off2= r.img_off
        $img = Util.tag('img', off2)
        $img.attr('data-values', "#{room_id}:#{r.title}")
        $img.tooltip({title: "未読数：#{unread_count} / 投稿数：#{total_count}", placement: 'bottom'})
        $img.addClass('col-sm-2 room_icon room_link')
        $img.css('cursor', 'pointer')
        $img.attr('data-on', "#{on2}")
        $img.attr('data-off', "#{off2}")
        $('#select_rooms .imgs').append($img)
      else
        $('.modal-body').append(
          "<a class='room_link' style='cursor: pointer; display:block;'  data-values=\"#{room.id}:#{room.title}\">#{room.title} (#{unread_count}/#{total_count})</option>"
        )
      
    #  その他
    on2= 'https://ruffnote.com/attachments/24855'
    off2= 'https://ruffnote.com/attachments/24854'
    $img = Util.tag('img', off2)
    $img.tooltip({title: 'その他の部屋を見たい場合はここをクリックしてね', placement: 'bottom'})
    $img.addClass('col-sm-2')
    $img.addClass('room_icon sonota room_link')
    $img.css('cursor', 'pointer')
    $img.attr('data-toggle', 'modal')
    $img.attr('data-target', '#selectRoomModal')
    $img.attr('data-on', "#{on2}")
    $img.attr('data-off', "#{off2}")

    $('#select_rooms .imgs').append($img)

    $(document).on('click', ".room_link", () ->
      $self = $(this)

      # 画像部屋を押したらその部屋だけ開くようにする
      if $self.hasClass('room_icon')
        for i in $('.on')
          $(i).attr('src', $(i).attr('data-off'))
          $(i).removeClass('on')
        $self.addClass('on')
        $self.attr('src', $self.attr('data-on'))

      # 押したのがその他だったらモーダルを開く
      if $self.hasClass('sonota')
        if $('#selectRoomModal').attr('style').match(/hidden/)
          $('#selectRoomButton').click()
      # そうでなければその部屋を開いてモーダルを閉じる
      else
        vals = $self.attr('data-values').split(':')
        initRoom(vals[0], vals[1])
        $('.modal-header .close').click()
    )

    $(document).on('mouseover', ".room_icon", () ->
      $self = $(this)
      $self.attr('src', $self.attr('data-on'))
    )

    $(document).on('mouseout', ".room_icon", () ->
      $self = $(this)
      unless $self.hasClass('on')
        $self.attr('src', $self.attr('data-off'))
    )
  )
 
complete = () ->
  console.log 'complete'
  if location.href.match(/timecrowd=/)
    $.get('/timecrowd/stop')

  @syncWorkload('chatting')
  window.is_hato = false
  Util.countDown(@env.chattime*60*1000, 'finish')
  $('#header').hide()
  $('#otukare').fadeIn()
  $("#playing").fadeOut()
  $("#search").fadeOut()
  $("#playing").html('') # for stopping
  initWantedly()
  ruffnote(23777, 'livechat')
  unless @env.is_kakuhen
    @initSelectRooms()

  alert '24分間お疲れ様でした！5分間交換日記ができます☆' if location.href.match('alert') unless @env.is_done

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
    $.get('/ads/random.json', (ad) ->
      $('#ad').html(
        """
        <h2><a href=\"#{ad.click_url}?from=245cloud.com\" target=\"_blank\">#{ad.name}</a></h2>
        <iframe width=\"560\" height=\"315\" src=\"#{ad.movie_url}\" frameborder=\"0\" allowfullscreen></iframe>
        """
      )
    )

  $.ajax({
    type: 'PUT',
    url: "/workloads/#{window.workload.id}/complete"
  })

  $complete = $('#complete')
  $complete.html('')
  initComments()

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

window.initRoom = (id = 0, title='いつもの部屋') ->
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
    
    limit = if id == 0 then 100 else 10000

    $.get("/rooms/#{id}/comments.json", (comments) ->
      $(document).on('keypress', "#room_#{id} .create_comment", (e) ->
        if e.which == 13 #enter
          window.createComment(id)
      )
      for comment in comments
        window.addComment(id, comment)
      return
    )

window.finish = () ->
  console.log 'finish'
  @syncWorkload('finish')
  if location.href.match(/auto_close=/)
    window.open(location, '_self', '')
    window.close()
  else
    location.reload()

window.createComment = (room_id) ->
  console.log 'createComment'
  $createComment = $("#room_#{room_id} .create_comment")
  
  content = $createComment.val()

  $createComment.val('')
  
  return if content.length < 1

  params = {content: content}

  params.room_id = room_id

  #$.post("/rooms/#{room_id}/comments.json", params, (comment) ->
  $.post("/rooms/#{room_id}/comments.json", params, () -> # レスポンスに関係なくレンダリングとsync
    comment = params
    # 自分の投稿を自分の画面に
    window.addComment(room_id, comment, true, true)

    # 自分の投稿を他人の画面に
    syncComment(room_id, comment, true)
  )

@addDoing = (workload) ->
  $("#doing_title").show()
  t = new Date(workload.created_at)
  end_time = @env.pomotime*60*1000 + t.getTime()
  disp = "#{Util.hourMin(workload.created_at, '開始')}（あと<span class='realtime' data-countdown='#{end_time}'></span>）"
  @addWorkload("#doing", workload, disp)

@addChatting = (workload) ->
  $("#chatting_title").show()
  t = new Date(workload.created_at)
  end_time = @env.pomotime*60*1000 + @env.chattime*60*1000 + t.getTime()
  disp = "#{Util.hourMin(workload.created_at, '開始')}（あと<span class='realtime' data-countdown='#{end_time}'></span>）"
  @addWorkload("#chatting", workload, disp)

@addWorkload = (dom, workload, disp) ->
  w = workload
  if w.title
    href = '#'
    if w.key
      href += w.key
    fixed = "<a href=\"#{href}\" class='fixed_start'><img src='https://ruffnote.com/attachments/24921' /></a>"
    jacket = "<a href=\"/musics/#{w.music_id}\">#{if w.artwork_url then '<img src=\"' + w.artwork_url + '\" class=\"jacket\" />' else "<img src=\"#{@nomusic_url}\" class=\"jacket\" />"}</a>"
    title = w.title
  else
    title = '無音'
    if location.href.match(/offline=/)
      fixed = "<a href=\"#\" class='fixed_start'>無音で集中</a>"
    else
      fixed = "<a href=\"#\" class='fixed_start'><img src='https://ruffnote.com/attachments/24926' /></a>"
    jacket = "<img src=\"https://ruffnote.com/attachments/24981\" class='jacket'/>"
  user_img = "<img class='icon img-thumbnail' src='#{workload.icon_url}' />"

  $item = Util.tag('div', null, {class: 'inborder'})
  $item.css("border", '4px solid #eadba0')
  $item.css("border-radius", '18px')
  $item.css("background", '#fff')
  $item.css("margin", '10px 5px 3px')
  $item.css("padding", '0 0 6px')
  $item.css("color", '#b2b2b2')

  $item.html("""
   <h5 title='#{title}' data-toggle='tooltip' data-placement='top'>#{title} </h5>
   <span>#{jacket}</span>
   <span><a href='/#{workload.user_id}'>#{user_img}</a></span>
   <div class='disp'>#{disp}</div>
   <div>#{fixed}</div>
  """)
  $('[data-toggle="tooltip"]').tooltip()

  unless dom == '#done'
    $("#chatting .user_#{user_id}").remove()
    $("#doing .user_#{user_id}").remove()
  if (dom == '#doing' or dom == '#chatting') and $("#{dom} .user_#{user_id}").length
    $("#{dom} .user_#{user_id}").html($item)
  else
    $workload = $('<div></div>')
    $workload.addClass("workload")
    $workload.addClass("col-sm-2")
    $workload.css("min-height", '180px')
    $workload.html($item)
    $("#{dom}").append($workload)
    renderWorkloads('#doing')
    renderWorkloads('#chatting')

  if @env.is_doing || @env.is_done
    $(".fixed_start").hide()

  $("#{dom}").hide()
  $("#{dom}").fadeIn()

initFixedStart = () ->
  $(document).on('click', '.fixed_start', () ->
    if true
      hash = $(this).attr('href').replace(/^#/, '')
      location.hash = hash
      start_hash()
    else
      alert 'Facebookログインをお願いします！'
      window.fbAsyncInit()
  )

window.ruffnote = (id, dom, callback=null) ->
  Ruffnote.fetch("pandeiro245/245cloud/#{id}", dom, callback)

window.addComment = (room_id, comment, is_countup=false, is_prepend=true) ->
  $comments = $("#room_#{room_id} .comments")
  c = comment
  t = new Date()
  hour = t.getHours()
  min = t.getMinutes()

  html = """
  <tr>
  <td>
  <a target='_blank'>
  <img src='#{c.user_img}' />
  <div class='facebook_name_#{c.user_id}'></div>
  </a>
  <td>
  <td>#{Util.parseHttp(c.content)}</td>
  <td>#{Util.hourMin(c.created_at)}</td>
  </tr>
  """
  if is_prepend
    $comments.prepend(html)
  else
    $comments.append(html)
userIdToIconUrl = (userId) ->
  localStorage["icon_#{userId}"] || ""

@syncWorkload = (type) ->
  return if location.href.match(/offline=/)
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
  Nicovideo.search(q, $tracks)
  Soundcloud.search(q, @env.sc_client_id, $tracks)
  Mixcloud.search(q, $tracks)
  #EightTracks.search(q, $tracks)


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
  #console.log 'renderWorkloads'
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

