class Prompt
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
      'server.sh',
      'config/puma.rb',

      # 'config/importmap.rb',
      # 'package.json',
      # 'app/javascript/controllers/index.js'
    ]
  end
end
