class ParsecomWorkload < ParseResource::Base
  fields :workload_id, :sc_id, :mc_id, :yt_id, :et_id, :sm_id, :is_done, :number, :artwork_url, :title

  def self.sync
    self.where(workload_id: nil).order('createdAt asc').each do |parse_workload|
      workload = parse_workload.attributes

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
        parsehash: workload['objectId']
      )

      user = User.find_by(parsecomhash: workload['user']['objectId'])

      unless workload2.id
        workload2.user_id = user.id
        workload2.created_at =  workload['createdAt'].to_time
        workload2.number = workload['number']
        workload2.place_id = workload['place_id']
        workload2.status = workload['is_done'] || 0
        workload2.music_id = music.id if music
        workload2.save!
      end
      parse_workload.workload_id = workload2.id
      parse_workload.save

      puts "done: workload.id = #{workload2.id}"
    end
    puts 'done'
  end
end

