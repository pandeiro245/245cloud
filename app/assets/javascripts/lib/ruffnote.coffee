class @Ruffnote
  @fetch: (path, name, callback=null) ->
    if cached_content = localStorage["ruffnote_#{name}"]
      $("##{name}").html(cached_content)
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
