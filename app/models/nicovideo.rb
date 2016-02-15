class Nicovideo
  def self.search title
    nico = NicoSearchSnapshot.new('245cloud')
    nico.search(title)
  end
end

