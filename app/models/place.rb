class Place < ActiveRecord::Base
  belongs_to :pref
  belongs_to :city
  store :info, accessors: [:urls, :wimax, :elec], coder: JSON

  def add_url url
    if urls
      self.urls.each do |url2| 
        return if url == url2
      end
    else
      self.urls = [] 
    end
    self.urls += [url]
    self.save!
  end

  def self.store_names
    Place.first.info.keys
  end

  def self.init
    Place.delete_all
    [
      [1, 
        'COUTUME ディアモール大阪店（クチューム）', 
        'http://tabelog.com/osaka/A2701/A270101/27082299/', nil, 1,
        27,
        1226
      ],
      [2, 
        'ラウンドポイントカフェ （ROUND POINT CAFE）', 
        'http://tabelog.com/hyogo/A2801/A280102/28040387/dtlmenu/', 3, 3,
        28,
        1283
      ],
      [3,
        'ネットカフェ・漫画喫茶のメディアカフェポパイ 三ノ宮店',
        'http://www.media-cafe.ne.jp/tenpo/sannomiya/service.htm', nil, nil,
        28,
        1283
      ]
    ].each do |param|
    place = Place.create!(
      id: param[0],
      name: param[1]
      )
      place.add_url param[2]
      place.wimax = param[3]
      place.elec  = param[4]
      place.save!
    end
  end
end
