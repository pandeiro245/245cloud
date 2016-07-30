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
        audio.play()
      )
