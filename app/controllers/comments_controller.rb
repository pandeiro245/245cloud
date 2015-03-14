class CommentsController < ApplicationController
  # GET /rooms/#{room_id}/comments
  def index
    # TODO このAPIのデータを返したら未読数をアップデートする
    render json: Comment.all
  end
end
