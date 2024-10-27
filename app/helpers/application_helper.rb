module ApplicationHelper
  def profile_image_tag user_id, size=40
    image_tag "/images/profile/#{user_id}.jpg", width: size
  end

  def top_path_with_music(music)
    array = music.key.split(':')
    root_path(music_provider: array.first, music_key: array.last)
  end

  def root_path_with_params(additional_params)
    uri = URI.parse(request.url)
    current_params = Rack::Utils.parse_nested_query(uri.query)
    merged_params = current_params.merge(additional_params)
    uri.query = merged_params.to_query
    uri.to_s
  end
end
