class Issue < ActiveRecord::Base
  belongs_to :user
  has_many :issue_workloads
  has_many :workloads, through: :issue_workloads

  scope :actives, -> (user)  {
    where(user: user).where('estimated is not null')
  }
end
