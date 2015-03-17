class CommentsController < ApplicationController
  # GET /rooms/#{room_id}/comments
  def index
    # TODO このAPIのデータを返したら未読数をアップデートする
    room_id = params[:room_id].to_i
    @comments = Comment.where(room_id: room_id)
    render json: @comments
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.room_id = params[:room_id].to_i
    if @comment.save
      render json: @comment
    else
      render json: 'ng...'
    end
  end

  private
    def comment_params
      params.permit(:content)
    end
end

