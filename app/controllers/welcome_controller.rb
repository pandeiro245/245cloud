class WelcomeController < ApplicationController
  def index
    @musics_users = MusicsUser.limit(3).order('total desc')
  end
end

