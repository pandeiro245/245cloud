class @Soundcloud
  @fetch: (sc_id, client_id, callback) ->
    url = "//api.soundcloud.com/tracks/#{sc_id}.json?client_id=#{client_id}"
    $.get(url, (track) ->
      callback(track)
    )

  @play: (sc_id, client_id, $dom, is_autoplay=true) ->
    container = $dom.html("""
    <div>
       <label>
          Volume <input type="range" min=0 max=100 value=100>
       </label>
       <iframe width="100%" height="400" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?visual=true&url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F#{sc_id}&show_artwork=true&client_id=#{client_id}&auto_play=#{if is_autoplay then 'true' else 'false'}&t=3000"></iframe>
    </div>
    """)

    widget = SC.Widget($('iframe', container)[0])
    $("input", container).on("change", ->
      widget.setVolume($(this).val() / 100)
    )

    widget.getVolume((volume) ->
      $("input", container).val(volume * 100)
    )

    container

  @search: (keyword, client_id, $dom, callback=null) ->
    url = "http://api.soundcloud.com/tracks.json?client_id=#{window.env.sc_client_id}&q=#{keyword}&duration[from]=#{24*60*1000}"
    $.get(url, (tracks) ->
      if tracks[0]
        for track in tracks
          artwork = "<img src=\"https://ruffnote.com/attachments/24162\" width='100px'/>"
          if track.artwork_url
            artwork = "<img src=\"#{track.artwork_url}\" width='100px'/>"
          href = "soundcloud:#{track.id}"
          $dom.append("""
            <div class='col-lg-2' style='min-height: 200px;'>
              <a href='#{track.permalink_url}' target='_blank'>#{track.title}</a>
              (#{Util.time(track.duration)})<br />
              <br />
              #{artwork}
              <a href=\"##{href}\" class='fixed_start'><img src='https://ruffnote.com/attachments/24353' /></a>
              <!--<a href=\"#\" class='add_playlist btn btn-default'>追加</a>-->
            </div>
          """)
        callback() if callback
      else
        $dom.append("<div>「#{q}」SoundCloudにはで24分前後の曲はまだ出てないようです...。他のキーワードで探してみてください！</div>")
    )

