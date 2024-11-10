# Usage example:
#   GET /api/gyazo/proxy?id=c9daa287c4865d4754e79540d52d7150
# class Api::GyazoController < ApplicationController
#   def proxy
#     # params
#     id = params[:id]
#
#     # load gyazo html
#     url = "https://gyazo.com/#{id}"
#     html = open(url).read
#
#     # Get raw image url
#     doc = Nokogiri::HTML(html)
#     rawurl = doc.at('link[rel="image_src"]')['href']
#
#     # Render raw image data
#     data = open(rawurl)
#     send_file data, type: data.content_type, disposition: 'inline'
#   end
# end
