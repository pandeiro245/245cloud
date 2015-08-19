class CommentsController < ApplicationController
  def create
    if comment_params[:content].present?
      @comment = Comment.new(comment_params)
      @comment.user_id = current_user.id
      @comment.save
      @comment.save_with_parsecom!

      #redirect_to room_path(@comment.room)

      render json: 'ok'
    end
  end

  private
    def comment_params
      params.require(:comment).permit(:content, :room_id)
    end
end

