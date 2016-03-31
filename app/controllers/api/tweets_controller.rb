class Api::TweetsController < ApplicationController
  def yaruki
    begin
      #@tweets = Tweet.home(cookies['twitter'])
      @tweets = Tweet.yaruki(cookies['twitter']).slice(0, 3)
    rescue
      @tweets = {status: 'ng'}
    end
    render json: @tweets
  end
end
