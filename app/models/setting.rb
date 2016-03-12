class Setting
  def self.data cookies
    cookies[:settings] ||= '{}'
    JSON.parse(cookies[:settings])
  end

  def self.get cookies, key
    self.data(cookies)[key]
  end

  def self.set cookies, key, val = 1
    data = self.data cookies
    data[key] = val
    data.to_json
  end

  def self.del cookies, key
    data = self.data cookies
    data.delete(key.to_s)
    data.to_json
  end
end
