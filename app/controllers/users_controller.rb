class UsersController < ApplicationController
  def index
    res = `curl -X GET \
  -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
  -H "X-Parse-REST-API-Key: #{ENV['PARSE_REST_KEY']}" \
  https://api.parse.com/1/users`
    render json: JSON.parse(res)['results']
  end

  def show
    res = `curl -X GET \
  -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
  -H "X-Parse-REST-API-Key: #{ENV['PARSE_REST_KEY']}" \
  https://api.parse.com/1/users/#{params[:id]}`
    render json: JSON.parse(res)
  end
end
