class Api::TweetsController < ApplicationController
  def yaruki
    begin
      #@tweets = Tweet.home(cookies['twitter'])
      @tweets = Tweet.yaruki(cookies['twitter'])
      @tweets = [@tweets[(@tweets.length * rand).to_i]]
    rescue
      @tweets = {status: 'ng'}
    end
    render json: @tweets
  end
end
