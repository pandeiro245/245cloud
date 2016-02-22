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
      url = "ruffnotes?page=#{path}"
    $.getJSON(url, (data) ->
      content = data.content
      return unless content
      content = content.replace(
        'https://ruffnote.com/attachments/',
        '/ruffnotes?attachment_id='
      )
      localStorage["ruffnote_#{name}"] = content
      $("##{name}").html(content)
      if is_calback?
        callback()
    )
