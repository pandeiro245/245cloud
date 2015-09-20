vm = (model_name, action_name, view_name) ->
  {
    controller: ->
      eval(model_name)[action_name]().then((items) ->
        {
          items: items
          reverse: ->
            items().reverse()
        }
      )
    view: (ctrl) ->
      eval(view_name)(ctrl)
  }

WorkloadsView = (ctrl, status=null) ->
  return unless ctrl().items.length
  m 'div', [
    ctrl().items.map((item) ->
      WorkloadView(item, status)
    ),
    renderWorkloads('#chatting'),
    renderWorkloads('#doing')
  ]

WorkloadView = (workload, status=null) ->
  if workload.attributes
    w = workload.attributes
    user_id = w.user.id
  else
    w = workload
    user_id = w.user.objectId

  img_id = if w.title then '24921' else '24926' # この曲 or 無音
  t = new Date(workload.createdAt)

  if status == 'doing'
    end_time = @env.pomotime*60*1000
  else if status == 'chatting'
    end_time = @env.chattime*60*1000

  if status == 'doing' or status == 'chatting'
    disp = m.trust("#{Util.hourMin(workload.createdAt, '開始')}（あと<span class='realtime' data-countdown='#{end_time + t.getTime()}'></span>）")
  else
    disp = "#{Util.hourMin(workload.createdAt, '開始')}（#{w.number}回目）"

  m "div.col-sm-2.workload.user_#{user_id}", {'data-user_id': user_id}, [
    m '.inborder', [
      m 'h5', w.title || '無音'
      m 'span', [
        m 'img.jacket', src: jacketUrl(w)
      ]
      m 'span', [
        m 'img.icon.img-thumbnail', src: iconUrl(w)
      ]
      m '.disp', disp
      m 'div', [
        m 'a.fixed_start', {href: w2href(w), onclick: fixedStart}, [
          m 'img', src: "https://ruffnote.com/attachments/#{img_id}"
        ]
      ]
    ]
  ]

CommentsView = (ctrl) ->
  comments = ctrl().items
  m 'div', [
    ctrl().items.map((comment) ->
      CommentView(comment)
    )
  ]
  # TODO: 未読数の更新（部屋毎）
  #window.updateUnreads(search_id, comments.length)

CommentView = (comment) ->
  if typeof(comment.attributes) != 'undefined'
    c = comment.attributes
  else
    c = comment
  m 'tr', [
    m 'td', [
      m 'img', {src: c.icon_url}
    ]
    m 'td', c.body
    m 'td', Util.hourMin(comment.createdAt)
  ]

# Model

Workload = {
  doings: ->
    cond = [
      ["is_done", null]
      ["createdAt", '>', Util.minAgo(24)]
    ]
    ParseParse.where("Workload", cond)
  chattings: ->
    cond = [
      ["is_done", true]
      ["createdAt", '>', Util.minAgo(29)]
      ["createdAt", '<', Util.minAgo(24)]
    ]
    ParseParse.where("Workload", cond)
  dones: ->
    cond = [
      ["is_done", true]
      ["createdAt", '<', Util.minAgo(29)]
    ]
    ParseParse.where("Workload", cond, 48)
  you: ->
    cond = [
      ["user", Parse.User.current()]
      ["is_done", true]
      ["createdAt", '<', Util.minAgo(29)]
    ]
    ParseParse.where("Workload", cond, 24)
}

Room = {
  list:  ->
    ParseParse.all("Room")
}

Comment = {
  list: (room_id=null)->
    cond = [
      ["room_id", room_id]
    ]
    ParseParse.where("Comment", cond)
}


$ ->
  ParseParse.addAccesslog()
  Util.scaffolds([
    ['header', ['row', 'without-will_hide']]
    'news'
    ['otukare', ['hidden', 'without-will_hide']]
    'ad'
    'contents'
    'start_buttons'
    'doing_title'
    'doing'
    'chatting_title'
    'chatting'
    'done_title'
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
    ['playing', ['without-will_hide']]
    ['complete', ['without-will_hide']]
    ['select_rooms', ['without-will_hide']]
    ['rooms_title', ['without-will_hide']]
    ['rooms', ['without-will_hide']]
    'whatis_title'
    ['whatis', ['row']]
    'footer'
    'hatopoppo'
  ])

  Util.realtime()
  ruffnote(13475, 'header')
  ruffnote(18004, 'news')
  ruffnote(13477, 'footer')
  ruffnote(17758, 'search_title')
  ruffnote(17762, 'ranking_title')
  ruffnote(17498, 'otukare')

  $('#selectRoomButton').hide()

  ruffnote(17661, 'music_ranking')

  initSearch()
  init8tracks()
  initNaotake()
  initKimiya()
  initChatting()
  initStart()
  initDoing()
  initDone()
  initRanking()
  initFixedStart()
  initHatopoppo()
  window.initWhatis()
  initYou()

