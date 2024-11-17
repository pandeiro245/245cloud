task batch_minutely: :environment do
  Sync.new.workloads
end
