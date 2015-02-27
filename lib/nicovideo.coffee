class @Nicovideo
  @fetch: (sm_id, callback) ->
    console.log 'nicovideo', sm_id # sm_id: 'smXXXXXXX'

    # see http://allow-any-origin.appspot.com/
    # ToDo: use your proxy
    #       see https://gist.github.com/DanielG/899973
    url = "http://allow-any-origin.appspot.com/http://ext.nicovideo.jp/api/getthumbinfo/#{sm_id}"

    $.get(url, (xml) ->
      if $(xml).find('nicovideo_thumb_response').attr('status') == 'fail'
          console.error('video has been deleted', sm_id)
        else
          callback({
            sm_id: sm_id,
            title: $(xml).find('title').text(),
            artwork_url: $(xml).find('thumbnail_url').text()
          })
    )

  @play: (sm_id, $dom) ->
    console.log 'sm_id', sm_id

    # see http://mementoo.info/archives/1557
    document._write = document.write;
    document.write = (msg) ->
      $dom.html(msg)
      document.write = document._write

    script = document.createElement('script')
    script.src = "http://ext.nicovideo.jp/thumb_watch/#{sm_id}"
    $dom.append(script)

  @search: (keyword, $dom, callback=null) ->
    url = "http://api.search.nicovideo.jp/api/snapshot/"
    query = {
      query: keyword,
      service: ["video"],
      search: ["title", "description"],
      join: ["cmsid", "title", "length_seconds", "thumbnail_url"],
      filters: [{
        type: "range",
        field: "length_seconds",
        from: 1440,
        include_lower: true
      }],
      issuer: "245cloud"
    }
    
    $.ajax({
      type: 'POST',
      url: url,
      data: JSON.stringify(query),
      contentType: 'application/json',
      dataType: "text",
      success: (text) ->
        try
          result = JSON.parse(text.split('\n')[0]);
          if result.values && result.values.length
            for sm in result.values
              sm_id = sm.cmsid
              duration = sm.length_seconds * 1000
              title = sm.title
              artwork_url = sm.thumbnail_url
              url = "http://www.nicovideo.jp/watch/#{sm_id}"
              href = "nicovideo:#{sm_id}"
              
              $dom.append("""
                <div class='col-lg-2' style='min-height: 200px;'>
                  <a href='#{url}' target='_blank'>#{title}</a>
                  (#{Util.time(duration)})<br />
                  <br />
                  <img src=\"#{artwork_url}\" width='100px'/>
                  <a href=\"##{href}\" class='fixed_start'><img src='https://ruffnote.com/attachments/24353' /></a>
                  <!--<a href=\"#\" class='add_playlist btn btn-default'>追加</a>-->
                </div>
              """)
          
          callback() if callback
        catch
          console.error('server error or parse error')
    })
    