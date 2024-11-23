class Prompt
  def goal
    # 'カウントダウン終了7秒前に /audio/Zihou01-4.mp3 を鳴らしたい'
    'developmentモードなのにjavascriptの更新がブラウザ表示に反映されない'
  end

  def codes
    hash = {}
    paths.each do |path|
      hash[path] = File.read(path)
    end
    hash
  end

  def paths
    [
      'Gemfile',

      # server
      # 'server.sh',
      # 'stop.sh',
      # 'restart.sh',
      'config/puma.rb',
      'config/application.rb',
      # 'config/environments/production.rb',
      'config/environments/development.rb',

      # js
      # 'config/importmap.rb',
      # 'package.json',
      # 'app/javascript/controllers/index.js',
      'app/javascript/controllers/timer_controller.js'

      # view
      # 'app/views/home/_footer.html.slim'
      # 'app/views/home/_hatopoppo.html.slim'
    ]
  end
end
