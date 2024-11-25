class ErrorLog < ActiveRecord::Base
  belongs_to :user, optional: true

  validates :error_class, presence: true
  validates :error_message, presence: true

  def self.recent_errors(limit = 100)
    order(created_at: :desc).limit(limit)
  end
end
