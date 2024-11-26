class Prompt
  def goal
    'このlintエラーをなおしたい app/models/instance.rb:37:11: C: [Correctable] Style/IdenticalConditionalBranches: Move workload.update(api_data) out of the conditional.'
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
      # 'app/javascript/controllers/timer_controller.js',

      # view
      # 'app/views/musics/index.html.haml',
      # 'app/views/users/show.html.haml',
      # 'app/views/home/index.html.slim',
      # 'app/views/home/_footer.html.slim',
      # 'app/views/home/_hatopoppo.html.slim',

      # helper
      # 'app/helpers/application_helper.rb',
      # 'app/views/home/index.html.slim',
      # 'app/views/home/_footer.html.slim',
      # 'app/views/home/_hatopoppo.html.slim',

      # controller
      # 'app/controllers/application_controller.rb',
      # 'app/controllers/users_controller.rb',
      # 'app/controllers/home_controller.rb',

      # model
      'app/models/instance.rb',
      # 'app/models/access_log.rb',
      # 'app/models/workload.rb',
    ]
  end
end
