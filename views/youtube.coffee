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
