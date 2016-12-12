class @Soundcloud
  @fetch: (sc_id, client_id, callback) ->
    url = "//api.soundcloud.com/tracks/#{sc_id}.json?client_id=#{client_id}"
    $.get(url, (track) ->
      callback(track)
    )
    
  @play: (sc_id, client_id, $dom, is_autoplay=true) ->
    $dom.html("""
      <div class="player-container">
        <iframe class="player" width="600" height="400" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?visual=true&url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F#{sc_id}&show_artwork=true&client_id=#{client_id}&auto_play=#{if is_autoplay then 'true' else 'false'}&t=3000"></iframe>
        <div class="volume-container">
            <span class="volume-icon-left glyphicon glyphicon-minus"></span>
            <div class="volume-slider">
                <div class="volume-button"></div>
            </div>
            <span class="volume-icon-right glyphicon glyphicon-plus"></span>
        </div>
      </div>
    """)
    Soundcloud.initVolume()

  @initVolume: () ->
    press = false
    cursorWidth = 8
    max = $('.volume-slider').width() - cursorWidth / 2;
    min = cursorWidth / 2
    ready = false
    widget = SC.Widget($('.player')[0])

    setLeft = (clientX) ->
      left = clientX - $('.volume-slider').offset().left
      left = Math.max(min, left)
      left = Math.min(max, left)

      $('.volume-button').css({
        left: left
      })

      volume = (left - min) / (max - min)
      widget.setVolume(volume) if ready

    $('.volume-button').on('mousedown', (e)->
      e.preventDefault()
      press = true
    )

    $('body').on('mousemove', (e) ->
      e.preventDefault()
      setLeft(e.clientX) if press
    ).on('mouseup', () ->
      press = false
    )

    $('.volume-slider').on('click', (e) ->
      setLeft(e.clientX)
    )

    widget.bind(SC.Widget.Events.READY, ->
      widget.getVolume((volume) ->
        ready = true;
        $('.volume-button').css({
          left: min + (max - min) * volume
        })
      )
    )

  @search: (keyword, client_id, $dom, callback=null) ->
    url = "//api.soundcloud.com/tracks.json?client_id=#{window.env.sc_client_id}&q=#{keyword}&duration[from]=#{24*60*1000}"
    $.get(url, (tracks) ->
      if tracks[0]
        for track in tracks
          artwork = "<img src='#{ImgURLs.track_noimage}' width='100px'/>"
          href = "soundcloud:#{track.id}"
          $dom.append(
            Util.renderTrack('soundcloud', track.permalink_url, track.title, track.artwork_url, href, Util.time(track.duration))
          )
        callback() if callback
      else
        $dom.append("<div>「#{keyword}」SoundCloudにはで24分前後の曲はまだ出てないようです...。他のキーワードで探してみてください！</div>")
    )

