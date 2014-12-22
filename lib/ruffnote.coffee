class @Ruffnote
  @fetch: (path, name, callback=null) ->
    if cache = localStorage["ruffnote_#{name}"]
      $("##{name}").html(cache)
      if callback?
        callback()
    else
      is_callback = true
    url = "https://ruffnote.com/#{path}/download.json?callback=?"
    $.getJSON(url, (data) ->
      localStorage["ruffnote_#{name}"] = data.content
      $("##{name}").html(data.content)
      if is_calback?
        callback()
    )
