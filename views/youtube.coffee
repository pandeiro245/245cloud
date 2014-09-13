class @Youtube
  @fetch: (sc_id, client_id, callback) ->
    url = "http://api.soundcloud.com/tracks/#{sc_id}.json?client_id=#{client_id}"
    $.get(url, (track) ->
      callback(track)
    )
    
  @play: (youtube_key, $dom, is_autoplay=true) ->
    $dom.html("""
      <iframe width="560" height="315" src="//www.youtube.com/embed/#{youtube_key}?autoplay=#{if is_autoplay then '1' else '0'}" frameborder="0" allowfullscreen></iframe>
    """)
