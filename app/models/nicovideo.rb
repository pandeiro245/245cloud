class Nicovideo
  # https://api.search.nicovideo.jp/api/snapshot/

  def self.search title
    limit = 20
    JSON.parse(`curl -A '245cloud' 'http://api.search.nicovideo.jp/api/v2/snapshot/video/contents/search?targets=title&fields=contentId,title,viewCounter&_sort=-viewCounter&_offset=0&_limit=#{limit}&_context=245cloud' --data-urlencode "q=#{title}" --data-urlencode "filters[viewCounter][gte]=10000"`)['data']
  end
end

