class @EightTracks
  @fetch: (et_id, client_id, callback) ->
    console.log et_id
    id = parseInt(et_id)
    if id  > 0
      url = "//8tracks.com/mixes/#{et_id}?format=json&api_key=#{client_id}"
    else
      url = "//8tracks.com/#{et_id}.json?api_key=#{client_id}"
    $.get(url, (track) ->
      console.log track
      location.hash = "8tracks:#{track.mix.id}"
      callback(track)
    )
    
  @play: (et_id, $dom, is_autoplay=true) ->
    $dom.html("""
      <iframe src="http://8tracks.com/mixes/#{et_id}/player_v3_universal/autoplay" width="300" height="250" style="border: 0px none;"></iframe>
    """)

  @search: (keyword, client_id, $dom, callback) ->
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
              <a href=\"##{href}\" class='fixed_start btn btn-default'>再生</a>
              <!--<a href=\"#\" class='add_playlist btn btn-default'>追加</a>-->
            </div>
          """)
        callback()
      else
        $dom.append("<div>「#{q}」SoundCloudにはで24分前後の曲はまだ出てないようです...。他のキーワードで探してみてください！</div>")
    )

