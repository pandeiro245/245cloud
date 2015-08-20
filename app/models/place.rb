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
      ],
      [4,
        'Planet3rd 心斎橋店（プラネットサード）',
        'http://tabelog.com/osaka/A2701/A270201/27013879/', nil, nil,
        27,
        1227
      ],
      [5,
        '住之江公園',
        'http://www.osaka-park.or.jp/rinkai/suminoe/main.html', nil, nil,
        27,
        1224
      ]
      [6,
        'フレイムス 中目黒店（FRAMES）',
        'http://tabelog.com/tokyo/A1317/A131701/13025901/', nil, nil,
        0,
        0
      ]
    ].each do |param|
      place = Place.find_or_create_by(
        id: param[0]
      )
      place.name = param[1]
      place.add_url param[2]
      place.wimax = param[3]
      place.elec  = param[4]

      place.pref_id = param[5]
      place.city_id  = param[6]

      place.save!
    end
  end
end
