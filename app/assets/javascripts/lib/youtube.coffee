class @Youtube
  window.onJSClientLoad = () ->
    gapi.client.setApiKey(@env.yt_client_id)
    gapi.client.load('youtube', 'v3', makeRequest)

  window.makeRequest = () ->
    if location.hash.match(/youtube/)
      id = location.hash.split(':')[1]
      Youtube.fetch(id, (data) ->
        track = data['items'][0]['snippet']
        artwork_url = artworkUrlWithNoimage(track['thumbnails']['default']['url'])
        txt = "<h5>#{track['title']}</h5>"
        $('#fixedstart').append(txt)
        txt = "<img src='#{artwork_url}' class='jacket'>"
        $('#fixedstart').append(txt)
        Util.addButton('start', $('#fixedstart'), fixed_text, start_hash)
        $('#fixedstart').fadeIn()
        $('#random').removeClass("col-sm-offset-#{getOffset(2)}")
        $('#random').addClass("col-sm-offset-#{getOffset(3)}")
      )

  fixed_text = [
    'https://ruffnote.com/attachments/24921'
    'https://ruffnote.com/attachments/24922'
  ]

  getOffset = (all_count) ->
    return 0 if all_count >= 5
    data = {
      1: 5
      2: 4
      3: 3
      4: 2
    }
    data[all_count]

  artworkUrlWithNoimage = (artwork_url) ->
    artwork_url || @nomusic_url

  @fetch: (yt_id, callback) ->
    console.log 'youtube', yt_id
    requestOptions = {
      id: yt_id
      part:"id, snippet, contentDetails, player, statistics, status, topicDetails,recordingDetails"
    }

    request=gapi.client.request({
      mine:"",
      path:"/youtube/v3/videos",
      params:requestOptions
    })
    request.execute((resp) ->
      if resp.error
        console.log 'error'
        console.log resp.error.message
      else
        #output(resp,pageToken)
        callback(resp)
    )
    
  @play: (youtube_key, $dom, is_autoplay=true, start_sec=0) ->
    console.log 'youtube_key', youtube_key
    $dom.html("""
      <iframe width="560" height="315" src="//www.youtube.com/embed/#{youtube_key}?autoplay=#{if is_autoplay then '1' else '0'}&start=#{start_sec}" frameborder="0" allowfullscreen></iframe>
    """)

  @search: (keyword, $dom, callback=null) ->
    requestOptions = {
      q: keyword,
      type: 'video',
      part:"id, snippet",
      videoDuration: 'long'
    }

    request=gapi.client.request({
      mine:"",
      path:"/youtube/v3/search",
      params:requestOptions
    })
    request.execute((resp) ->
      if resp.error
        console.log 'error'
        console.log resp.error.message
      else
        tracks = resp['items']
        if tracks[0]
          for data in tracks
            id = data['id']['videoId']
            url = "https://www.youtube.com/watch?v=#{id}"
            track = data['snippet']
            title = track['title']
            artwork_url = artworkUrlWithNoimage(track['thumbnails']['default']['url'])
            #duration = youtubeDurationSec(data) * 1000
            duration = 1000
            artwork = "<img src=\"https://ruffnote.com/attachments/24162\" width='100px'/>"
            if artwork_url
              artwork = "<img src=\"#{artwork_url}\" width='100px'/>"
            href = "youtube:#{id}"
            $dom.append("""
              <div class='col-lg-2' style='min-height: 200px;'>
                <a href='#{url}' target='_blank'>#{title}</a>
                <!--(#{Util.time(duration)})<br />-->
                <br />
                #{artwork}
                <a href=\"##{href}\" class='fixed_start'><img src='https://ruffnote.com/attachments/24353' /></a>
                <!--<a href=\"#\" class='add_playlist btn btn-default'>追加</a>-->
              </div>
            """)
          callback() if callback
        else
          $dom.append("<div>「#{keyword}」YouTubeCloudにはで24分前後の曲はまだ出てないようです...。他のキーワードで探してみてください！</div>")
    )
   
