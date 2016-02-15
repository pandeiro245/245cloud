class Workload < ActiveRecord::Base
  def self.sync
    url = 'http://245cloud.com/api/dones.json'
    uri = URI.parse(url)
    json = Net::HTTP.get(uri)
    JSON.parse(json).each do |w|
      created_at = Time.at(w['created_at']/1000)
      workload = Workload.find_or_create_by(
        created_at: created_at,
        facebook_id: w['facebook_id']
      )
      %w(is_done key title artwork_url).each do |key|
        workload.send("#{key}=", w[key])
      end
      workload.save!
    end
  end

  def self.pomotime
    24.minutes
  end

  def self.chattime
    5.minutes
  end

  def self.yours user, limit=48
    Workload.where(
      is_done: true,
      facebook_id: user.facebook_id
    ).limit(limit).order('created_at desc')
  end

  def self.playings
    limit = 200
    from = Time.now - self.pomotime
    to   = Time.now
    Workload.where(
      created_at: from..to,
    ).limit(limit).order('created_at desc')
  end

  def self.chattings
    limit = 200
    from = Time.now - self.pomotime - self.chattime
    to   = Time.now-self.pomotime
    Workload.where(
      is_done: true,
      created_at: from..to,
    ).limit(limit).order('created_at desc')
  end


  def self.dones limit=48
    Workload.where(is_done: true).limit(limit).order('created_at desc')
  end

  def next_number
    to = created_at || Time.now
    to -= Workload.pomotime
    from = to.to_date.beginning_of_day
    Workload.where(
      facebook_id: facebook_id,
      created_at: from..to,
      is_done: true
    ).count + 1
  end

  def update_number!
    self.number = next_number
    self.save!
  end

  def self.update_numbers
    self.where(is_done: true).order('created_at desc').each do |w|
      w.update_number!
    end
  end
end
