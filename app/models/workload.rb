class Workload < ActiveRecord::Base
  POMOTIME = 24.minutes
  CHATTIME = 5.minutes

  before_save :set_music_key

  has_one :issue, through: :issue_workload
  has_one :issue_workload

  scope :created, -> {
    order('workloads.created_at DESC')
  }
  scope :dones, -> {
    where(is_done: true)
  }
  scope :his, -> (facebook_id) {
    where(
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
  scope :best_listeners, -> (music_key) { select(
    '*, count(facebook_id) as facebook_id_count'
  ).where(music_key: music_key
  ).group(:facebook_id).order(
      'facebook_id_count DESC'
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
  scope :thisweek, -> (created_at = nil) {
    to = created_at || Time.now
    to -= POMOTIME
    from = to.to_date.beginning_of_day
    from = if created_at.wday == 0 # sunday
      from - 6.day
    else
      from - (created_at.wday - 1).day
    end
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

  def self.create_with_issue! user, params
    ActiveRecord::Base.transaction do
      workload = Workload.create!(
        facebook_id: user.facebook_id,
        music_key: params['music_key'].presence,
        title: params['title'].presence,
        artwork_url: params['artwork_url'].presence
      )
      if params['issue_id']
        issue = Issue.find(params['issue_id'])
        raise unless issue.user.id == user.id
        IssueWorkload.create!(
          issue: issue,
          workload: workload
        )
      end
      workload
    end
  end

  def set_music_key
    return nil if self.music_key.nil?
    self.music_key = URI.decode(self.music_key)
  end

  def to_done!
    #if workload.created_at + Workload.pomotime <= Time.now
    if true
      self.number = next_number
      self.weekly_number = next_number(:weekly)
      self.is_done = true
      self.save!
    end
    if self.issue.present?
      self.issue.worked = self.issue.workloads.dones.count
      self.issue.save!
    end
    self
  end

  def self.active_type? type
    %w(dones chattings playings all).include?(type)
  end

  def update_number!
    self.number = next_number
    self.weekly_number = next_number(:weekly)
    self.save!
  end

  def self.update_numbers
    self.created.dones.each do |w|
      w.update_number!
    end
  end

  def next_number type=nil
    scope = Workload.his(facebook_id).dones
    scope = case type
    when :weekly
      scope.thisweek(created_at)
    else
      scope.today(created_at)
    end
    scope.count + 1
  end

  def music_path
    key = music_key.gsub(/:/, '/')
    "/musics/#{key}"
  end

  def repair!
    return unless music_key
    if music_key.match(/^mixcloud:/)
      puts music_key
      self.music_key = URI.decode(self.music_key)
      self.save!
    end
  end
end

