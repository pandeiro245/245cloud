class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :create_access_log

  private

  def create_access_log
    current_user ? current_user.id : nil
    AccessLog.create!(
      user_id: current_user&.id,
      url: request.url
    )
  end

  def store_music_session(provider, key)
    session[:music_provider] = provider
    session[:music_key] = key
  end

  def clear_music_session
    session.delete(:music_provider)
    session.delete(:music_key)
  end

  def load_music_from_session
    return if session[:music_provider].blank?

    @music = Music.new_from_key(session[:music_provider], session[:music_key])
  end
end
