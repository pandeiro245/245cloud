class Pref < ActiveRecord::Base
  has_many :cities
  has_many :postals
  store :info, accessors: [:population2005, :population2010, :size]

  def cities_desc_pop
    cities.sort{|a, b| b.pop <=> a.pop} 
  end

  def self.init
    JpPrefecture::Prefecture.all.each do |p|
      Pref.find_or_create_by(
        name: p.name
      )
    end
  end

  def pop(type=2010)
    if type.to_i == 2005
      (population2005.to_i/10000).to_i
    else
      (population2010.to_i/10000).to_i
    end
  end
end

