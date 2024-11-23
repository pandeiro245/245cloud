class Api::CommentsController < ApplicationController
  def download
    if params[:page].present?
      page = params[:page].to_i
      from = (page - 1) * 1000 + 1 
      to   = from + 999 
      range = from.upto(to).to_a
      comments = Comment.where(id: range)
    else
      comments = Comment.all.order('id desc').limit(1000)
    end 
    render json: comments.to_json
  end 

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
    parent_id = params[:room_id] || 1
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
    # render json: comment
    redirect_to params[:redirect_url]
  end
end
