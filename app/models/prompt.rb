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
      'config/importmap.rb',
      'package.json',
      'app/javascript/controllers/index.js',
    ]
  end
end
