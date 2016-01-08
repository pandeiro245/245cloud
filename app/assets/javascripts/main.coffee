$(()->
  $('#nc').html('''
  <div id="header"></div>
  <div id="news"></div>
  <div id="contents"></div>
  <div data-react-class="StartBox" data-react-props="{}"></div>
  <div data-react-class="Dones" data-react-props="{}"></div>
  <div id="footer"></div>
  <div id="hatopoppo"></div>
  ''')
  Util.realtime()
  ruffnote(23854, 'header')
  ruffnote(18004, 'news')
  ruffnote(13477, 'footer')
)

window.ruffnote = (id, dom, callback=null) ->
  Ruffnote.fetch("pandeiro245/245cloud/#{id}", dom, callback)


