class AccessLog < ActiveRecord::Base
  def self.add url, user = nil
    facebook_id = user ? user.facebook_id : nil
    self.create!(
      url: url,
      facebook_id: facebook_id
    )
  end
end
