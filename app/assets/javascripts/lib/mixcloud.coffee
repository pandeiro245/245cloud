class @Mixcloud
  @play: (mc_id, $dom, is_autoplay=true, start_sec=0) ->
    console.log mc_id
    $dom.html("""
      <iframe width="660" height="180" src="https://www.mixcloud.com/widget/iframe/?feed=http%3A%2F%2Fwww.mixcloud.com#{encodeURIComponent(mc_id)}&amp;embed_uuid=be4c7df5-5995-4985-97c7-0c64d5ebbefc&amp;replace=0&amp;hide_cover=1&amp;embed_type=widget_standard&amp;hide_tracklist=1&amp;autoplay=#{if is_autoplay then '1' else '0'}&start=#{start_sec}" frameborder="0"></iframe>
    """)

  @search: (keyword, $dom, callback=null) ->
    url = "http://api.mixcloud.com/search/?q=#{keyword}&type=cloudcast"
    $.getJSON(url, (tracks) ->
      if tracks.data
        for track in tracks.data
          artwork = "<img src=\"https://ruffnote.com/attachments/24162\" width='100px'/>"
          if track.pictures.medium
            artwork = "<img src=\"#{track.pictures.medium}\" width='100px'/>"
          href = "/musics?key=mc:#{track.key}"
          $dom.append("""
            <div class='col-lg-2' style='min-height: 200px;'>
              <a href='#{track.url}' target='_blank'>#{track.name}</a>
              (#{Util.time(track.audio_length*1000)})<br />
              <br />
              #{artwork}
              <a href=\"#{href}\" class='fixed_start'><img src='https://ruffnote.com/attachments/24353' /></a>
              <!--<a href=\"#\" class='add_playlist btn btn-default'>追加</a>-->
            </div>
          """)
        callback() if callback
      else
        $dom.append("<div>「#{q}」MixCloudはで24分前後の曲はまだ出てないようです...。他のキーワードで探してみてください！</div>")
    )

