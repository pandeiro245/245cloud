class Parsecom
  def self.import
    MusicsUser.delete_all


    user_hashs = {}

    path = 'tmp/parsecom/_User.json'
    users = JSON.parse(File.open(path).read)['results']
    users = users.sort!{|a, b| 
      a['createdAt'].to_time <=> b['createdAt'].to_time
    }
    users.each do |u|
      facebook_id = u['authData']['facebook']['id']
      email = "#{facebook_id}@245cloud.com"
      user = User.find_by(
        email: email 
      )
      unless user
        user = User.create!(
          email: email,
          password: Devise.friendly_token[0, 20]
        )
      end
      user_hashs[u['objectId']] = user
    end

    path = 'tmp/parsecom/Workload.json'
    workloads = JSON.parse(File.open(path).read)['results']

    puts 'start to sort Workload'
    #workloads = workloads.sort!{|a, b| a['createdAt'].to_time <=> b['createdAt'].to_time}
    puts 'end to sort Workload'

    workloads.each do |workload|
      id = nil
      key = nil
      if id = workload['sc_id']
        key = 'sc'
      elsif id = workload['mc_id']
        key = 'mc'
      elsif id = workload['yt_id']
        key = 'yt'
      elsif id = workload['et_id']
        key = 'et'
      end
      if id
        music = Music.find_or_create_by(
          key: "#{key}:#{id}"
        )
        music.title = workload['title']
        music.icon = workload['artwork_url']
        music.save!
      end
     
      next unless workload['user']
      user = user_hashs[workload['user']['objectId']]

      if music 
        msuic_user = MusicsUser.find_or_create_by(
          music_id: music.id,
          user_id: user.id,
        )
        msuic_user.total += 1
        msuic_user.save!
      end

      workload2 = Workload.find_or_create_by(
        user_id: user.id,
        created_at: workload['createdAt'].to_time
      )

      workload2.is_done = workload['is_done']
      workload2.music_id = music.id if music
      workload2.save!
    end
    puts 'done'
  end
end

