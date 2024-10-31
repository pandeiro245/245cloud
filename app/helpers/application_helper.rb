module ApplicationHelper
  def profile_image_tag user_id, size=40
    image_tag "/images/profile/#{user_id}.jpg", width: size
  end
end
