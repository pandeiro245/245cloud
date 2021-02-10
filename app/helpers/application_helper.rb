module ApplicationHelper
  def facebook_image_tag user, size=40
    # image_tag "/images/profile/#{user.facebook_id}.jpg"
    image_tag "https://graph.facebook.com/#{user.facebook_id}/picture?height=#{size}&width=#{size}"
  end
end
