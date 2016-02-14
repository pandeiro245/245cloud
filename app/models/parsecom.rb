class Parsecom
  def self.import zip_path = nil
    User.delete_all
    ActiveRecord::Base.connection.execute('ALTER TABLE users AUTO_INCREMENT = 0')
    Workload.delete_all
    ActiveRecord::Base.connection.execute('ALTER TABLE workloads AUTO_INCREMENT = 0')
    Comment.delete_all
    ActiveRecord::Base.connection.execute('ALTER TABLE comments AUTO_INCREMENT = 0')
    self.fetch_zip zip_path if zip_path
    self.new.import
  end

  def self.fetch_zip zip_path
    f = open zip_path
    `rm -rf tmp/parsecom/*`
    `unzip #{f.path} -d tmp/parsecom`
    f.close
  end

  def initialize
    @from = Workload.last.created_at.to_date if Workload.count > 0
    @workload_path = 'tmp/parsecom/Workload.json'
    @user_path = 'tmp/parsecom/_User.json'
    @room_path = 'tmp/parsecom/Room.json'
    @comment_path = 'tmp/parsecom/Comment.json'
    @default_room = nil
    @room_ids = {}
    @user_hashs = {}
  end

  def import
    import_users
    import_workloads
    #Music.update_done_count

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
      begin
        facebook_id = u['authData']['facebook']['id']
      rescue
        facebook_id = u['facebook_id_str']
      end
      next unless facebook_id
      email = "#{facebook_id}@245cloud.com"
      user = User.find_or_create_by(
        email: email 
      )
      #user.name = u['name']
      user.facebook_id = facebook_id
      user.save!
      @user_hashs[u['objectId']] = user
    end
  end

  def import_workloads
    workloads = JSON.parse(File.open(@workload_path).read)['results']
    
    #workloads.select!{|w| w['createdAt'].to_time > @from} if @from

    #puts 'start to sort Workload'
    #workloads = workloads.sort!{|a, b| a['createdAt'].to_time <=> b['createdAt'].to_time}
    #puts 'end to sort Workload'

    queue = []
    workloads.each do |workload|
      next unless workload['user']
      user = @user_hashs[workload['user']['objectId']]

      workload2 = Workload.new(
        facebook_id: user.facebook_id,
        created_at: workload['createdAt'].to_time,
        title: workload['title'],
        artwork_url: workload['artwork_url'],
        created_at: workload['createdAt'].to_time,
        number: workload['number'],
        is_done: workload['is_done']
      )
      queue.push(workload2)
      if queue.count > 1000
        Workload.import queue
        queue = []
      end
    end
    Workload.import queue
  end

  def import_rooms
    #@default_room = Room.create_default_room
    @default_room = Comment.create!(body: 'いつもの部屋')
    JSON.parse(File.open(@room_path).read)['results'].each do |room|
      comment = Comment.create!(
        body: room['title'],
        created_at: room['createdAt'],
        #image_off: room['img_off'],
        #image_on: room['img_on'],
      )
      @room_ids[room['objectId']] = comment.id
    end
  end

  def import_comments
    queue = []
    comments = JSON.parse(File.open(@comment_path).read)['results']

    comments.each do |comment|
      user_hash = comment['user'] ? comment['user']['objectId'] : "eAYx93GzJ8"
      user = @user_hashs[user_hash]
      
      if comment['room_id']
        room_id = @room_ids[comment['room_id']]
      else
        room_id = @default_room.id
      end

      comment2 = Comment.new(
        body: comment['body'],
        created_at: comment['createdAt'],
        facebook_id:  user.facebook_id,
        parent_id: room_id
      )
      queue.push(comment2)
      if queue.count > 1000
        Comment.import queue
        queue = []
      end
    end
    Comment.import queue
  end
end
