class ParsecomWorkload
  def self.sync(skip=0)
    data = ParsecomUser.user2facebook
    count = self.count
    while skip < count
      ws = self.fetch(skip)
      ws.each do |w|
        begin
          user_id = w['user']['objectId']
          facebook_id = data[user_id] || '10152403406713381'
        rescue
          facebook_id = '10152403406713381'
        end
        puts "facebook_id is #{facebook_id}"

        workload = Workload.find_or_create_by(
          facebook_id: facebook_id,
          created_at: w['createdAt'].to_time
        )

        workload.key = self.get_key(w)
        workload.is_done = w['is_done']
        workload.title = w['title']
        workload.number = w['number']
        workload.artwork_url = w['artwork_url']
        workload.save!
      end
      skip+=1000
      puts "skip is #{skip}"
    end
  end

  def self.get_key w
    if w['sc_id']
      key = "soundcloud:#{w['sc_id']}"
    elsif w['mc_id']
      key = URI.decode("mixcloud:#{w['mc_id']}")
    elsif w['yt_id']
      key = "mixcloud:#{w['yt_id']}"
    elsif w['et_id']
      key = "8tracks:#{w['et_id']}"
    elsif w['sm_id']
      key = "nicovideo:#{w['sm_id']}"
    else
      key = ''
    end
    key
  end

  def self.count
    res = `curl -X GET \
      -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
      -H "X-Parse-MASTER-Key: #{ENV['PARSE_MASTER_KEY']}"\
      --data-urlencode 'count=1' \
      https://api.parse.com/1/classes/Workload`
    JSON.parse(res)['count']
  end

  def self.fetch(skip=0)
    # 1000件
    res = `curl -X GET \
      -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
      -H "X-Parse-MASTER-Key: #{ENV['PARSE_MASTER_KEY']}"\
      --data-urlencode 'limit=1000' \
      --data-urlencode 'skip=#{skip}' \
      https://api.parse.com/1/classes/Workload`
    JSON.parse(res)['results']
  end
end
