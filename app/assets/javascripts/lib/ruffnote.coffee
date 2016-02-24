class @Ruffnote
  @fetch: (path, name, callback=null) ->
    if cached_content = localStorage["ruffnote_#{name}"]
      $("##{name}").html(cached_content)
      if callback?
        callback()
    else
      is_callback = true
    if false
      url = "https://ruffnote.com/#{path}/download.json?callback=?"
    else
      url = "/ruffnotes?page=#{path}"
    $.getJSON(url, (data) ->
      data = data.content || data[0]
      data = JSON.parse(data.replace(/^\?\(/,'').replace(/\);$/,''))
      content = data.content.replace(
        'https://ruffnote.com/attachments/',
        '/ruffnotes?attachment_id='
      )
      localStorage["ruffnote_#{name}"] = content
      $("##{name}").html(content)
      if is_calback?
        callback()
    )
  @attachment: (id, id2=null) ->
    if false
      "https://ruffnote.com/attachments/#{id}"
    else
      val1 = "/ruffnotes?attachment_id=#{id}"
      val2 = "/ruffnotes?attachment_id=#{id2}"
      if id2 then [val1, val2] else val1

