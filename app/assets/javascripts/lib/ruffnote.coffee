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
      content = data.content.replace(
        "http://ruffnote.com/?timecrowd=1",
        "/?timecrowd=1",
      )
      content = data.content.replace(
        "http://ruffnote.com/?twitter=1",
        "/?twitter=1",
      )
    localStorage["ruffnote_#{name}"] = content
      $("##{name}").html(content)
      if is_calback?
        callback()
    )
