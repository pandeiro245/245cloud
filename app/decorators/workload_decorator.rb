class WorkloadDecorator < Draper::Decorator
  delegate_all

  def created_at
    workload.created_at.to_i * 1000 # micro sec for JS
  end
end
