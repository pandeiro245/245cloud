class Workload < ActiveRecord::Base
  def self.sync(skip=0)
    ParsecomWorkload.sync(skip)
  end

  def self.dones limit=48
    Workload.where(is_done: true).limit(limit).order('created_at desc')
  end
end
