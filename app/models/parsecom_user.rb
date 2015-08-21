class ParsecomUser < ParseUser
  fields :name, :facebook_id_str, :user_id

  def self.hoge!
    User.delete_all
    ActiveRecord::Base.connection.execute('ALTER TABLE users AUTO_INCREMENT = 1')

    #self.order('createdAt asc').limit(999999).each do |parse_user|
    #  if parse_user.attributes['user_id'] 
    #    parse_user.user_id = nil
    #    parse_user.save
    #  else
    #    return
    #  end
    #end


  end

  def self.sync refresh = false
    r = Redis.new
    if refresh
      parse_users = self.order('createdAt asc').limit(999999)
    else
      parse_users = self.where(user_id: nil).order('createdAt asc')
    end
    parse_users.each do |parse_user|
      u = parse_user.attributes

      facebook_id = u['facebook_id_str']
      email = "#{facebook_id}@245cloud.com"
      user = User.find_or_create_by(
        parsecomhash: u['objectId']
      )
      user.name = u['name']
      user.email = email
      user.parsecomhash = u['objectId']
      user.save!
      
      r.set("user_icon_#{user.id.to_s}", user.icon)
      

      #parse_user.user_id = user.id
      #parse_user.save

     # auth = Auth.find_or_initialize_by(
     #   provider: 'facebook',
     #   uid: facebook_id
     # )
     # auth.user_id = user.id
     # auth.save!
    end
    return 'done'
  end
end

