class Parsecom::Comment < ParseResource::Base
  fields :user, :icon_url

  def self.sync_icon_url
    Parsecom::Comment.where(icon_url: nil).each do |c|
      c.sync_icon_url
    end
    self.sync_icon_url
  end

  def sync_icon_url
    self.icon_url = user ? "https://graph.facebook.com/#{user.facebook_id}/picture?height=40&width=40" : 'https://ruffnote.com/attachments/24654'
    self.save
  end

  def user
    return nil unless self.attributes['user']
    Parsecom::User.find(self.attributes['user']['objectId'])
  end
end
