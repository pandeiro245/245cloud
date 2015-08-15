class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :commons

  def commons
    if params[:refresh]
      ['dones', 'playings', 'chattings'].each do |key|
        Rails.cache.delete(key)
      end
    end
    @dones = Rails.cache.fetch('dones') do
      Workload.dones
    end
    @playings = Rails.cache.fetch('playings') do
      Workload.playings
    end
    @chattings = Rails.cache.fetch('chattings') do
      Workload.chattings
    end
    @yous = current_user ? current_user.workloads : []
  end

  def current_user
    User.find_by(id: session[:user_id])
  end
end
