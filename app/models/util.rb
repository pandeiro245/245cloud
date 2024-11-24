class Util
  def self.sync
    url = 'https://245cloud.com/api/workloads.json?limit=1000&type=dones'
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

  def export
    models.each do |model|
      File.write("tmp/#{model}.json", model.all.to_json)
    end
  end

  def import
    models.each do |model|
      JSON.parse(File.open("tmp/#{model}.json").read).each do |data|
        item = model.find_or_initialize_by(id: data['id'])
        data.each do |key, val|
          next if key == 'id'
          item.send("#{key}=", val)
        end
        item.save(validate: false)
      end
    end
  end

  def models
    [User, Comment, Workload, AccessLog]
  end
end

