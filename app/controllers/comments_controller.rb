class CommentsController < ApplicationController
  def create
    @comment = Comment.new(comment_params)
    @comment.user_id = current_user.id
    @comment.save
    redirect_to room_path(@comment.room)
  end

  private
    def comment_params
      params.require(:comment).permit(:content, :room_id)
    end
end

