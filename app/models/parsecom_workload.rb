class ParsecomWorkload
  def self.sync
    data = ParsecomUser.user2facebook
    ParsecomWorkload.all.each do |w|
      begin
        user_id = w['user']['objectId']
        facebook_id = data[user_id] || '10152403406713381'
      rescue
        facebook_id = '10152403406713381'
      end
      puts "facebook_id is #{facebook_id}"
      workload = Workload.find_or_create_by(
        facebook_id: facebook_id,
        created_at: w['createdAt']
      )
      workload.key = self.get_key(w)
      workload.is_done = w['is_done']
      workload.title = w['title']
      workload.save!
    end
  end

  def self.get_key w
    if w['sc_id']
      key = "soundcloud:#{w['sc_id']}"
    elsif w['mc_id']
      key = "mixcloud:#{w['mc_id']}"
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

  def self.all
    # 1000件
    res = `curl -X GET \
      -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
      -H "X-Parse-MASTER-Key: #{ENV['PARSE_MASTER_KEY']}"\
      --data-urlencode 'limit=999999' \
      https://api.parse.com/1/classes/Workload`
    JSON.parse(res)['results']
  end
end
