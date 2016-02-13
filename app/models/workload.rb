class Workload < ActiveRecord::Base
  def self.sync(skip=0)
    ParsecomWorkload.sync(skip)
  end
end
