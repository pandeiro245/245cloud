class Api::AccessLogsController < ApplicationController
  facebook_id = current_user ? current_user.facebook_id : nil
  access_log = AccessLog.create!(
    facebook_id: facebook_id,
    url: params[:url]
  ).decorate
  render json: access_log
end
