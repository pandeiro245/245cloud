class @Youtube
  @fetch: (yt_id, callback) ->
    console.log 'youtube', yt_id
    url = "https://gdata.youtube.com/feeds/api/videos/#{yt_id}?alt=json"
    $.get(url, (track) ->
      callback(track)
    )
    
  @play: (youtube_key, $dom, is_autoplay=true, start_sec=0) ->
    is_autoplay = true
    $dom.html("""
      <iframe width="560" height="315" src="//www.youtube.com/embed/#{youtube_key}?autoplay=#{if is_autoplay then '1' else '0'}&start=#{start_sec}" frameborder="0" allowfullscreen></iframe>
    """)

  @search: (keyword, $dom) ->
    url = "http://gdata.youtube.com/feeds/api/videos?q=#{keyword}&filter=long&alt=json"
    $.get(url, (tracks) ->
      tracks = tracks.feed.entry
      if tracks[0]
        for track in tracks
          duration = parseInt(track['media$group']['yt$duration']['seconds']) * 1000
          continue if duration < 24 * 60 *1000

          tmp = track['id']['$t']
          id = tmp.split("/")[tmp.split("/").length - 1]
          url = "https://www.youtube.com/watch?v=#{id}"
          title = track['title']['$t']
          artwork_url = track['media$group']['media$thumbnail'][3]['url']
          duration = parseInt(track['media$group']['yt$duration']['seconds']) * 1000
          artwork = ''
          if artwork_url
            artwork = "<img src=\"#{artwork_url}\" width=100px/>"
          href = "youtube:#{id}"
          $dom.append("""
            <hr />
            <div>
              <a href='#{url}' target='_blank'>#{title}</a>
              (#{Util.time(duration)})<br />
              <br />
              #{artwork}
              <a href=\"#{href}\" class='fixed_start btn btn-default'>この曲で集中</a>
              <a href=\"#\" class='add_playlist btn btn-default'>プレイリストに追加（準備中）</a>
            </div>
          """)
        callback()
      else
        $dom.append("<div>「#{q}」YouTubeCloudにはで24分前後の曲はまだ出てないようです...。他のキーワードで探してみてください！</div>")
    )
   
