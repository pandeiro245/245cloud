class AccessLog < ActiveRecord::Base
  def self.add url, user = nil
    user_id = user ? user.id : nil
    self.create!(
      url: url,
      user_id: user_id
    )
  end
end
