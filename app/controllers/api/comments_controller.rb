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
    render json: Comment.create(
      facebook_id: current_user.facebook_id,
      parent_id: params[:room_id],
      body: params[:body]
    )
  end
end
