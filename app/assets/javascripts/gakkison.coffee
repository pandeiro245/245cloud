window.is_active = false
window.dateDiff = 0
window.mp = 100.000

#hash = location.hash
#if hash.match(/[0-9]/)
#  window.bpm = parseInt(hash.replace(/#/, ''))
#else
#  window.bpm  = 120
window.bpm  = 131

window.jsont = (data) ->
  nowDate = Date.now()
  window.dateDiff = ((data.st * 1000) + ((nowDate - (data.it * 1000)) / 2)) - nowDate
  init()

exactTime = () ->
  serverList = [
    'https://ntp-a1.nict.go.jp/cgi-bin/jsont',
    'http://ntp-a1.nict.go.jp/cgi-bin/jsont',
    'https://ntp-b1.nict.go.jp/cgi-bin/jsont',
    'http://ntp-b1.nict.go.jp/cgi-bin/jsont'
  ]
  scriptE = document.createElement('script')
  serverUrl = serverList[Math.floor(Math.random() * serverList.length)]
  scriptE.src = serverUrl + '?' + (Date.now() / 1000)
  document.body.appendChild(scriptE)

$ ->
  if $('#gakkison').length
    exactTime()

window.key = () ->
  $('#keypressBar').css('width', "#{parseInt(window.mp)}%")

  if window.is_active && window.mp > 0
    exec(true)
    window.mp -= 0.07 * Math.random()
  else
    if !window.is_active && window.mp <= 100
      window.mp += 0.5
  #console.log window.mp
  setTimeout("window.key()", 1)

exec = (is_active=true) ->
  #console.log is_active
  #now = new Date()
  now = new Date(Date.now() + window.dateDiff)

  #sec8 = now.getTime() % (8 * 1000)
  #is_break = sec8 < 6 * 1000
  is_break = false

  #msec = now.getMilliseconds() * window.bpm / 120
  #msec = now.getMilliseconds()
  msec = now.getTime()

  if msec % (250 * 120 / window.bpm) < 50 && !is_break && is_active
    audio = document.getElementById('hh')
    audio.pause()
    audio.currentTime = 0
    audio.play()

  if msec % (1000 * 120 / window.bpm) < 50 && is_active
    audio = document.getElementById('bd')
    audio.pause()
    audio.currentTime = 0
    audio.play()

  if (msec + 500) % (1000 * 120 / window.bpm) < 50 && !is_break && is_active
    audio = document.getElementById('sd')
    audio.pause()
    audio.currentTime = 0
    audio.play()

#exec2 = (is_active=true) ->
#  console.log('exec2', is_active)
#  now = new Date(Date.now() + window.dateDiff)
#  msec = now.getMilliseconds()
#  if msec % 1000 < 50 && is_active
#    audio = document.getElementById('cc')
#    audio.pause()
#    audio.currentTime = 0
#    audio.play()

init = ()->
  if $('#gakkison').length
    for key in ['bd', 'hh', 'sd', 'cc']
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
  #    x = hand.screenPosition()[0]
  #    console.log x
  #    #exec2(x < 500)
  #    exec2(x < 500)
  #}).use('screenPosition')

  window.key()

