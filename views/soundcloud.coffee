class @Soundcloud
  @fetch: (sc_id, client_id, callback) ->
    url = "http://api.soundcloud.com/tracks/#{sc_id}.json?client_id=#{client_id}"
    $.get(url, (track) ->
      callback(track)
    )
