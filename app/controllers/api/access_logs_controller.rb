class Api::AccessLogsController < ApplicationController
  def create
    user_id = current_user ? current_user.id : nil
    access_log = AccessLog.create!(
      user_id: user_id,
      url: params[:url]
    )
    render json: access_log
  end
end
