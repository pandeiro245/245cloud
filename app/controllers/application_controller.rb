class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

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
