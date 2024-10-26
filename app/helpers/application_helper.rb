module ApplicationHelper
  def profile_image_tag user, size=40
    image_tag "/images/profile/#{user.id}.jpg"
  end

  def top_path_with_music(music)
    array = music.key.split(':')
    root_path(music_provider: array.first, music_key: array.last)
  end
end
