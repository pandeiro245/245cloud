$ ->
  if $('#gakkison').length
    $audio = $('<audio></audio>')
    $audio.css('width', '1px')
    $audio.attr('id', 'mp3')
    $audio.attr('src', '/audio/Zihou01-4.mp3')
    $('#gakkison').append($audio)

  $('#gakkison a').on('click', (e) ->
    audio = document.getElementById("mp3")
    audio.play()
  )
