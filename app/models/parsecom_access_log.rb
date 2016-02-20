class ParsecomAccessLog
  def self.sync(skip=0)
    data = ParsecomUser.user2facebook
    count = self.count
    puts "count is #{count}"
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

        workload = AccessLog.find_or_create_by(
          facebook_id: facebook_id,
          created_at: w['createdAt'].to_time
        )

        workload.url = w['url']
        workload.save!
      end
      skip+=1000
      puts "skip is #{skip}"
    end
  end

  def self.count
    res = `curl -X GET \
      -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
      -H "X-Parse-MASTER-Key: #{ENV['PARSE_MASTER_KEY']}"\
      --data-urlencode 'count=1' \
      https://api.parse.com/1/classes/AccessLog`
    JSON.parse(res)['count']
  end

  def self.fetch(skip=0)
    # 1000件
    res = `curl -X GET \
      -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
      -H "X-Parse-MASTER-Key: #{ENV['PARSE_MASTER_KEY']}"\
      --data-urlencode 'limit=1000' \
      --data-urlencode 'skip=#{skip}' \
      https://api.parse.com/1/classes/AccessLog`
    JSON.parse(res)['results']
  end
end
