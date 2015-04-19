class Workload < ActiveRecord::Base
  belongs_to :user
  belongs_to :music

  def icon
    user.icon
  end
end

