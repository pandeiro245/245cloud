class Util
  def self.migrate
    # User.all.each do |user|
    #   if user.discord_id.present?
    #     pu = user.provider_user('discord')
    #     pu.key = user.discord_id
    #     pu.save!
    #   end
    #   pu = user.provider_user('facebook')
    #   pu.key = user.facebook_id
    #   pu.save!
    # end
    Workload.all.each do |workload|
      workload.user_id = ProviderUser.find_by(
        provider_id: 1, # facebook
        key: workload.facebook_id
      ).user_id
      workload.save!
    end
  end

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
end

