class HomeController < ApplicationController
  def index
    if current_user.present? && current_user.status == 'chatting'
      current_user.chatting.to_done!
    end
  end

  def redirect
    if is_valid_url?(params[:url])
      redirect_to params[:url]
    else
      redirect_to root_path
    end
  end 

  private

  def is_valid_url?(url)
    # 正規表現を使用して、httpまたはhttpsプロトコルで始まるかどうかを確認します
    !!(url =~ /\A(http|https):\/\//)
  end
end