# Util

iconUrl = (instance) ->
  #"https://graph.facebook.com/#{instance.user.facebook_id_str}/picture?height=40&width=40"
  
  #return instance.icon_url if instance.icon_url
  #user = User.find(instance.user.objectId)
  #"https://graph.facebook.com/#{user.facebook_id_str}/picture?height=40&width=40"
  
  return instance.icon_url


jacketUrl = (workload) ->
  return'https://ruffnote.com/attachments/24981' unless workload.title
  workload.artwork_url || @nomusic_url

initDoing = () ->
  ruffnote(22877, 'doing_title')
  m.mount $('#doing')[0], vm('Workload', 'doings', 'WorkloadsView')
  window.renderWorkloads('#doing')

initChatting = () ->
  ruffnote(22878, 'chatting_title')
  m.mount $('#chatting')[0], vm('Workload', 'chattings', 'WorkloadsView')
  window.renderWorkloads('#chatting')

initDone = () ->
  ruffnote(17769, 'done_title')
  m.mount $('#done')[0], vm('Workload', 'dones', 'WorkloadsView')

initYou = () ->
  return unless Parse.User.current()
  ruffnote(22876, 'you_title')
  m.mount $('#you')[0], vm('Workload', 'you', 'WorkloadsView')
  
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
  text = "24分やり直しでも大丈夫ですか？"
  Util.beforeunload(text, 'env.is_doing')
  
  if Parse.User.current()
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

    #text = '曲おまかせで24分間集中する！'
    text = [
      'https://ruffnote.com/attachments/24919'
      'https://ruffnote.com/attachments/24920'
    ]
    tooltip = '現在はSoundcloudの人気曲からランダム再生ですが今後もっと賢くなっていくはず'
    $random = $('#start_buttons #random')
    $random.html("""<h5>おまかせ</h5>
      <img src="\https://ruffnote.com/attachments/24982\" class='jacket'/>
    """)
    #Util.addButton('start', $random, text, start_random, tooltip)
    Util.addButton('start', $random, text, start_random)
    $random.addClass("col-sm-offset-#{getOffset(2)}")
 
    #text = 'この曲で集中'
    $('#fixedstart').hide()
    fixed_text = [
      'https://ruffnote.com/attachments/24921'
      'https://ruffnote.com/attachments/24922'
    ]
    id = location.hash.split(':')[1]
    if location.hash.match(/soundcloud/)
      Soundcloud.fetch(id, @env.sc_client_id, (track) ->
        artwork_url = artworkUrlWithNoimage(track['artwork_url'])
        txt = "<h5>#{track['title']}</h5>"
        $('#fixedstart').append(txt)
        txt = "<img src='#{artwork_url}' class='jacket'>"
        $('#fixedstart').append(txt)
        Util.addButton('start', $('#fixedstart'), fixed_text, start_hash)
        $('#fixedstart').fadeIn()
        $('#random').removeClass("col-sm-offset-#{getOffset(2)}")
        $('#random').addClass("col-sm-offset-#{getOffset(3)}")
      )
    if location.hash.match(/mixcloud/)
      Mixcloud.fetch(id, (track) ->
        artwork_url = artworkUrlWithNoimage(track.pictures.medium)
        txt = "<h5>#{track.name}</h5>"
        $('#fixedstart').append(txt)
        txt = "<img src='#{artwork_url}' class='jacket'>"
        $('#fixedstart').append(txt)
        Util.addButton('start', $('#fixedstart'), fixed_text, start_hash)
        $('#fixedstart').fadeIn()
        $('#random').removeClass("col-sm-offset-#{getOffset(2)}")
        $('#random').addClass("col-sm-offset-#{getOffset(3)}")
      )
    if location.hash.match(/nicovideo/)
      Nicovideo.fetch(id, (track) ->
        artwork_url = artworkUrlWithNoimage(track.artwork_url)
        txt = "<h5>#{track.title}</h5>"
        $('#fixedstart').append(txt)
        txt = "<img src='#{artwork_url}' class='jacket'>"
        $('#fixedstart').append(txt)
        Util.addButton('start', $('#fixedstart'), fixed_text, start_hash)
        $('#fixedstart').fadeIn()
        $('#random').removeClass("col-sm-offset-#{getOffset(2)}")
        $('#random').addClass("col-sm-offset-#{getOffset(3)}")
      )
    if location.hash.match(/8tracks/)
      EightTracks.fetch(id, @env.et_client_id, (track) ->
        artwork_url = artworkUrlWithNoimage(track.mix.cover_urls.sq100)
        txt = "<h5>#{track.mix.name}</h5>"
        $('#fixedstart').append(txt)
        txt = "<img src='#{artwork_url}' class='jacket'>"
        $('#fixedstart').append(txt)
        Util.addButton('start', $('#fixedstart'), fixed_text, start_hash)
        $('#fixedstart').fadeIn()
        $('#random').removeClass("col-sm-offset-#{getOffset(2)}")
        $('#random').addClass("col-sm-offset-#{getOffset(3)}")
      )

    #text = '無音で24分集中'
    text = [
      'https://ruffnote.com/attachments/24926'
      'https://ruffnote.com/attachments/24927'
    ]
    tooltip = '無音ですが終了直前にはとぽっぽが鳴ります'
    $nomusic = $('#start_buttons #nomusic')

    $nomusic.html('<h5>無音</h5>')
    $nomusic.append(Util.tag('img', 'https://ruffnote.com/attachments/24981', {class: 'jacket'}))
    #Util.addButton('start', $nomusic, text, start_nomusic, tooltip)
    Util.addButton('start', $nomusic, text, start_nomusic)

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
  $('#rooms_title').html(Util.tag('h2', Util.tag('img', 'https://ruffnote.com/attachments/24968'), {class: 'status'}))
  $('#select_rooms').html(Util.tag('h2', Util.tag('img', 'https://ruffnote.com/attachments/24967'), {class: 'status'}))
  $('#select_rooms').append(Util.tag('div', null, {class: 'imgs'}))

  ParseParse.all("Room", (rooms) ->
    $('#select_rooms .imgs').html('')

    # いつも部屋
    on2= 'https://ruffnote.com/attachments/24831'
    off2= 'https://ruffnote.com/attachments/24832'
    $img = Util.tag('img', on2)
    $img.attr('data-values', "default:いつもの部屋")
    $img.tooltip({title: 'いつもの部屋はログが流れやすいよ', placement: 'bottom'})
    $img.addClass('col-sm-2 room_icon room_link')
    $img.addClass('on')
    $img.css('cursor', 'pointer')
    $img.attr('data-on', "#{on2}")
    $img.attr('data-off', "#{off2}")
    $('#select_rooms .imgs').append($img)

    $('.modal-body').html('')

    # DB部屋
    for room in rooms
      r = room.attributes
      room_id = room.id
      total_count = r.comments_count
      unread_count = getUnreadsCount(room.id, total_count)
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
          "<a class='room_link' style='cursor: pointer; display:block;'  data-values=\"#{room.id}:#{room.attributes.title}\">#{room.attributes.title} (#{unread_count}/#{total_count})</option>"
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

login = () ->
  window.fbAsyncInit()

start_random = () ->
  ParseParse.all("Music", (musics) ->
    n = Math.floor(Math.random() * musics.length)
    sc_id = musics[n].attributes.sc_id
    location.hash = "soundcloud:#{sc_id}"
    window.play("soundcloud:#{sc_id}")
  )
  
window.start_hash = (key = null) ->
  unless key
    key = location.hash.replace(/#/, '')

  if key
     window.play(key)
   else
     start_nomusic()

window.start_nomusic = () ->
  createWorkload({}, start)

createWorkload = (params = {}, callback) ->
  params.host = location.host

  ParseParse.create("Workload", params, (workload) ->
    @workload = workload
    callback()
  )
  
start = () ->
  $(".will_hide").hide()

  @env.is_doing = true
  @syncWorkload('doing')
  
  if @env.is_kakuhen
    initComments()
    @initSelectRooms()

  Util.countDown(@env.pomotime*60*1000, complete)

window.youtubeDurationSec = (key)  ->
  duration = key['contentDetails']['duration'].replace(/^PT/, '').replace(/S$/, '')
  hour = parseInt(duration.split('H')[0])
  min = parseInt(duration.split('H')[1].split('M')[0])
  sec = parseInt(duration.split('H')[1].split('M')[1])
  sec = hour*60*60+min*60+sec
  parseInt(sec)

window.play = (key) ->
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
    Youtube.fetch(id, (data) ->
      track = data['items'][0]['snippet']
      params['yt_id'] = id
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
      params['mc_id'] = id
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
      createWorkload(track, start)
    )
    Nicovideo.play(id, $("#playing"))
  if key.match(/^8tracks/)
    EightTracks.fetch(id, @env.et_client_id, (track) ->
      params['et_id'] = parseInt(id)
      params.title = track.mix.name
      params.artwork_url = track.mix.cover_urls.sq100
      createWorkload(params, start)
      window.play_repeat(key, track.mix.duration * 1000)
    )

window.play_repeat = (key, duration) ->
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

complete = () ->
  @syncWorkload('chatting')
  window.is_hato = false
  Util.countDown(@env.chattime*60*1000, 'finish')
  $('#header').hide()
  $('#otukare').removeClass('hidden')
  $('#otukare').fadeIn()
  $("#playing").fadeOut()
  $("#playing").html('') # for stopping
  unless @env.is_kakuhen
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

  $complete = $('#complete')
  $complete.html('')

  initComments()

window.initComments = () ->
  initRoom()

window.initRoom = (id = 'default', title='いつもの部屋') ->
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
    
    search_id = if id == 'default' then null else id
    limit = if id == 'default' then 100 else 10000

    m.mount $('#rooms .comments')[0], vm('Comment', 'list', 'CommentsView')

window.updateUnreads = (room_id, count) ->
  unreads = Parse.User.current().get("unreads")
  unreads = {} unless unreads
  unreads[room_id] = count
  Parse.User.current().set("unreads", unreads)
  Parse.User.current().save()

window.finish = () ->
  @syncWorkload('finish')
  location.reload()

window.createComment = (room_id) ->
  $createComment = $("#room_#{room_id} .create_comment")
  
  body = $createComment.val()

  $createComment.val('')
  
  return if body.length < 1

  params = {body: body}

  if room_id != 'default'
    params.room_id = room_id
  ParseParse.create('Comment', params, (comment)->
    updateRoomCommentsCount(room_id)

    # 自分の投稿を自分の画面に
    @addComment(room_id, comment, true, true)

    # 自分の投稿を他人の画面に
    syncComment(room_id, comment, true)
  )

initRanking = () ->
  $('#ranking').html('ここにランキング結果が入る予定')

@addDoing = (workload) ->
  $("#doing_title").show()
  t = new Date(workload.createdAt)
  end_time = @env.pomotime*60*1000 + t.getTime()
  disp = "#{Util.hourMin(workload.createdAt, '開始')}（あと<span class='realtime' data-countdown='#{end_time}'></span>）"
  @addWorkload("#doing", workload, disp)

@addChatting = (workload) ->
  $("#chatting_title").show()
  t = new Date(workload.createdAt)
  end_time = @env.pomotime*60*1000 + @env.chattime*60*1000 + t.getTime()
  disp = "#{Util.hourMin(workload.createdAt, '開始')}（あと<span class='realtime' data-countdown='#{end_time}'></span>）"
  @addWorkload("#chatting", workload, disp)

@addWorkload = (dom, workload, disp) ->
  if workload.attributes
    w = workload.attributes
    user_id = w.user.id
  else
    w = workload
    user_id = w.user.objectId

  if w.title
    href = w2href(w)
    fixed = "<a href=\"#{href}\" class='fixed_start'><img src='https://ruffnote.com/attachments/24921' /></a>"
    jacket = "#{if w.artwork_url then '<img src=\"' + w.artwork_url + '\" class=\"jacket\" />' else "<img src=\"#{@nomusic_url}\" class=\"jacket\" />"}"
    title = w.title
  else
    title = '無音'
    fixed = "<a href=\"#\" class='fixed_start'><img src='https://ruffnote.com/attachments/24926' /></a>"
    jacket = "<img src=\"https://ruffnote.com/attachments/24981\" class='jacket'/>"
  user_img = "<img class='icon img-thumbnail' src='#{w.icon_url}' />"

  $item = Util.tag('div', null, {class: 'inborder'})
  $item.html("""
   <h5>#{title} </h5>
   <span>#{jacket}</span>
   <span>#{user_img}</span>
   <div class='disp'>#{disp}</div>
   <div>#{fixed}</div>
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
    $workload.css("min-height", '180px')
    $workload.html($item)
    if workload.attributes # init
      $("#{dom}").append($workload)
    else # with PubNub
      $("#{dom}").prepend($workload)
      renderWorkloads('#doing')
      renderWorkloads('#chatting')

  if @env.is_doing || @env.is_done
    $(".fixed_start").hide()

  $("#{dom}").hide()
  $("#{dom}").fadeIn()

initFixedStart = () ->
  fixedStart()

fixedStart = ()->
  $(document).on('click', '.fixed_start', () ->
    if Parse.User.current()
      hash = $(this).attr('href').replace(/^#/, '')
      location.hash = hash
      start_hash()
    else
      alert 'Facebookログインをお願いします！'
      window.fbAsyncInit()
  )

ruffnote = (id, dom, callback=null) ->
  Ruffnote.fetch("pandeiro245/245cloud/#{id}", dom, callback)

initService = ($dom, url) ->
  $dom.append("<iframe src='#{url}' width='85%' height='900px'></iframe>")

@addComment = (room_id, comment, is_countup=false, is_prepend=false) ->
  $comments = $("#room_#{room_id} .comments")
  if typeof(comment.attributes) != 'undefined'
    c = comment.attributes
  else
    c = comment
  user = c.user

  if user && c.body
    html = """
    <tr>
    <td>
    <a class='facebook_#{user.id}' target='_blank'>
    <img class='icon icon_#{user.id}' src='#{userIdToIconUrl(c.user.objectId)}' />
    <!--<div class='facebook_name_#{user.id}'></div>-->
    </a>
    <td>
    <td>#{Util.parseHttp(c.body)}</td>
    <td>#{Util.hourMin(comment.createdAt)}</td>
    </tr>
    """

    if typeof(comment.attributes) != 'undefined'
      if is_prepend
        $comments.prepend(html)
      else
        $comments.append(html)
      ParseParse.fetch("user", comment, (ent, user) ->
        img = "https://graph.facebook.com/#{user.get('facebook_id_str')}/picture?height=40&width=40"

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

updateRoomCommentsCount = (room_id) ->
  ParseParse.find('Room', room_id, (room) ->
    ParseParse.where('Comment', [['room_id', room_id]], (room, comments)->
      room.set('comments_count', comments.length)
      room.save()
      window.updateUnreads(room_id, comments.length)
    , room)
  )

@syncWorkload = (type) ->
  @socket.push({
    type: type
    workload: @workload
  })

syncComment = (room_id, comment, is_countup=false) ->
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
  # thanks for http://musicisvfr.com/free/se/clock01.html
  $audio.attr('src', '/audio/Zihou01-4.mp3')
  #$audio.attr('src', '/audio/20141231_shion_poppo.m4a')
  $('#hatopoppo').append($audio)

getOffset = (all_count) ->
  return 0 if all_count >= 5
  data = {1: 5, 2: 4, 3: 3, 4: 2}
  data[all_count]

window.renderWorkloads = (dom) ->
  $dom = $("#{dom}")
  $items = $("#{dom} .workload")

  unless $items.length
    $dom = $("#{dom}_title").hide()
    return

  # doingとchattingは1userあたり最新の1workloadのみ表示
  for item in $items
    user_id = $(item).attr('data-user_id')
    user_items = $("#{dom} .user_#{user_id}")
    if user_items.length > 1
      for user_item in user_items
        unless user_item == user_items[0]
          $(user_item).remove()
  
  $items = $("#{dom} .workload")

  # workloads 5つ以下は1つめにoffsetをつける(中央寄せにする)
  $first = $("#{dom} .workload:first")
  for i in [2..5]
    $items.removeClass("col-sm-offset-#{i}")
  $first.addClass("col-sm-offset-#{getOffset($items.length)}")

  $dom = $("#{dom}_title").fadeIn()

artworkUrlWithNoimage = (artwork_url) ->
  artwork_url || @nomusic_url

w2href = (w) ->
  href = '#'
  if w.sc_id
    href += "soundcloud:#{w.sc_id}"
  if w.yt_id
    href += "youtube:#{w.yt_id}"
  if w.mc_id
    href += "mixcloud:#{w.mc_id}"
  if w.et_id
    href += "8tracks:#{w.et_id}"
  if w.sm_id
    href += "nicovideo:#{w.sm_id}"
  return href
