class Cafe < ActiveRecord::Base
  belongs_to :pref
  belongs_to :city
  store :info, accessors: [:urls]

  def add_url url
    if urls
      urls2 = JSON.parse(urls)
      urls2.each do |url2| 
        return if url == url2
      end
    else
      urls2 = []
    end
    urls2 += [url]
    self.urls = urls2.to_json
    self.save!
  end
end
