class @Ruffnote
  @fetch: (path, name) ->
    $("##{name}").html(localStorage["ruffnote_#{name}"])
    $.get("/proxy?url=https://ruffnote.com/#{path}/download.json", (data) ->
      localStorage["ruffnote_#{name}"] = data.content
      $("##{name}").html(data.content)
    )
