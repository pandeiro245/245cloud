class Api::CommentsController < ApplicationController
  def index
    parent_id = params[:room_id] || nil
    @comments = Comment.where(parent_id: params[:parent_id]).limit(48).order('created_at desc')

    render json: @comments.map{|c|
      hash = JSON.parse(c.to_json)
      hash['created_at'] = c.created_at.to_i * 1000 # JSはマイクロ秒
      hash
    }.reverse!
  end

  def create
    parent_id = params[:room_id] || nil
    comment = Comment.create!(
      user_id: current_user.id,
      parent_id: parent_id,
      body: params[:body]
    )
    if parent_id.present?
      parent = comment.parent
      parent.num = parent.children.count
      parent.save!(validate: false)
    end
    render json: comment
  end
end
