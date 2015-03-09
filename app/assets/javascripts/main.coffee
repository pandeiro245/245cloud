@env.is_doing = false
@env.is_done = false

@nomusic_url = 'https://ruffnote.com/attachments/24985'

$ ->
  # ParseParse.addAccesslog()
  Util.scaffolds([
    ['header', {is_row: false}]
    'news'
    ['otukare', {is_hide: true}]
    'ad'
    'contents'
    'start_buttons'
    'doing_title'
    'doing'
    'chatting_title'
    'chatting'
    'done'
    'you_title'
    'you'
    'ranking_title'
    'ranking'
    '8tracks_title'
    '8tracks'
    'search_title'
    'search'
    'playing'
    'complete'
    'select_rooms'
    'rooms_title'
    'rooms'
    'whatis_title'
    ['whatis', {is_row: false}]
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
  initChatting()
  initStart()
  initDoing()
  initDone()
  initRanking()
  initFixedStart()
  initHatopoppo()
  initWhatis()
  initYou()
  
init8tracks = () ->
  ruffnote(17763, '8tracks_title')
  EightTracks.attrip($('#8tracks'))

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
    if location.hash.match(/youtube/)
      Youtube.fetch(id, (track) ->
        artwork_url = artworkUrlWithNoimage(track['entry']['media$group']['media$thumbnail'][3]['url'])
        txt = "<h5>#{track['entry']['title']['$t']}</h5>"
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

initChatting = () ->
  console.log 'initChatting'
  $("#chatting_title").html("<h2 class='status'><img src='https://ruffnote.com/attachments/24938' /></h2>")

  $("#chatting_title").hide()
  $.get('/workloads/chatting.json', (workloads) ->
    return unless workloads.length > 0
    $("#chatting_title").show()
    for workload, i in workloads
      continue unless workload.attributes.user
      @addChatting(workload)
    renderWorkloads('#chatting')
    renderWorkloads('#doing')
  )

initDoing = () ->
  console.log 'initDoing'
  $("#doing_title").html("<h2 class='status'><img src='https://ruffnote.com/attachments/24939' /></h2>")
  $("#doing_title").hide()

  $.get('/workloads/doings.json', (workloads) ->
    return unless workloads.length > 0
    $("#doing_title").show()
    user_keys = {}
    user_count = 0
    for workload, i in workloads
      continue unless workload.attributes.user
      unless user_keys[workload.attributes.user.id]
        @addDoing(workload)
        user_keys[workload.attributes.user.id] = true
    renderWorkloads('#doing')
  )

initDone = () ->
  console.log 'initDone'
  $.get('/workloads/dones.json', (workloads) ->
    return unless workloads.length > 0
    $("#done").append("<h2 class='status'><img src='https://ruffnote.com/attachments/24937' /></h2>")
    for workload in workloads
      continue unless workload.attributes.user
      disp = "#{Util.hourMin(workload.createdAt, '開始')}（#{workload.attributes.number}回目）"
      @addWorkload("#done", workload, disp)
  , null, 24)
 
login = () ->
  console.log 'login'
  location.href = '/auth/facebook'

start_random = () ->
  console.log 'start_random'
  $.get('/musics/random.json', (music) ->
    sc_id = musics.sc_id
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
    'start_buttons'
    'fixedstart_artwork'
    '8tracks'
    '8tracks_title'
    'search_title'
    'ranking_title'
    'ranking'
    'whatis_title'
    'whatis'
    'you_title'
    'you'
    'news'
    'footer'
  ]
  for dom in doms
    $("##{dom}").hide()

  @env.is_doing = true
  @syncWorkload('doing')
  
  if @env.is_kakuhen
    initComments()
    @initSelectRooms()

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
  window.is_hato = false
  Util.countDown(@env.chattime*60*1000, 'finish')
  $('#header').hide()
  $('#otukare').fadeIn()
  $("#playing").fadeOut()
  $("#search").fadeOut()
  $("#playing").html('') # for stopping
  unless @env.is_kakuhen
    @initSelectRooms()

  alert '24分間お疲れ様でした！5分間交換日記ができます☆' if location.href.match('alert') unless @env.is_done

  @env.is_doing = false
  @env.is_done = true

  if location.href.match("ad=") and !$('#ad iframe').length
    $.get('/ads/random.json', (ad) ->
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

  $complete = $('#complete')
  $complete.html('')
  initComments()

window.initComments = () ->
  initRoom()

window.initRoom = (id = 'default', title='いつもの部屋') ->
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
    
    search_id = if id == 'default' then null else id
    limit = if id == 'default' then 100 else 10000

    $.get("/rooms/#{search_id}/comments.json", (comments) ->
      $(document).on('keypress', "#room_#{id} .create_comment", (e) ->
        if e.which == 13 #enter
          window.createComment(id)
      )
      for comment in comments
        @addComment(id, comment)
    )

window.finish = () ->
  console.log 'finish'
  @syncWorkload('finish')
  location.reload()

window.createComment = (room_id) ->
  console.log 'createComment'
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
    href = '#'
    if w.sc_id
      href += "soundcloud:#{w.sc_id}"
    if w.yt_id
      href += "youtube:#{w.yt_id}"
    if w.mc_id
      href += "mixcloud:#{w.mc_id}"
    if w.et_id
      href += "8tracks:#{w.et_id}"
    fixed = "<a href=\"#{href}\" class='fixed_start'><img src='https://ruffnote.com/attachments/24921' /></a>"
    jacket = "#{if w.artwork_url then '<img src=\"' + w.artwork_url + '\" class=\"jacket\" />' else "<img src=\"#{@nomusic_url}\" class=\"jacket\" />"}"
    title = w.title
  else
    title = '無音'
    fixed = "<a href=\"#\" class='fixed_start'><img src='https://ruffnote.com/attachments/24926' /></a>"
    jacket = "<img src=\"https://ruffnote.com/attachments/24981\" class='jacket'/>"
  user_img = "<img class='icon icon_#{user_id} img-thumbnail' src='#{userIdToIconUrl(user_id)}' />"

  $item = Util.tag('div', null, {class: 'inborder'})
  $item.css("border", '4px solid #eadba0')
  $item.css("border-radius", '18px')
  $item.css("background", '#fff')
  $item.css("margin", '10px 5px 3px')
  $item.css("padding", '0 0 6px')
  $item.css("color", '#b2b2b2')

  $item.html("""
   <h5>#{title} </h5>
   <span>#{jacket}</span>
   <span>#{user_img}</span>
   <div class='disp'>#{disp}</div>
   <div>#{fixed}</div>
   <div>#{stars}</div>
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
  $(document).on('click', '.fixed_start', () ->
    if Parse.User.current()
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


ruffnote = (id, dom, callback=null) ->
  Ruffnote.fetch("pandeiro245/245cloud/#{id}", dom, callback)

@addComment = (room_id, comment, is_countup=false, is_prepend=false) ->
  $comments = $("#room_#{room_id} .comments")
  if typeof(comment.attributes) != 'undefined'
    c = comment.attributes
  else
    c = comment
  user = c.user



  t = new Date()
  hour = t.getHours()
  min = t.getMinutes()

  if user && c.body
    html = """
    <tr>
    <td>
    <a class='facebook_#{user.id}' target='_blank'>
    <img class='icon icon_#{user.id}' src='#{userIdToIconUrl(c.user.objectId)}' />
    <div class='facebook_name_#{user.id}'></div>
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
        img = user.get('icon_url') || user.get('icon')._url
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
  console.log "updateRoomCommentsCount room_id is #{room_id}"
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

start_unless_doing = ()->
  unless ( @env.is_doing or @env.is_done)
    start_hash()

artworkUrlWithNoimage = (artwork_url) ->
  artwork_url || @nomusic_url

initWhatis = () ->
  $("#whatis_title").html("<h2 class='status'><img src='https://ruffnote.com/attachments/24942' /></h2>")
  now = new Date()
  month = now.getMonth() + 1
  day = now.getDate()
  youbi = now.getDay()
  numbers = {}
  for i in [1..31]
    i2 = 24371 + i
    numbers[i] = "https://ruffnote.com/attachments/#{i2}"
  youbis = {}
  for i in [1..5]
    i2 = 24358 + i
    youbis[i] = "https://ruffnote.com/attachments/#{i2}"
  youbis[0] = "https://ruffnote.com/attachments/24465" #日曜日
  youbis[6] = "https://ruffnote.com/attachments/24464" #土曜日

  $kokuban = $('<div></div>')
  $kokuban.css('position', 'relative')
  $kokuban.css('background', 'url(https://ruffnote.com/attachments/24501)')
  $kokuban.css('width', '735px')
  $kokuban.css('height', '483px')
  $kokuban.css('margin', '0 auto')

  $month = $('<img />')
  $month.attr('src', numbers[month])
  $month.css('position', 'absolute')
  $month.css('right', '69px')
  $month.css('top', '36px')

  $day = $('<img />')
  $day.attr('src', numbers[day])
  $day.css('position', 'absolute')
  $day.css('right', '70px')
  $day.css('top', '88px')

  $youbi = $('<img />')
  $youbi.attr('src', youbis[youbi])
  $youbi.css('position', 'absolute')
  $youbi.css('right', '70px')
  $youbi.css('top', '138px')

  $kokuban.append($month)
  $kokuban.append($day)
  $kokuban.append($youbi)
  $('#whatis').css('text-align', 'center')
  $('#whatis').html($kokuban)

initYou = () ->
  return unless Parse.User.current()
  ruffnote(17769, 'you_title')
  cond = [
    ["user", Parse.User.current()]
    ["is_done", true]
    ["createdAt", '<', Util.minAgo(@env.pomotime + @env.chattime)]
  ]
  ParseParse.where('Workload', cond, (workloads) ->
    for workload in workloads
      continue unless workload.attributes.user
      disp = "#{Util.hourMin(workload.createdAt, '開始')}（#{workload.attributes.number}回目）"
      addWorkload("#you", workload, disp)
  null, 24)

