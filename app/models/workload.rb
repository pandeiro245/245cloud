class Workload < ActiveRecord::Base
  POMOTIME = 24.minutes
  CHATTIME = 5.minutes

  scope :created, -> {
    order('workloads.created_at DESC')
  }
  scope :dones, -> {
    where(is_done: true)
  }
  scope :his_dones, -> (facebook_id) {
    dones.where(
      facebook_id: facebook_id
    )
  }
  scope :bests, ->  { select(
    '*, count(music_key) as music_key_count'
  ).where.not(music_key: ''
  ).group(:music_key).order(
      'music_key_count DESC'
    )
  }
  scope :today, -> (created_at = nil) {
    to = created_at || Time.now
    to -= POMOTIME
    from = to.to_date.beginning_of_day
    where(
      created_at: from..to
    )
  }
  scope :chattings, -> {
    from = Time.now - POMOTIME - CHATTIME
    to   = Time.now - POMOTIME
    by_range(from..to)
  }
  scope :playings, -> {
    from = Time.now - POMOTIME
    to   = Time.now
    by_range(from..to)
  }
  scope :by_range, -> range {
    where(
      created_at: range
    )
  }
  scope :of_type, -> type {
    raise if type && !active_type?(type)
    type ? public_send(type) : dones
  }

  def self.active_type? type
    %w(dones chattings playings all).include?(type)
  end

  def update_number!
    self.number = next_number
    self.save!
  end

  def self.update_numbers
    self.dones.each do |w|
      w.update_number!
    end
  end

  def next_number
    Workload.his_dones(self).today(created_at).count + 1
  end
end

