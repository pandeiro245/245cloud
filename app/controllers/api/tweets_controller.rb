class Api::TweetsController < ApplicationController
  def notifications
    @tweets = Tweet.new(cookies['twitter']).notifications
    render json: @tweets
  end

  def home
    @tweets = Tweet.new(cookies['twitter']).home
    render json: @tweets
  end

  def yaruki
    begin
      @tweets = Tweet.new(cookies['twitter']).yaruki
      @tweets = [@tweets[(@tweets.length * rand).to_i]]
    rescue
      @tweets = {status: 'ng'}
    end
    render json: @tweets
  end
end
