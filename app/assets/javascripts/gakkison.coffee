window.is_active = false

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
      $(document).on('keydown', (e) ->
        window.is_active = true
      )
      $(document).on('keyup', (e) ->
        window.is_active = false
      )

  #Leap.loop({
  #  hand: (hand)->
  #    height = hand.screenPosition()[0]
  #    console.log height
  #    exec(height < 1000)
  #}).use('screenPosition')

  window.key()

window.key = () ->
  exec(window.is_active)
  setTimeout("window.key()", 10)

exec = (is_active=true) ->
  now = new Date()
  sec8 = now.getTime() % (8 * 1000)
  msec = now.getMilliseconds()
  if location.hash == '#hh' && msec % (500 / 4 ) < 50 && sec8 < 6 * 1000 && is_active
    audio = document.getElementById('hh')
    audio.pause()
    audio.currentTime = 0
    audio.play()
  #if msec % 500 < 50
  #  audio = document.getElementById('bd')
  #  audio.pause()
  #  audio.currentTime = 0
  #  audio.play()

  if location.hash == '#bd' && msec % 500 < 50 && is_active
    audio = document.getElementById('bd')
    audio.pause()
    audio.currentTime = 0
    audio.play()


  if location.hash == '#sd' && msec % 500 < 50 && sec8 < 6 * 1000 && is_active
    audio = document.getElementById('sd')
    audio.pause()
    audio.currentTime = 0
    audio.play()


