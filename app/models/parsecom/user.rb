class Parsecom::User < ParseResource::Base
  fields :facebook_id_str

  def facebook_id
    self.attributes['facebook_id_str']
  end
end
