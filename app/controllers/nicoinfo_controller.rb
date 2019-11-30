require 'net/http'
class NicoinfoController < ApplicationController
  def show
    @id = params[:id]

    url = URI.parse('http://ext.nicovideo.jp/api/getthumbinfo/' + @id)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    render :text => res.body
  end
end
