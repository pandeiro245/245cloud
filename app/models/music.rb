class Music < ActiveRecord::Base
  has_many :workloads
  def self.import
    path = '/Users/nishiko/Downloads/b72cfac2-f5d8-4fd3-a305-ffb486c4d9da_1427114248_export/Music.json'
    f = JSON.parse(File.open(path).read)['results']
    return f
  end
end

