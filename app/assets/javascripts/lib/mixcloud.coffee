class @Mixcloud
  @fetch: (mc_id, callback) ->
    url = "//api.mixcloud.com#{mc_id}"
    console.log url
    $.getJSON(url, (track) ->
      console.log track
      callback(track)
    )
    
  @play: (mc_id, $dom, is_autoplay=true, start_sec=0) ->
    console.log mc_id
    $dom.html("""
      <iframe width="660" height="180" src="//www.mixcloud.com/widget/iframe/?feed=https%3A%2F%2Fwww.mixcloud.com#{encodeURIComponent(mc_id)}&amp;embed_uuid=be4c7df5-5995-4985-97c7-0c64d5ebbefc&amp;replace=0&amp;hide_cover=1&amp;embed_type=widget_standard&amp;hide_tracklist=1&amp;autoplay=#{if is_autoplay then '1' else '0'}&start=#{start_sec}" frameborder="0"></iframe>
    """)

  @search: (keyword, $dom, callback=null) ->
    url = "//api.mixcloud.com/search/?q=#{keyword}&type=cloudcast"
    $.getJSON(url, (tracks) ->
      if tracks.data
        for track in tracks.data
          artwork_url = ImgURLs.track_noimage
          if track.pictures.medium
            artwork_url = track.pictures.medium
          href = "mixcloud:#{track.key}"
          duration = track.audio_length*1000
          $dom.append(
            Util.renderTrack('mixcloud', track.url, track.name, artwork_url, href, Util.time(duration))
          )
        callback() if callback
      else
        $dom.append("<div>「#{q}」MixCloudはで24分前後の曲はまだ出てないようです...。他のキーワードで探してみてください！</div>")
    )

