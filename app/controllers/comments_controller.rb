class CommentsController < ApplicationController
  # GET /rooms/#{room_id}/comments
  def index
    # TODO このAPIのデータを返したら未読数をアップデートする
    room_id = params[:room_id].to_i
    room_id = nil if room_id == 0
    @comments = Comment.where(room_id: room_id)
    render json: @comments
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      render json: 'ok'
    else
      render json: 'ng...'
    end
  end

  private
    def comment_params
      params.permit(:content)
    end
end

