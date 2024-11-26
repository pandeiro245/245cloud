class Prompt
  def goal
    'Instance.fetchした時、すでに存在するworkloadレコードのis_doneがtrueになるのはいいがtrueになっているものがnilに戻るのは防ぎたい'
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
      # Basic
      # 'Gemfile',

      # server
      # 'server.sh',
      # 'stop.sh',
      # 'restart.sh',
      # 'config/puma.rb'
      # 'config/application.rb',
      # 'config/environments/production.rb',
      # 'config/environments/development.rb',

      # js
      # 'config/importmap.rb',
      # 'package.json',
      # 'app/javascript/controllers/index.js',
      # 'app/javascript/controllers/timer_controller.js'

      # view
      # 'app/views/home/_footer.html.slim'
      # 'app/views/home/_hatopoppo.html.slim'

      # controller
      # 'app/controllers/users_controller.rb'

      # model
      'app/models/instance.rb',
    ]
  end
end
