class IssueWorkload < ActiveRecord::Base
  belongs_to :issue
  belongs_to :workload
end
