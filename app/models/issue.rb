class Issue < ActiveRecord::Base
  belongs_to :user
  has_many :issue_workloads
  has_many :workloads, through: :issue_workloads

  scope :actives, -> (user)  {
    where(user: user).where.not(estimated: nil).where("deadline > ?", Time.now).order('deadline IS NULL').order(:deadline)
  }
end
