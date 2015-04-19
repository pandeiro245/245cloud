class WelcomeController < ApplicationController
  def index
    @musics_users = MusicsUser.limit(200).order('total desc')
    render layout: 'top'
  end
end

