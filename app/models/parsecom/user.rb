class Parsecom::User < ParseResource::Base
  fields :facebook_id_str

  def self.sync_facebook_id_str
    self.where(facebook_id_str: nil).each do |c|
      c.sync_facebook_id_str
    end
    self.sync_facebook_id_str
  end

  def sync_facebook_id_str
    self.facebook_id_str = self.attributes['authData']['facebook']['id']
    self.save
  end

  def facebook_id
    self.attributes['facebook_id_str']
  end
end
