class @Ruffnote
  @fetch: (path, name) ->
    console.log 'ruffnote'
    $("##{name}").html(localStorage["ruffnote_#{name}"])
    url = "https://ruffnote.com/#{path}/download.json?callback=?"
    $.getJSON(url, (data) ->
      localStorage["ruffnote_#{name}"] = data.content
      $("##{name}").html(data.content)
    )
