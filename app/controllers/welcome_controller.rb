class WelcomeController < ApplicationController
  def index
    #raise cookies['timecrowd'].inspect
  end

  def pitch
    render layout: 'top'
  end
end

