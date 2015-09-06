class Workload
  def self.doings
    query = " --data-urlencode 'where={\"is_done\":{\"$ne\": true}}'"
    query += " --data-urlencode 'where={\"createdAt\":{\"$gte\": \"#{self.ago(24) }\"}}'"
    self.res(query)
  end

  def self.chattings
    query = " --data-urlencode 'where={\"is_done\":true}' "
    query += " --data-urlencode 'where={\"createdAt\":{\"$lt\": \"#{self.ago(24)}\"}}'"
    query += " --data-urlencode 'where={\"createdAt\":{\"$gt\": \"#{self.ago(29)}\"}}'"
    self.res(query, ignore_doing: true)
  end

  def self.dones user_id = nil
    with_user = ''
    if user_id
      with_user = "--data-urlencode 'where={\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"#{user_id}\"}}}'"
    end
    query = " --data-urlencode 'where={\"is_done\":true}' "
    query += " --data-urlencode 'where={\"createdAt\":{\"$lte\": \"#{self.ago(29)}\"}}'"
    query += with_user
    query += " --data-urlencode 'limit=48'"
    self.res(query)
  end

  private
    def self.ago(min)
      (Time.now - min.minutes).utc.iso8601
    end

    def self.res q, ignore_doing: false
      query = "curl -X GET"
      query += " -H \"X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}\""
      query += " -H \"X-Parse-REST-API-Key: #{ENV['PARSE_REST_KEY']}\""
      query += " -G"
      query += q
      query += " --data-urlencode 'order=-createdAt'"
      #query += " --data-urlencode 'include=user'"
      query += " https://api.parse.com/1/classes/Workload"
      res = `#{query}`
      res = JSON.parse(res)['results']
      return res unless ignore_doing

      res.select{|item| item['is_done']} # self.chattingsの query = " --data-urlencode 'where={\"is_done\":true}' " がきかない？ための暫定対応
    end
end

