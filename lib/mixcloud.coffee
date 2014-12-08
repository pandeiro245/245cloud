class @Mixcloud
  ###
  @fetch: (sc_id, client_id, callback) ->
    url = "//api.soundcloud.com/tracks/#{sc_id}.json?client_id=#{client_id}"
    $.get(url, (track) ->
      callback(track)
    )
  ###
    
  @play: (mc_id, $dom, is_autoplay=true) ->
    $dom.html("""
      <iframe width="660" height="180" src="https://www.mixcloud.com/widget/iframe/?feed=http%3A%2F%2Fwww.mixcloud.com%2F#{mc_id}%2F&amp;embed_uuid=be4c7df5-5995-4985-97c7-0c64d5ebbefc&amp;replace=0&amp;hide_cover=1&amp;embed_type=widget_standard&amp;hide_tracklist=1&amp;autoplay=#{if is_autoplay then '1' else '0'}" frameborder="0"></iframe>
    """)
  ###
  @search: (keyword, $dom, callback) ->
    #url = "http://api.soundcloud.com/tracks.json?client_id=#{window.env.sc_client_id}&q=#{keyword}&duration[from]=#{24*60*1000}"
    url = "http://api.mixcloud.com/search/?q=#{keyword}&type=cloudcast"
    console.log url
    $.get(url, (tracks) ->
      
      console.log tracks.data
      if tracks.data
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
  ###

