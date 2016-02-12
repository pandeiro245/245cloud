#class ParsecomUser < ParseUser
#  fields :name, :facebook_id_str, :user_id
#end

# deviseのUserとバッティングしているっぽいので
# parse_resource使わずにREST APIで動かす
# https://parse.com/docs/rest/guide#users-retrieving-users
class ParsecomUser

  def self.find_by_facebook_id facebook_id
    res = `curl -X GET \
      -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
      -H "X-Parse-REST-API-Key: #{ENV['PARSE_REST_KEY']}"\
      --data-urlencode 'where={"facebook_id_str": "#{facebook_id}"}'\
      https://api.parse.com/1/users`
    JSON.parse(res)['results'].first
  end


  def self.find id
    res = `curl -X GET \
      -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
      -H "X-Parse-REST-API-Key: #{ENV['PARSE_REST_KEY']}"\
      https://api.parse.com/1/users/#{id}`
    JSON.parse(res)
  end
end

