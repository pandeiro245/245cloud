class UsersController < ApplicationController
  def show
    @user = User.find_or_create_by(
      facebook_id: params[:id]
    )
  end
end
