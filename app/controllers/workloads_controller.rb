class WorkloadsController < ApplicationController
  def dones
    res = `curl -X GET \
  -H "X-Parse-Application-Id: #{ENV['PARSE_APP_ID']}" \
  -H "X-Parse-REST-API-Key: #{ENV['PARSE_REST_KEY']}" \
  -G \
  --data-urlencode 'where={"is_done":true}' \
  --data-urlencode 'order=-createdAt' \
  --data-urlencode 'limit=48' \
  https://api.parse.com/1/classes/Workload`

    render json: JSON.parse(res)['results']
  end
end
