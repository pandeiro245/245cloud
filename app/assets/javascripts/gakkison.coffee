$ ->
  if $('#gakkison').length
    for key in ['bd', 'hh', 'sd']
      $audio = $('<audio></audio>')
      $audio.css('width', '1px')
      $audio.attr('id', key)
      $audio.attr('src', "/audio/gakkison/dr1/#{key}.mp3")
      $('#gakkison').append($audio)
      $("#gakkison a").on('click', (e) ->
        console.log $(e.currentTarget).attr('id')
        key = $(e.currentTarget).attr('id').replace(/link_/, '')
        audio = document.getElementById(key)
        audio.pause()
        audio.currentTime = 0
        audio.play()
      )
  Leap.loop((frame) ->

    now = new Date()
    sec8 = now.getTime() % (8 * 1000)
    msec = now.getMilliseconds()
    sec = frame.hands.length
    if sec && msec % (500 / 4 ) < 50 && sec8 < 6 * 1000
      #audio = document.getElementById('sd')
      #audio = document.getElementById('bd')
      audio = document.getElementById('hh')
      #console.log audio.currentTime
      audio.pause()
      audio.currentTime = 0
      audio.play()
    if sec && msec % 500 < 50
      audio = document.getElementById('bd')
      audio.pause()
      audio.currentTime = 0
      audio.play()
    if sec && (msec + 500) % 1000 < 50 && sec8 < 6 * 1000
      audio = document.getElementById('sd')
      audio.pause()
      audio.currentTime = 0
      audio.play()

  )
