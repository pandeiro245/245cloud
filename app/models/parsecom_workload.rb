class ParsecomWorkload < ParseResource::Base
  fields :workload_id, :sc_id, :mc_id, :yt_id, :et_id, :sm_id, :is_done, :number, :artwork_url, :title


  def self.hoge!
    Workload.delete_all
    ActiveRecord::Base.connection.execute('ALTER TABLE workloads AUTO_INCREMENT = 0')
    self.order('createdAt asc').where(host: '245cloud.com').limit(999999).each do |parse_workload|
      if parse_workload.attributes['workload_id'] 
        parse_workload.workload_id = nil
        parse_workload.save
      else
        return
      end
    end
  end

  def self.sync
    #self.where(workload_id: nil).order('createdAt asc').each do |parse_workload|
    #self.where(workload_id: nil).order('createdAt desc').each do |parse_workload|
    
    self.limit(100).order('createdAt desc').each do |parse_workload|
    #self.limit(5).order('createdAt desc').each do |parse_workload|
      workload = parse_workload.attributes

      puts workload['createdAt']

      next if workload['user'].nil?

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

      workload2 = Workload.find_or_initialize_by(
        parsecomhash: workload['objectId']
      )

      user = User.find_by(parsecomhash: workload['user']['objectId'])

      unless workload2.id
        workload2.user_id = user.id
        workload2.created_at =  workload['createdAt'].to_time
        workload2.place_id = workload['place_id']
        workload2.music_id = music.id if music
      else
        workload2.number = workload['number']
      end
       
      workload2.status = workload['is_done'] ? 1 : 0

      workload2.save!

      parse_workload.workload_id = workload2.id
      parse_workload.save unless parse_workload.workload_id.to_i == workload2.id

      puts "done: workload.id = #{workload2.id}"
    end
    puts 'done'
    ParsecomUser.sync(true)
    ParsecomComment.sync(true)
    puts "sleep 60sec..."
    sleep 60
    self.sync
  end
end

