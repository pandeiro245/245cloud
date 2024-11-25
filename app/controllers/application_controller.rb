class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :create_access_log
  rescue_from StandardError, with: :handle_error

  private

  def create_access_log
    AccessLog.create!(
      user_id: current_user&.id,
      url: request.url,
      params: params.to_unsafe_h.except('password', 'token', 'auth_token'),
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      session_id: session.id,
      request_method: request.method
    )
  end

  # その他のメソッドは変更なし
  def handle_error(exception)
    ErrorLog.create!(
      error_class: exception.class.name,
      error_message: exception.message,
      backtrace: exception.backtrace&.join("\n"),
      user_id: current_user&.id,
      url: request.url,
      params: sanitize_params(params),
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      session_id: session.id,
      request_method: request.method
    )
    raise exception
  end

  def sanitize_params(params)
    params.to_unsafe_h.except('password', 'token', 'auth_token')
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
