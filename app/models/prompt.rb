class Prompt
  RSPEC_RESULT_PATH = Rails.root.join('tmp/rspec_result.txt')
  RUBOCOP_RESULT_PATH = Rails.root.join('tmp/rubocop_result.txt')

  def goal
    '/prompt_rspec にアクセスしたらRspecを修正するたねのプロンプトを生成させるために Prompt.new.rspec_resultで bundle exec rspecの実行結果を返すようにしたい'
  end

  def rspec_result
    # 結果ファイルが存在しない場合は実行中または未実行のメッセージを返す
    return 'RSpec実行結果はまだ生成されていません。script/run_rspec.shを実行してください。' unless File.exist?(RSPEC_RESULT_PATH)

    # ファイルの更新時刻を確認
    file_age = Time.zone.now - File.mtime(RSPEC_RESULT_PATH)
    return "RSpec実行結果が1時間以上前のものです。新しい結果を取得するにはscript/run_rspec.shを実行してください。\n\n#{File.read(RSPEC_RESULT_PATH)}" if file_age > 1.hour

    # 結果ファイルを読み取って返す
    File.read(RSPEC_RESULT_PATH).force_encoding('UTF-8')
  rescue StandardError => e
    "RSpec結果の読み取り中にエラーが発生しました: #{e.message}"
  end

  def rubocop_result
    @rubocop_result ||= File.read(RUBOCOP_RESULT_PATH).force_encoding('UTF-8')
  end

  def spec_codes
    hash = {}
    spec_paths = [
      # テストファイル
      Rails.root.glob('spec/**/*_spec.rb'),
      # ヘルパーファイル
      Rails.root.glob('spec/rails_helper.rb'),
      Rails.root.glob('spec/spec_helper.rb'),
      # ファクトリーファイル
      Rails.root.glob('spec/factories/*.rb'),
      # サポートファイル
      Rails.root.glob('spec/support/*.rb'),
    ].flatten

    spec_paths.each do |path|
      relative_path = Pathname.new(path).relative_path_from(Rails.root).to_s
      hash[relative_path] = File.read(path)
    end
    hash
  end

  def rubocop_codes
    hash = {}
    rubocop_paths.each do |path|
      hash[path] = File.read(path)
    end
    hash
  end

  def rubocop_paths
    text = rubocop_result

    filenames = text.lines.map do |line|
      if match = line.match(/^([^:]+):\d+/)
        match[1]
      end
    end
    filenames.compact.uniq
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
      'config/routes.rb',

      # js
      # 'config/importmap.rb',
      # 'package.json',
      # 'app/javascript/controllers/index.js',
      # 'app/javascript/controllers/timer_controller.js',
      # 'app/javascript/controllers/workload_countdown_controller.js',

      # view
      # 'app/views/musics/index.html.haml',
      # 'app/views/users/show.html.haml',
      # 'app/views/home/index.html.slim',
      # 'app/views/home/_workload.html.slim',
      # 'app/views/home/_playings.html.slim',
      # 'app/views/home/_chattings.html.slim',
      # 'app/views/home/_done.html.slim',
      # 'app/views/home/_playing.html.slim',
      # 'app/views/home/_chatting.html.slim',
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
      'app/controllers/home_controller.rb',

      # model
      'app/models/prompt.rb',
      # 'app/models/instance.rb',
      # 'app/models/access_log.rb',
      # 'app/models/workload.rb',
      # 'app/models/comment.rb',
      # 'app/models/user.rb',
      # 'app/models/music.rb',
      # 'app/models/concerns/workload_music_concern.rb',

      # service
      # 'app/services/number_calculator_service.rb',

      # spec
      # 'spec/spec_helper.rb',
      # 'spec/rails_helper.rb',
      # 'spec/models/workload_spec.rb',
      # 'spec/factories/users.rb',
      # 'spec/factories/workloads.rb',
    ]
  end
end
