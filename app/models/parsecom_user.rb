class ParsecomUser
  def self.user2facebook
    data = {}
    self.all.each do |u|
      user_id = u['objectId']
      if u['authData'] and u['authData']['facebook']
        facebook_id = u['authData']['facebook']['id']
      else
        facebook_id = u['facebook_id_str']
      end
      data[user_id] = facebook_id
    end
    data
  end

  def self.update_password facebook_id
    user = self.find_by_facebook_id facebook_id
    user = self.create!(facebook_id) unless user
    id = user['objectId']
    username = user['username']
    password = SecureRandom.hex(16)
    
    res = `curl -X PUT \
      -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
      -H "X-Parse-MASTER-Key: #{ENV['PARSE_MASTER_KEY']}"\
      -H "Content-Type: application/json" \
      -d '{"password": "#{password}", "memo": "hoge of memo"}'\
      https://api.parse.com/1/users/#{id}`

    user = `curl -X GET \
    -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
    -H "X-Parse-REST-API-Key: #{ENV['PARSE_REST_KEY']}"\
    -H "X-Parse-Revocable-Session: 1" \
    -G \
    --data-urlencode 'username=#{username}' \
    --data-urlencode 'password=#{password}' \
    https://api.parse.com/1/login`

    # facebook_id_strが偽の値だったとき対策
    # raise 'データ不整合が発生したので西小倉までご連絡ください' if JSON.parse(user)['authData']['facebook']['id'].to_i  != facebook_id.to_i
    {
      username: username,
      password: password,
      res: JSON.parse(res) # 成功した場合updatedAtだけが返る
    }
  end

  def self.all
    res = `curl -X GET \
      -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
      -H "X-Parse-MASTER-Key: #{ENV['PARSE_MASTER_KEY']}"\
      --data-urlencode 'limit=9999' \
      https://api.parse.com/1/users`
    JSON.parse(res)['results']
  end

  def self.create! facebook_id
    `curl -X POST \
      -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
      -H "X-Parse-MASTER-Key: #{ENV['PARSE_MASTER_KEY']}"\
      -H "Content-Type: application/json" \
      -d '{"facebook_id_str": "#{facebook_id}", "password": "thispasswordwillbechangedsoon", "username": "fa#{facebook_id}"}'\
      https://api.parse.com/1/users`
    self.find_by_facebook_id facebook_id
  end

  def self.find_by_facebook_id facebook_id
    res = `curl -X GET \
      -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
      -H "X-Parse-MASTER-Key: #{ENV['PARSE_MASTER_KEY']}"\
      --data-urlencode 'where={"facebook_id_str": "#{facebook_id}"}'\
      https://api.parse.com/1/users`
    JSON.parse(res)['results'].first
  end

  def self.find id
    res = `curl -X GET \
      -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
      -H "X-Parse-MASTER-Key: #{ENV['PARSE_MASTER_KEY']}"\
      https://api.parse.com/1/users/#{id}`
    JSON.parse(res)
  end
end

