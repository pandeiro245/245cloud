class @Soundcloud
  @fetch: (sc_id, client_id, callback) ->
    url = "http://api.soundcloud.com/tracks/#{sc_id}.json?client_id=#{client_id}"
    $.get(url, (track) ->
      callback(track)
    )
    
  @play: (sc_id, client_id, $dom, is_autoplay=true) ->
    $dom.html("""
      <iframe width="100%" height="400" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?visual=true&url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F#{sc_id}&show_artwork=true&client_id=#{client_id}&auto_play=#{if is_autoplay then 'true' else 'false'}"></iframe>
    """)
