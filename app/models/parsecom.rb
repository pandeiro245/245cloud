class Parsecom
  def self.import
    self.new.import
  end

  def initialize
    @workload_path = 'tmp/parsecom/Workload.json'
    @user_path = 'tmp/parsecom/_User.json'
    @room_path = 'tmp/parsecom/Room.json'
    @comment_path = 'tmp/parsecom/Comment.json'
    @room_ids = {}
    @user_hashs = {}
  end

  def import
    import_users
    import_workloads
    import_rooms
    import_comments
    puts 'done'
  end

  def import_users
    users = JSON.parse(File.open(@user_path).read)['results']
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
          #password: Devise.friendly_token[0, 20]
        )
      end
      user.name = u['name']
      user.save!
      auth = Auth.find_or_initialize_by(
        provider: 'facebook',
        uid: facebook_id
      )
      auth.user_id = user.id
      auth.save!

      @user_hashs[u['objectId']] = user
    end
  end

  def import_workloads
    workloads = JSON.parse(File.open(@workload_path).read)['results']

    puts 'start to sort Workload'
    workloads = workloads.sort!{|a, b| a['createdAt'].to_time <=> b['createdAt'].to_time}
    puts 'end to sort Workload'

    workloads.each do |workload|
      id = nil
      key = nil
      if id = workload['sc_id']
        id = id.to_i.to_s
        key = 'sc'
      elsif id = workload['mc_id']
        key = 'mc'
      elsif id = workload['yt_id']
        key = 'yt'
      elsif id = workload['et_id']
        key = 'et'
      elsif id = workload['sm_id']
        key = 'sm'
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
      user = @user_hashs[workload['user']['objectId']]

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
        number: workload['number'],
        created_at: workload['createdAt'].to_time
      )

      workload2.status = workload['is_done'] || 0
      workload2.music_id = music.id if music
      workload2.save!
    end
    Music.all.each{|m| m.total_count = MusicsUser.where(music_id: m.id).count; m.save!}
  end

  def import_rooms
    JSON.parse(File.open(@room_path).read)['results'].each do |room|
      room2 = Room.create!(
        title: room['title'],
        created_at: room['createdAt'],
        image_off: room['img_off'],
        image_on: room['img_on'],
      )
      @room_ids[room['objectId']] = room2.id
    end
  end

  def import_comments
    JSON.parse(File.open(@comment_path).read)['results'].each do |comment|
      user_hash = comment['user'] ? comment['user']['objectId'] : "eAYx93GzJ8"
      user = @user_hashs[user_hash]
      Comment.create!(
        content: comment['body'],
        created_at: comment['createdAt'],
        user_id: user.id,
        room_id: @room_ids[comment['room_id']]
      )
    end
  end
end
