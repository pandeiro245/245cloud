class Util
  def self.sync
    facebook_ids = {} # facebook_id => true
    music_icons = {} # music_key => artwork_url
    url = 'http://245cloud.com/api/workloads.json?limit=1000&type=dones'
    uri = URI.parse(url)
    json = Net::HTTP.get(uri)
    JSON.parse(json).each do |w|
      created_at = Time.at(w['created_at']/1000)
      facebook_id = w['facebook_id']
      facebook_ids[facebook_id] = true
      workload = Workload.find_or_create_by(
        created_at: created_at,
        facebook_id: facebook_id
      )
      %w(is_done music_key title artwork_url number).each do |key|
        workload.send("#{key}=", w[key])
      end
      music_icons[w['music_key']] = w['artwork_url']
      workload.save!
    end
    facebook_ids.keys.each do |facebook_id|
      `wget -O tmp/facebook/icons/#{facebook_id} https://graph.facebook.com/#{facebook_id}/picture?height=40&width=40`
    end
    music_icons.each do |music_key, artwork_url|
      puts artwork_url
      next unless music_key
      music_key = music_key.gsub(/\//, '_')
      `wget -O tmp/musics/icons/#{music_key} #{artwork_url}`
    end
    puts 'done'
  end
 
  def self.exist? key
    File.exist?("/tmp/#{key}")
  end

  def self.size key
    File.size("/tmp/#{key}")
  end

  def self.get key
    File.open("/tmp/#{key}", 'r').read
  end

  def self.save key, val
    File.open("/tmp/#{key}", 'w') { |file| file.write(val) }
  end
end

