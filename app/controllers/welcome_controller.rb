class WelcomeController < ApplicationController
  def index
    #raise cookies['timecrowd'].inspect
    @musics_users = MusicsUser.limit(3).order('total desc')
    render layout: 'top'
  end

  def pitch
    render layout: 'top'
  end
end

