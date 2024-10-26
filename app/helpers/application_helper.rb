module ApplicationHelper
  def profile_image_tag user, size=40
    image_tag "/images/profile/#{user.id}.jpg"
  end
end
