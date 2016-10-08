class Api::TweetsController < ApplicationController
  def notifications
    @tweets = Tweet.notifications(cookies['twitter'])
    render json: @tweets
  end

  def home
    @tweets = Tweet.home(cookies['twitter'])
    render json: @tweets
  end

  def yaruki
    begin
      @tweets = Tweet.yaruki(cookies['twitter'])
      @tweets = [@tweets[(@tweets.length * rand).to_i]]
    rescue
      @tweets = {status: 'ng'}
    end
    render json: @tweets
  end
end
