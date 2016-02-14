class Workload < ParseResource::Base
  fields :facebook_id

  def self.sync
    data = {}
    ParsecomUser.all.each do |u|
      user_id = u['objectId']
      if u['authData'] and u['authData']['facebook']
        facebook_id = u['authData']['facebook']['id']
      else
        facebook_id = u['facebook_id_str']
      end
      data[user_id] = facebook_id
    end
    Workload.limit(99999).each do |w|
      begin
        user_id = w.attributes['user']['objectId']
        w.facebook_id = data[user_id]
      rescue
        w.facebook_id = 10152403406713381
      end
      w.facebook_id ||= 10152403406713381
      w.save
    end
  end
end
