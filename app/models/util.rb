class Util
  def self.sync
    Workload.delete_all
    Music.delete_all
    facebook_ids = {} # facebook_id => true
    music_icons = {} # music_key => artwork_url
    Server.all.each do |server|
      next if server.url == ENV['HOST']
      url = "#{server.url}/api/workloads.json?limit=1000&type=dones"
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
        user = User.find_or_create_by(
          facebook_id: facebook_id
        )
        icon = "https://graph.facebook.com/#{facebook_id}/picture?height=40&width=40"
        user.icon = Base64.strict_encode64(open(icon).read)
        user.save!
      end
      music_icons.each do |music_key, artwork_url|
        puts artwork_url
        next unless music_key
        music = Music.find_or_create_by(
          key: URI.encode(music_key)
        )
        music.artwork_url = artwork_url
        music.icon = Base64.strict_encode64(open(artwork_url).read)
        music.save!
      end
    end
    puts 'done'
  end
 
  def self.exist? key
    File.exist?("tmp/#{key}")
  end

  def self.size key
    File.size("tmp/#{key}")
  end

  def self.get key
    File.open("tmp/#{key}", 'r').read
  end

  def self.save key, val
    File.open("tmp/#{key}", 'w') { |file| file.write(val) }
  end
end

