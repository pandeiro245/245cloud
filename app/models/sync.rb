class Sync
  def fb2user
    [Workload, Comment, AccessLog].each do |model|
      model.where.not(facebook_id: nil).each do |item|
        next if model == Comment && item.facebook_id.to_i == 1
        begin
          user = User.find_or_initialize_by(facebook_id: item.facebook_id)
          if user.id.blank?
            user.email = 'temp@245cloud.com'
            user.save!
            user.email = "#{user.id}@245cloud.com"
            user.save!
          end
          item.user_id = user.id
          item.save!
        rescue => e
          binding.pry
        end
      end
    end
  end
end
