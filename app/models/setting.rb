class Setting
  def self.get cookies, key

  end

  def self.set cookies, key
    cookies[:settings] ||= '{}'
    data = JSON.parse(cookies[:settings])
    data[key] = 1
    data.to_json
  end
end
