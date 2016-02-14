class CommentsController < ApplicationController
  def index
    @room = Comment.find_by(parent_id: nil)
    @comments = Comment.where(parent_id: @room.id).limit(48).order('created_at desc')

    render json: @comments.map{|c|
      hash = JSON.parse(c.to_json)
      hash['created_at'] = c.created_at.to_i * 1000 # JSはマイクロ秒
      hash
    }
  end
end
