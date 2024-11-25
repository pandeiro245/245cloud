class AccessLog < ActiveRecord::Base
  belongs_to :user, optional: true

  validates :url, presence: true

  def self.add(url, user = nil)
    create!(
      url: url,
      user_id: user&.id
    )
  end

  def self.recent_accesses(limit = 100)
    order(created_at: :desc).limit(limit)
  end
end
