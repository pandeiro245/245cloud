class RuffnotesController < ApplicationController
  def index
    if page = params[:page]
      id = page.split('/').last
      json = File.open("tmp/ruffnote/pages/#{id}.json", 'r')
      render json: json
    else
      if id = params[:attachment_id]
        key = "ruffnote/attachments/#{id}"
        url = "https://ruffnote.com/attachments/#{id}"
      elsif id = params[:facebook_id]
        key = "facebook/icons/#{id}"
        url = "https://graph.facebook.com/#{id}/picture?height=40&width=40"
      elsif id = params[:music_key]
        key = "musics/icons/#{id}"
        url = Workload.find_by(music_key: id).artwork_url
      end
      send_data find_or_create(key, url)
    end
  end

  def find_or_create(key, url=nil)
    if url && !(Util.exist?(key) && Util.size(key) > 10)
      `wget -O tmp/#{key} #{url}`
    end
    Util.get(key)
  end
end
