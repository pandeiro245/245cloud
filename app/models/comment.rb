class Comment < ActiveRecord::Base

  belongs_to :user
  def room
    Room.find(self.room_id)
  end

  def icon_url
    'https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/c32.32.401.401/s50x50/148782_450079083380_6432972_n.jpg?oh=bdbe1653f8db778471c43c872fcc97d5&oe=55514D90&__gda__=1430901205_655202eb092cf8b4ffff266a03b5e658'
  end
end
