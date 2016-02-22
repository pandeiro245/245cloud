class RuffnotesController < ApplicationController
  def index
    if page = params[:page]
      id = page.split('/').last
      json = File.open("tmp/ruffnote/pages/#{id}.json", 'r')
      render json: json
    else
      if id = params[:attachment_id]
        attachment = File.open("tmp/ruffnote/attachments/#{id}", 'r')
      elsif id = params[:facebook_id]
        attachment = File.open("tmp/facebook/icons/#{id}", 'r')
      elsif id = params[:music_key]
        attachment = File.open("tmp/musics/icons/#{id}", 'r')
      end
      send_data attachment.read
    end
  end
end
