class Workload < ActiveRecord::Base
  belongs_to :user
  belongs_to :music

  def icon
    user.icon
  end

  def key
    return nil unless music
    music.key_old
  end
end

