class @Nicovideo
  @fetch: (sm_id, callback) ->
    console.log 'nicovideo', sm_id # sm_id: 'smXXXXXXX'
    url = "./nicovideo/#{sm_id}"

    url = "./nicoinfo/#{sm_id}"

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
    unless confirm('この曲はニコニコ動画経由なので自分で再生ボタンを押すまで再生されなかったり最新のFLASHプレイヤーが必要だったり、ニコニコ動画にログインしていないと読み込みが遅かったりしますが大丈夫でしょうか？（対応策模索中）')
      location.reload()

    # see http://mementoo.info/archives/1557
    document._write = document.write
    document.write = (msg) ->
      $dom.html(msg)
      document.write = document._write

    # append する前に src を設定しちゃうと iframe が head の中に入っちゃう.
    # …ので、append した後に src を設定する.
    script = document.createElement('script')
    $dom.append(script)
    script.src = "//ext.nicovideo.jp/thumb_watch/#{sm_id}"

  @search: (keyword, $dom, callback=null) ->
    # url = "//api.search.nicovideo.jp/api/snapshot/"
    url = "//api.search.nicovideo.jp/api/v2/snapshot/video/contents/search"
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
              url = "//www.nicovideo.jp/watch/#{sm_id}"
              href = "nicovideo:#{sm_id}"
              $dom.append(
                Util.renderTrack('nicovideo', url, title, artwork_url, href, Util.time(duration), 'television')
              )
          callback() if callback
        catch
          console.error('server error or parse error')
    })
