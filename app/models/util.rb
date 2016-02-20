class Util
  def self.sync
    url = 'http://245cloud.com/api/dones.json?limit=1000'
    uri = URI.parse(url)
    json = Net::HTTP.get(uri)
    JSON.parse(json).each do |w|
      created_at = Time.at(w['created_at']/1000)
      workload = Workload.find_or_create_by(
        created_at: created_at,
        facebook_id: w['facebook_id']
      )
      %w(is_done music_key title artwork_url number).each do |key|
        workload.send("#{key}=", w[key])
      end
      workload.save!
    end
    puts 'done'
  end
end

