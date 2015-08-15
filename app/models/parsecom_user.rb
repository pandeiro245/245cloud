class ParsecomUser < ParseUser
  fields :name, :facebook_id_str, :user_id

  def self.hoge
    User.delete_all
    ActiveRecord::Base.connection.execute('ALTER TABLE users AUTO_INCREMENT = 0')
  end

  def self.sync refresh = false
    if refresh
      parse_users = self.order('createdAt asc')
    else
      parse_users = self.where(user_id: nil).order('createdAt asc')
    end
    parse_users.each do |parse_user|
      u = parse_user.attributes

      facebook_id = u['authData']['facebook']['id']
      email = "#{facebook_id}@245cloud.com"
      user = User.find_or_create_by(
        email: email 
      )
      user.name = u['name']
      user.parsecomhash = u['objectId']
      user.save!

      parse_user.user_id = user.id
      parse_user.save

      auth = Auth.find_or_initialize_by(
        provider: 'facebook',
        uid: facebook_id
      )
      auth.user_id = user.id
      auth.save!
    end
    return 'done'
  end
end

