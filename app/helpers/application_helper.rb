module ApplicationHelper
  def profile_image_tag user_id, size=40
    image_tag "/images/profile/#{user_id}.jpg", width: size
  end

  def top_path_with_music(music)
    params = {
      music_provider: music.provider,
      music_key: music.key,
    }
    root_path(params)
  end

  def root_path_with_params
    params = {}
    if session[:music_provider].present?
      params[:music_provider] = session[:music_provider]
      params[:music_key] = session[:music_key]
    end
    root_path(params)
  end
end
