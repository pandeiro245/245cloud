class Api::AccessLogsController < ApplicationController
  def create
    facebook_id = current_user ? current_user.facebook_id : nil
    access_log = AccessLog.create!(
      facebook_id: facebook_id,
      url: params[:url]
    )
    render json: access_log
  end
end
