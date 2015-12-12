$ ->
  return unless $('#np').length
  Util.scaffolds([
    ['header', {is_row: false}]
    'news'
    'appearin'
    'calendar'
    'footer'
  ], 'np')
  Util.realtime()
  ruffnote(23812, 'header')
  #ruffnote(23813, 'news')
  ruffnote(23814, 'footer')
  initAppearin()
  initCalendar()

initAppearin =->
  $('#appearin').html('<iframe src="https://appear.in/245pitch" width="800" height="640" frameborder="0"></iframe>')

initCalendar = ->
  ParseParse.all('Pitch', (data) ->
    pitches = {}
    for pitch in data
      pitches[pitch.get('startAt').getTime()] = pitch

    now = new Date()
    $(document).on('click', '.apply', ()->
      unless user = Parse.User.current()
        alert '245cloudにログインしてから操作してください（あとでこっちからもログインできるようにしますね...）'
        location.href = '/'

      params = {startAt: new Date(parseInt($(this).attr('data-start')))}
      console.log params

      if $(this).hasClass('do')
        params['type'] = 'do'
        ParseParse.create('Pitch', params, ->
          alert 'ピッチの登壇予約が完了しました！'
          location.reload()
        )
      else
        params['type'] = 'watch'
        ParseParse.create('Pitch', params, ->
          alert 'ピッチの応援予約が完了しました！'
          location.reload()
        )
    )

    utime = now.getTime()
    wdays = ['日', '月', '火', '水', '木', '金', '土']
    button = "<button class='btn btn-primary'>申し込む</btton>"
    ths = """
    <tr>
      <th colspan='2'>&nbsp;</th>
      <th>08:00〜</th>
      <th>12:00〜</th>
      <th>16:00〜</th>
      <th>20:00〜</th>
    </tr>
    """
    wantdo = "<table class='table table-bordered'>#{ths}"
    wantwatch = "<table class='table table-bordered'>#{ths}"

    for i in [0..30]
      target = new Date(utime + i*24*3600*1000)

      wantdo += """
        <tr>
          <th>#{target.getMonth()+1}/#{target.getDate()} </th>
          <th>#{wdays[target.getDay()]}</th>
      """
      for i in ['08:00', '12:00', '16:00', '20:00']
        start = new Date("#{1900+target.getYear()}-#{target.getMonth()+1}-#{target.getDate()} #{i}")
        wantdo += "<td style='vertical-align:bottom;'>"
        if start.getTime() < now.getTime()
          wantdo += "<button class='btn btn-disabled cancel do' data-start=#{start.getTime()}>終了</btton></td>"
        else if pitch = pitches[start.getTime()]
          wantdo += "<img src='#{pitch.get('icon_url')}' style='margin:6px; '/>"
          if pitch.get('user').get('id') == Parse.User.current().get('id')
            wantdo += "<button class='btn btn-danger cancel do' data-start=#{start.getTime()}>キャンセル</btton>"
          wantdo += "</td>"
        else
          wantdo += "<button class='btn btn-primary apply do' data-start=#{start.getTime()}>申し込む</btton></td>"
      wantdo += "</tr>"

      wantwatch += """
        <tr>
          <th>#{target.getMonth()+1}/#{target.getDate()} </th>
          <th>#{wdays[target.getDay()]}</th>
      """
      for i in ['08:00', '12:00', '16:00', '20:00']
        start = new Date("2015-#{target.getMonth()+1}-#{target.getDate()} #{i}")
        wantwatch += "<td><button class='btn btn-primary apply do' data-start=#{start.getTime()}>申し込む</btton></td>"
      wantwatch += "</tr>"
      wantwatch += "</tr>"


    wantdo += '</table>'
    wantwatch += '</table>'
    html = """
    <h2>ピッチしたい</h2>
    #{wantdo}
    <h2>ピッチ観たい</h2>
    #{wantwatch}
    """
    $('#calendar').html(html)
  )
