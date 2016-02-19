class Workload < ActiveRecord::Base
  def self.sync
    url = 'http://245cloud.com/api/dones.json?limit=1000'
    uri = URI.parse(url)
    json = Net::HTTP.get(uri)
    JSON.parse(json).each do |w|
      created_at = Time.at(w['created_at']/1000)
      workload = Workload.find_or_create_by(
        created_at: created_at,
        facebook_id: w['facebook_id']
      )
      puts "key is #{w['key']}"
      %w(is_done music_key title artwork_url number).each do |key|
        if key == 'music_key'
          workload.music_key = w['key']
        else
          workload.send("#{key}=", w[key])
        end
      end
      workload.save!
    end
    puts 'done'
  end

  def self.pomotime
    24.minutes
  end

  def self.chattime
    5.minutes
  end

  def self.your_bests user, limit=48
    Workload.where(
      is_done: true,
      facebook_id: user.facebook_id
    ).where.not(music_key: '').group(:music_key).order(
      'count_music_key desc'
    ).count('music_key').to_a.map{|music_key, count| 
      w = Workload.find_by(
        facebook_id: user.facebook_id,
        music_key: music_key
      )
      w.number = count
      w
    }
  end

  def self.yours user, limit=48
    Workload.where(
      is_done: true,
      facebook_id: user.facebook_id
    ).limit(limit).order('created_at desc')
  end

  def self.playings
    limit = 200
    from = Time.now - self.pomotime
    to   = Time.now
    Workload.where(
      created_at: from..to,
    ).limit(limit).order('created_at desc')
  end

  def self.chattings
    limit = 200
    from = Time.now - self.pomotime - self.chattime
    to   = Time.now-self.pomotime
    Workload.where(
      is_done: true,
      created_at: from..to,
    ).limit(limit).order('created_at desc')
  end


  def self.dones limit=48
    Workload.where(is_done: true).limit(limit).order('created_at desc')
  end

  def next_number
    to = created_at || Time.now
    to -= Workload.pomotime
    from = to.to_date.beginning_of_day
    Workload.where(
      facebook_id: facebook_id,
      created_at: from..to,
      is_done: true
    ).count + 1
  end

  def update_number!
    self.number = next_number
    self.save!
  end

  def self.update_numbers
    self.where(is_done: true).order('created_at desc').each do |w|
      w.update_number!
    end
  end

  def self.wrongs
    self.where('title is not null').where(music_key: nil)
  end

  def self.recover!
    self.wrongs.each do |w|
      if w.artwork_url.match(/smilevideo.jp/)
        Nicovideo.search(w.title).each do |item|
          if item.thumbnail_url == w.artwork_url
            w.music_key = "nicovideo:#{item.cmsid}"
          end
        end
        unless w.music_key
          id =  w.artwork_url.split('smilevideo.jp/smile?i=').last
          w.music_key = "nicovideo:sm#{id}"
          puts w.music_key
        end
        w.save!
      end
    end
  end
end
