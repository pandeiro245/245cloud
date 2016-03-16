module ApplicationHelper
  def facebook_image_tag user, size=40
    if params[:offline]
      url = base64 user.icon
    else
      url = "https://graph.facebook.com/#{user.facebook_id}/picture?height=#{size}&width=#{size}"
    end
    image_tag url, {width: size}
  end

  def base64 val
    "data:image/png;base64,#{val}"
  end
end
